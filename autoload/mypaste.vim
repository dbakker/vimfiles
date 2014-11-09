" Personalized pasting plugin
"
" Inspired by https://github.com/AndrewRadev/whitespaste.vim, check that one
" out it's pretty cool.

if exists('g:loaded_mypaste')
  finish
endif
let g:loaded_mypaste = 1

if !exists('g:max_empty_lines')
  let g:max_empty_lines = {'python': 2}
endif
if !exists('g:reindent_langs')
  let g:reindent_langs = {'vim': 1, 'c': 1, 'cpp': 1, 'javascript': 1}
endif

fun! mypaste#normal(command, register)
  let contents = getreg(a:register)
  let r = '"'.a:register.a:command
  if getregtype()!~"\<C-V>" && contents=~"\n" && v:count1 == 1
    call s:normal_linewise(line('.') - (a:command ==# 'P'), contents)
  else
    exe 'normal! '.v:count1.'"'.a:register.a:command
  endif
  sil! call repeat#set(r, v:count1)
endf

fun! mypaste#special(command, register)
  try
    let reg_type = getregtype(a:register)
    let reg_content = getreg(a:register)
    call setreg(a:register, '', 'al')
    exe 'normal "'.a:register.a:command
  finally
    call setreg(a:register, reg_content, reg_type)
  endtry
endf

fun! s:normal_linewise(start, contents)
  let temp=a:contents
  if strpart(temp, len(temp)-1)=="\n"
    let temp=strpart(temp, 0, len(temp)-1)
  endif
  let out=split(temp, '\n', 1)

  let s:tab=repeat(' ', &ts)
  if len(s:tab)==0
    echoerr 'tabstop is necessary to use mypaste'
    return
  endif

  " Remove trailing spaces
  call map(out, 'substitute(v:val,''\s\+$'','''','''')')
  " Convert tabs to spaces (always, even with `et`)
  call map(out, 'substitute(v:val,''\t'','''.s:tab.''',''g'')')

  call s:trim_empty_lines(a:start, out)

  " Convert spaces to tabs if necessary
  if &et == 0
    call map(out, 'substitute(v:val,'''.s:tab.''',"\t",''g'')')
  endif

  " Write the lines to the buffer
  let a=@"
  try
    let @"=join(out,"\n")."\n"
    exe 'normal! :'.a:start."\<CR>".(a:start>0?'p':'P')
  finally
    let @"=a
  endtry

  " Reindent the pasted code
  if get(g:reindent_langs, &ft, 0) != 0
    exe 'normal! :'.(a:start+1)."\<CR>=:".(a:start+len(out))."\<CR>"
  endif
endf

fun! s:trim_empty_lines(start, lines)
  " Trim empty lines from the start and the back if there are too many
  " TODO: find a shorter way to do this...
  let out=a:lines
  let max_empty_lines = get(g:max_empty_lines, &ft, 1)

  let infront = 0
  for i in range(a:start, 1, -1)
    if len(getline(i))!=0
      break
    endif
    let infront += 1
  endfor

  let inpaste = 0
  while len(out)>0 && len(out[0])==0
    call remove(out, 0)
    let inpaste += 1
  endw

  for i in range(max([0,min([max_empty_lines-infront, inpaste])]))
    call insert(out, '')
  endfor

  let atend = 0
  for i in range(a:start+1, line('$'))
    if len(getline(i))!=0
      break
    endif
    let atend += 1
  endfor

  let inpaste = 0
  while len(out)>0 && len(out[-1])==0
    call remove(out, -1)
    let inpaste += 1
  endw

  endfor
endf

" Visual paste without overwriting any register {{{1
" Only works for the default register
fun! mypaste#pasteblackhole()
  let r = 'v'.(col("'>")-col("'<")).'l'
  let d = line("'>")-line("'<")
  normal! gv"_d
  if visualmode()==#'V'
    call mypaste#special('P', '"')
  else
    normal! P
  endif

  if line("'<") == line("'>") && visualmode()==#'v'
    sil! call repeat#set(r.'P', 0)
  elseif visualmode()==#'V'
    if d == 0
      sil! call repeat#set('VP', 0)
    else
      sil! call repeat#set('V'.d.'P', 0)
    endif
  else
    sil! call repeat#set('p', 0)
  endif
endf
