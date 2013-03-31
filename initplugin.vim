filetype off                   " required!

" Setup plugin loader {{{1
execute pathogen#infect()

" Load plugins {{{1

" Configuration of options for plugins {{{1
filetype plugin indent on     " required!

" Tcomment {{{2
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
let g:syntastic_python_flake8_args='--ignore=E501'

" CtrlP {{{2
let g:ctrlp_cache_dir = $HOME.'/.vim/local/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_mruf_exclude = '.*/vim../doc/.*\|.*\.git/.*'

" Vim-Jedi {{{2
let g:jedi#auto_vim_configuration = 0
let g:jedi#goto_command = "<leader>ig"
let g:jedi#get_definition_command = "<leader>id"
let g:jedi#pydoc = "<leader>iK"
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#rename_command = "<leader>ir"
let g:jedi#related_names_command = "<leader>in"
