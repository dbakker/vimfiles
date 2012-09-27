" Set a vertical ruler for the preferred 80 chars limit
setlocal cc=80

fun b:CompileAndRun()
    exe '!python2 %'
endfunction
