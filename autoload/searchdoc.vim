" Improve K functionality
" by Daan Bakker
"
" This plugin works similar to the way `keywordprg` is normally used, but:
"   * GUI Vim opens a split window with syntax colors.
"   * Extra support is added for certain languages.
"   * Instead of just the word `bar`, `foo.bar` is also tried for certain
"     languages.
"   * No window is opened if no documentation can be found
"
" Example mappings:
"   nnoremap <silent> K :<C-U>call searchdoc#cword()<CR>
"   xnoremap <silent> K :<C-U>call searchdoc#visual()<CR>

if exists('g:loaded_searchdoc')
  finish
endif
let g:loaded_searchdoc = 1

" searchdoc#ctext(): search documentation for text under cursor {{{1
fun! searchdoc#ctext()
  if exists('*b:searchdoc#ctext_buffer')
    let result = b:searchdoc#ctext_buffer()
  elseif exists('*searchdoc#ctext_'.&ft)
    let result = call('searchdoc#ctext_'.&ft, [])
  elseif &kp!~'man' && &ft!='vim'
    let result = {'kp': &kp}
  elseif (has('gui_running') && &ft!='vim')
    let d = system('man '.expand('<cword>'))
    if d=~'No manual entry for '
      let result = -1
    else
      let result = {'result': d}
    endif
  else
    normal! K
    return
  endif

  if type(result) == 0
    unlet result
    let result = searchdoc#ctext_ctags()
  endif

  if type(result) == 0
    echohl WarningMsg
    echo "Could not find documentation"
    echohl None
    return
  endif

  let result['string'] = get(result, 'string', expand('<cword>'))
  call s:display(result)
endf

" searchdoc#visual(): search documentation for selected text {{{1
" TODO: flesh this out more
fun! searchdoc#visual()
  if exists('*b:searchdoc#visual')
    let result = b:searchdoc#visual()
  elseif exists('*searchdoc#visual'.&ft)
    let result = call('searchdoc#visual'.&ft, [])
  elseif (has('gui_running') && &ft!='vim') || &kp!~'man'
    let result = {}
  else
    normal! gvK
    return
  endif

  if type(result) == 0
    echohl WarningMsg
    echo "Could not find documentation"
    echohl None
    return
  endif

  let result['string'] = get(result, 'string', strpart(getline("'<"), col("'<")-1, col("'>")-col("'<")+1))
  call s:display(result)
endf

" Utilities {{{1

fun! s:display(args)
  if has_key(a:args, 'result')
    let result = a:args['result']
  else
    let kp = get(a:args, 'kp', &kp)
    let result = system(kp.' '.a:args['string'])
  endif

  let curbuf = bufnr('')

  call s:closeold()

  new
  let b:searchdoc_window = 1
  setl buftype=nofile bufhidden=delete noswapfile nobuflisted

  let z = type(result) == 3 ? result : split(result, "\n", 1)
  while z[-1]=~'^\s*$'
    call remove(z, -1)
  endw
  call append(0, z)

  let &ft=get(a:args, 'ft', 'man')
  keepj normal! gg
  setl ro nolist

  if line('$')<winheight(0)
    sil! exe 'resize '.line('$')
  endif

  exe "normal! ".bufwinnr(curbuf)."\<C-W>w"
endf

fun! s:closeold()
  for wnr in range(1, winnr('$'))
    let buf = winbufnr(wnr)
    let bt = getbufvar(buf, '&bt')
    if getbufvar(buf, 'searchdoc_window') == 1 || bt=='help'
      exe "normal! ".wnr."\<C-W>w"
      bdelete
      return
    endif
  endfor
endf

fun! s:loadfile(tl_entry)
  let filename = a:tl_entry['filename']
  let cmd = a:tl_entry['cmd']
  let file = readfile(filename)
  if cmd=~'/\^.*\$/'
    let str = matchstr(cmd, '/\^\zs.*\ze\$/')
    return [file, index(file, str)]
  else
    echoerr 'Unknown cmd: '.cmd
  endif
endf

" Language specific code {{{1
" Python {{{2
if executable('pydoc')
  fun! searchdoc#ctext_python()
    let cw=expand('<cword>')
    let l = []

    " Find `from foo import bar`
    for line in getline(1, 20)
      let w = matchstr(line, 'from\s*\zs\S\+\ze\s*import.*\<'.cw.'\>')
      if len(w)>0
        let l += [w.'.'.cw]
        break
      endif
    endfor

    let l += s:ctext_list()

    for w in l
      let f = system('pydoc '.w)
      if f!~'no Python documentation'
        return {'result': f}
      endif
    endfor
    return -1
  endf
endif

fun! s:ctext_list()
  let e = match(getline('.'), '[^a-zA-Z0-9.]', col('.'))
  let l = e<0 ? getline('.') : substitute(strpart(getline('.'), 0, e), '[^a-zA-Z0-9_]*$', '', '')
  let m = substitute(l, '^\zs.\{-}\ze[a-zA-Z0-9.]\+$', '', '')

  if len(m)==0 || m == expand('<cword>')
    return [expand('<cword>')]
  else
    return [m, expand('<cword>')]
  endif
endf

" PHP {{{2
if executable('pman')
  " $ sudo apt-get install php-pear
  " $ pear install doc.php.net/pman
  fun! searchdoc#ctext_php()
    let cw = expand('<cword>')
    let f = system('pman '.cw)
    if f!~'No manual entry'
      return {'result': f}
    endif
  endf
endif

" Puppet {{{2
if executable('puppet')
  fun! searchdoc#ctext_puppet()
    return {'kp': 'puppet describe', 'ft': 'markdown'}
  endf
endif

" Ctags {{{2
" Tries to find comment blocks in tags files
fun! searchdoc#ctext_ctags()
  let cw = expand('<cword>')
  let tl = taglist('^'.cw.'$')
  let tl = filter(tl, 'v:val["name"]==#"'.cw.'"')

  if &ft=='php' && len(tl) > 1
    let tl = filter(tl, 'v:val["kind"]!="v"')
  endif

  if len(tl) == 0 || len(tl) > 1
    return -1
  endif

  let te = tl[0]

  let [lines, linenr] = s:loadfile(te)
  let start = linenr
  let end = linenr
  let result = []

  if &ft=='php' || &ft=='c' || &ft=='cpp' || &ft=='java'
    while start>0 && lines[start-1]=~'\v^\s*(\*|/)'
      let start -= 1
    endw
    exe 'let result = lines['.start.':'.end.']'
    if &ft=='php'
      return {'result': ['<?php // Source: '.te['filename'], ''] + result, 'ft': 'php'}
    endif
  elseif &ft=='python'
    if lines[end+1]=~'"""'
      let end += 3
      while end<line('$') && lines[end]!~'"""'
        let end += 1
      endw
    endif
  endif

  if len(result) == 0
    exe 'let result = lines['.start.':'.end.']'
  endif
  return {'result': result, 'ft': &ft}
endf
