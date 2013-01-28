
" I still mostly use `:` because it is annoying when you are used to `;` and
" then have to work on a system that doesn't have this map. But I won't use it
" for its original purpose anyway.
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

" Mapping for swapping the system and unnamed register {{{1
" The greatest thing about this is that you can use it *after* you
" have already deleted (or yanked) something.
nnoremap <silent> <unique> <leader><space> :call SwapRegisters('+', '"')<cr>
vnoremap <silent> <unique> <leader><space> <esc>:call SwapRegisters('+', '"')<cr>gv

" Clear search highlighting or refresh screen {{{1
nnoremap <unique> <silent> <C-L> :nohlsearch<CR><C-L>
nnoremap <unique> <silent> ,/ :nohlsearch<CR>
nnoremap <unique> <silent> ,\ :nohlsearch<CR>

" Buffer write/delete mappings {{{1
nnoremap <silent> <unique> <leader>wa :wa<cr>
nnoremap <silent> <unique> <leader>wf :w!<cr>
nnoremap <silent> <unique> <leader>wj :w<cr>
nnoremap <silent> <unique> <leader>wq :w<cr>:BD<cr>
nnoremap <silent> <unique> <leader>wx :wa<cr>:bufdo BD<cr>
nnoremap <silent> <unique> <leader>qa :bufdo BD<cr>
nnoremap <silent> <unique> <leader>qf :BD!<cr>
nnoremap <silent> <unique> <leader>qj :BD<cr>

" Use Q as alias for @j (execute 'j' recording) {{{1
" This is great because you can just do something like QnQnnQ to quickly
" repeat your recording where needed. You never have to press `@` again.
nnoremap <unique> Q @j
vnoremap <unique> Q @j

