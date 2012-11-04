
if exists("loaded_gfunctions")
  finish
endif
let loaded_gfunctions = 1

" Global variables/autocmds {{{1

" Global functions {{{1
" These are functions that are useful for custom scripts
" Note: remember that functions can be placed *inside* if statements

" FindVar(varname[, default]) {{{2
fun! FindVar(varname, ...)
  if exists('b:'.a:varname)
    return b:{a:varname}
  elseif exists('g:'.a:varname)
    return g:{a:varname}
  elseif a:0 == 1
    return a:1
  endif
  throw 'variable '.a:varname.' not found'
endf

" ExtendDictVar(varname[, default]) {{{2
fun! ExtendDictVar(dictname, ...)
  let result = {}
  if a:0 == 1
    call extend(result, a:1)
  endif
  if exists('g:'.a:dictname)
    call extend(result, g:{a:dictname})
  endif
  if exists('b:'.a:dictname)
    call extend(result, b:{a:dictname})
  endif
  return result
endf

" FindInDict(key, dictname[, default]) {{{2
fun! FindInDict(key, dictname, ...)
  if exists('b:'.a:dictname) && has_key(b:{a:dictname}, a:key)
    return b:{a:dictname}[a:key]
  elseif exists('g:'.a:dictname) && has_key(g:{a:dictname}, a:key)
    return g:{a:dictname}[a:key]
  elseif a:0 == 1
    return a:1
  endif
  throw 'cant find '.a:key
endf

" GetVisualLine() {{{2
function! GetVisualLine()
  let col1 = getpos("'<")[2]
  let col2 = getpos("'>")[2]
  return getline('.')[col1-1:col2-1]
endfunction

" BufDelete([bang]) {{{2
" Simplified/personalized version of the BufKill plugin...
fun! BufDelete(...)
  let bang = a:0 ? a:1 : ''
  let curwindow = winnr()
  let bufferToKill = winbufnr(curwindow)

  if &modified && strlen(bang) == 0
    throw 'Error: buffer is modified'
  endif

  if &bt == 'quickfix' || &bt=='help'
    exe 'q'.bang
    return
  endif

  bprev
  if winbufnr(curwindow) == bufferToKill
    enew
    if winbufnr(curwindow) == bufferToKill
      return
    endif
  endif

  " Point windows containing this buffer to other buffers
  let i = 1
  let buf = winbufnr(i)
  while buf != -1
    if buf == bufferToKill
      exec 'normal! ' . i . 'w'
      bprev
    endif
    let i = i + 1
    let buf = winbufnr(i)
  endwhile

  exec 'normal! ' . curwindow . 'w'
  sil! exe 'sil! bd'.bang.' '.bufferToKill
endf
command! -nargs=0 -bang BD call BufDelete('<bang>')

" GetAllBuffers() {{{2
fun! GetAllBuffers()
  let all = range(1, bufnr('$'))
  let res = []
  for b in all
    if buflisted(b)
      call add(res, bufname(b))
    endif
  endfor
  return res
endfunction

" GetNextProjectBuffer(count) {{{2
" Creates a list of all open buffers sharing a projectroot with
" this buffer, and goes to the next buffer on that list.

fun! GetNextProjectBuffer(count)
  let thisfile = expand('%:p')
  let root = ProjectRootGuess(thisfile)
  let bufs = []
  let mybuf = -1
  for b in GetAllBuffers()
    let file = bufname(b)
    let file = fnamemodify(b, ':p')
    if stridx(file, root)==0
      if file==thisfile
        let mybuf = len(bufs)
      endif
      call add(bufs, file)
    endif
  endfor
  if mybuf==-1
    throw 'error, could not find '.thisfile.' amongst buffers'
  endif
  let target = ((mybuf+a:count) % len(bufs) + len(bufs)) % len(bufs)
  return bufs[target]
endf

