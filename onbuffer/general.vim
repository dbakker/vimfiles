" This file is sourced whenever a buffer is entered for the first time

" Add filetype specific tags from /.vim/local/tags/[filetype]
setl tags<
if len(&filetype)>0
  exe 'setl tags^=~/.vim/local/tags/'.&filetype
else
  setl tags+=~/.vim/local/tags/*
endif

if ((&kp=~'help') || (&kp=~':man')) && &ft!='vim' && &ft!='man'
  exe 'nnoremap <buffer> <silent> K :OpenURL http://www.google.com/search?q=<cword>\%20'.&ft.'<CR>'
endif
