
if exists("loaded_functions")
  finish
endif
let loaded_functions = 1

" Global variables/autocmds {{{1

" Global functions {{{1
" These are functions that are useful for custom scripts

" FindVar(varname[, default]) {{{2
function! FindVar(varname, ...)
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
function! ExtendDictVar(dictname, ...)
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
function! FindInDict(key, dictname, ...)
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
endf

" SwapRegisters(reg1, reg2) {{{2
function! SwapRegisters(reg1, reg2)
  exe 'let tmp=@'.a:reg1
  exe 'let @'.a:reg1.'=@'.a:reg2
  exe 'let @'.a:reg2.'=tmp'
endf

" RemoveSharedIndent(start, last) {{{2
function! RemoveSharedIndent(start, last)
  let minimum_indent = indent(a:start)
  for linenr in range(a:start, a:last)
    let minimum_indent = min([minimum_indent, indent(linenr)])
  endfor
  let indent_to_remove = minimum_indent / &sw
  for _ in range(0, indent_to_remove - 1)
    exe ':'.a:start.','.a:last.'normal <<'
  endfor
endf
command! -range RemoveSharedIndent call RemoveSharedIndent(<line1>, <line2>)

" ChangeCwd(path) {{{2
" Change path with informative message
function! CDMessage(path)
  let curpath = getcwd()
  exe 'cd' fnameescape(a:path)
  redraw!
  let prettypath = PrettyPath(getcwd())
  if getcwd() ==# curpath
    echo 'CWD is now '.prettypath.' (unchanged)'
  else
    echo 'CWD is now '.prettypath
  endif
endf
command! -nargs=1 CDMessage call CDMessage(<q-args>)

" PrettyPath(path) {{{2
" Use ~ instead of /home/johndoe
function! PrettyPath(path)
  return substitute(expand(a:path), expand('~'), '~', '')
endf

" IsExtraBuffer(buffer) {{{2
function! IsExtraBuffer(...)
  if a:0==1
    let bt=getbufvar(a:1, '&bt')
  else
    let bt=&bt
  endif
  return bt=='help' || bt=='quickfix' || bt=='nofile'
endf

" CloseExtraBuffers() {{{1
function! CloseExtraBuffers()
  for b in tabpagebuflist()
    if IsExtraBuffer(b)
      exe 'bd '.b
    endif
  endfor
endf

" BufDelete([bang]) {{{2
" Simplified/personalized version of the BufKill plugin...
function! BufDelete(...)
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

  exe 'b' (bufloaded(bufnr('#')) && !IsExtraBuffer(bufnr('#')) ? '#' : GetNextBuffer(-1))
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
      exe 'normal! ' i . 'w'
      exe 'b' GetNextBuffer(-1)
    endif
    let i = i + 1
    let buf = winbufnr(i)
  endwhile

  exe 'normal! ' curwindow . 'w'
  sil! exe 'sil! bd'.bang bufferToKill
endf
command! -nargs=0 -bang BD call BufDelete('<bang>')

" GetMarkFile(mark) {{{2
function! GetMarkFile(mark)
  try
    let message=''
    redir => message
    sil exe ':marks' a:mark
    redir END
    let lines=split(message, '\n')
    let lastline=split(lines[len(lines)-1])
    let f = expand(lastline[len(lastline)-1])
    return filereadable(f) ? f : ''
  catch
    return ''
  endtry
endf

" GetListedBuffers() {{{2
function! GetListedBuffers()
  let all = range(1, bufnr('$'))
  let res = []
  for b in all
    if buflisted(b) && !IsExtraBuffer(b)
      call add(res, b)
    endif
  endfor
  return res
endfunction

" GetNextProjectBuffer(count[, file]) {{{2
" Creates a list of all open buffers sharing a projectroot with
" this buffer, and goes to the next buffer on that list.

function! GetNextProjectBuffer(count, ...)
  let root = a:0 ? fnamemodify(a:1, ':p:h') : ProjectRootGuess()
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
function! GetNextBuffer(count)
  let nowinbufs = []
  let thisbuf = bufnr('')
  for b in GetListedBuffers()
    if bufwinnr(b) == -1
      call add(nowinbufs, b)
    endif
  endfor
  return s:GetRelativeBuffer(nowinbufs, a:count)
