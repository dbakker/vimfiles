filetype off                   " required!

execute pathogen#infect(g:vimdir.'/bundles/general/{}')
execute pathogen#infect(g:vimdir.'/bundles/navigation/{}')
execute pathogen#infect(g:vimdir.'/bundles/colorschemes/{}')
execute pathogen#infect(g:vimdir.'/bundles/syntax/{}')
syntax on

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" Tcomment {{{2
let g:tcommentOptions = {'strip_whitespace': 1}
let g:tcomment_types={'java': '// %s'}
call tcomment#DefineType('markdown', g:tcommentInlineXML)
call tcomment#DefineType('rst', {'col': 1, 'commentstring': '.. %s' })

" NERDTree {{{2
let NERDTreeHijackNetrw=1
let NERDTreeBookmarksFile=expand(localdir.'/NERDTreeBookmarks.txt')
let NERDTreeMouseMode=2
let NERDTreeIgnore=['\.o$', '\.pyc$', '\.exe$','\.class$', 'tags$', '\~$']
function! NERDTreeSmartToggle()
  for buf in tabpagebuflist()
    if bufname(buf) =~ 'NERD_tree'
      NERDTreeClose
      return
    endif
  endfor
  try
    ProjectRootExe NERDTreeFind
  catch
    ProjectRootExe NERDTree
  endtry
endfunction

function! RangerChooser()
  try
    let temp = tempname()
    " The option "--choosefiles" was added in ranger 1.5.1. Use the next line
    " with ranger 1.4.2 through 1.5.0 instead.
    execute 'silent !ranger --choosefiles=' . shellescape(temp)
    if !filereadable(temp)
      " Nothing to read.
      return
    endif
    let names = readfile(temp)
    if empty(names)
      " Nothing to open.
      return
    endif
    " Edit the first item.
    execute 'edit ' . fnameescape(names[0])
    " Add any remaning items to the arg list/buffer list.
    for name in names[1:]
      execute 'argadd ' . fnameescape(name)
    endfor
  finally
    redraw!
  endtry
endfunction
command! -bar RangerChooser call RangerChooser()
nnoremap + :<C-U>RangerChooser<CR>

" Filetype detection {{{2
autocmd BufNewFile,BufRead nginx.conf set filetype=nginx.conf
autocmd BufNewFile,BufRead *.muttrc set filetype=muttrc

" Java autocomplete {{{2
autocmd Filetype java setlocal omnifunc=javacomplete#Complete

" Syntastic

" Read ignore flags from env for local overrides
let $FLAKE8_IGNORE='--ignore=E501,F401'
" Do not warn about already present style issues
let g:syntastic_python_flake8_exe='bash'
let g:syntastic_python_flake8_args='-c "' .
    \ 'if diff=\$(git diff HEAD \"\$0\");' .
    \ 'then echo \"\$diff\"|flake8 --diff \$FLAKE8_IGNORE;' .
    \ 'else flake8 \$FLAKE8_IGNORE \"\$0\"; fi' .
    \ '"'

let g:syntastic_puppet_lint_arguments='--error-level error'
let g:syntastic_php_phpmd_post_args = 'text design,unusedcode'
let g:syntastic_rst_checkers = ['rstcheck']  " Support for 'ref' role and in-file language checking
let g:syntastic_rst_rstcheck_args='--report warning'
let g:syntastic_warning_symbol='--'
let g:syntastic_stl_format = '[%E{%e ERR}%B{ }%W{%w WRN}]'

" Misc {{{2
autocmd BufNewFile,BufRead *.fo if len(&ft)==0 | set ft=xml | endif " Apache FOP file
autocmd BufNewFile,BufRead *.less setl cms=/*\ %s\ */
autocmd BufNewFile,BufRead *.do setl ft=sh sw=2 ts=2 sts=2 et " redo file, see https://github.com/mildred/redo
autocmd BufNewFile */ac/journal/* call setline(1, '==========') | call setline(2, strftime('%Y-%m-%d')) | call setline(3, '==========') | call setline(4, '') | call cursor(5, 0) | set nomodified

let g:searchfold_foldlevel = 2
let g:searchfold_do_maps = 0
nmap <leader>z <Plug>SearchFoldNormal:AdjustScroll<cr>
nmap <leader>Z <Plug>SearchFoldRestore:AdjustScroll<cr>

let g:searchfold_do_maps = 0
let g:SuperTabDefaultCompletionType = "context"

let g:clang_hl_errors = 0
let g:clang_close_preview = 1

if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column'
endif

" Automatically set some file permissions {{{2
if executable('chmod')
  augroup autoChmod
    autocmd!
    autocmd BufWritePost * if getline(1)=~'^#!' && getfperm(expand('%'))=~'^rw-' | call system('chmod u+x '.expand('%:p')) | endif
    autocmd BufWritePost ~/.netrc,~/.ssh/* call system('chmod go-rwx '.expand('%:p'))
  augroup END
endif

" Statusline {{{2
set statusline=%t%m%r%{exists('b:statusnew')?'[new]':''}%{&paste?'[paste]':''}%{exists('b:file_status')\ ?b:file_status\ :\ ''}%w%#ErrorMsg#%(\ %{SyntasticStatuslineFlag()}%)%*%{StatusDir()}%=\ %{fugitive#statusline()}\ %l%<

augroup fileNew
  autocmd!
  autocmd BufNewFile * let b:statusnew = 1
  autocmd BufWritePost * unlet! b:statusnew
augroup END

let b:laststatusdir = ''
let b:laststatuscwd = ''
function! StatusDir()
  if exists('b:laststatuscwd') && getcwd()==b:laststatuscwd
    return b:laststatusdir
  endif
  let b:laststatuscwd = getcwd()
  if len(&bt)>0
    let b:laststatusdir = ''
  else
    let d = PrettyPath(getcwd())
    let s = PrettyPath(expand('%:p:h'))
    if stridx(s, d) == 0
      if ProjectRootGuess(s) ==# expand(d)
        let b:laststatusdir = ' {' . s . '}'
      else
        let b:laststatusdir = ' (' . s . ')'
      endif
    else
      let b:laststatusdir = ' <' . s . '>'
    endif
  endif
  return b:laststatusdir
endfunction

function! s:UpdateFileStatus()
  let b:file_status = ''
  if &ff != 'unix'
    let b:file_status .= '['.&ff.']'
  endif
endfunction

augroup updateFileStatus
  autocmd!
  autocmd BufReadPost * call s:UpdateFileStatus()
  autocmd BufWritePost * call s:UpdateFileStatus()
augroup END

" CtrlP {{{2
let g:ctrlp_cache_dir = localdir.'/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_mruf_exclude = '.*/vim../doc/.*\|.*\.git/.*\|.*/\.cache/.*\|/tmp/.*'
let g:ctrlp_mruf_max = 1000
let g:ctrlp_max_height = 32
let g:ctrlp_mruf_save_on_update = 0

