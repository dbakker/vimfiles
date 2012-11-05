if getftype(glob("~/.vim/bundle/vundle"))=="dir"

filetype off                   " required!

" Setup plugin loader {{{1
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Load plugins {{{1
" let Vundle manage Vundle (required!)
Bundle 'gmarik/vundle'

" My Bundles here:
Bundle 'git://github.com/Lokaltog/vim-powerline.git'
Bundle 'git://github.com/altercation/vim-colors-solarized.git'
Bundle 'git://github.com/bronson/vim-visual-star-search.git'
Bundle 'git://github.com/dbakker/vim-projectroot.git'
Bundle 'git://github.com/ervandew/supertab.git'
Bundle 'git://github.com/godlygeek/tabular.git'
Bundle 'git://github.com/kien/ctrlp.vim.git'
Bundle 'git://github.com/mileszs/ack.vim/'
Bundle 'git://github.com/nelstrom/vim-markdown-folding.git'
Bundle 'git://github.com/scrooloose/nerdtree.git'
Bundle 'git://github.com/tomtom/tcomment_vim.git'
Bundle 'git://github.com/tpope/vim-fugitive.git'
Bundle 'git://github.com/tpope/vim-markdown.git'
Bundle 'git://github.com/tpope/vim-repeat.git'
Bundle 'git://github.com/tpope/vim-surround.git'
Bundle 'git://github.com/vim-scripts/bufexplorer.zip.git'
Bundle 'git://github.com/vim-scripts/eclipse.vim.git'
Bundle 'git://github.com/vim-scripts/javacomplete.git'
Bundle 'git://github.com/vim-scripts/mru.vim.git'
Bundle 'git://github.com/vim-scripts/searchfold.vim.git'
Bundle 'git://github.com/vim-scripts/wombat256.vim'
Bundle 'git://github.com/xolox/vim-session.git'

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" MRU {{{2
let MRU_File = expand('~/.vim/local/mru_data.txt')
let MRU_Exclude_Files = '\.git'
let MRU_Add_Menu = 0

" Tcomment {{{2
let g:tcomment_types={'java': '// %s'}
let g:tcommentInlineC='// %s'

" Fuzzy finder: ignore stuff that can't be opened, and generated files {{{2
let g:fuzzy_ignore = "*.png;*.PNG;*.JPG;*.jpg;*.GIF;*.gif;"

" Settings for ctrl-p plugin
" the nearest ancestor that contains one of these
" directories or files: .git .hg .svn .bzr _darcs
let g:ctrlp_working_path_mode = 2
let g:ctrlp_cmd = 'CtrlPMixed'

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
let NERDTreeHijackNetrw=0
let NERDTreeBookmarksFile=expand('~/.vim/local/NERDTreeBookmarks.txt')
let NERDTreeMouseMode=2
fun! NERDTreeSmartToggle()
  for buf in tabpagebuflist()
    if bufname(buf) =~ 'NERD_tree'
      NERDTreeClose
      return
    endif
  endfor
  ProjectRootExe NERDTreeFind
endf

" Java autocomplete {{{2
if has("autocmd")
  autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif

endif
" vim: fdm=marker
