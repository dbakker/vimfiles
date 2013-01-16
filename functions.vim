
if exists("loaded_functions")
  finish
endif
let loaded_functions = 1

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
fun! GetVisualLine()
  let col1 = getpos("'<")[2]
  let col2 = getpos("'>")[2]
  return getline('.')[col1-1:col2-1]
endf

" SwapRegisters(reg1, reg2) {{{2
fun! SwapRegisters(reg1, reg2)
  exe 'let tmp=@'.a:reg1
  exe 'let @'.a:reg1.'=@'.a:reg2
  exe 'let @'.a:reg2.'=tmp'
endf

" IsExtraBuffer(buffer) {{{2
fun! IsExtraBuffer(...)
  if a:0==1
    let bt=getbufvar(a:1, '&bt')
  else
    let bt=&bt
  endif
  return bt=='help' || bt=='quickfix' || bt=='nofile'
endf

" BufDelete([bang]) {{{2
" Simplified/personalized version of the BufKill plugin...
fun! BufDelete(...)
  let bang = a:0 ? a:1 : ''
  let curwindow = winnr()
  let bufferToKill = winbufnr(curwindow)

  if &modified && strlen(bang) == 0
    throw 'Error: buffer is modified'
  endif

  if IsExtraBuffer()
    exe 'sil! bd'.bang
    return
  endif

  exe 'b ' . (bufloaded(bufnr('#')) ? '#' : GetNextBuffer(-1))
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
      exe 'normal! ' . i . 'w'
      exe 'b '.GetNextBuffer(-1)
    endif
    let i = i + 1
    let buf = winbufnr(i)
  endwhile

  exe 'normal! ' . curwindow . 'w'
  sil! exe 'sil! bd'.bang.' '.bufferToKill
endf
command! -nargs=0 -bang BD call BufDelete('<bang>')

" GetListedBuffers() {{{2
fun! GetListedBuffers()
  let all = range(1, bufnr('$'))
  let res = []
  for b in all
    if buflisted(b)
      call add(res, b)
    endif
  endfor
  return res
endfunction

" GetNextProjectBuffer(count) {{{2
" Creates a list of all open buffers sharing a projectroot with
" this buffer, and goes to the next buffer on that list.

fun! GetNextProjectBuffer(count)
  let root = ProjectRootGuess()
  let bufs = []
  for b in GetListedBuffers()
    let bname = bufname(b)
    let bfile = fnamemodify(bname, ':p')
    if len(bname) && stridx(bfile, root)==0 && bufwinnr(b)==-1
      call add(bufs, b)
    endif
  endfor
  return s:GetRelativeBuffer(bufs, a:count)
endf

" GetNextBuffer(count) {{{2
fun! GetNextBuffer(count)
  let nowinbufs = []
  let thisbuf = bufnr('')
  for b in GetListedBuffers()
    if bufwinnr(b) == -1
      call add(nowinbufs, b)
    endif
  endfor
  return s:GetRelativeBuffer(nowinbufs, a:count)
endf

fun! s:GetRelativeBuffer(buflist, count)
  let l=[]
  for b in a:buflist
    call add(l, len(bufname(b))?bufname(b):b)
  endfor
  let thisbuf = len(bufname(''))?bufname(''):bufnr('')
  if index(l, thisbuf)==-1
    call add(l, thisbuf)
  endif
  call sort(l)

  let i = index(l, thisbuf)
  let s = len(l)
  let target = (((i+a:count) % s)+s) % s
  return bufnr(get(l, target, thisbuf))
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

" OpenPrompt() {{{2
fun! OpenPrompt()
  if has('win32')
    exe 'sil !start cmd'
    return
  else
    for p in ['rxvt', 'gnome-terminal', 'xterm', &shell]
      if executable(p)
        exe 'sil !'.p.' &'
      endif
      return
    endfor
  endif
  throw 'Could not find a way to open a prompt'
endf

" OpenURL(url) {{{2
function! OpenURL(url) " (tpope)
  let url = substitute(a:url, '%', '\\%', 'g')
  let url = substitute(url, '#', '\\#', 'g')
  if has("win32")
    exe '!start cmd /cstart /b '.url
  elseif $DISPLAY !~ '^\w'
    exe 'silent !sensible-browser "'.url.'"'
  else
    exe 'silent !sensible-browser -T "'.url.'"'
  endif
  " redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)

