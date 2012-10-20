if &ft!='vim' && &ft!='man'
  exe 'nnoremap <buffer> <silent> K :OpenURL http://www.google.com/search?q=<cword>\%20'.&ft.'<CR>'
endif
