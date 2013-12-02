filetype off                   " required!

" Setup plugin loader {{{1
if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'

" Load plugins {{{1
NeoBundle 'Rip-Rip/clang_complete'
NeoBundle 'Shougo/unite-outline'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'SirVer/ultisnips'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'bronson/vim-visual-star-search'
NeoBundle 'chrisbra/Recover.vim'
NeoBundle 'ciaranm/detectindent'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'dbakker/vim-adjustscroll'
NeoBundle 'dbakker/vim-holmes'
NeoBundle 'dbakker/vim-indent'
NeoBundle 'dbakker/vim-lint'
NeoBundle 'dbakker/vim-md-noerror'
NeoBundle 'dbakker/vim-paragraph-motion'
NeoBundle 'dbakker/vim-projectroot'
NeoBundle 'dbakker/vim-puppet'
NeoBundle 'dbakker/vim-sparkup'
NeoBundle 'endel/vim-github-colorscheme'
NeoBundle 'ervandew/supertab'
NeoBundle 'glts/vim-textobj-comment'
NeoBundle 'godlygeek/tabular'
NeoBundle 'gregsexton/gitv'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'mattboehm/vim-unstack'
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'nelstrom/vim-markdown-folding'
NeoBundle 'noahfrederick/Hemisu'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'shawncplus/phpcomplete.vim'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tomtom/tlib_vim'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-characterize'
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-vividchalk'
NeoBundle 'tsukkee/unite-tag'
NeoBundle 'vim-scripts/AutoTag'
NeoBundle 'vim-scripts/argtextobj.vim'
NeoBundle 'vim-scripts/bufexplorer.zip'
NeoBundle 'vim-scripts/dbext.vim'
NeoBundle 'vim-scripts/javacomplete'
NeoBundle 'vim-scripts/loremipsum'
NeoBundle 'vim-scripts/md5.vim'
NeoBundle 'vim-scripts/mediawiki.vim'
NeoBundle 'vim-scripts/nginx.vim'
NeoBundle 'vim-scripts/searchfold.vim'
NeoBundle 'vimwiki/vimwiki'
NeoBundle 'yuku-t/unite-git'

NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }

" Custom settings for the Unite
autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
  " Play nice with supertab
  let b:SuperTabDisabled=1
  " Enable navigation with control-j and control-k in insert mode
  imap <silent> <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <silent> <buffer> <C-k>   <Plug>(unite_select_previous_line)
  imap <silent> <buffer> <esc>   <esc>:bd<cr>
endfunction

call unite#filters#matcher_default#use(['matcher_fuzzy'])

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" Tcomment {{{2
let g:tcommentOptions = {'strip_whitespace': 1}
if isdirectory(expand('~/.vim/bundle/tcomment_vim'))
  let g:tcomment_types={'java': '// %s'}
  call tcomment#DefineType('markdown', g:tcommentInlineXML)
endif

" Settings for Ack plugin {{{2
if executable('ack-grep')
  let g:ackprg="ack-grep -H --nocolor --nogroup --column"
elseif executable('ack')
  let g:ackprg="ack -H --nocolor --nogroup --column"
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
let g:searchfold_foldlevel = 2
let g:searchfold_do_maps = 0
nmap <leader>z <Plug>SearchFoldNormal:AdjustScroll<cr>
nmap <leader>Z <Plug>SearchFoldRestore:AdjustScroll<cr>
let g:syntastic_python_flake8_args='--ignore=E501,F401'
let g:syntastic_puppet_lint_arguments='--error-level error'
let g:syntastic_php_phpmd_post_args = 'text design,unusedcode'
let g:syntastic_warning_symbol='--'

let g:UltiSnipsNoPythonWarning = 1
let g:UltiSnipsSnippetsDir=expand("~/.vim/myultisnips")
let g:UltiSnipsSnippetDirectories=['myultisnips']
aug visualSnip
  au!
  au VimEnter * exe 'xnoremap <tab> :RemoveSharedIndent<CR>gv'.maparg('<tab>', 'x')
aug END

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
set statusline=%t%m%r%{exists('b:statusnew')?'[new]':''}%{&paste?'[PASTE]':''}%{exists('b:file_status')\ ?b:file_status\ :\ ''}%w%#ErrorMsg#%(\ %{SyntasticStatuslineFlag()}%)%*%{StatusDir()}%=\ %y%{exists('b:cvs_status')\ ?b:cvs_status\ :\ ''}\ %l%<
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
  let color = a:color
  if has("gui_running")
    if color == 'light'
      sil! colorscheme eclipse
    else
      sil! colorscheme jellybeans
    endif
  else
    if &t_Co == 256
      if color == 'dark'
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
