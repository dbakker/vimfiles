
" I still mostly use `:` because it is annoying when you are used to `;` and
" then have to work on a system that doesn't have this map. But I won't use it
" for its original purpose anyway.
map ; :

" Swap meaning of 0 and ^ {{{1
nnoremap 0 ^
xnoremap 0 ^
nnoremap ^ 0
xnoremap ^ 0

" Make the up and down arrows also move the screen {{{1
nnoremap <down> gj<C-e>
nnoremap <up> gk<C-y>

" Remap j and k to act as expected when used on long, wrapped, lines {{{1
nnoremap j gj
nnoremap k gk

" Mapping for swapping the system and unnamed register {{{1
" The greatest thing about this is that you can use it *after* you
" have already deleted (or yanked) something.
nnoremap <silent> <leader><space> :call SwapRegisters('+', '"')<cr>
xnoremap <silent> <leader><space> <esc>:call SwapRegisters('+', '"')<cr>gv

" Clear search highlighting or refresh screen {{{1
nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
xnoremap <silent> <C-L> :<C-U>nohlsearch<CR>gv<C-L>
nnoremap <silent> ,/ :nohlsearch<CR>
nnoremap <silent> ,\ :nohlsearch<CR>

" Buffer write/delete mappings {{{1
nnoremap <silent> <leader>wa :wa<cr>:redraw<cr>
nnoremap <silent> <leader>wf :w!<cr>:redraw<cr>
nnoremap <silent> <leader>wj :w<cr>:redraw<cr>
nnoremap <silent> <leader>wq :w<cr>:BD<cr>
nnoremap <silent> <leader>wx :wa<cr>:bufdo BD<cr>
nnoremap <silent> <leader>qa :bufdo BD<cr>
nnoremap <silent> <leader>qf :BD!<cr>
nnoremap <silent> <leader>qj :BD<cr>

" Use Q as alias for @j (execute 'j' recording) {{{1
" This is great because you can just do something like QnQnnQ to quickly
" repeat your recording where needed. You never have to press `@` again.
nnoremap Q @j
xnoremap Q @j

