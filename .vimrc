" Base vimrc file of Daan Bakker
" This one is designed to always work standalone, and be extendible
" on desktops with more advanced settings, themes and plugins.

" Many parts were blatantly stolen from others.

" Init {{{1
set nocompatible                " forget being compatible with good ol' vi
let mapleader=","               " Change the mapleader from \ to ,

" on Windows ~/vimfiles/ normally replaces ~/.vim/
if has("win32")
    set runtimepath+=~/.vim/
endif

" initialize global methods and variables
if filereadable(glob("~/.vim/gfunctions.vim"))
    source ~/.vim/gfunctions.vim
endif

" plugin stuff (Vundle/Pathogen) needs to be initialized here
if filereadable(glob("~/.vim/initplugin.vim"))
    source ~/.vim/initplugin.vim
endif

" Get that filetype stuff happening
if version>600
    filetype plugin indent on
else
    filetype on
endif

" allow files to define some custom settings like foldmethod
" Warning: this might be insecure on some old versions of vim
set modeline
set modelines=5

" let g:RunProject=function("")

" let g:TabCompleteChain=[]

" Editor options {{{1
" Standard mappings {{{2

" Since I never use the ; key anyway, this is a real optimization for almost
" all Vim commands, as I don't have to press the Shift key to form chords to
" enter ex mode.
" nnoremap ; :

" Make the up and down arrows also move the screen
nnoremap <unique> <down> gj<C-e>
nnoremap <unique> <up> gk<C-y>

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap <unique> j gj
nnoremap <unique> k gk

" Use space for (un)folding
nnoremap <unique> <Space> za
vnoremap <unique> <Space> za

" Use ,/ to clear search highlighting
nmap <silent> ,/ :nohlsearch<CR>

" Use ,w as a replacement to CTRL-W (useful in many window commands)
nnoremap <unique> ,w <C-w>

" Use ,y/p/P to yank/paste to the OS clipboard
nnoremap <unique> <leader>y "+y
vnoremap <unique> <leader>y "+y
nnoremap <unique> <leader>p "+p
vnoremap <unique> <leader>p "+p
nnoremap <unique> <leader>P "+P
vnoremap <unique> <leader>P "+P

" Give Y a more logical purpose than aliasing yy
nnoremap <unique> Y y$

" Use Q as alias for @j (execute 'j' recording)
nnoremap <unique> Q @j

" Use ':R foo' to run foo and capture its output in a scratch buffer
command! -nargs=* -complete=shellcmd R new | setlocal buftype=nofile bufhidden=hide noswapfile | r !<args>

nnoremap <unique> <silent> <F5> :call CompileAndRun()<cr>

" Standard settings {{{2
" Dont complain about hiding unsaved buffers
set hidden

" Don't update the display while executing macros
set lazyredraw

" At least let yourself know what mode you're in
set showmode

" Enable enhanced command-line completion. Presumes you have compiled
" with +wildmenu.  See :help 'wildmenu'
set wildmenu
" don't list a bunch of known binary files (not archives)
set wildignore=*.swp,*.bak,*.pyc,*.class,*.gif,*.png,*.jpg,*.exe,tags

set tabstop=4                   " a tab is four spaces
set softtabstop=4               " when hitting <BS>, pretend like a tab is removed, even if spaces
set expandtab                   " expand tabs by default (overloadable per file type later)
set shiftwidth=4                " number of spaces to use for autoindenting
set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set autoindent                  " always set autoindenting on
set copyindent                  " copy the previous indentation on autoindenting
set smarttab                    " insert tabs on the start of a line according to
                                "    shiftwidth, not tabstop
set gdefault                    " search/replace "globally" (on a line) by default
set mouse=                      " disable mouse
set fileformats="unix,dos,mac"
set formatoptions+=1            " when wrapping paragraphs, don't end lines
                                "    with 1-letter words (looks stupid)
set nrformats=                  " make <C-a> and <C-x> play well with
                                "    zero-padded numbers (i.e. don't consider
                                "    them octal or hex)
set fillchars=""                " get rid of the silly chars in separators
set undolevels=1000             " use many muchos levels of undo
set history=1000                " remember more commands and search history
set nobackup                    " do not keep backup files, it's 70's style cluttering
set noswapfile                  " do not write annoying intermediate swap files,
                                "    who did ever restore from swap files anyway?
set viminfo='20,\"80            " read/write a .viminfo file, don't store more
                                "    than 80 lines of registers
set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list:full          " show a list when pressing tab and complete
                                "    first full match
set visualbell                  " flash the screen on error
set noerrorbells                " don't beep
set ttyfast                     " always use a fast terminal
set timeoutlen=20000            " vastly increase the duration before an
                                " incomplete command is cancelled
                                " (this prevents time based mappings)