if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
  let g:ctrlp_use_caching = 0
  let g:unite_source_rec_async_command =
          \ 'ag --follow --nocolor --nogroup --hidden -g ""'
endif

" Vim-Jedi {{{2
let g:jedi#auto_vim_configuration = 0
let g:jedi#goto_assignments_command = "<leader>ig"
let g:jedi#goto_definitions_command = "<leader>id"
let g:jedi#documentation_command = "<leader>iK"
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#rename_command = "<leader>ir"
let g:jedi#usages_command = "<leader>in"

" Clear non-ctrl select mode mappings {{{2
function! s:clearsmap()
  redir => f
  silent execute 'smap'
  redir END
  let b = split(f, "\n")
  for line in b
    let m = matchstr(line, '...\zs\S\+')
    if m[0]!='<'
      silent! execute 'sunmap '.m
    endif
  endfor
endfunction
augroup clearSMap
  autocmd!
  autocmd VimEnter * call <SID>clearsmap()
augroup END

" Select colorscheme {{{2
fun! s:load_colorscheme(color)
  let color = tolower(a:color)
  if has("gui_running")
    if color =~ '^light'
      sil! colorscheme eclipse
    else
      sil! colorscheme jellybeans
    endif
  else
    if &t_Co == 256
      if color =~ '^dark'
        sil! colorscheme jellybeans
      else
        let g:solarized_termcolors=256
        let g:solarized_contrast = "high"
        sil! colorscheme solarized
      endif
    else
      let &bg = color
      sil! colorscheme ron
    endif
  endif
endf

fun! s:select_colorscheme()
  let s:color_switch_time = localtime() + str2nr(system('~/.dotfiles/assets/sunrise.py countdown'))
  let color = system('~/.dotfiles/assets/sunrise.py color')
  call <SID>load_colorscheme(color)
endf

call s:select_colorscheme()

fun! s:time_colorscheme()
  if localtime() > s:color_switch_time
    call s:select_colorscheme()
  end
endf

augroup updateColor
  autocmd!
  autocmd CursorHold * call <SID>time_colorscheme()
augroup END

" RST Tables {{{2
augroup realignRST
  autocmd!
  autocmd InsertLeave *.rst call rst_tables#reformat()
augroup END

" Trash {{{2
" Adapted from tpope/eunuch's 'Remove'
command! -bar -bang Trash :
      \ let s:file = fnamemodify(bufname(<q-args>), ':p') |
      \ update | execute 'BD<bang>' |
      \ if !bufloaded(s:file) && system("trash-put " . fnameescape(s:file)) |
      \   echoerr 'Failed to trash "' . s:file . '"' |
      \ endif |
      \ unlet s:file

" Read only conversions {{{2
" `catdoc` {{{3
if executable('catdoc')
  autocmd BufReadPre *.doc setl ro ft= wrap nolist
  autocmd BufReadPost *.doc sil! %!catdoc "%"
endif
if executable('xls2csv')
  autocmd BufReadPre *.xls setl ro ft=csv
  autocmd BufReadPost *.xls sil! %!xls2csv -q -x "%" -c -
  autocmd BufReadPost *.xls redraw
endif
if executable('catppt')
  autocmd BufReadPre *.ppt setl ro ft=
  autocmd BufReadPost *.ppt sil! %!catppt "%"
  autocmd BufReadPost *.ppt redraw
endif
if executable('sqlite3')
  autocmd BufReadPre *.sqlite setl ro ft=sql
  autocmd BufReadPost *.sqlite sil! %!sqlite3 "%" .dump
  autocmd BufReadPost *.sqlite redraw
endif

" `xpdf` {{{3
if executable('pdftotext')
  autocmd BufReadPre *.pdf setl ro ft=
  autocmd BufReadPost *.pdf sil! %!pdftotext -nopgbrk "%" -
endif

" `docx2txt` {{{3
if executable('docx2txt')
  autocmd BufReadPre *.docx setl ro ft= wrap nolist
  autocmd BufReadPost *.docx sil! %!docx2txt
endif

" `xlsx2csv` {{{3
autocmd BufReadPre *.xlsx setl ro ft=csv
autocmd BufReadPost *.xlsx sil! %!python ~/.vim/assets/xlsx2csv.py "%"
autocmd BufReadPost *.xlsx redraw
