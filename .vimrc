" Extreme customizable vim config by Daan O. Bakker

" Init {{{1
set nocompatible                " forget being compatible with good ol' vi
let mapleader=","               " Change the mapleader from \ to ,

" use ~/.vim/ as runtime path on every OS, including Windows
if has("win32")
  let &runtimepath=substitute(&runtimepath,'\(Documents and Settings\|Users\)[\\/][^\\/,]*[\\/]\zsvimfiles\>','.vim','g')
endif

" Loads the given script file if it exists.
fun TrySource(script)
  if filereadable(expand(a:script))
    exe 'source '.a:script
  endif
endf

" initialize global methods and variables for use in scripts/plugins
call TrySource('~/.vim/gfunctions.vim')
" initialize plugin stuff (Vundle/Pathogen)
call TrySource('~/.vim/initplugin.vim')

" Get that filetype stuff happening (assume version>600)
filetype plugin indent on

" Load general vim scripts {{{1
if !exists('g:loaded_general_scripts')
  let g:loaded_general_scripts=1
  call TrySource('~/.vim/general.vim')
  call TrySource('~/.vim/local/general.vim')
  call TrySource('~/.vimrc.local')
endif

" GetFileScript([filename]) {{{1
" Returns the name of the script file directly associated
" to the given file or directory. It may not exist yet.
fun GetFileScript(...)
  if a:0==1 && len(a:1)>0
    let scriptname=fnamemodify(expand(a:1), ':p')
  else
    let scriptname=expand('%:p')
  endif
  let scriptname=substitute(scriptname, '\v[\\/]+$', '', 'g')
  let scriptname=substitute(scriptname, '\v[^a-zA-Z0-9. ]', '_', 'g')
  return expand('~/.vim/local/filescripts/').scriptname.'.vim'
endf

command -nargs=? -complete=file EditScript exe ':e '.GetFileScript('<args>')

" SourceFileScripts(absolutefilename) {{{1
" Finds all scripts associated to the given file or directory and sources
" them.

fun SourceFileScripts(file)
  let subdir=fnamemodify(a:file, ':h')
  if subdir!=a:file
    call SourceFileScripts(subdir)
  endif
  call TrySource(GetFileScript(a:file))
endf

" LoadBufScripts() {{{1
" This method automatically sources certain scripts when a buffer is entered for
" the first time. The most general, global scripts are loaded first, and the
" most specific scripts last. This means that specific scripts can override
" settings made by more general scripts.

fun LoadBufScripts()
  if !exists('b:loaded_buf_scripts')
    let b:loaded_buf_scripts=1
    call TrySource('~/.vim/onbuffer/general.vim')
    call TrySource('~/.vim/onbuffer/'.&filetype.'.vim')
    call TrySource('~/.vim/local/onbuffer/general.vim')
    call TrySource('~/.vim/local/onbuffer/'.&filetype.'.vim')
    call SourceFileScripts(expand('%:p'))
  endif
endf

autocmd BufEnter * call LoadBufScripts()

