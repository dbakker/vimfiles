" Sparkup
" Notes:
"    (romainl:2012.10.25) Added SparkupPrevious() and the corresponding mappings.
"    (dbakker:2013.5.29) Moved the plugin into autoload/
"    (dbakker:2013.5.29) Made <C-e> mapping jump to end-of-line instead of
"    invoking sparkup when not already at end-of-line. C-n and C-p now also
"    find single quotes.

function! sparkup#transform()
  if !exists('s:sparkup')
    let s:sparkup = exists('g:sparkup') ? g:sparkup : 'sparkup'
    let s:sparkupArgs = exists('g:sparkupArgs') ? g:sparkupArgs : '--no-last-newline'
    " check the user's path first. if not found then search relative to
    " sparkup.vim in the runtimepath.
    if !executable(s:sparkup)
      let paths = substitute(escape(&runtimepath, ' '), '\(,\|$\)', '/**\1', 'g')
      let s:sparkup = findfile('sparkup.py', paths)

      if !filereadable(s:sparkup)
        echohl WarningMsg
        echom 'Warning: could not find sparkup on your path or in your vim runtime path.'
        echohl None
        finish
      endif
    endif
    let s:sparkup = '"' . s:sparkup . '"'
    let s:sparkup .= printf(' %s --indent-spaces=%s', s:sparkupArgs, &shiftwidth)
    if has('win32') || has('win64')
      let s:sparkup = 'python ' . s:sparkup
    endif
  endif
  exec '.!' . s:sparkup
  call sparkup#next()
endfunction

function! sparkup#next()
  " 1: empty tag, 2,3: empty attribute, 4: empty line
  let n = search('><\/\|\(''''\)\|\(""\)\|^\s*$', 'Wp')
  if n == 4
    startinsert!
  elseif n > 0
    execute 'normal l'
    startinsert
  else
    echohl WarningMsg
    echo 'Sparkup: search hit BOTTOM'
    echohl None
  endif
endfunction

function! sparkup#prev()
  " 1: empty tag, 2,3: empty attribute, 4: empty line
  exe 'normal! '.(col('.')==1 ? 'k$' : 'h')
  let n = search('><\/\|\(''''\)\|\(""\)\|^\s*$', 'Wpb')
  if n == 4
    startinsert!
  elseif n > 0
    execute 'normal l'
    startinsert
  else
    echohl WarningMsg
    echo 'Sparkup: search hit TOP'
    echohl None
  endif
endfunction
