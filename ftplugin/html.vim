setlocal ai et sta sw=2 sts=2 ts=2

fun! b:CompileAndRun()
  if !exists('b:url')
    call OpenURL(expand('%:p'))
  else
    call OpenURL(b:url)
  endif
endf
