" This file is sourced whenever a buffer is entered for the first time

" Add filetype specific tags from /.vim/local/tags/[filetype]
setl tags<
if len(&filetype)>0
  exe 'setl tags^=~/.vim/local/tags/'.&filetype
else
  setl tags+=~/.vim/local/tags/*
endif

" Allow commands such as gf to work relative to the projectroot
setl path<
if filereadable(expand('%')) && exists('*GuessProjectRoot')
  let prjroot=GuessProjectRoot()
  let prjroote=escape(prjroot, ' \')
  if isdirectory(prjroot.'/source')
    let prjroote.='/source'
  elseif isdirectory(prjroot.'/src')
    let prjroote.=.'/src'
  endif
  if isdirectory(prjroote)
    exe 'setl path=.,'.prjroote.','
  endif
endif

if ((&kp=~'help') || (&kp=~':man')) && &ft!='vim' && &ft!='man'
  exe 'nnoremap <buffer> <silent> K :OpenURL http://www.google.com/search?q=<cword>\%20'.&ft.'<CR>'
endif
