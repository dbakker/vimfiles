" Set a vertical ruler for the preferred 80 chars limit
setlocal cc=80

fun! b:CompileAndRun()
  if getline(1) =~ '#!/usr/bin/env'
    exe '!'.strpart(getline(1), 15).' %'
  else
    exe '!python %'
  endif
endf
