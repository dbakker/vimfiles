if getftype(glob("~/.vim/bundle/vundle"))=="dir"

filetype off                   " required!

" Setup plugin loader {{{1
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Load plugins {{{1
" let Vundle manage Vundle (required!)
Bundle 'gmarik/vundle'

" My Bundles here:
Bundle 'git://github.com/tomtom/tcomment_vim.git'
Bundle 'git://github.com/dbakker/dirmap.git'
Bundle 'git://github.com/kien/ctrlp.vim.git'
Bundle 'git://github.com/xolox/vim-session.git'
Bundle 'git://github.com/vim-scripts/searchfold.vim.git'
Bundle 'git://github.com/vim-scripts/wombat256.vim'
Bundle 'git://github.com/altercation/vim-colors-solarized.git'
Bundle 'git://github.com/mileszs/ack.vim/'
Bundle 'git://github.com/vim-scripts/bufkill.vim.git'
Bundle 'git://github.com/tpope/vim-markdown'
Bundle 'git://github.com/vim-scripts/javacomplete.git'
Bundle 'git://github.com/tpope/vim-unimpaired.git'
Bundle 'git://github.com/vim-scripts/eclipse.vim.git'

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

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
let g:ackprg="ack-grep -H --nocolor --nogroup --column"

" Plugin mappings {{{2
" Search in files and buffers
nnoremap <leader>t :CtrlPMixed<cr>
nnoremap <leader>aa :Ack 
nnoremap <leader>apy :Ack --python 

" Delete a buffer without closing its window
nnoremap <leader>qq :BD<cr>
nnoremap <leader>qf :BD!<cr>
nnoremap <leader>qw :w<cr>:BD<cr>
nnoremap <leader>qaq :bufdo BD<cr>
nnoremap <leader>qaw :wa<cr>:bufdo BD<cr>
nnoremap <leader>qaf :bufdo BD!<cr>

" Java autocomplete {{{2
if has("autocmd")
  autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif

endif
" vim: fdm=marker
