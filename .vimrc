" Extreme customizable vim config by Daan O. Bakker

" Init {{{1
set nocompatible                " forget being compatible with good ol' vi
let mapleader=","               " Change the mapleader from \ to ,

" use ~/.vim/ as runtime path on every OS, including Windows
if has("win32")
  let &runtimepath=substitute(&runtimepath,'\(Documents and Settings\|Users\)[\\/][^\\/,]*[\\/]\zsvimfiles\>','.vim','g')
elseif $USER == 'root' && $HOME!=#'/root' && filereadable('/root/.vimrc')
  set rtp-=~/.vim rtp-=~/.vim/after
  let $HOME='/root'
  set rtp+=~/.vim rtp+=~/.vim/after
  sil! source ~/.vimrc
  finish
endif

" Create local directories for vim to use
let g:localdir=expand("~/.local/share/vim")
let &directory=localdir."/swap//"
let &viewdir=localdir."/views"
let &undodir=localdir."/undo"

for dir in [localdir, localdir."/swap", &viewdir, &undodir]
  if !isdirectory(dir) && exists('*mkdir')
    sil! call mkdir(dir, 'p', 0700)
  endif
endfor

" Loads the given script file if it exists.
fun! TrySource(script)
  if filereadable(expand(a:script))
    exe 'source '.a:script
  endif
endf

" initialize global methods and variables for use in scripts/plugins
call TrySource('~/.vim/functions.vim')
call TrySource('~/.vim.local/functions.vim')
" initialize plugin stuff (Vundle/Pathogen)
call TrySource('~/.vim/initplugin.vim')

" Get that filetype stuff happening (assume version>600)
filetype plugin indent on

" Load general vim scripts
call TrySource('~/.vim/general.vim')
call TrySource('~/.vim.local/general.vim')
call TrySource('~/.vim/keybindings.vim')

" GetFileScript([filename]) {{{1
" Returns the name of the script file directly associated
" to the given file or directory. It may not exist yet.
fun! GetFileScript(...)
  if a:0==1 && len(a:1)>0
    let scriptname=fnamemodify(expand(a:1), ':p')
  else
    let scriptname=expand('%:p')
  endif
  let scriptname=substitute(scriptname, '\v[\\/]+$', '', 'g')
  let scriptname=substitute(scriptname, '\v[^a-zA-Z0-9. ]', '_', 'g')
  return expand('~/.vim.local/filescripts/').scriptname.'.vim'
endf

command! -nargs=? -complete=file EditScript exe ':e '.GetFileScript('<args>')

" SourceFileScripts(absolutefilename) {{{1
" Finds all scripts associated to the given file or directory and sources
" them.

fun! SourceFileScripts(file)
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

fun! LoadBufScripts()
  if !exists('b:loaded_buf_scripts')
    let b:loaded_buf_scripts=1
    let ftname=&filetype
    if len(ftname)==0
      let ftname='none'
      let b:ftnone=1
    endif
    call TrySource('~/.vim/onbuffer/general.vim')
    call TrySource('~/.vim/onbuffer/'.ftname.'.vim')
    call TrySource('~/.vim.local/onbuffer/general.vim')
    call TrySource('~/.vim.local/onbuffer/'.ftname.'.vim')
    call SourceFileScripts(expand('%:p'))
  endif
endf

aug ftChangeHook
  au!
  au FileType * if exists('b:ftnone')
  au FileType * unlet b:ftnone
  au FileType * call TrySource('~/.vim/onbuffer/'.&ft.'.vim')
  au FileType * call TrySource('~/.vim.local/onbuffer/'.&ft.'.vim')
  au FileType * endif
aug END

augroup LoadBufScripts
  au!
  au BufEnter * call LoadBufScripts()
augroup END
