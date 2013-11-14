
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
nnoremap <silent> <leader>/ :nohlsearch<CR>
nnoremap <silent> <leader>\ :nohlsearch<CR>

" Buffer write/delete mappings {{{1
nnoremap <silent> <leader>wa :wa<cr>:redraw<cr>
nnoremap <silent> <leader>we :<C-U>call setloclist(0,[])<cr>:wa<cr>:Errors<cr>:lrewind<cr>:AdjustScroll<cr>
nnoremap <silent> <leader>wf :w!<cr>:redraw<cr>
nnoremap <silent> <leader>wj :w<cr>:redraw<cr>
nnoremap <silent> <leader>wq :w<cr>:BD<cr>
nnoremap <silent> <leader>wx :wa<cr>:bufdo BD<cr>
nnoremap <silent> <leader>qa :bufdo BD<cr>
nnoremap <silent> <leader>qf :BD!<cr>
nnoremap <silent> <leader>qj :BD<cr>
nnoremap <silent> <leader>qt :tabclose<cr>

" Create repeatable mappings similar to ci' and ca" for other symbols {{{1
fun! s:MapSymbolPair(c, m1, m2)
  for x in split("ycd", '\zs')
    for y in split("ia", '\zs')
      exe 'nnoremap <expr> '.x.y.a:c." ExecSymbolPair('".a:c.a:m1.a:m2.x.y."')"
    endfor
  endfor
endf

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
endf

for c in split('%@#$^!~/\+-=_*,.:;&f', '\zs')
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
    return ':e '.PrettyPath(a:dir).'/'
  endif
  return ':e '
endf
nnoremap <silent> <leader>df :<C-u>call CDMessage(fnamemodify(GuessMainFile(), ':h'))<cr>
nnoremap <expr> <leader>di EditFromDir(fnamemodify(GuessMainFile(), ':h'))
nnoremap <silent> <leader>dp :<C-u>call CDMessage(ProjectRootGuess(GuessMainFile()))<cr>
nnoremap <silent> <leader>du :<C-u>CDMessage ..<cr>
nnoremap <silent> <leader>de :<C-u>CDMessage .<cr>

" CtrlP mappings
nnoremap <silent> <leader>l :SwitchMain<cr>:Unite -start-insert -no-split line<cr>
nnoremap <silent> <leader>r :SwitchMain<cr>:Unite -start-insert -buffer-name=mru file_mru<cr>
nnoremap <silent> <leader>ef :SwitchMain<cr>:exe 'Unite -start-insert file_rec/async:'.ProjectRootGuess("'F")<cr>
nnoremap <silent> <leader>ep :SwitchMain<cr>:Unite -start-insert file_rec/async:!<cr>
nnoremap <silent> <leader>es :SwitchMain<cr>:Unite -no-split -buffer-name=outline -start-insert outline<cr>
nnoremap <silent> <leader>et :SwitchMain<cr>:CtrlPTag<cr>
nnoremap <silent> <leader>ev :SwitchMain<cr>:Unite -start-insert file_rec/async:~/.vim<cr>
nnoremap <silent> <leader>ew :SwitchMain<cr>:Unite -start-insert file_rec/async:~/vimwiki<cr>

nnoremap <silent> [q :cprev<cr>:AdjustScroll<cr>
nnoremap <silent> ]q :cnext<cr>:AdjustScroll<cr>
nnoremap <silent> [t :tprev<cr>
nnoremap <silent> ]t :tnext<cr>
nnoremap <silent> [l :lprev<cr>:AdjustScroll<cr>
nnoremap <silent> ]l :lnext<cr>:AdjustScroll<cr>
nnoremap <silent> [L :lfirst<cr>:AdjustScroll<cr>
nnoremap <silent> ]L :llast<cr>:AdjustScroll<cr>

" Increase/decrease font-size {{{1
command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)+1','g')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+','\=submatch(0)-1','g')
noremap <C-kPlus> :Bigger<CR>
noremap <C-kMinus> :Smaller<CR>

" Paste mappings {{{1
nmap <leader>p :<C-U>call mypaste#special('p')<CR>
xmap <leader>p :<C-U>call mypaste#special('p')<CR>
nmap <leader>P :<C-U>call mypaste#special('P')<CR>
xmap <leader>P :<C-U>call mypaste#special('P')<CR>
xnoremap <silent> P :<C-U>call mypaste#pasteblackhole()<cr>

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
  silent! call repeat#set(a:before ? '[ ' : '] ', cnt)
endf

nnoremap <silent> [<space> :<C-U>call <SID>AddLines(1)<CR>
nnoremap <silent> ]<space> :<C-U>call <SID>AddLines(0)<CR>

" Add maps for <C-V>$ and friends {{{1
" Using C, D and Y instead of c$, d$ and y$ is cool. I think v$ would also be
" useful. Unfortunately V is already taken, so I'll be bold and sacrifice C-K.

" The idea here is to try to always select from the current cursor position to
" the end of the line. Unless it is already like that in which case we exit
" visual mode.

nnoremap <expr> <C-K> (v:count>1 ? "\<ESC>\<C-V>".v:count : "\<C-V>")."$"
onoremap <C-K> $
xnoremap <expr> <C-K> mode(1)=="\<C-V>" && col('.')>=len(getline('.')) ? "\<C-V>" : "\<ESC>'<\<Home>".(col('.')-1)."l\<C-V>'>$"

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

" Tabularize {{{1
let s:tabularize_map = {':': ':\zs/l0r1'}
fun! s:Tabularize()
  let c = nr2char(getchar())
  return ":Tabularize /".get(s:tabularize_map, c, c)."\<CR>"
endf
noremap <expr> <leader>t <SID>Tabularize()
noremap <expr> <leader>t= ':Tabularize /^[^=]*\zs' . (getline('.')=~'=>' ? '=>' : '=\ze[^>]') . "\<CR>"
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
nnoremap <leader>gv :Gitv<cr>
nnoremap <leader>gw :Gwrite<cr>
xmap <leader>g <ESC><space>g

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
set pastetoggle=<F1>
noremap <silent> <expr> <F1> <SID>PasteToggle()
inoremap <silent> <expr> <F1> <SID>PasteToggle()

noremap <silent> <leader>oh :<C-U>call NERDTreeSmartToggle()<cr>
noremap <silent> <leader>oj :<C-U>call ToggleQuickFix()<cr>
noremap <silent> <leader>ok :<C-U>call ToggleFullscreen()<cr>
noremap <silent> <leader>ol :<C-U>TagbarToggle<cr>
noremap <silent> <leader>or :<C-U>call CompileAndRun()<cr>
noremap <silent> <leader>ot :<C-U>tabnew <C-R>=filereadable(expand('%')) ? '%':''<CR><CR>
noremap <silent> <leader>os :<C-U>SwitchMain<CR>:botright wincmd s<CR>
noremap <silent> <leader>oS :<C-U>SwitchMain<CR>:topleft wincmd s<CR>
noremap <silent> <leader>ov :<C-U>SwitchMain<CR>:botright wincmd v<CR>
noremap <silent> <leader>oV :<C-U>SwitchMain<CR>:topleft wincmd v<CR>

" Window management {{{1
" Remaps Alt+x to <C-W>x (without overwriting previously defined mappings)
" Alt is somewhat unreliable, as it only works in the Vim GUI version,
" but I almost never use windows in the console version anyway.
for c in split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+<>=', '\zs')
  if maparg('<M-'.c.'>', 'n') ==# ''
    exe 'nmap <M-'.c.'> <C-W>'.c
    exe 'xmap <M-'.c.'> <C-W>'.c
  endif
endfor
nmap <M-Left> <C-W>h
nmap <M-Down> <C-W>j
nmap <M-Up> <C-W>k
nmap <M-Right> <C-W>l
xmap <M-Left> <C-W>h
xmap <M-Down> <C-W>j
xmap <M-Up> <C-W>k
xmap <M-Right> <C-W>l

" Complete HTML tag (idea from ragtag) {{{1
" Uses the built-in tag completion to let <C-x>/ complete a tag
function! s:htmlEn()
  let b:cot=&cot
  let b:ofu=&ofu
  let b:isk=&isk
  setl cot=menu isk+=: omnifunc=htmlcomplete#CompleteTags
  let before=strpart(getline('.'), 0, col('.')-1)
  return before=~'<$' ? '/' : (before=~'</$' ? '' : '</')
endfunction
function! s:htmlDis()
  if exists('b:cot')
    let &cot=b:cot
    let &ofu=b:ofu
    let &isk=b:isk
    unlet b:cot b:ofu b:isk
  endif
  return ""
endfunction
inoremap <silent> <C-X>/ <C-R>=<SID>htmlEn()<CR><C-X><C-O><C-R>=<SID>htmlDis()<CR>

" Search fold {{{1
nmap <Leader>oz   <Plug>SearchFoldNormal
nmap <Leader>oZ   <Plug>SearchFoldRestore

" Various other mappings {{{1
xnoremap . :norm.<cr>
nnoremap _ "_
nnoremap <silent> gG :call SearchWebMap(expand("<cword>"))<CR>:redraw!<CR>
xnoremap <silent> gG :call SearchWeb(GetVisualLine())<CR>:redraw!<CR>
nnoremap <silent> K :<C-U>call searchdoc#ctext()<CR>
xnoremap <silent> K :<C-U>call searchdoc#visual()<CR>
nmap c* :<C-U>let @/='\<'.expand("<cword>").'\>'<cr>:set hls<cr>ciw
" gI: move to last change without going into insert mode like gi
nnoremap gI `.
nmap <leader>; :
nmap <leader>: :
" Reselect last pasted/edited text
nnoremap <expr> gs line("']")==line("'[") ? "`[v`]" : "'[V']"
xmap gs <ESC>gs
nnoremap gV :echoerr 'use gs!'<CR>
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
nnoremap z= :<C-U>setl spell<CR>z=
xmap <PageUp> <ESC><PageUp>
xmap <PageDown> <ESC><PageDown>
imap <PageUp> <ESC><PageUp>
imap <PageDown> <ESC><PageDown>
" Sometimes I use TMUX shortcuts
map <C-W>% <C-W>v
map <C-W>" <C-W>s
if has('gui_running')
  map <C-Z> <C-W>
endif
inoremap <C-X><C-K> <C-K>
noremap <silent> <leader>z :<C-U>call CloseExtraBuffers()<CR>
inoremap <expr> <C-X>! GetSheBang()
let g:unstack_mapkey="<space>oe"

" Tag jump {{{1
fun! TagJump()
  try
    let sc=&smartcase
    let ic=&ignorecase
    set noignorecase
    set nosmartcase
    exe 'tj '.expand('<cword>')
  finally
    let &smartcase=sc
    let &ignorecase=ic
  endtry
endf

nnoremap <C-]> :<C-u>call TagJump()<CR>

" File/text search {{{1
nnoremap <leader>aa :Holmes<space>

nmap <leader>am <Plug>(holmes-motion)
xmap <leader>am <Plug>(holmes-motion)
nmap <leader>aw <Plug>(holmes-inner-word)
xmap <leader>aw <Plug>(holmes-inner-word)
nnoremap <leader>as :Holmes<space>
nnoremap <leader>al :HolmesL<space>
nnoremap <leader>av :lv //g %<left><left><left><left>
