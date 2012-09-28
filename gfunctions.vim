
if exists("loaded_globalfunctions")
  finish
endif
let loaded_globalfunctions = 1

" Global functions {{{1
" These are functions that are useful for custom scripts
" Note: remember that functions can be placed *inside* if statements

" GuessProjectRoot; returns the project root or the current dir of the file {{{2
let projectrootmarkers = ['.git', '.hg', '.svn', '.bzr', '_darcs', 'build.xml']
fun! GuessProjectRoot(file)
  let fullfile=fnamemodify(expand(a:file), ':p')
  for marker in g:projectrootmarkers
    let result=''
    let pivot=fullfile
    while pivot!=fnamemodify(pivot, ':h')
      let pivot=fnamemodify(pivot, ':h')
      if len(glob(pivot.'/'.marker))
        let result=pivot
      endif
    endwhile
    if len(result)
      return result
    endif
  endfor
  if filereadable(fullfile)
    return fnamemodify(fullfile, ':h')
  else
    return fullfile
  endif
endf

" SpawnWith(out)Shell {{{2
" Starts a command asynchronously
if has('unix')
  if executable('urxvt')
    fun! SpawnWithShell(command, params)
      silent! exe 'silent !urxvt -e '.a:command.' '.a:params.' &'
    endf
  elseif executable('xterm')
    fun! SpawnWithShell(command, params)
      silent! exe 'silent !xterm -e '.a:command.' '.a:params.' &'
    endf
  endif

  fun! SpawnWithoutShell(command, params)
    silent exe '! ('.a:command.' '.a:params.' &> /dev/null ) &'
  endf
elseif has('win32')
  fun! SpawnWithShell(command, params)
    silent exe '!start cmd /c ""'.a:command.'" "'.a:params.'""'
  endf
  fun! SpawnWithoutShell(command, params)
    silent exec '!start /min cmd /c ""'.a:command.'" "'.a:params.'"">NUL'
  endf
endif

" OpenURL {{{2
fun! OpenURL(url)
  if exists('browser') && executable(browser)
    call SpawnWithoutShell(browser, a:url)
  elseif executable('chromium')
    call SpawnWithoutShell('chromium', a:url)
  elseif executable('firefox')
    call SpawnWithoutShell('firefox', a:url)
  elseif executable('chrome')
    call SpawnWithoutShell('chrome', a:url)
  elseif executable('explorer')
    call SpawnWithoutShell('explorer', a:url)
  else
    throw 'No browser could be found'
  endif
endf

" RunFile {{{2
fun! RunFile(file)
  if !filereadable(a:file)
    throw 'file '.a:file.' does not exist'
  endif
  if has('unix')
    if executable('xdg-open')
      call SpawnWithoutShell('xdg-open', a:file)
    endif
  elseif has('win32')
    call SpawnWithoutShell(a:file, '')
  endif
endf
