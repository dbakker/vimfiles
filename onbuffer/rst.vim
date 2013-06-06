au InsertLeave <buffer> call UpdateUnderlines()

fun! s:searchmethod(dir)
  if search('\v^(\=+|\-+|\*+)$', 'sW'.(a:dir ? 'b' : '')) == 0
    echohl warningmsg
    echo (a:dir?'Top' : 'Bottom') . ' reached'
    echohl none
  endif
endf

nnoremap <buffer> [m :<C-U>call <SID>searchmethod(1)<cr>
nnoremap <buffer> ]m :<C-U>call <SID>searchmethod(0)<cr>
