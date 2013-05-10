
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
nnoremap <silent> <leader>we :<C-U>wa<cr>:call setloclist(0,[])<cr>:w<cr>:Errors<cr>:lrewind<cr>:ResetScroll<cr>
nnoremap <silent> <leader>wf :w!<cr>:redraw<cr>
nnoremap <silent> <leader>wj :w<cr>:redraw<cr>
nnoremap <silent> <leader>wq :w<cr>:BD<cr>
nnoremap <silent> <leader>wx :wa<cr>:bufdo BD<cr>
nnoremap <silent> <leader>qa :bufdo BD<cr>
nnoremap <silent> <leader>qf :BD!<cr>
nnoremap <silent> <leader>qj :BD<cr>

" Create repeatable mappings similar to ci' and ca" for other symbols {{{1
fun! s:MapSymbolPair(c, m1, m2)
  for x in split("ycd", '\zs')
    for y in split("ia", '\zs')
      exe 'nnoremap <expr> '.x.y.a:c." ExecSymbolPair('".a:c.a:m1.a:m2.x.y."')"
    endfor
  endfor
endfun

fun! ExecSymbolPair(packed)
  let [c, m1, m2, x, y] = split(a:packed, '\zs')
  let d=''
  if c=='f' " Add a special case for 'if' and 'af'
    let [m1, m2] = [nr2char(getchar()), nr2char(getchar())]
    let d=m1.m2
  endif
  let l = getline('.')
  let inside = y=='i'
  let first_m1 = stridx(strpart(l,0,strridx(l, m2)), m1)
  let last_m1 = strridx(strpart(l,0,strridx(l, m2)), m1)
  if first_m1 == -1 || stridx(l, m2, first_m1+1)==-1
    return "\<ESC>"
  endif
  let cc = col('.')-1
  let r = ''
  if cc<=first_m1
    let r.=(cc<first_m1) ? 'f'.m1 : ''
    let cc=first_m1
  elseif cc>last_m1
    let r.=cc>strridx(l, m2) ? 'F'.m2 : ''
    let r.='F'.m1
    let cc=last_m1
  else
    let r.='F'.m1
    let cc=strridx(strpart(l,0,strridx(l, m2, cc)), m1)
  endif

  let hit_m2 = stridx(l, m2, cc+1)
  if y=='a'
    let r.= x.'f'.m2
  elseif cc+1 == hit_m2
    if x=='c'
      let r.= 'a'
    endif
  else
    let r.='l'.x.'t'.m2
  endif

  let s:w = x.y.c.d
  if x=='c'
    aug repeatChange
      au InsertLeave * silent! call repeat#set(s:w.@.."\<ESC>")
      au InsertLeave * au! repeatChange
    aug END
    return r
  else
    return r.':sil! call repeat#set("'.s:w."\")\<CR>:\<CR>"
  endif
endfun

for c in split('/\+-=_*,.:;&f', '\zs')
  call s:MapSymbolPair(c, c, c)
endfor
call s:MapSymbolPair("<tab>","\<tab>","\<tab>")
call s:MapSymbolPair(">","<",">")

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
nnoremap <leader>dc :cd<space>
nnoremap <silent> <leader>df :exe 'cd' fnamemodify(GuessMainFile(), ':h')<cr>
nnoremap <expr> <leader>di EditFromDir(fnamemodify(GuessMainFile(), ':h'))
nnoremap <silent> <leader>dp :exe 'ProjectRootCD' GuessMainFile()<cr>
nnoremap <silent> <leader>du :cd ..<cr>

" CtrlP mappings
nnoremap <silent> <leader>l :SwitchMain<cr>:CtrlPLine<cr>
nnoremap <silent> <leader>r :SwitchMain<cr>:CtrlPMRU<cr>
nnoremap <silent> <leader>ea :SwitchMain<cr>:CtrlPMixed<cr>
nnoremap <silent> <leader>eb :SwitchMain<cr>:CtrlPBuffer<cr>
nnoremap <silent> <leader>ed :SwitchMain<cr>:CtrlPCurWD<cr>
nnoremap <silent> <leader>ef :SwitchMain<cr>:exe 'CtrlP' ProjectRootGuess("'F")<cr>
nnoremap <silent> <leader>ep :SwitchMain<cr>:exe 'CtrlP' ProjectRootGuess()<cr>
nnoremap <silent> <leader>es :SwitchMain<cr>:CtrlPBufTag<cr>
nnoremap <silent> <leader>et :SwitchMain<cr>:CtrlPTag<cr>
nnoremap <silent> <leader>ev :SwitchMain<cr>:CtrlP ~/.vim<cr>

nnoremap <silent> [b :SwitchMain<cr>:exe 'b' GetNextBuffer(-1)<cr>
nnoremap <silent> ]b :SwitchMain<cr>:exe 'b' GetNextBuffer(1)<cr>
nnoremap <silent> [o :SwitchMain<cr>:exe 'e' GetNextFileInDir(-1)<cr>
nnoremap <silent> ]o :SwitchMain<cr>:exe 'e' GetNextFileInDir(1)<cr>
nnoremap <silent> [p :SwitchMain<cr>:ProjectBufPrev<cr>
nnoremap <silent> ]p :SwitchMain<cr>:ProjectBufNext<cr>
nnoremap <silent> [f :SwitchMain<cr>:ProjectBufPrev 'F<cr>
nnoremap <silent> ]f :SwitchMain<cr>:ProjectBufNext 'F<cr>
nnoremap <silent> [q :cprev<cr>:ResetScroll<cr>
nnoremap <silent> ]q :cnext<cr>:ResetScroll<cr>
nnoremap <silent> [t :tprev<cr>
nnoremap <silent> ]t :tnext<cr>
nnoremap <silent> [l :lprev<cr>:ResetScroll<cr>
nnoremap <silent> ]l :lnext<cr>:ResetScroll<cr>
nnoremap <silent> [L :lfirst<cr>:ResetScroll<cr>
nnoremap <silent> ]L :llast<cr>:ResetScroll<cr>
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
map <expr> <MiddleMouse> <SID>FixedPaste('p')
" Paste+visually select what was just pasted
nmap <leader>vp "+pgV
nmap <leader>vP "+PgV
xmap <leader>vp "+pgV
xmap <leader>vP "+PgV

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

" Add []<space> mappings for adding empty lines {{{1
fun! s:AddLines(before)
  let cnt = (v:count>0) ? v:count : 1
  call append(line('.')-a:before, repeat([''], cnt))
  silent! call repeat#set((a:before ? '[ ' : '] '), cnt)
endf

nnoremap <silent> [<space> :<C-U>call <SID>AddLines(1)<CR>
nnoremap <silent> ]<space> :<C-U>call <SID>AddLines(0)<CR>

" Add [e and ]e mappings (from vim-unimpaired) {{{1
function! s:Move(cmd, count, map) abort
  normal! m`
  exe 'move'.a:cmd.a:count
  norm! ``
  silent! call repeat#set("\<Plug>unimpairedMove".a:map, a:count)
endfunction

nnoremap <silent> <Plug>unimpairedMoveUp   :<C-U>call <SID>Move('--',v:count1,'Up')<CR>
nnoremap <silent> <Plug>unimpairedMoveDown :<C-U>call <SID>Move('+',v:count1,'Down')<CR>
xnoremap <silent> <Plug>unimpairedMoveUp   :<C-U>exe 'exe "normal! m`"<Bar>''<,''>move--'.v:count1<CR>``
xnoremap <silent> <Plug>unimpairedMoveDown :<C-U>exe 'exe "normal! m`"<Bar>''<,''>move''>+'.v:count1<CR>``

nmap [e <Plug>unimpairedMoveUp
nmap ]e <Plug>unimpairedMoveDown
xmap [e <Plug>unimpairedMoveUp
xmap ]e <Plug>unimpairedMoveDown

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
onoremap K $
xnoremap <expr> K mode(1)=="\<C-V>" && col('.')>=len(getline('.')) ? "\<C-V>" : "\<ESC>'<\<Home>".(col('.')-1)."l\<C-V>'>$"

" Use ':R foo' to run foo and capture its output in a scratch buffer {{{1
" You can also just do ':R' to get an empty scratch buffer
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
" an empty line is encountered.
fun! s:Columnwise(d)
  let l = line('.')+a:d
  while getline(l)=~'^\s*$' && (l>=0) && (l<=line('$'))
    let l = l+a:d
  endw
  while !(getline(l)=~'^\s*$') && (l>=0) && (l<=line('$'))
    let l = l+a:d
  endw
  return max([1, abs(l-line('.'))-1])
endf
noremap <expr> <leader>j <SID>Columnwise(1).'j'
noremap <expr> <leader>k <SID>Columnwise(-1).'k'

" Navigate/create tabpages with g<num> {{{1
fun! NavTabPage(num)
  while tabpagenr('$')<a:num
    tabnew
  endwhile
  exe 'tabnext' a:num
endf
nnoremap <silent> g1 :call NavTabPage(1)<CR>
nnoremap <silent> g2 :call NavTabPage(2)<CR>
nnoremap <silent> g3 :call NavTabPage(3)<CR>
nnoremap <silent> g4 :call NavTabPage(4)<CR>
nnoremap <silent> g5 :call NavTabPage(5)<CR>
nnoremap <silent> g6 :call NavTabPage(6)<CR>
nnoremap <silent> g7 :call NavTabPage(7)<CR>

" Tabularize {{{1
let s:tabularize_map = {'=': '^[^=]*\zs=>\?', ':': ':\zs/l0r1'}
fun! s:Tabularize()
  let c = nr2char(getchar())
  return ":Tabularize /".get(s:tabularize_map, c, c)."\<CR>"
endf
noremap <expr> <leader>t <SID>Tabularize()
sunmap <leader>t

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
for i in range(1,12)
  let c='<F'.i.'>'
  if maparg(c, 'i') ==# ''
    exe 'imap '.c.' <ESC>'.c
  endif
endfor
fun! s:PasteToggle()
  aug pasteToggle
    au!
    au InsertLeave * set nopaste | au! pasteToggle
  aug END
  set paste
  if mode() != 'i'
    return ":\<C-U>startinsert\<CR>"
  endif
  return ''
endf
noremap <F1> <Nop>
noremap <silent> <expr> <F2> <SID>PasteToggle()
inoremap <silent> <expr> <F2> <SID>PasteToggle()
set pastetoggle=<F2>
noremap <silent> <F3> :<C-U>call ToggleModeless()<cr>
noremap <F4> :<C-U>set invlist list?<cr>
noremap <silent> <F5> :<C-U>call CompileAndRun()<cr>
noremap <silent> <F7> :<C-U>call OpenPrompt()<cr>
noremap <silent> <S-F7> :<C-U>cd %:h<cr>:call OpenPrompt()<cr>
noremap <silent> <F9> :<C-U>call NERDTreeSmartToggle()<cr>
noremap <silent> <F10> :<C-U>call ToggleQuickFix()<cr>
noremap <silent> <F11> :<C-U>call ToggleFullscreen()<cr>
noremap <silent> <F12> :<C-U>TagbarToggle<cr>

noremap <silent> <C-F9>  :vertical resize -10<cr>
noremap <silent> <C-F10> :resize +10<cr>
noremap <silent> <C-F11> :resize -10<cr>
noremap <silent> <C-F12> :vertical resize +10<cr>

" Window management {{{1
" Remaps Alt+x to <C-W>x (without overwriting previously defined mappings)
" Alt is somewhat unreliable, as it only works in the Vim GUI version,
" but I almost never use windows in the console version anyway.
for c in split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+<>=', '\zs')
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
imap <C-R><space> <+.+>
nmap c* :<C-U>let @/='\<'.expand("<cword>").'\>'<cr>:set hls<cr>ciw
for i in split('n N * # zr zm <C-O> <C-I> <C-W>o <C-U> <C-D>')
  exe 'nnoremap '.i.' '.i.':ResetScroll<cr>'
endfor
" gI: move to last change without going into insert mode like gi
nnoremap gI `.
" Reselect last pasted/edited text
nnoremap <expr> gV line("']")==line("'[") ? "`[v`]" : "'[V']"
xmap gV <ESC>gV
" Make CTRL-^ also go to the correct column of the alternate file
noremap <C-^> <C-^>`"
" Add an extra undo point after using <C-U>
inoremap <C-U> <C-G>u<C-U>
" Remove all trailing spaces
nnoremap <silent> <leader>S :let g:pos=getpos('.')<Bar>:retab<Bar>:let _s=@/<Bar>:keepjumps %s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<Bar>:call setpos('.',g:pos)<CR>
command! -nargs=0 Wrap let w:wrapnu=&nu<Bar>setl wrap nolist nu
command! -nargs=0 NoWrap let &nu=w:wrapnu<Bar>setl nowrap list&
" Typos
nmap dD D
nmap cC C
nmap yY Y
nnoremap z<CR> :<C-U>echoerr "BOO: Use zt"<CR>
nnoremap z- :<C-U>echoerr "BOO: Use zb"<CR>
nnoremap z. :<C-U>echoerr "BOO: You're thinking of zb (or zz)"<CR>

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
