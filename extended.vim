" Daan Bakker's extended vim settings
" These change vim in a more drastic way

set nofoldenable                " do not fold by default (use zM/zR)

" Undo {{{1
set undolevels=1000             " use many muchos levels of undo
if exists('+undofile')
  set undodir=~/.vim/local/undo
  set undofile
endif

" Make 0 work as ^ {{{1
nnoremap 0 ^
xnoremap 0 ^
vnoremap 0 ^
nnoremap ^ 0
xnoremap ^ 0
vnoremap ^ 0

" Make "inner block" commands work from outside the block {{{1
nnoremap cib %cib
nnoremap dib %dib
nnoremap yib %yib

" My own invention: search for the last deleted thing {{{1
nnoremap <unique> <silent><leader>s :<C-U>exe '/'.escape(substitute(@1,'$.*','','g'),'?\.*$^~[')<CR>bn

" Select theme {{{1
if has("gui_running")
    set background=dark
    colorscheme solarized
else
    let g:solarized_termcolors=256
    colorscheme solarized
endif

" vim: fdm=marker