set shortmess+=IfilmnrxoOtT     " Show short messages and don't show welcome
set switchbuf=useopen,usetab    " when reopening files use existing tabs/buffers
set ignorecase                  " case insensitive search
set smartcase                   " lowercase search matches any case

" Search for tags in the current directory, the file directory,
" and upper directories
set tags=./tags,./../tags,./../../tags,./../../../tags,./../../../../tags
set tags+=./../../../../../tags,./../../../../../../tags,./../../../../../../../tags

set grepprg=grep\ -rnH\ --exclude='.*.swp'\ --exclude='.git'\ --exclude=tags

" Restore cursor position upon reopening files {{{2
augroup resCur
    autocmd!
    autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END

" Allow insert mode <tab> and <S-tab> to autocomplete {{{2
function! CleverTab(dir)
    if(pumvisible())                                 " if popup menu is visible
        return a:dir                                 " go to next entry
    endif

    let substr = strpart(getline('.'), -1, col('.')) " get line until cursor
    let substr = matchstr(substr, '[!@#$%^&*()\-+{}\[\]~\.\\/]*\a*$') " get word until cursor

    " If there is nothing to complete before the cursor, return a tab
    if (strlen(substr)==0)
        return "\<tab>"
    endif

    " If there is a slash before the cursor, treat it as a filename
    if (match(substr, '/') != -1)
        return "\<C-X>\<C-F>"
    endif

    " If there is a dot before the cursor, use plugin matching
    if (strlen(&omnifunc) && (match(substr, '\.') != -1 || match(substr, '->') != -1))
        return "\<C-X>\<C-O>"
    endif

    " use normal text matching
    return "\<C-X>" . a:dir
endfunction

" Don't select first match but just complete as far as possible
set completeopt=longest,menuone
silent! inoremap <expr> <unique> <silent> <tab> CleverTab("\<C-N>")
silent! inoremap <expr> <unique> <silent> <S-tab> CleverTab("\<C-P>")

" Visual options {{{1
if &t_Co > 2 || has("gui_running")
   syntax on                    " switch syntax highlighting on, when the terminal has colors
endif

set title                       " change the terminal's title
set showmode                    " always show what mode we're currently editing in
set nowrap                      " don't wrap lines
set scrolloff=1                 " keep 1 line distance from the edges of the screen
set virtualedit=all             " allow the cursor to go in to "invalid" places
set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type
set diffopt+=iwhite             " Add ignorance of whitespace to diff

" Syntax coloring lines that are too long just slows down the world
set synmaxcol=2048

if has("balloon_eval") && has("unix")
    set ballooneval
endif

" Status is [filename] [mode] [line/column number]
set stl=%f%m%r\ Line:%l/%L[%p%%]\ Col:%v

" Speed up scrolling of the viewport slightly
nnoremap <unique> <C-e> 2<C-e>
nnoremap <unique> <C-y> 2<C-y>

set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " don't update the display while executing macros
set laststatus=2                " tell VIM to always put a status line in, even
                                "    if there is only one window
set cmdheight=2                 " use a status bar that is 2 rows high

set showcmd                     " show (partial) command in the last line of the screen
                                "    this also shows visual selection info

" Set a nice default foldtext {{{2
function! MyFoldText()
    " Trim unwanted symbols from the text
    let sub = substitute(getline(v:foldstart), '\v[^a-zA-Z)}>\]]+$', '', '')
    let sub = substitute(sub, '\v^[^a-zA-Z({<\[]+', '', '')
    return printf('+%s[%3d] %s' , v:folddashes, v:foldend-v:foldstart+1, sub)
endfunction

set foldtext=MyFoldText()
" Visualize suspicious characters {{{2
if (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8') && version >= 700
  let &listchars = "tab:\u21e5\u00b7,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u26ad"
else
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<
endif
set list


" Font and GUI options {{{2
if has("gui_running")
    " Remove all menus, scollbars, etc.
    set guioptions=aegit

    " Set font depending on system (tpope)
    if exists("&guifont")
        if has("mac")
            set guifont=Monaco:h12
        elseif has("unix")
            if &guifont == ""
                set guifont=Inconsolata\ 14,bitstream\ vera\ sans\ mono\ 11
            endif
        elseif has("win32")
            set guifont=Consolas:h11,Courier\ New:h10
        endif
    endif

    set guicursor+=n-v:blinkon0
else
    set bg=dark
endif

" Load local filetype specific code, if present {{{1
augroup LocalFileType
    autocmd!
    autocmd FileType * exe 'sil! source ~/.vim/local/ftplugin/' . &filetype . '.vim'
augroup END

" Load extra themes, etc. if present {{{1
if filereadable(glob("~/.vim/extended.vim"))
    source ~/.vim/extended.vim
endif

" Load a local vimrc file if present {{{1
if filereadable(glob("~/.vim/local.vim"))
    source ~/.vim/local.vim
elseif filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" vim: fen fdm=marker