endf

function! s:GetRelativeBuffer(buflist, count)
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
function! GetNextFileInDir(count)
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

" GetSheBang() {{{2
function! GetSheBang()
  return '#!/usr/bin/env '.&ft
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
  let win=winnr()
  if !IsExtraBuffer()
    return win
  endif
  let size=-1
  for i in range(1, tabpagewinnr('', '$'))
    let s = winheight(i) * winwidth(i)
    if s>size
      let size=s
      let win=i
    endif
  endfor
  return win
endf

" GuessMainFile() {{{2
fun! GuessMainFile()
  return bufname(GuessMainBuffer())
endf

" SwitchMain() {{{2
fun! SwitchMain()
  exe 'normal! ' GuessMainWindow() . 'w'
endf
com! -nargs=0 SwitchMain call SwitchMain()

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

" Update printed underline: {{{2
fun! UpdateUnderlines()
  for i in range(line("'["), line("']")+1)
    if getline(i)=~'^\s*\(-\+\|=\+\)$'
      let prev=getline(i-1)
      if len(prev)>0 && len(getline(i))!=len(prev)
        let symbol = matchstr(getline(i), '\(-\|=\)')
        let line = matchstr(prev, '^\s*')
        let line .= repeat(symbol, len(prev)-len(line))
        call setline(i, line)
      endif
    endif
  endfor
endf

" VimLoadedGuard() {{{2
fun! VimLoadedGuard()
  let f = matchstr(expand('%:p'),'.*\ze\.vim')
  if f=~'autoload'
    let type='autoload'
    let guard='autoloaded'
  elseif f=~'plugin'
    let type='plugin'
    let guard='loaded'
  else
    return ''
  endif

  let b=matchstr(f,'.*[\\/]'.type.'[\\/]\zs.*')
  if b==''
    return b
  endif

  return guard.'_'.substitute(b,'[\\/]','_','g')
endf

" IGrep(): grep in a more clever way {{{2
fun! IGrep(args, bang)
  redraw
  echo "Searching ..."
  sil! exe 'grep! '.a:args
  if len(getqflist()) == 0
    echo "IGrep: no matches"
    cclose
  else
    call SortQuickFix()
    copen
    if a:bang!='!'
      cfirst
    endif
  endif
endf

com! -nargs=* -bang IGrep call IGrep(<q-args>, <q-bang>)
com! -nargs=* -bang FGrep call IGrep(' -F '.shellescape(<q-args>), <q-bang>)

" SortQuickFix(): order quickfix list by filename {{{2
fun! SortQuickFix()
  let qflist = getqflist()
  let qfs = [[],[],[],[],[]]
  for item in qflist
    let score = s:getquickfixscore(item['bufnr'])
    if len(item['text'])<300
      call add(qfs[score], item)
    endif
  endfor
  call setqflist([])
  for qf in qfs
    call setqflist(qf, 'a')
  endfor
endf

fun! s:getquickfixscore(bufnr)
  if len(a:bufnr) == 0 || a:bufnr == 0
    return 3
  endif
  let bn=bufname(a:bufnr)
  if bn ==# bufname('')
    return 0
  endif
  if stridx(bn, '/') == -1 && stridx(bn, '\') == -1
    return 1
  endif
  if bn[0]!='/' && bn[0]!='\'
    return 2
  endif
  return 3
endf

" CompileAndRun() {{{2
let cnr_browserlangs=['xhtml', 'html', 'xml', 'css']
let cnr_defhandlers={'py': 'python', 'sh': 'sh', 'php': 'php', 'pl': 'perl', 'jar': 'java -jar'}

fun! GetDefaultHandler(filename)
  if filereadable(a:filename)
    let first = readfile(a:filename, '', 1)
    let prg = matchstr(getline(1),'^#!\zs[^ ]*')
    if prg=='/usr/bin/env'
      let prg=strpart(getline(1), 15)
    endif
    if executable(prg)
      return prg
    endif
  endif
  let ext = fnamemodify(a:filename, ':e')
  return get(g:cnr_defhandlers, ext, '')
endf
