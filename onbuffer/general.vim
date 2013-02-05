" This file is sourced whenever a buffer is entered for the first time

" Add filetype specific tags from /.vim/local/tags/[filetype]
setl tags<
if len(&filetype)>0
  exe 'setl tags^=~/.vim/local/tags/'.&filetype
else
  setl tags+=~/.vim/local/tags/*
endif
