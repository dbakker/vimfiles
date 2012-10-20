
if exists("loaded_gfunctions")
  finish
endif
let loaded_gfunctions = 1

" Global variables/autocmds {{{1

" Global functions {{{1
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
let projectrootmarkers = ['.projectroot', '.git', '.hg', '.svn', '.bzr', '_darcs', 'build.xml']
fun! GuessProjectRoot(file)
  let fullfile=fnamemodify(expand(a:file), ':p')
  if exists('b:projectroot')
    if stridx(fullfile, fnamemodify(b:projectroot, ':p'))==0
      return b:projectroot
    endif
  endif
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

" OpenURL(url) {{{2
function! OpenURL(url) " (tpope)
  if has("win32")
    exe '!start cmd /cstart /b '.a:url
  elseif $DISPLAY !~ '^\w'
    exe 'silent !sensible-browser "'.a:url.'"'
  else
    exe 'silent !sensible-browser -T "'.a:url.'"'
  endif
  redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)

" CompileAndRun() {{{2
let cnr_scriptlangs={}
let cnr_browserlangs=['xhtml', 'html', 'xml', 'css']

for lang in ['python', 'php', 'perl', 'sh']
  if executable(lang)
    let cnr_scriptlangs[lang] = lang
  endif
endfor
if executable('ipython')
  cnr_scriptlangs['python'] = 'ipython'
endif

fun! CompileAndRun()
  try
    " Try to do project wide compilations/runs
    let s:projectRoot = GuessProjectRoot("%")
    if &ft=='java' || expand('%:t')=='build.xml'
      if(filereadable(s:projectRoot.'/build.xml'))
        wa
        exe 'setl makeprg=ant\ -f\ '.s:projectRoot.'/build.xml run'
        setl efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
        make
        return
      endif
    endif

    " Fall back to single file compilations/runs
    if &modified
      write
    endif
    let shebang = matchstr(getline(1),'^#!\zs[^ ]*')
    if shebang == '/usr/bin/env'
      exe '!'.strpart(getline(1), 15).' %'
    elseif executable(shebang)
      exe '!'.matchstr(getline(1),'^#!\zs.*').' %'
    elseif has_key(g:cnr_scriptlangs, &ft)
      exe '!'.g:cnr_scriptlangs[&ft].' %'
    elseif index(g:cnr_browserlangs, &ft)>=0
      if exists('b:url')
        call OpenURL(b:url)
      else
        call OpenURL(expand('%:p'))
      endif
    elseif &ft=='vim'
      unlet! g:loaded_{expand('%:t:r')}
      so %
    elseif &ft=='markdown' && executable('markdown')
      exe '!markdown %'
      call OpenUrl(expand('%:p'))
    elseif &ft=='java' && executable('java') && executable('javac')
      let package = search('\s*package\s', 'nw')
      let qualified = expand('%:t:r')
      if package!=0
        let package = matchstr(getline(package), '\v^\s*package\s+\zs[^;]+')
        let classdir = expand('%:p:h:h'.substitute(substitute(package, '[^.]', '', 'g'), '\.', ':h', 'g'))
        let qualified = package.'.'.qualified
      else
        let classdir = expand('%:p:h')
      endif
      let &cmdheight += 1
      let cmd = '!javac -d "'.classdir.'" "'.expand('%').'" &&'
      exe cmd.' java -cp "'.classdir.'" '.qualified
      let &cmdheight -= 1
    else " If all else fails, use default handler
      exe '!%'
    endif
  finally
    redraw!
  endtry
endf
