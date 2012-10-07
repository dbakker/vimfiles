
if exists("loaded_globalfunctions")
  finish
endif
let loaded_globalfunctions = 1

" Global functions
" These are functions that are useful for custom scripts
" Note: remember that functions can be placed *inside* if statements

" FindVar(varname[, default]) {{{2
fun! FindVar(varname, ...)
  if exists('b:'.a:varname)
    return b:{a:varname}
  elseif exists('g:'.a:varname)
    return g:{a:varname}
  elseif a:0 == 1
    return a:1
  endif
  throw 'variable '.a:varname.' not found'
endf

" ExtendDictVar(varname[, default]) {{{2
fun! ExtendDictVar(dictname, ...)
  let result = {}
  if a:0 == 1
    call extend(result, a:1)
  endif
  if exists('g:'.a:dictname)
    call extend(result, g:{a:dictname})
  endif
  if exists('b:'.a:dictname)
    call extend(result, b:{a:dictname})
  endif
  return result
endf

" FindInDict(key, dictname[, default]) {{{2
fun! FindInDict(key, dictname, ...)
  if exists('b:'.a:dictname) && has_key(b:{a:dictname}, a:key)
    return b:{a:dictname}[a:key]
  elseif exists('g:'.a:dictname) && has_key(g:{a:dictname}, a:key)
    return g:{a:dictname}[a:key]
  elseif a:0 == 1
    return a:1
  endif
  throw 'cant find '.a:key
endf

" GuessProjectRoot(file): returns the project root or the current dir of the file {{{2
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

" SpawnWith(out)Shell(command, params) {{{2
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

" OpenURL(url) {{{2
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

" FindProgram(name): returns the path to a program {{{2
let programpathdict = {}

" TODO: instead make bat files like
" @"C:\Program Files (x86)\Mozilla Firefox\firefox.exe" %*
fun! FindProgram(p)
  if(exists('*b:FindProgram'))
    let result=b:FindProgram(a:p)
    if(executable(result))
      return result
    endif
  endif

  if exists('$PROGRAMFILES')
    let f=findfile(a:p.'exe', $PROGRAMFILES)
    if executable(f)
      return f
    endif
  endif

  return FindInDict(a:p, 'programpathdict', a:p)
endf

" RunFile(file): Run a file with its default handler {{{2
fun! RunFile(file)
  if !filereadable(a:file)
    throw 'file '.a:file.' does not exist'
  endif
  if has('unix')
    if executable('xdg-open')
      call SpawnWithoutShell('xdg-open', a:file)
    else
      throw 'couldnt find any way to run an arbitrary file'
    endif
  elseif has('win32')
    call SpawnWithoutShell(a:file, '')
  endif
endf

" CompileAndRun() {{{2
fun! CompileAndRun()
  if &modified
    wa
  endif
  if exists('*b:CompileAndRun')
    call b:CompileAndRun()
  else
    call RunFile(expand('%:p'))
  endif
endf
