au InsertLeave <buffer> call UpdateUnderlines()

fun! s:searchmethod(dir)
  if search('\v^(\=+|\-+|\*+)$', 'sW'.(a:dir ? 'b' : '')) == 0
    echohl warningmsg
    echo (a:dir?'Top' : 'Bottom') . ' reached'
    echohl none
  else
    norm k
  endif
endf

nnoremap <silent> <buffer> [m :<C-U>call <SID>searchmethod(1)<cr>
nnoremap <silent> <buffer> ]m j:<C-U>call <SID>searchmethod(0)<cr>

setl formatoptions+=tnro
setl formatoptions-=cq
Wrap
set nonu