" Use (visual) X to eXchange two pieces of text {{{1
" To use: first delete something, then visual something else
vnoremap <unique> X <esc>`.``gvP``P

" File management mappings {{{1
fun! EditFromDir(dir)
  if isdirectory(a:dir) && a:dir!='.'
    return ':e '.a:dir.'/'
  endif
  return ':e '
endf
nnoremap <unique> <silent> go :exe 'ptag '.expand('<cword>')<cr>
xnoremap <unique> <silent> go :exe 'ptag '.GetVisualLine()<cr>
nnoremap <unique> <leader>d<space> :e<space>
nnoremap <unique> <leader>db :NERDTreeFromBookmark<space>
nnoremap <unique> <leader>dc :cd<space>
nnoremap <unique> <silent> <leader>df :exe 'cd '.fnamemodify(GuessMainFile(), ':h')<cr>
nnoremap <unique> <expr> <leader>di EditFromDir(fnamemodify(GuessMainFile(), ':h'))
nnoremap <unique> <expr> <leader>dj EditFromDir(ProjectRootGuess(GuessMainFile()))
nnoremap <unique> <silent> <leader>dt :call NERDTreeSmartToggle()<cr>
nnoremap <unique> <leader>dr :SwitchMain<cr>:MRU<space>
nnoremap <unique> <silent> <leader>dp :exe 'cd '.ProjectRootGuess(GuessMainFile())<cr>
nnoremap <unique> <silent> <leader>du :cd ..<cr>
nnoremap <unique> <silent> [b :SwitchMain<cr>:exe 'b '.GetNextBuffer(-1)<cr>
nnoremap <unique> <silent> ]b :SwitchMain<cr>:exe 'b '.GetNextBuffer(1)<cr>
nnoremap <unique> <silent> [o :SwitchMain<cr>:exe 'e '.GetNextFileInDir(-1)<cr>
nnoremap <unique> <silent> ]o :SwitchMain<cr>:exe 'e '.GetNextFileInDir(1)<cr>
" The original mappings for [p and ]p have become =p
nnoremap <unique> <silent> [p :SwitchMain<cr>:exe 'b '.GetNextProjectBuffer(-1)<cr>
nnoremap <unique> <silent> ]p :SwitchMain<cr>:exe 'b '.GetNextProjectBuffer(1)<cr>
nnoremap <unique> <silent> [q :cprev<cr>
nnoremap <unique> <silent> ]q :cnext<cr>
nnoremap <unique> <silent> [t :tprev<cr>
nnoremap <unique> <silent> ]t :tnext<cr>
if has("gui_mac")
  noremap <C-6> <C-^>
endif

" Increase/decrease font-size {{{1
command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)+1','g')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)-1','g')
noremap <C-kPlus> :Bigger<CR>
noremap <C-kMinus> :Smaller<CR>

" Use ,y/p/P/vp/vP to yank/paste to the OS clipboard {{{1
nnoremap <unique> <leader>y "+y
vnoremap <unique> <leader>y "+y
nnoremap <unique> <leader>Y "+Y
vnoremap <unique> <leader>Y "+Y
nnoremap <unique> <leader>p "+p
vnoremap <unique> <leader>p "+p
nnoremap <unique> <leader>P "+P
vnoremap <unique> <leader>P "+P
" Paste+visually select what was just pasted
nnoremap <unique> <leader>vp "+p`[v`]
nnoremap <unique> <leader>vP "+P`[v`]
vnoremap <unique> <leader>vp "+p`[v`]
vnoremap <unique> <leader>vP "+P`[v`]

" Give Y a more logical purpose than aliasing yy {{{1
nnoremap <unique> Y y$

" Use ':R foo' to run foo and capture its output in a scratch buffer {{{1
command! -nargs=* -complete=shellcmd R new | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

" Add readline/emacs style mappings for insert/command mode {{{1
inoremap <unique> <C-X><C-@> <C-A>
inoremap <unique> <C-A> <C-O>^
inoremap <unique> <C-X><C-A> <C-A>
inoremap <unique> <expr> <C-B> getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"
inoremap <unique> <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
inoremap <unique> <expr> <C-E> col('.')>strlen(getline('.'))?"\<Lt>C-E>":"\<Lt>End>"
inoremap <unique> <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"

cnoremap <unique> <C-X><C-A> <C-A>
cnoremap <unique> <C-A> <Home>
cnoremap <unique> <C-B> <Left>
cnoremap <unique> <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <unique> <C-E> <End>
cnoremap <unique> <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"

" Add columnwise 0 and $ mappings {{{1
" This one is really cool. These mappings motion columnwise until
" a non-character (eg. empty or shorter line) is encountered. It has
" special behavior for corner cases.
fun! s:Columnwise(d)
  let l = line('.')+a:d
  let c = len(getline('.'))
  let c = col('.')<c ? col('.') : (c>0 ? c : 1)
  while len(getline(l+a:d))>=c
    let l = l+a:d
  endw
  return abs(l-line('.'))
endf
xnoremap <unique> <expr> <leader>j <SID>Columnwise(1).'j'
xnoremap <unique> <expr> <leader>k <SID>Columnwise(-1).'k'

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

" Fugitive plugin {{{1
nnoremap <leader>g<space> :Git<space>
nnoremap <leader>ga :Git<space>
nnoremap <leader>gb :Gblame<space>
nnoremap <leader>gc :Gcommit<space>
nnoremap <leader>gd :Gdiff<space>
nnoremap <leader>gl :Glog<space>
nnoremap <leader>gm :Gmove<space>
nnoremap <leader>gp :Git push<space>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gw :Gwrite<cr>

" File/text search {{{1
nnoremap <leader>aa :Ack<space>
nnoremap <expr> <leader>aj ':Ack'.(len(&ft)?' --'.&ft:'').' -Q -i '

" <F1-12> mappings {{{1
nnoremap <F2> :set invlist list?<cr>
imap <F2> <C-O><F2>
xmap <F2> <Esc><F2>gv
nnoremap <unique> <silent> <F5> :call CompileAndRun()<cr>
nnoremap <unique> <silent> <F7> :call OpenPrompt()<cr>
nnoremap <unique> <silent> <S-F7> :cd %:h<cr>:call OpenPrompt()<cr>
nnoremap <unique> <silent> <F9> :call NERDTreeSmartToggle()<cr>
nnoremap <unique> <silent> <F10> :call ToggleQuickFix()<cr>
nnoremap <unique> <silent> <F12> :TagbarToggle<cr>
nnoremap <unique> <silent> <F3> :call ToggleModeless()<cr>
inoremap <unique> <silent> <F3> <C-O>:call ToggleModeless()<cr>

noremap <unique> <silent> <C-F9>  :vertical resize -10<cr>
noremap <unique> <silent> <C-F10> :resize +10<cr>
noremap <unique> <silent> <C-F11> :resize -10<cr>
noremap <unique> <silent> <C-F12> :vertical resize +10<cr>

" Window management {{{1
" Remaps Alt+x to <C-W>x (without overwriting previously defined mappings)
" Alt is somewhat unreliable, as it only works in the Vim GUI version,
" but I almost never use windows in the console version anyway.
for c in split('abcdefghijklmnopqrstuvwxyz!@#$%^&*()_-+<>=', '\zs')
  if maparg('<M-'.c.'>', 'n') ==# ''
    exe 'nnoremap <unique> <M-'.c.'> <C-W>'.c
  endif
endfor
nnoremap <unique> <M-Left> <C-W>h
nnoremap <unique> <M-Down> <C-W>j
nnoremap <unique> <M-Up> <C-W>k
nnoremap <unique> <M-Right> <C-W>l

" Various other mappings {{{1
imap <unique> <C-Space> <C-X><C-O>
nnoremap gG :call SearchWebMap(expand("<cword>"))<CR>
vnoremap gG :call SearchWeb(GetVisualLine())<CR>
nnoremap gK K
" gI: move to last change without going into insert mode like gi
nnoremap gI `.
" Reselect last pasted/edited text
nnoremap gV `[v`]
" Paste without overwriting any register
xnoremap <unique> <silent> P "_dP
" Make CTRL-^ also go to the right column of the alternate file
noremap <C-^> <C-^>`"
" Remove all trailing spaces
nnoremap <silent> <leader>S :retab<Bar>:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
command! -nargs=0 Wrap setl wrap nolist
command! -nargs=0 NoWrap setl nowrap list&

" Ack motions {{{1
" https://github.com/sjl/dotfiles/blob/master/vim/vimrc
"
" Motions to Ack for things.  Works with pretty much everything, including:
"
"   w, W, e, E, b, B, t*, f*, i*, a*, and custom text objects
"
" Awesome.
"
" Note: If the text covered by a motion contains a newline it won't work.  Ack
" searches line-by-line.

nnoremap <silent> <leader>am :set opfunc=<SID>AckMotion<CR>g@
xnoremap <silent> <leader>am :<C-U>call <SID>AckMotion(visualmode())<CR>

nnoremap <silent> <leader>aw :Ack! '\b<c-r><c-w>\b'<cr>
xnoremap <silent> <leader>aw :<C-U>call <SID>AckMotion(visualmode())<CR>

function! s:CopyMotionForType(type)
  if a:type ==# 'v'
    sil exe "normal! `<" . a:type . "`>y"
  elseif a:type ==# 'char'
    sil exe "normal! `[v`]y"
  endif
endfunction

function! s:AckMotion(type) abort
  let reg_save = @@
  call s:CopyMotionForType(a:type)
  exe "normal! :Ack! --literal " . shellescape(@@) . "\<cr>"
  let @@ = reg_save
endfunction