" Use (visual) X to eXchange two pieces of text {{{1
" To use: first delete something, then visual something else
xnoremap X <esc>`.``gvP``P

" File management mappings {{{1
fun! EditFromDir(dir)
  if isdirectory(a:dir) && a:dir!='.'
    return ':e '.a:dir.'/'
  endif
  return ':e '
endf
nnoremap <silent> go :exe 'ptag '.expand('<cword>')<cr>
xnoremap <silent> go :exe 'ptag '.GetVisualLine()<cr>
nnoremap <leader>d<space> :e<space>
nnoremap <leader>db :CtrlPBuffer<cr>
nnoremap <leader>dc :cd<space>
nnoremap <silent> <leader>df :exe 'cd '.fnamemodify(GuessMainFile(), ':h')<cr>
nnoremap <expr> <leader>di EditFromDir(fnamemodify(GuessMainFile(), ':h'))
nnoremap <expr> <leader>dj EditFromDir(ProjectRootGuess(GuessMainFile()))
nnoremap <silent> <leader>dt :CtrlPTag<cr>
nnoremap <leader>dr :SwitchMain<cr>:CtrlPMRU<cr>
nnoremap <silent> <leader>dp :exe 'cd '.ProjectRootGuess(GuessMainFile())<cr>
nnoremap <silent> <leader>du :cd ..<cr>
nnoremap <silent> [b :SwitchMain<cr>:exe 'b '.GetNextBuffer(-1)<cr>
nnoremap <silent> ]b :SwitchMain<cr>:exe 'b '.GetNextBuffer(1)<cr>
nnoremap <silent> [o :SwitchMain<cr>:exe 'e '.GetNextFileInDir(-1)<cr>
nnoremap <silent> ]o :SwitchMain<cr>:exe 'e '.GetNextFileInDir(1)<cr>
" The original mappings for [p and ]p have become =p
nnoremap <silent> [p :SwitchMain<cr>:exe 'b '.GetNextProjectBuffer(-1)<cr>
nnoremap <silent> ]p :SwitchMain<cr>:exe 'b '.GetNextProjectBuffer(1)<cr>
nnoremap <silent> [q :cprev<cr>
nnoremap <silent> ]q :cnext<cr>
nnoremap <silent> [t :tprev<cr>
nnoremap <silent> ]t :tnext<cr>
if has("gui_mac")
  noremap <C-6> <C-^>
endif

" Increase/decrease font-size {{{1
command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)+1','g')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)-1','g')
noremap <C-kPlus> :Bigger<CR>
noremap <C-kMinus> :Smaller<CR>


" Use ,y/p/P/vp/vP to yank/paste to the OS clipboard {{{1
" Try to cleanup what is about to be pasted. Inspired by the WhitesPaste plugin.
fun! s:FixedPaste(c)
  let r = []
  for l in split(@+, '\n', 1)
    let l = substitute(l,'\s\+$','','')
    let l = &et ? substitute(l,'^\t\+','\=substitute(submatch(0),"\t",repeat(" ",&ts),"")','g') : l
    call insert(r, l, len(r))
  endfor

  while len(r)>2 && len(r[0])==0 && len(r[1])==0
    call remove(r, 0)
  endwhile
  while len(r)>2 && len(r[len(r)-1])==0 && len(r[len(r)-2])==0
    call remove(r, len(r)-1)
  endwhile

  if mode(1)=='n'
    let linebefore = getline(line('.') - (a:c==#'P'?1:0))
    if linebefore=~'^\s*$' && len(r[0])==0
      call remove(r, 0)
    endif
    let lineafter = getline((line('.') - (a:c==#'P'?1:0)) + 1)
    if lineafter=~'^\s*$' && len(r[len(r)-1])==0
      call remove(r, len(r)-1)
    endif
  endif

  let @9 = (@+=~"\n" ? join(r,"\n") . "\n" : @+)
  return '"9'.a:c
endf
nmap <leader>y "+y
xmap <leader>y "+y
nmap <leader>Y "+Y
xmap <leader>Y "+Y
nmap <expr> <leader>p <SID>FixedPaste('p')
xmap <expr> <leader>p <SID>FixedPaste('p')
nmap <expr> <leader>P <SID>FixedPaste('P')
xmap <expr> <leader>P <SID>FixedPaste('P')
" Paste+visually select what was just pasted
nmap <leader>vp "+p`[v`]
nmap <leader>vP "+P`[v`]
xmap <leader>vp "+p`[v`]
xmap <leader>vP "+P`[v`]

" Give Y a more logical purpose than aliasing yy {{{1
nnoremap Y y$

" Remap `cw` to a repeatable `dwi` {{{1
fun! s:PrepareCW(w)
  let s:w = a:w
  aug restoreThing
    au InsertLeave * silent! call repeat#set("c".s:w.@.."\<ESC>", s:count)
    au InsertLeave * au! restoreThing
  aug END
  let s:count = v:count
  return 'd'.s:w.'i'
endf

nmap <expr> cw <SID>PrepareCW('w')
nmap <expr> cW <SID>PrepareCW('W')

" Add []<space> mappings for adding spaces {{{1
fun! s:AddSpace(before)
  let [bufnum, lnum, col, off] = getpos('.')
  if a:before
    let lnum += (v:count>0) ? v:count : 1
  endif

  let result = (a:before ? "O" : "o") . "\<esc>"
  let result .= ":" . lnum . "\<CR>\<Home>"
  let result .= col>0 ? (col-1) . "l" : ""
  if &fo =~# 'o'
    setl fo-=o
    let result .= ":setl fo+=o\<CR>"
  endif
  let result .= ':silent! call repeat#set("'.(a:before ? '[' : ']').' ", '.v:count.')'."\<CR>"
  return result
endf
nnoremap <expr> [<space> <SID>AddSpace(1)
nnoremap <expr> ]<space> <SID>AddSpace(0)

" Paste without overwriting any register {{{1
fun! s:PasteOver()
  if getreg(v:register)=~#"\<C-J>"
    if mode(1)==#'V'
      return ":\<C-U>let b:move=getpos(\"'>\")[1]-getpos(\"\'<\")[1]\<CR>".'gv"_dP:sil! call repeat#set("V".(b:move?b:move."j":"")."P",0)'."\<CR>"
    else
      return '"_dP'
    endif
  else
    return "\"_c\<C-R>\"\<ESC>"
  endif
endf
xnoremap <expr> <silent> P <SID>PasteOver()

" Add maps for <C-V>$ and friends {{{1
" Using C, D and Y instead of c$, d$ and y$ is cool. I think v$ would also be
" useful. Unfortunately V is already taken, so I'll be bold and sacrifice K.

" The idea here is to try to always select from the current cursor position to
" the end of the line. Unless it is already like that in which case we exit
" visual mode.

nnoremap <expr> K (v:count>1 ? "\<ESC>\<C-V>".v:count : "\<C-V>")."$"
xnoremap <expr> K mode(1)=="\<C-V>" && col('.')>=len(getline('.')) ? "\<C-V>" : "\<ESC>'<\<Home>".(col('.')-1)."l\<C-V>'>$"

" Use ':R foo' to run foo and capture its output in a scratch buffer {{{1
command! -nargs=* -complete=shellcmd R new | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

" Add readline/emacs style mappings for insert/command mode {{{1
inoremap <C-X><C-@> <C-A>
inoremap <C-A> <C-O>^
inoremap <C-X><C-A> <C-A>
inoremap <expr> <C-B> getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"
inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
inoremap <expr> <C-E> col('.')>strlen(getline('.'))?"\<Lt>C-E>":"\<Lt>End>"
inoremap <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"

cnoremap <C-X><C-A> <C-A>
cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <C-E> <End>
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"

" Add columnwise 0 and $ mappings {{{1
" This one is really cool. These mappings motion columnwise until
" a non-character (eg. empty or shorter line) is encountered. It has
" special behavior for corner cases.
fun! s:Columnwise(d)
  let l = line('.')+a:d
  let c = len(getline('.'))
  let c = col('.')<c ? col('.') : (c>0 ? c : 1)
  while len(substitute(getline(l+a:d),'\s\+$','',''))>=c
    let l = l+a:d
  endw
  return abs(l-line('.'))
endf
noremap <expr> <leader>j <SID>Columnwise(1).'j'
noremap <expr> <leader>k <SID>Columnwise(-1).'k'

" Navigate/create tabpages with g<num> {{{1
fun! NavTabPage(num)
  while tabpagenr('$')<a:num
    tabnew
  endwhile
  exe 'tabnext '.a:num
endf
nnoremap <silent> g1 :call NavTabPage(1)<CR>
nnoremap <silent> g2 :call NavTabPage(2)<CR>
nnoremap <silent> g3 :call NavTabPage(3)<CR>
nnoremap <silent> g4 :call NavTabPage(4)<CR>
nnoremap <silent> g5 :call NavTabPage(5)<CR>
nnoremap <silent> g6 :call NavTabPage(6)<CR>
nnoremap <silent> g7 :call NavTabPage(7)<CR>

" Tabularize {{{1
nnoremap <Leader>t= :Tabularize /=>\?<CR>
xnoremap <Leader>t= :Tabularize /=>\?<CR>
nnoremap <Leader>t: :Tabularize /:<CR>
xnoremap <Leader>t: :Tabularize /:<CR>
nnoremap <Leader>t, :Tabularize /,<CR>
xnoremap <Leader>t, :Tabularize /,<CR>
nnoremap <Leader>t<Bar> :Tabularize /<Bar><CR>
xnoremap <Leader>t<Bar> :Tabularize /<Bar><CR>

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
nnoremap <silent> <F5> :call CompileAndRun()<cr>
nnoremap <silent> <F7> :call OpenPrompt()<cr>
nnoremap <silent> <S-F7> :cd %:h<cr>:call OpenPrompt()<cr>
nnoremap <silent> <F9> :call NERDTreeSmartToggle()<cr>
nnoremap <silent> <F10> :call ToggleQuickFix()<cr>
nnoremap <silent> <F12> :TagbarToggle<cr>
nnoremap <silent> <F3> :call ToggleModeless()<cr>
inoremap <silent> <F3> <C-O>:call ToggleModeless()<cr>

noremap <silent> <C-F9>  :vertical resize -10<cr>
noremap <silent> <C-F10> :resize +10<cr>
noremap <silent> <C-F11> :resize -10<cr>
noremap <silent> <C-F12> :vertical resize +10<cr>

" Window management {{{1
" Remaps Alt+x to <C-W>x (without overwriting previously defined mappings)
" Alt is somewhat unreliable, as it only works in the Vim GUI version,
" but I almost never use windows in the console version anyway.
for c in split('abcdefghijklmnopqrstuvwxyz!@#$%^&*()_-+<>=', '\zs')
  if maparg('<M-'.c.'>', 'n') ==# ''
    exe 'nmap <M-'.c.'> <C-W>'.c
  endif
endfor
nmap <M-Left> <C-W>h
nmap <M-Down> <C-W>j
nmap <M-Up> <C-W>k
nmap <M-Right> <C-W>l

" Various other mappings {{{1
imap <C-Space> <C-X><C-O>
nnoremap gG :call SearchWebMap(expand("<cword>"))<CR>
xnoremap gG :call SearchWeb(GetVisualLine())<CR>
nnoremap gK K
map <C-K> %
" gI: move to last change without going into insert mode like gi
nnoremap gI `.
" Reselect last pasted/edited text
nnoremap gV `[v`]
xnoremap gV <ESC>`[v`]
" Make CTRL-^ also go to the correct column of the alternate file
noremap <C-^> <C-^>`"
" Remove all trailing spaces
nnoremap <silent> <leader>S :retab<Bar>:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
command! -nargs=0 Wrap let w:wrapnu=&nu<Bar>setl wrap nolist nu
command! -nargs=0 NoWrap let &nu=w:wrapnu<Bar>setl nowrap list&

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