" GetNextBuffer(count) {{{2
fun! GetNextBuffer(count)
  let nowinbufs = []
  let thisfile = expand('%:p')
  for b in GetAllBuffers()
    if bufwinnr(b) == -1 || b==thisfile
      call add(nowinbufs, b)
    endif
  endfor
  return s:getbuffer(nowinbufs, a:count)
endf

fun! s:getbuffer(l, count)
  let thisfile = expand('%:p')
  let i = index(a:l, thisfile)
  let s = len(a:l)
  let target = (((i+a:count) % s)+s) % s
  return get(a:l, target, thisfile)
endf

" GetNextFileInDir(count) {{{2
fun! GetNextFileInDir(count)
  let files = []
  for file in split(glob(expand('%:p:h').'/*'), "\n")
    if !isdirectory(file)
      call add(files, file)
    endif
  endfor
  call sort(files)
  let i = index(files, expand('%:p'))
  let s = len(files)
  return files[(((i+a:count) % s)+s) % s]
endf

" OpenURL(url) {{{2
function! OpenURL(url) " (tpope)
  if has("win32")
    exe '!start cmd /cstart /b '.a:url
  elseif $DISPLAY !~ '^\w'
    exe 'silent !sensible-browser "'.a:url.'"'
  else
    exe 'silent !sensible-browser -T "'.a:url.'"'
  endif
  redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)

" CompileAndRun() {{{2
let cnr_scriptlangs={}
let cnr_browserlangs=['xhtml', 'html', 'xml', 'css']

for lang in ['python', 'php', 'perl', 'sh']
  if executable(lang)
    let cnr_scriptlangs[lang] = lang
  endif
endfor
if executable('ipython')
  cnr_scriptlangs['python'] = 'ipython'
endif

fun! CompileAndRun()
  try
    " Try to do project wide compilations/runs
    let s:projectRoot = ProjectRootGuess("%")
    if &ft=='java' || expand('%:t')=='build.xml'
      if(filereadable(s:projectRoot.'/build.xml'))
        wa
        exe 'setl makeprg=ant\ -f\ '.s:projectRoot.'/build.xml run'
        setl efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
        make
        return
      endif
    endif

    " Fall back to single file compilations/runs
    if &modified
      write
    endif
    let shebang = matchstr(getline(1),'^#!\zs[^ ]*')
    if shebang == '/usr/bin/env'
      exe '!'.strpart(getline(1), 15).' %'
    elseif executable(shebang)
      exe '!'.matchstr(getline(1),'^#!\zs.*').' %'
    elseif has_key(g:cnr_scriptlangs, &ft)
      exe '!'.g:cnr_scriptlangs[&ft].' %'
    elseif index(g:cnr_browserlangs, &ft)>=0
      if exists('b:url')
        call OpenURL(b:url)
      else
        call OpenURL(expand('%:p'))
      endif
    elseif &ft=='vim'
      unlet! g:loaded_{expand('%:t:r')}
      so %
    elseif &ft=='markdown' && executable('markdown')
      exe '!markdown %'
      call OpenUrl(expand('%:p'))
    elseif &ft=='java' && executable('java') && executable('javac')
      let package = search('\s*package\s', 'nw')
      let qualified = expand('%:t:r')
      if package!=0
        let package = matchstr(getline(package), '\v^\s*package\s+\zs[^;]+')
        let classdir = expand('%:p:h:h'.substitute(substitute(package, '[^.]', '', 'g'), '\.', ':h', 'g'))
        let qualified = package.'.'.qualified
      else
        let classdir = expand('%:p:h')
      endif
      let &cmdheight += 1
      let cmd = '!javac -d "'.classdir.'" "'.expand('%').'" &&'
      exe cmd.' java -cp "'.classdir.'" '.qualified
      let &cmdheight -= 1
    else " If all else fails, use default handler
      exe '!%'
    endif
  finally
    redraw!
  endtry
endf
