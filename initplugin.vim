filetype off                   " required!

" Setup plugin loader {{{1
execute pathogen#infect()

" Load plugins {{{1

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" Tcomment {{{2
let g:tcommentOptions = {'strip_whitespace': 1}
if isdirectory(expand('~/.vim/bundle/tcomment_vim'))
  let g:tcomment_types={'java': '// %s'}
  call tcomment#DefineType('markdown', g:tcommentInlineXML)
endif

" Settings for Session plugin {{{2
let g:session_directory = '~/.vim/local/session'
let g:session_autoload = 'no'
let g:session_autosave = 'no'

" Settings for Ack plugin {{{2
if executable('ack-grep')
  let g:ackprg="ack-grep -H --nocolor --nogroup --column"
elseif executable('ack')
  let g:ackprg="ack -H --nocolor --nogroup --column"
endif

" NERDTree {{{2
let NERDTreeHijackNetrw=1
let NERDTreeBookmarksFile=expand('~/.vim/local/NERDTreeBookmarks.txt')
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

" Filetype detection {{{2
au BufNewFile,BufRead nginx.conf set filetype=nginx.conf
au BufNewFile,BufRead *.muttrc set filetype=muttrc

" Easymotion {{{2
let g:EasyMotion_leader_key = '<space>'

" Java autocomplete {{{2
if has("autocmd")
  autocmd Filetype java setlocal omnifunc=javacomplete#Complete
endif

" Misc {{{2
au BufNewFile,BufRead *.fo if len(&ft)==0 | set ft=xml | endif " Apache FOP file
let g:solarized_contrast = "high"
let g:searchfold_foldlevel = 2
let g:searchfold_do_maps = 0
nmap ,z <Plug>SearchFoldNormal:ResetScroll<cr>
nmap ,Z <Plug>SearchFoldRestore:ResetScroll<cr>
let g:syntastic_python_flake8_args='--ignore=E501,F401'
let g:syntastic_puppet_lint_arguments='--error-level error'
let g:syntastic_php_phpmd_post_args = 'text design,unusedcode'
let g:syntastic_warning_symbol='--'
let g:UltiSnipsSnippetDirectories=["myultisnips"]
let g:tskelMapInsert = '<c-y>'

aug tSkelSetup
  au!
  au BufNewFile */application/classes/*/*.php TSkeletonSetup kohana_extend.php
  au BufNewFile *.vim if VimLoadedGuard()!='' | TSkeletonSetup plugin.vim | endif
aug END

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
set statusline=%t%m%r%{exists('b:statusnew')?'[new]':''}%{&paste?'[PASTE]':''}%{exists('b:file_status')\ ?b:file_status\ :\ ''}%w%#ErrorMsg#%(\ %{SyntasticStatuslineFlag()}%)%*%{StatusDir()}%=\ %y%{exists('b:cvs_status')\ ?b:cvs_status\ :\ ''}\ %l%<
let g:syntastic_stl_format = '[%E{%e ERR}%B{ }%W{%w WRN}]'

aug fileNew
  au!
  au BufNewFile * let b:statusnew = 1
  au BufWritePost * unlet! b:statusnew
aug END

fun! StatusDir()
  if len(&bt)>0
    return ''
  endif
  let d = expand('%:h')
  if isdirectory(d) && d!='.'
    return ' (' . substitute(d, expand('~'), '~', '') . ')'
  else
    return ''
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
let g:ctrlp_cache_dir = $HOME.'/.vim/local/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_mruf_exclude = '.*/vim../doc/.*\|.*\.git/.*\|.*/\.cache/.*\|/tmp/.*'

" Vim-Jedi {{{2
let g:jedi#auto_vim_configuration = 0
let g:jedi#goto_command = "<leader>ig"
let g:jedi#get_definition_command = "<leader>id"
let g:jedi#pydoc = "<leader>iK"
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#rename_command = "<leader>ir"
let g:jedi#related_names_command = "<leader>in"

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

" DetectIdent {{{2
let g:detectindent_preferred_expandtab = 1
let g:detectindent_max_lines_to_analyse = 1024
aug detectIndentRead
  au!
  autocmd BufReadPost * if exists(":DetectIndent") | DetectIndent | endif
aug END

" RST Tables {{{2
aug realignRST
  au!
  au InsertLeave *.rst call rst_tables#reformat()
aug END

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
