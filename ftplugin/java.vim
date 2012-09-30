setl foldenable foldmethod=syntax foldlevel=1 foldnestmax=2
setl cms="// %s" cin

let s:projectRoot = GuessProjectRoot("%")
if(filereadable(s:projectRoot.'/build.xml'))
  exe 'setl makeprg=ant\ -f\ '.s:projectRoot.'/build.xml'
else
  setl makeprg=ant\ -find\ 'build.xml'
endif
setl efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#

fun! b:GetJavaPackage()
  let packline = search('\s*package\s', 'nw')
  if packline==0
    return packline
  endif
  let packstr = getline(packline)
  let sub = substitute(packstr, '\v;[^;]*$', '', '')
  let sub = substitute(sub, '\v^[^\s]+\s', '', '')
  return sub
endfunction

fun! b:CompileAndRunSingle()
  let package=b:GetJavaPackage()
  let classdir=glob('%:p:h')
  let fullclass=expand('%:t:r')
  " TODO: use package to guess classdir and fullclass better
  exe '!javac -d '.shellescape(classdir).' '.shellescape(glob('%:p')).' && java -cp '.shellescape(classdir).' '.fullclass
endfunction

fun! b:CompileAndRun()
  let projectRoot = GuessProjectRoot("%")
  if(filereadable(projectRoot.'/build.xml'))
    exe '!ant -f '.projectRoot.'/build.xml'
  else
    call b:CompileAndRunSingle()
  endif
endfunction
