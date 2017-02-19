if exists('g:loaded_shmdir')
  finish
endif
" Get access to an as secure as possible temporary directory that is
" persistant throughout Vim restarts but gets deleted on reboot. Prefers
" direct in-memory storage, so perfect for small files with lots of writes
" and reads but bad for super large files.

let g:loaded_shmdir = 1

" Create temporary directory for vim to use
let s:lastboot = ""
if filereadable(g:localdir."/lastboot.txt")
  let s:lastboot = readfile(g:localdir."/lastboot.txt")[0]
endif
let s:curboot = system("who -b")

if s:lastboot != s:curboot
  let s:shmdir = system("python -c 'import tempfile,os.path;print(tempfile.mkdtemp(dir=\"/dev/shm\" if os.path.isdir(\"/dev/shm\") else None))'")
  call writefile([s:shmdir], g:localdir."/shmdir.txt")
  call writefile([s:curboot], g:localdir."/lastboot.txt")
else
  let s:shmdir = readfile(g:localdir."/shmdir.txt")[0]
endif

unlet s:lastboot
unlet s:curboot

function! shmdir#get()
  return s:shmdir
endfunction
