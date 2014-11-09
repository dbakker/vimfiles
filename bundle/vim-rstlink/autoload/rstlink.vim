" rstlink.vim by Daan O. Bakker
" Version: 0.1
" License: MIT

if exists('g:autoloaded_rstlink')
  finish
endif

let g:autoloaded_rstlink = 1

lua << END
RSTLink = {}

RSTLink.URL_REGEX = '%a+://[^%s\'"<>]+[^%s\'"<>%.,;:]'
RSTLink.EMAIL_REGEX = '[^%s@]+@[^%s@]+%.[^%s@]+'

function RSTLink._get_cursor_link()
  local title, target, url, startcol, endcol = nil

  local b = vim.buffer()
  local w = vim.window()
  local l = b[w.line]

  -- Move the current column away from any edges
  local col = w.col
  if l:sub(col, col) == '_' then
    col = col - 1
  end
  if l:sub(col, col) == '`' then
    if l:sub(col + 1, col + 1) == '_' then
      col = col - 1
    else
      col = col + 1
    end
  end

  local partial_line = l:sub(1, col)
  local link_begin = partial_line:find("`[^`]+$")

  if link_begin and l:sub(link_begin+1, link_begin+1) ~= '_' then
    startcol, endcol, title, url = l:find("`([^`<]+)%s<([^`>]+)>`_", link_begin)
    if startcol then
      -- Check for internal references
      if url:sub(#url - 1) == '\\_' then
        url = url:sub(1, #url - 1) .. '_'
      elseif url:sub(#url) == '_' then
        target = url:sub(1, #url - 1)
        url = nil
      end

      return title, target, url, startcol, endcol
    end

    startcol, endcol, title = l:find("`([^`]+)`_", link_begin)
    if startcol then
      target = title
      return title, target, url, startcol, endcol
    end
  end

  -- Assume the link does not start with a "`", find the beginning of the word
  -- under the cursor
  local link_begin = partial_line:find("[^%s\"'`{}]+$")
  if not link_begin then
    error("Could find not any link")
  end

  -- Match a reference like "Foo_"
  startcol, endcol, title = l:find("^([%w_]+)_", link_begin)
  if startcol then
    target = title
    return title, target, url, startcol, endcol
  end

  -- Match plain URLs and email addresses
  for i, regex in ipairs({RSTLink.URL_REGEX, RSTLink.EMAIL_REGEX}) do
    local startcol, endcol = l:find('^' .. regex, link_begin)
    if startcol then
      url = l:sub(startcol, endcol):gsub('\\_', '_')
      return title, target, url, startcol, endcol
    end
  end

  error("Could find not any link")
end

function RSTLink._set_cursor_link(title, target, url)
  local output = nil

  if not url then
    if target and not title then
      title = target
    end
  end

  -- neutralize special characters in the title
  if title then
    title = title:gsub('([`<>\\])', '\\%1')
  end

  if title then
    if url then
      -- Escape any final _ to avoid confusion with targets
      url = url:gsub('_$', '\\_')

      output = '`' .. title .. ' <' .. url .. '>`_'
    elseif target then
      if target == title then
        local escapedtitle = title
        if title:find('[%s_]') then
          escapedtitle = '`' .. title .. '`'
        end
        output = escapedtitle .. '_'
      else
        output = '`' .. title .. ' <' .. target .. '_>`_'
      end
    else
      -- A title without a target or url is just plain text
      output = title
    end
  elseif url then
    if target then
      error('Cannot combine target and url on links')
    else
      output = url
    end
  else
    error('Missing arguments to _set_cursor_link')
  end

  local _, _, _, startcol, endcol = RSTLink._get_cursor_link()
  local b, w = vim.buffer(), vim.window()

  b[w.line] = b[w.line]:sub(1, startcol-1) .. output .. b[w.line]:sub(endcol+1)

  -- Keep cursor on the link if the link shrunk
  w.col = math.min(startcol + #output - 1, w.col)
end

function RSTLink._find_def(target)
  local targetdefstart = '.. _' .. target:gsub(':', '\\:') .. ': '
  local b = vim.buffer()

  for i=#b, 1, -1 do
    local line = b[i]
    local startcol = line:find(targetdefstart, 1, true)
    if startcol == 1 then
      return i, line:sub(#targetdefstart):gsub('^%s+', ''):gsub('%s+$', '')
    end
  end

  return nil, nil
end

function RSTLink._find_url(target)
  for z=1, 5 do
    local i, url = RSTLink._find_def(target)
    if not url then
      return nil
    end

    local m = url:match('^`([^`]+)`_$')
    if not m then
      m = url:match('^(%S+)_$')
    end
    if not m then
      return i, url
    else
      target = m
    end
  end
  error('Could not find "' .. target ..'" (possible infinite reference loop)')
end

function RSTLink._find_use(target)
  local b, w = vim.buffer(), vim.window()

  local targetquoted = target
  local results = {}
  if target:find('%s') then
    targetquoted = '`' .. target .. '`'
  end
  targetquoted = targetquoted .. '_'

  for i=1, #b do
    local line = b[i]
    local startcol, endcol = line:find(targetquoted, 1, true)
    if startcol then
      table.insert(results, {i, startcol, endcol})
    end
  end

  return results
end

function RSTLink.get_cursor_url()
  local title, target, url = RSTLink._get_cursor_link()
  local _ = nil

  if not url then
    _, url = RSTLink._find_url(target)
  end

  return url
end

function RSTLink.use_reference()
  local b, w = vim.buffer(), vim.window()
  local title, target, url = RSTLink._get_cursor_link()

  if target then
    error('The link is already using reference "' ..target .. '"')
  end

  -- Check for any possible collisions
  local target_line, target_url = RSTLink._find_def(title)
  local create_new = true
  if target_line then
    if target_url ~= url then
      error('Target "' .. title .. '" already exists')
    else
      create_new = false
    end
  end

  target = title

  RSTLink._set_cursor_link(title, target, nil)

  if create_new then
    -- If this is the first link to be put at the bottom, add an extra empty
    -- line above it
    if b[#b]:sub(1, 4) ~= ".. _" and b[#b]:find('%S') then
      b:insert('')
    end

    b:insert('.. _' .. title:gsub(':', '\\:') .. ': ' .. url)
  end
end

function RSTLink.use_inline()
  local title, target, url = RSTLink._get_cursor_link()

  local target_line, _ = RSTLink._find_def(target)
  local _, target_url = RSTLink._find_url(target)
  if not target_url then
    error("Cannot find url for target '" .. title .. "'")
  end

  RSTLink._set_cursor_link(title, nil, target_url)

  local b = vim.buffer()
  local w = vim.window()
  if #(RSTLink._find_use(target)) == 0 then
    if target_line == #b and b[#b-1] == '' then
      b[#b] = nil
      b[#b] = nil
    else
      b[target_line] = nil
    end
  end
end

function RSTLink.toggle_reference()
  -- TODO: support executing this on a ".. _foo:" line

  local title, target, url = RSTLink._get_cursor_link()

  if url then
    RSTLink.use_reference()
  else
    RSTLink.use_inline()
  end
end

function RSTLink.set_web_title()
  local title, target, url = RSTLink._get_cursor_link()
  if not url then
    error('Could not find any URL')
  end

  title = vim.eval('rstlink#load_web_title("' .. url:gsub('\\', '\\\\') .. '")')

  if title then
    RSTLink._set_cursor_link(title, target, url)
  end
end
END

function! rstlink#load_web_title(url)
if has('python')
py << END
try:
  from HTMLParser import HTMLParser  # python 2
except:
  from html.parser import HTMLParser  # python 3

# Using the default Python UA makes many sites block you
DEFAULT_URLLIB_UA = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/36.0.1985.125 Chrome/36.0.1985.125 Safari/537.36'

class HTMLTitleParser(HTMLParser):
    def __init__(self, *args, **kwargs):
        HTMLParser.__init__(self, *args, **kwargs)
        self.tagstack = []
        self.title = None

    def handle_starttag(self, tag, attrs):
        self.tagstack.append(tag)

    def handle_endtag(self, tag):
        if self.tagstack[-1] == tag:
            self.tagstack.pop()

    def handle_data(self, data):
        data = data.strip()
        if self.tagstack and self.tagstack[-1].lower() in ['title', 'h1'] and data:
            if not self.title:
              self.title = data


def get_html(url):
      try:
        from urllib2 import urlopen, Request  # python 2
      except:
        from urllib.request import urlopen, Request  # python 3

      request = Request(url=url, headers={'User-Agent': DEFAULT_URLLIB_UA})
      return urlopen(request).read()

def get_title(url):
    parser = HTMLTitleParser()
    parser.feed(get_html(url))

    # Communicate with vimscript through a temporary variable
    # XXX: Not sure if there is a better way to do this
    import vim
    vim.current.buffer.vars['html_title'] = parser.title
END
  try
    exe 'python get_title(' . shellescape(a:url) . ')'
  catch
  endtry

  endif
  if exists('b:html_title')
    let title = b:html_title
    unlet b:html_title
    return title
  else
    throw 'Could not find title'
    return ''
  end
endfunction

function! rstlink#toggle_reference()
  lua RSTLink.toggle_reference()
endfunction

function! rstlink#set_web_title()
  lua RSTLink.set_web_title()
endfunction

function! rstlink#get_cursor_url()
  return luaeval('RSTLink.get_cursor_url()')
endfunction

function! rstlink#browse_link()
  let url = rstlink#get_cursor_url()
  let url = substitute(url, '%', '\\%', 'g')
  let url = substitute(url, '#', '\\#', 'g')
  if has("win32")
    exe '!start cmd /cstart /b '.url
  else
    let arg = ' "'.url.'" >/dev/null 2>/dev/null &'
    if executable('exo-open')
      exe 'silent! !exo-open' . arg
    elseif $DISPLAY !~ '^\w'
      exe 'silent! !sensible-browser' . arg
    else
      exe 'silent! !sensible-browser -T' . arg
    endif
  endif
  redraw!
endfunction
