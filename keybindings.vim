
" Since I never use the ; key anyway, this is a real optimization for almost
" all Vim commands, as I don't have to press the Shift key to form chords to
" enter ex mode.
noremap <unique> ; :

" Swap meaning of 0 and ^ {{{1
nnoremap <unique> 0 ^
vnoremap <unique> 0 ^
nnoremap <unique> ^ 0
vnoremap <unique> ^ 0

" Make the up and down arrows also move the screen {{{1
nnoremap <unique> <down> gj<C-e>
nnoremap <unique> <up> gk<C-y>

" Remap j and k to act as expected when used on long, wrapped, lines {{{1
nnoremap <unique> j gj
nnoremap <unique> k gk

" Use ,/ to clear search highlighting {{{1
nmap <silent> ,/ :nohlsearch<CR>

" Buffer write/delete mappings {{{1
nnoremap <silent> <unique> <leader>wa :wa<cr>
nnoremap <silent> <unique> <leader>wf :w!<cr>
nnoremap <silent> <unique> <leader>wj :w<cr>
nnoremap <silent> <unique> <leader>wq :w<cr>:BD<cr>
nnoremap <silent> <unique> <leader>wx :wa<cr>:bufdo BD<cr>
nnoremap <silent> <unique> <leader>qa :bufdo BD<cr>
nnoremap <silent> <unique> <leader>qf :BD!<cr>
nnoremap <silent> <unique> <leader>qj :BD<cr>

" File management mappings {{{1
nnoremap <unique> <Leader>db :NERDTreeFromBookmark<space>
nnoremap <unique> <silent> <Leader>dt :call NERDTreeSmartToggle()<CR>
nnoremap <unique> <leader>dr :MRU<space>
nnoremap <unique> <silent> [b :exe 'b '.GetNextBuffer(-1)<CR>
nnoremap <unique> <silent> ]b :exe 'b '.GetNextBuffer(1)<CR>
nnoremap <unique> <silent> [o :exe 'e '.GetNextFileInDir(-1)<CR>
nnoremap <unique> <silent> ]o :exe 'e '.GetNextFileInDir(1)<CR>
nnoremap <unique> <silent> [p :exe 'b '.GetNextProjectBuffer(-1)<CR>
nnoremap <unique> <silent> ]p :exe 'b '.GetNextProjectBuffer(1)<CR>
nnoremap <unique> <silent> [q :cprev<CR>
nnoremap <unique> <silent> ]q :cnext<CR>
if has("gui_mac")
  noremap <C-6> <C-^>
endif

" Increase/decrease font-size {{{1
command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)+1','g')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)-1','g')
noremap <C-kPlus> :Bigger<CR>
noremap <C-kMinus> :Smaller<CR>

" Use ,y/p/P to yank/paste to the OS clipboard {{{1
nnoremap <unique> <leader>y "+y
vnoremap <unique> <leader>y "+y
nnoremap <unique> <leader>p "+p
vnoremap <unique> <leader>p "+p
nnoremap <unique> <leader>P "+P
vnoremap <unique> <leader>P "+P

" Give Y a more logical purpose than aliasing yy {{{1
nnoremap <unique> Y y$

" Use Q as alias for @j (execute 'j' recording) {{{1
nnoremap <unique> Q @j

" Use ':R foo' to run foo and capture its output in a scratch buffer {{{1
command! -nargs=* -complete=shellcmd R new | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

" Add commandline/emacs style mappings for insert/command mode {{{1
inoremap <unique> <C-X><C-@> <C-A>
inoremap <unique> <C-A> <C-O>^
inoremap <unique> <C-B> <Left>
inoremap <unique> <C-D> <Del>
inoremap <unique> <C-E> <End>
inoremap <unique> <C-F> <Right>
inoremap <unique> <S-CR> <C-O>o
inoremap <unique> <C-CR> <C-O>O

cnoremap <unique> <C-X><C-A> <C-A>
cnoremap <unique> <C-A> <Home>
cnoremap <unique> <C-B> <Left>
cnoremap <unique> <C-D> <Del>
cnoremap <unique> <C-E> <End>
cnoremap <unique> <C-F> <Right>
cnoremap <unique> <C-P> <Up>

" Navigate/create tabpages with g<num> {{{1
fun! NavTabPage(num)
  while tabpagenr('$')<a:num
    tabnew
  endwhile
  exe 'tabnext '.a:num
endf
nnoremap <unique> <silent> g1 :call NavTabPage(1)<CR>
nnoremap <unique> <silent> g2 :call NavTabPage(2)<CR>
nnoremap <unique> <silent> g3 :call NavTabPage(3)<CR>
nnoremap <unique> <silent> g4 :call NavTabPage(4)<CR>
nnoremap <unique> <silent> g5 :call NavTabPage(5)<CR>
nnoremap <unique> <silent> g6 :call NavTabPage(6)<CR>
nnoremap <unique> <silent> g7 :call NavTabPage(7)<CR>

" Tabulurize {{{1
nnoremap <unique> <Leader>t= :Tabularize /=>\?<CR>
vnoremap <unique> <Leader>t= :Tabularize /=>\?<CR>
nnoremap <unique> <Leader>t: :Tabularize /:<CR>
vnoremap <unique> <Leader>t: :Tabularize /:<CR>
nnoremap <unique> <Leader>t, :Tabularize /,<CR>
vnoremap <unique> <Leader>t, :Tabularize /,<CR>
nnoremap <unique> <Leader>t<Bar> :Tabularize /<Bar><CR>
vnoremap <unique> <Leader>t<Bar> :Tabularize /<Bar><CR>

" File/text search {{{1
nnoremap <leader>aa :Ack<space>
nnoremap <leader>apy :Ack --python<space>

" Various other mappings {{{1
nnoremap gG :OpenURL http://www.google.com/search?q=<cword><CR>
vnoremap gG :call OpenURL('http://www.google.com/search?q='.substitute(GetVisualLine(),'\s','+','g'))<CR>
nnoremap gK K
" Reselect last pasted/edited text
nnoremap gV `[v`]
nnoremap <unique> <silent> <F5> :call CompileAndRun()<cr>
command! -nargs=* Wrap setl wrap nolist
command! -nargs=* NoWrap setl nowrap list&

sil! nnoremap <unique> <silent> <F12> :call ToggleModeless()<cr>
sil! inoremap <unique> <silent> <F12> <C-O>:call ToggleModeless()<cr>
