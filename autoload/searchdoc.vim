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

  new
  setl buftype=nofile bufhidden=delete noswapfile nobuflisted
  let z = split(result, "\n", 1)
  call append(0, z)

  let &ft=get(a:args, 'ft', 'man')
  keepj normal! gg
  setl ro
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
    return -1
  endf
endif

" Puppet {{{2
if executable('puppet')
  fun! searchdoc#ctext_puppet()
    return {'kp': 'puppet describe', 'ft': 'markdown'}
  endf
endif
