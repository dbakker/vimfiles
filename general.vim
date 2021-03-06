" General and global vim configuration

" My thanks to the Vim wiki, tpope, derek wyatt and others.

" Editor options {{{1
" Standard settings {{{2

set autoindent                  " always set autoindenting on
set autoread                    " lets assume the original file is in version control
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set commentstring=#%s
set complete-=i                 " do not search in include files for completes
set completeopt=menuone,longest
set copyindent                  " copy the previous indentation on autoindenting
set fileformats=unix,dos,mac
set fillchars=""                " get rid of the silly chars in separators
set formatoptions+=1clqrj
set formatoptions-=aow
set gdefault                    " search/replace "globally" (on a line) by default
set hidden                      " dont complain about hiding unsaved buffers
set history=1000                " remember more commands and search history
set ignorecase                  " case insensitive search
set infercase                   " adjust keyword completion matches to the case of the typed text
set isfname-==
set modeline                    " allow files to define some custom settings like foldmethod
set modelines=5                 " check 5 lines from the bottom&top for modelines
set mouse=a                     " always activate mouse for colleagues
set nobackup                    " do not keep backup files
set noerrorbells                " don't beep
set nofoldenable                " do not fold by default (use zM/zR)
set nojoinspaces                " only insert 1 space after . ? and !
set nostartofline               " keep the cursor in its current column
set noswapfile                  " do not write annoying intermediate swap files
set nrformats-=octal            " don't consider numbers starting with 0 to be octal
set shortmess+=IfilmnrxoOtT     " show short messages and don't show welcome
set smartcase                   " lowercase search matches any case
set smarttab                    " insert tabs on the start of a line according to shiftwidth, not tabstop
set spellfile^=~/.vim/spell/en.utf-8.add
set spelllang+=nl
set switchbuf=useopen,usetab    " when reopening files use existing tabs/buffers
set tags=./.git/tags;,./tags;     " search for tags in the file directory and upper directories
set timeoutlen=20000            " wait a long time before timeout
set ttimeout
set ttimeoutlen=50
set undofile
set undolevels=1000             " use many muchos levels of undo
set viminfo^=!,h
set visualbell                  " flash the screen on error
set wildignore=*.swp,*.bak,*.pyc,*.class,*.exe,*.o,tags
set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list:full          " show a list when pressing tab and complete first full match

" Clipboard
set clipboard-=autoselect       " do not automatically copy visually selected things to the clipboard
if len($DISPLAY)>0
  set clipboard-=exclude:cons\\\|linux
  set clipboard+=unnamed
  if has('unnamedplus')
    set clipboard-=unnamed
    set clipboard+=unnamedplus
  endif
endif

" Set settings for tabs
set expandtab                   " expand tabs by default (overloadable per file type later)
set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
set shiftwidth=4                " number of spaces to use for autoindenting
set softtabstop=4               " when hitting <BS>, pretend like a tab is removed, even if spaces
set tabstop=4                   " a tab is four spaces

" Set default encodings to utf-8
set encoding=utf-8
set termencoding=utf-8

" Set options for views and sessions
set sessionoptions=blank,buffers,folds,help,resize,slash,unix,winsize
set viewoptions=cursor,folds,slash,unix

" Ask to create directories
fun! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir) && confirm("Create directory ".dir."?", "Yes\nNo")==1
      call mkdir(dir, 'p')
    endif
  endif
endf
aug BWCCreateDir
  au!
  au BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
aug END

" Restore cursor position upon reopening files {{{2
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
  autocmd BufWinEnter * if &fen && foldlevel('.')>0 | exe 'normal! zO' | endif | sil! AdjustScroll
augroup END

" Resize windows upon Vim resize {{{2
aug vimResize
  au!
  au VimResized * wincmd =
aug END

" Set initial directory {{{2
augroup initialDir
  au!
  if (has('win32') || has('win64'))
    au VimEnter * if !len(bufname('')) && !filereadable(expand('%')) | exe 'sil! cd' $HOME | endif
  endif
augroup END

