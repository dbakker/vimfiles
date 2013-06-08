if exists("<+call:VimLoadedGuard()+>") || &cp
  finish
endif

let g:<+call:VimLoadedGuard()+> = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

<+CURSOR+>

let &cpo = s:keepcpo
unlet s:keepcpo
