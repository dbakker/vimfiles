if exists("loaded_<+FILE_NAME_ROOT+>") || &cp
  finish
endif

let g:loaded_<+FILE_NAME_ROOT+> = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

<+CURSOR+>

let &cpo = s:keepcpo
unlet s:keepcpo
