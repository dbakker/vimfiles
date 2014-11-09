" Make sure for python we always use the recommended indenting
setl et ts=4 sw=4 cc=80

" Automatically put `pass` after def: if: else: etc. statements and select
" them with select mode. This means its easy to just keep typing but you can
" also escape and fill the statement in later.
fun! AutoPythonPlacehold()
  let l = substitute(getline('.'), '\s*#.*$', '', 'g')
  if l !~ '.*:$' || l=~'class' || col('.')<len(getline('.'))
    return "\<CR>"
  endif

  let ind = matchstr(l, '^\s*')
  for i in range(line('.')+1, line('$'))
    let m = substitute(getline(i), '#.*$', '', 'g')
    if m=~'^\s*$'
        continue
    endif
    let n = matchstr(m, '^\s*')
    if len(n)<=len(ind)
        return "\<CR>pass\<ESC>v^\<C-G>"
    endif
  endfor

  return "\<CR>"
endf

inoremap <buffer> <expr> <CR> AutoPythonPlacehold()
snoremap <buffer> <CR> <ESC>o
