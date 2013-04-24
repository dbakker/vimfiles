" Include compilation options from Makefiles to get exactly the same errors
let s:makefile = ProjectRootGuess().'/Makefile'
if filereadable(s:makefile)
  for l in readfile(s:makefile)
    let z = matchstr(l, 'CFLAGS\s*=\s*\zs.*')
    if len(z)
      let b:syntastic_c_cflags=z
      break
    endif
  endfor
endif
