filetype off                   " required!

let $BGCOLOR=system('~/.dotfiles/assets/sunrise.py COLOR')

let g:pymode_rope_enable_shortcuts = 0
let g:ropevim_enable_shortcuts = 0

execute pathogen#infect()
syntax on

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" Custom settings for the Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  " Play nice with supertab
  let b:SuperTabDisabled=1
  " Enable navigation with control-j and control-k in insert mode
  imap <silent> <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <silent> <buffer> <C-k>   <Plug>(unite_select_previous_line)
  imap <silent> <buffer> <esc>   <esc>:bd<cr>
endfunction

" Tcomment {{{2
if isdirectory(expand('~/.vim/bundle/tcomment_vim'))
  let g:tcommentOptions = {'strip_whitespace': 1}
  let g:tcomment_types={'java': '// %s'}
  call tcomment#DefineType('markdown', g:tcommentInlineXML)
endif

" NERDTree {{{2
let NERDTreeHijackNetrw=1
let NERDTreeBookmarksFile=expand(localdir.'/NERDTreeBookmarks.txt')
let NERDTreeMouseMode=2
let NERDTreeIgnore=['\.o$', '\.pyc$', '\.exe$','\.class$', 'tags$', '\~$']
fun! NERDTreeSmartToggle()
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
endf

function! RangerChooser()
  try
    let temp = tempname()
    " The option "--choosefiles" was added in ranger 1.5.1. Use the next line
    " with ranger 1.4.2 through 1.5.0 instead.
    exec 'silent !ranger --choosefiles=' . shellescape(temp)
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
    exec 'edit ' . fnameescape(names[0])
    " Add any remaning items to the arg list/buffer list.
    for name in names[1:]
      exec 'argadd ' . fnameescape(name)
    endfor
  finally
    redraw!
  endtry
endfunction
command! -bar RangerChooser call RangerChooser()
nnoremap + :<C-U>RangerChooser<CR>

" Filetype detection {{{2
au BufNewFile,BufRead nginx.conf set filetype=nginx.conf
au BufNewFile,BufRead *.muttrc set filetype=muttrc

" Java autocomplete {{{2
if has("autocmd")
  autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif

" Misc {{{2
au BufNewFile,BufRead *.fo if len(&ft)==0 | set ft=xml | endif " Apache FOP file
au BufNewFile,BufRead *.less setl cms=/*\ %s\ */
au BufNewFile,BufRead *.do setl ft=sh sw=2 ts=2 sts=2 et " redo file, see https://github.com/mildred/redo

let g:searchfold_foldlevel = 2
let g:searchfold_do_maps = 0
nmap <leader>z <Plug>SearchFoldNormal:AdjustScroll<cr>
nmap <leader>Z <Plug>SearchFoldRestore:AdjustScroll<cr>
let g:syntastic_python_flake8_args='--ignore=E501,F401'
let g:syntastic_puppet_lint_arguments='--error-level error'
let g:syntastic_php_phpmd_post_args = 'text design,unusedcode'
let g:syntastic_warning_symbol='--'

let g:searchfold_do_maps = 0
let g:SuperTabDefaultCompletionType = "context"

let g:clang_hl_errors = 0
let g:clang_close_preview = 1

" Automatically set some file permissions {{{2
if executable('chmod')
  aug autoChmod
    au!
    au BufWritePost * if getline(1)=~'^#!' && getfperm(expand('%'))=~'^rw-' | call system('chmod u+x '.expand('%:p')) | endif
    au BufWritePost ~/.netrc,~/.ssh/* call system('chmod go-rwx '.expand('%:p'))
  aug END
endif

" Statusline {{{2
set statusline=%t%m%r%{exists('b:statusnew')?'[new]':''}%{&paste?'[paste]':''}%{exists('b:file_status')\ ?b:file_status\ :\ ''}%w%#ErrorMsg#%(\ %{SyntasticStatuslineFlag()}%)%*%{StatusDir()}%=\ %{fugitive#statusline()}\ %l%<
let g:syntastic_stl_format = '[%E{%e ERR}%B{ }%W{%w WRN}]'

aug fileNew
  au!
  au BufNewFile * let b:statusnew = 1
  au BufWritePost * unlet! b:statusnew
aug END

let b:laststatusdir = ''
let b:laststatuscwd = ''
fun! StatusDir()
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
endf

fun! s:UpdateFileStatus()
  let b:file_status = ''
  if &ff != 'unix'
    let b:file_status .= '['.&ff.']'
  endif
endf

aug updateFileStatus
  au!
  au BufReadPost * call s:UpdateFileStatus()
  au BufWritePost * call s:UpdateFileStatus()
aug END

" CtrlP {{{2
let g:ctrlp_cache_dir = localdir.'/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_mruf_exclude = '.*/vim../doc/.*\|.*\.git/.*\|.*/\.cache/.*\|/tmp/.*'
let g:ctrlp_mruf_max = 1000
let g:ctrlp_max_height = 32

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
fun! s:clearsmap()
  redir => f
  sil exe 'smap'
  redir END
  let b = split(f, "\n")
  for line in b
    let m = matchstr(line, '...\zs\S\+')
    if m[0]!='<'
      sil! exe 'sunmap '.m
    endif
  endfor
endf
aug clearSMap
  au!
  au VimEnter * call <SID>clearsmap()
aug END

" Select colorscheme {{{2
fun! s:select_colorscheme(color)
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

call s:select_colorscheme(len($BGCOLOR) == 0 ? 'light' : tolower($BGCOLOR))

" Default indent {{{2
let default_indent_xml = 'setl et sw=2 sts=2'
let default_indent_vim = 'setl et sw=2 sts=2'
let default_indent_html = 'setl et sw=2 sts=2'
let default_indent_rst = 'setl et sw=2 sts=2'
let default_indent_markdown = 'setl et sw=2 sts=2'
let default_indent_sh = 'setl et sw=2 sts=2'
let default_indent_yaml = 'setl et sw=2 sts=2'

" RST Tables {{{2
aug realignRST
  au!
  au InsertLeave *.rst call rst_tables#reformat()
aug END

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
  au BufReadPre *.doc setl ro ft= wrap nolist
  au BufReadPost *.doc sil! %!catdoc "%"
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
  au BufReadPre *.pdf setl ro ft=
  au BufReadPost *.pdf sil! %!pdftotext -nopgbrk "%" -
endif

" `docx2txt` {{{3
if executable('docx2txt')
  au BufReadPre *.docx setl ro ft= wrap nolist
  au BufReadPost *.docx sil! %!docx2txt
endif

" `xlsx2csv` {{{3
autocmd BufReadPre *.xlsx setl ro ft=csv
autocmd BufReadPost *.xlsx sil! %!python ~/.vim/assets/xlsx2csv.py "%"
autocmd BufReadPost *.xlsx redraw

" `autopep8` {{{3
if executable('autopep8') && executable('pep8')
  " This program is especially useful for E127 - Fix visual indentation.
  " autopep8==0.9.7
  fun! s:AutoPep8()
    if exists('b:skip_autopep8')
      return
    endif

    sil! write !pep8 --ignore E501 -
    if v:shell_error
      let s=winsaveview()
      sil! %!autopep8 --ignore E501 -
      if v:shell_error
        undo
        let b:skip_autopep8=1
        echoerr "Unable to autopep8... Added an ignore for this buffer."
      endif
      call winrestview(s)
    endif
  endf
  au BufWritePre *.py call <SID>AutoPep8()
endif
