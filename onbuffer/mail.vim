setl ts=8 tw=76 et wrap nonu nornu

" Turn hard wrapping text off when inserting text in the header {{{1
fun! s:NoWrapHeader()
  for l in range(1, line('$'))
    if getline(l)=~'^\s*$'
      break
    endif
  endfor
  if line('.') < l
    let g:old_tw = &tw
    set tw=0
    aug resetWrap
      au!
      au InsertLeave,CursorMoved <buffer> let &tw=g:old_tw | au! resetWrap
    aug END
  endif
endf
aug noWrapHeader
  au!
  au InsertEnter <buffer> call <SID>NoWrapHeader()
aug END

" Status line {{{1
let g:subject = '[No subject]'
fun! s:UpdateSubject()
  for l in getline(1, line('$'))
    if l=~'^\s*$'
      break
    endif

    " Try to find the subject
    let m=matchstr(l, '^Subject:\zs .*$')
    if len(m)==1
      let g:subject = '[No subject]'
    elseif len(m)>2
      let g:subject = m[1:]
    endif
    let m=matchstr(l, '^Subject:\zs .*$')
  endfor
endf
aug updateSubject
  au!
  au InsertLeave,ShellFilterPost,FilterReadPost <buffer> call <SID>UpdateSubject()
aug END
call s:UpdateSubject()

setl statusline=%{g:subject}%m%{&paste?'[PASTE]':''}\ %=\ %l
