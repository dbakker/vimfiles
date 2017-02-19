" Check out `:help setting` to find more information about any command

" Init {{{1
set nocompatible  " needed when running vim with -u flag
let mapleader="\<space>"

let g:vimdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
if filereadable(g:vimdir . '/.vimrc')
  let g:vimdir = g:vimdir . '/.vim'
  if !isdir(g:vimdir)
    let g:vimdir = expand('~/.vim')
  endif
endif
let g:vimlocaldir = fnamemodify(g:vimdir, ':h') . '/.vim.local'

" use ~/.vim/ as runtime path on every OS, including Windows
if has("win32")
  let &runtimepath=substitute(&runtimepath,'\(Documents and Settings\|Users\)[\\/][^\\/,]*[\\/]\zsvimfiles\>','.vim','g')
endif

" Remove ~/.vim from the RTP if we're not actually in that directory
if g:vimdir != expand('~/.vim')
  set rtp-=~/.vim
  set rtp-=~/.vim/after
  execute 'set rtp^='.g:vimdir
  execute 'set rtp^='.g:vimdir.'/after'
"   let &runtimepath=substitute(&runtimepath,'\(,\|^\)\zs[^,]*[\\/].vim\ze\([\\/][^,]\+\)\?\(,\|$\)',g:vimdir,'g')
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
function! TrySource(script)
  if filereadable(expand(a:script))
    execute 'source '.a:script
  endif
endf

" initialize global methods and variables for use in scripts/plugins
call TrySource(g:vimdir.'/functions.vim')
" initialize plugin stuff (Vundle/Pathogen)
call TrySource(g:vimdir.'/initplugin.vim')

" Get that filetype stuff happening (assume version>600)
filetype plugin indent on

" Load general vim scripts
call TrySource(g:vimdir.'/general.vim')
call TrySource(g:vimlocaldir.'/general.vim')
call TrySource(g:vimdir.'/keybindings.vim')

" GetFileScript([filename]) {{{1
" Returns the name of the script file directly associated
" to the given file or directory. It may not exist yet.
function! GetFileScript(...)
  if a:0==1 && len(a:1)>0
    let scriptname=fnamemodify(expand(a:1), ':p')
  else
    let scriptname=expand('%:p')
  endif
  let scriptname=substitute(scriptname, '\v[\\/]+$', '', 'g')
  let scriptname=substitute(scriptname, '\v[^a-zA-Z0-9. ]', '_', 'g')
  return expand(g:vimlocaldir.'/filescripts/').scriptname.'.vim'
endf

command! -nargs=? -complete=file EditScript execute 'edit' GetFileScript('<args>')

" SourceFileScripts(absolutefilename) {{{1
" Finds all scripts associated to the given file or directory and sources
" them.

function! SourceFileScripts(file)
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

function! LoadBufScripts()
  if !exists('b:loaded_buf_scripts')
    let b:loaded_buf_scripts=1
    let ftname=&filetype
    if len(ftname)==0
      let ftname='none'
      let b:ftnone=1
    endif
    call TrySource(g:vimdir.'/onbuffer/general.vim')
    call TrySource(g:vimdir.'/onbuffer/'.ftname.'.vim')
    call TrySource(g:vimlocaldir.'/onbuffer/general.vim')
    call TrySource(g:vimlocaldir.'/onbuffer/'.ftname.'.vim')
    call SourceFileScripts(expand('%:p'))
  endif
endf

augroup ftChangeHook
  autocmd!
  autocmd FileType * if exists('b:ftnone')
  autocmd FileType * unlet b:ftnone
  autocmd FileType * call TrySource(g:vimdir.'/onbuffer/'.&ft.'.vim')
  autocmd FileType * call TrySource(g:vimlocaldir.'/onbuffer/'.&ft.'.vim')
  autocmd FileType * endif
augroup END

augroup LoadBufScripts
  autocmd!
  autocmd BufEnter * call LoadBufScripts()
augroup END