" SearchWeb(terms) {{{2
fun! SearchWeb(terms)
  let t = a:terms
  let t = substitute(t, '^\s\+', '', '')
  let t = substitute(t, '\s\+$', '', '')
  let t = substitute(t,'\W\+','+','g')
  call OpenURL('http://www.google.com/search?q='.t)
endf
fun! SearchWebMap(terms)
  " Same as SearchWeb, unless there is an URL under the cursor
  let line = getline(".")
  let url = matchstr(line, "http://[^ ,;\t\"']*")
  if len(url)>0
    return OpenURL(url)
  else
    return SearchWeb(a:terms)
  endif
endf

" GuessMainBuffer() {{{2
fun! GuessMainBuffer()
  if !IsExtraBuffer()
    return bufnr('')
  endif
  let buf=bufnr('')
  let size=-1
  for b in tabpagebuflist()
    if !IsExtraBuffer(b)
      let s=winheight(bufwinnr(b)) * winwidth(bufwinnr(b))
      if s>size
        let size=s
        let buf=b
      endif
    endif
  endfor
  return buf
endf

" GuessMainWindow() {{{2
fun! GuessMainWindow()
  return bufwinnr(GuessMainBuffer())
endf

" GuessMainFile() {{{2
fun! GuessMainFile()
  return bufname(GuessMainBuffer())
endf

" SwitchMain() {{{2
fun! SwitchMain()
  exe 'normal! ' . GuessMainWindow() . 'w'
endf
com! -nargs=0 SwitchMain call SwitchMain()

" Tags {{{2
if !exists('g:ctagsoptions')
  let g:ctagsoptions='--file-scope=no --fields=-f --java-kinds=-p --python-kinds=-i --languages=-JavaScript --fields=+S --exclude=.git'
endif
fun! s:TagsExe(tagdir, tagfile)
  if !exists('g:ctagsprg')
    let g:ctagsprg='ctags'
    if executable('ctags-exuberant')
      let g:ctagsprg='ctags-exuberant'
    endif
  endif

  silent exe '!'.g:ctagsprg.' '.g:ctagsoptions.' -f '.a:tagfile.' -R '.a:tagdir
endf
fun! TagRegenerate()
  let f = findfile('tags', '.;')
  if !filereadable(f)
    throw "Can't find tags file"
  endif
  let f = fnamemodify(f, ':p')
  call s:TagsExe(fnamemodify(f, ':h'), f)
endf
fun! TagInit()
  let dir = getcwd()
  call s:TagsExe(dir, dir.'/tags')
endf
com! -nargs=0 TagRegenerate call TagRegenerate()
com! -nargs=0 TagInit call TagInit()

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
    if exists('b:crcmd')
      sil exe b:crcmd
      return
    endif

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
    update " Write file if modified
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
      let tmp=expand('~/.vim/local/mdpreview.html')
      call writefile(['<title>Markdown preview</title>','<link href="file:///'.expand('~/.vim/assets/markdown.css').'" rel="stylesheet"></link>'], tmp)
      exe 'silent !markdown %>>'.tmp
      call OpenURL(tmp)
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

" ToggleQuickFix() {{{2
fun! ToggleQuickFix()
  for b in tabpagebuflist()
    if getbufvar(b, '&buftype') == 'quickfix'
      cclose
      return
    endif
  endfor
  botright copen
endf

" ToggleModeless(): Turn Vim into a modeless editor {{{2
let s:tm_toggle = 0
fun! ToggleModeless()
  if s:tm_toggle == 0
    let s:tm_toggle = 1
    let s:tm_insertmode=&insertmode
    let s:tm_fdc=&fdc
    if has("gui_running")
      let s:tm_guioptions=&guioptions
      set guioptions=gmrLtT
    endif
    set insertmode
    if &fdc<2
      set fdc=3
    endif
  else
    let s:tm_toggle = 0
    let &insertmode=s:tm_insertmode
    let &guioptions=s:tm_guioptions
    let &fdc=s:tm_fdc
  endif
endf
command! -nargs=0 ToggleModeless call ToggleModeless()

