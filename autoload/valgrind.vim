" Valgrind plugin by dbakker
"
" This plugin uses Valgrinds output to fill the quickfix list. You can make
" Valgrind output its errors in XML format like this:
"
"    valgrind --xml=yes --xml-file=out.xml
"
" Then load them into Vim with:
"
"    gvim --remote-expr 'valgrind#loadxml("out.xml")'


if exists('g:loaded_valgrind')
  finish
endif
let g:loaded_valgrind = 1

if !has('python')
  echo "Error: Required vim compiled with +python"
  finish
endif

fun! s:parsexml(xmlfile) abort
  exe 'py valgrind_getqflist("'.expand(a:xmlfile).'")'
  let r = g:return
  unlet g:return
  return r
endf

fun! valgrind#loadxml(xmlfile) abort
  let qf = s:parsexml(a:xmlfile)
  if len(qf) != 0
    call setqflist(qf)
    echohl WarningMsg
    echo 'Loaded '.len(qf).' valgrind errors.'
    echohl None
  else
    echo 'No valgrind errors.'
  endif
  return 1
endf

python << EOF
import vim
import os.path
import xml.etree.ElementTree as ET  # The reason we use Python

def valgrind_getqflist(xmlfile):
  qflist = []
  tree = ET.parse(xmlfile)
  root = tree.getroot()
  for err in root.iter('error'):
      kind = err.find('kind').text

      if err.find('what') is not None:
          what = err.find('what').text
      else:
          try:
              what = err.find('xwhat').find('text').text
          except:
              what = kind

      if kind == 'Leak_DefinitelyLost':
          what = 'Definitely leaked %s bytes' % err.find('xwhat').find('leakedbytes').text

      fullfile = ''
      lnum = 1
      for frame in err.find('stack').iter('frame'):
          if frame.find('file') is not None:
              dir = frame.find('dir').text
              file = frame.find('file').text
              fullfile = os.path.join(dir, file)

              try:
                  lnum = int(frame.find('line').text)
              except:
                  continue
              break

      qfitem = {'filename': fullfile,
                'lnum': lnum,
                'text': what}
      qflist.append(qfitem)

  vim.command("let g:return="+str(qflist))
EOF
