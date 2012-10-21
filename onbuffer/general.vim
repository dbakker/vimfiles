" This file is sourced whenever a buffer is entered for the first time

" Copy default tags to local tags
setl tags<
" Add filetype specific tags from /.vim/local/tags/[filetype]
exe 'setl tags^=~/.vim/local/tags/'.&filetype

if ((&kp=~'help') || (&kp=~':man')) && &ft!='vim' && &ft!='man'
  exe 'nnoremap <buffer> <silent> K :OpenURL http://www.google.com/search?q=<cword>\%20'.&ft.'<CR>'
endif