" Set working directory to root of first opened file {{{2
if has("gui_running")
  fun! s:WorkDirRead()
    if &bt=='' && filereadable(expand('%'))
      exe 'sil cd' ProjectRootGuess()
      au! workDir
    endif
  endf
  aug workDir
    au!
    au BufWinEnter * call <SID>WorkDirRead()
  aug END
endif

" Matchit {{{2
" Load matchit.vim, but only if the user hasn't installed a newer version. (tpope)
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" Set most recently changed file to 'R {{{2
aug recentlyEdited
  au!
  au BufWinEnter * if len(&bt)==0 | let b:lastedit = changenr() | endif
  au BufWinLeave * if exists('b:lastedit') && b:lastedit!=changenr() && expand('%:p')!~'.*/vim../doc/.*\|.*\.git/.*\|.*/\.cache/.*\|/tmp/.*' && len(&bt) == 0 | exe 'normal! mR'  | endif
aug END

" Quit extra buffers with `q` {{{2
aug quitQ
  au!
  au FileType help,qf :noremap <buffer> q :<C-U>quit<cr>
aug END

" Visual options {{{1
" Standard settings {{{2
if &t_Co > 2 || has("gui_running")
   syntax on                    " switch syntax highlighting on, when the terminal has colors
endif

set cmdheight=2                 " use a status bar that is 2 rows high
set diffopt+=iwhite             " add ignorance of whitespace to diff
set display+=lastline           " display as much of the last line as possible
set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type
set laststatus=2                " tell VIM to always put a status line in
set lazyredraw                  " don't update the display while executing macros
set linebreak                   " if we do wrap, wrap whole words, and mark it with '> '
set list                        " show tabs and trailing spaces by default
set listchars=tab:\ \ ,trail:-,extends:>,precedes:<
set nowrap                      " don't wrap lines by default
set scrolloff=1                 " keep 1 line distance from the edges of the screen
set showbreak=>\ 
set showcmd                     " show (partial) command in the last line of the screen
set showmode                    " always show what mode we're currently editing in
set showtabline=1               " show a list of tabs only if there are at least two tab pages
set sidescroll=1                " continuous horizontal scroll rather than jumpy
set sidescrolloff=7             " columns to keep visible before and after cursor
set synmaxcol=2048              " don't syntax color long lines (such as minified js)
set title                       " change the terminal's title
set virtualedit=block,onemore   " allow the cursor to go in to "invalid" places

if has("balloon_eval") && has("unix")
    set ballooneval
endif

" Speed up scrolling of the viewport slightly
sil! nnoremap <unique> <C-e> 2<C-e>
sil! nnoremap <unique> <C-y> 2<C-y>

" Hide trailing whitespaces in insert mode
aug trailing
  au!
  au InsertEnter * :let o_listchars=&listchars | let &listchars = substitute(&listchars, '\vtrail:.*(,|$)', '', '')
  au InsertLeave * :let &listchars=o_listchars
aug END

" Set a nice default foldtext {{{2
function! MyFoldText()
  " Trim unwanted symbols from the text
  let sub = substitute(getline(v:foldstart), '\v[^a-zA-Z)}>\]]+$', '', '')
  let sub = substitute(sub, '\v^[^a-zA-Z({<\[]+', '', '')
  return printf('+%s[%3d] %s' , v:folddashes, v:foldend-v:foldstart+1, sub)
endfunction

set foldtext=MyFoldText()

" Font and GUI options {{{2
if has("gui_running")
  " Remove all menus, scollbars, etc.
  set guioptions=cgit

  " Set font depending on system (tpope)
  if exists("&guifont")
    if has("mac")
      set guifont=Monaco:h12
    elseif has("unix")
      if &guifont == ""
        set guifont=Ubuntu\ Mono\ 12,Inconsolata\ 11,bitstream\ vera\ sans\ mono\ 11
      endif
    elseif has("win32")
      set guifont=Consolas:h11,Courier\ New:h10
    endif
  endif

  set guicursor+=n-v:blinkon0
else
  if &term == "screen-256color"
    let &t_SI = "\<Esc>[3 q"
    let &t_EI = "\<Esc>[0 q"
  endif
endif
