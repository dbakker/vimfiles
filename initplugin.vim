if getftype(glob("~/.vim/bundle/vundle"))=="dir"

filetype off                   " required!

" Setup plugin loader {{{1
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Load plugins {{{1
" let Vundle manage Vundle (required first line!)
Bundle 'gmarik/vundle'

Bundle 'Lokaltog/vim-easymotion'
Bundle 'altercation/vim-colors-solarized'
Bundle 'bronson/vim-visual-star-search'
Bundle 'dbakker/vim-md-noerror'
Bundle 'dbakker/vim-paragraph-motion'
Bundle 'dbakker/vim-placeholders'
Bundle 'dbakker/vim-powerline'
Bundle 'dbakker/vim-projectroot'
Bundle 'ervandew/supertab'
Bundle 'godlygeek/tabular'
Bundle 'kien/ctrlp.vim'
Bundle 'majutsushi/tagbar'
Bundle 'mileszs/ack.vim'
Bundle 'nelstrom/vim-markdown-folding'
Bundle 'scrooloose/nerdtree'
Bundle 'tomtom/tcomment_vim'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-ragtag'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'vim-scripts/argtextobj.vim'
Bundle 'vim-scripts/bufexplorer.zip'
Bundle 'vim-scripts/eclipse.vim'
Bundle 'vim-scripts/javacomplete'
Bundle 'vim-scripts/md5.vim'
Bundle 'vim-scripts/mru.vim'
Bundle 'vim-scripts/nginx.vim'
Bundle 'vim-scripts/searchfold.vim'
Bundle 'vim-scripts/wombat256.vim'
Bundle 'xolox/vim-session'
call TrySource('~/.vim/local/bundles.vim')

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" MRU {{{2
let MRU_File = expand('~/.vim/local/mru_data.txt')
let MRU_Exclude_Files = '\.git'
let MRU_Add_Menu = 0

" Tcomment {{{2
if isdirectory(expand('~/.vim/bundle/tcomment_vim'))
  let g:tcomment_types={'java': '// %s'}
  call tcomment#DefineType('markdown', g:tcommentInlineXML)
endif

" Fuzzy finder: ignore stuff that can't be opened, and generated files {{{2
let g:fuzzy_ignore = "*.png;*.PNG;*.JPG;*.jpg;*.GIF;*.gif;"

" Settings for Session plugin {{{2
let g:session_directory = '~/.vim/local/session'
let g:session_autoload = 'no'
let g:session_autosave = 'no'

let g:searchfold_foldlevel = 2

" Settings for Ack plugin {{{2
if executable('ack-grep')
  let g:ackprg="ack-grep -H --nocolor --nogroup --column"
elseif executable('ack')
  let g:ackprg="ack -H --nocolor --nogroup --column"
endif

" NERDTree {{{2
let NERDTreeHijackNetrw=1
let NERDTreeBookmarksFile=expand('~/.vim/local/NERDTreeBookmarks.txt')
let NERDTreeMouseMode=2
fun! NERDTreeSmartToggle()
  for buf in tabpagebuflist()
    if bufname(buf) =~ 'NERD_tree'
      NERDTreeClose
      return
    endif
  endfor
  try
    ProjectRootExe NERDTreeFind
  catch
    ProjectRootExe NERDTree
  endtry
endf

" Nginx {{{2
au BufNewFile,BufRead nginx.conf set filetype=nginx.conf

" Easymotion {{{2
let g:EasyMotion_leader_key = '<space>'

" Java autocomplete {{{2
if has("autocmd")
  autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif

" Misc {{{2
au BufNewFile,BufRead *.fo if len(&ft)==0 | set ft=xml | endif " Apache FOP file

" CtrlP {{{2
let g:ctrlp_cache_dir = $HOME.'/.vim/local/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'

endif
