# Vim configuration

This is my own complete Vim configuration. I hope you enjoy reading this and
will find some interesting snippets for your own Vim!

## Installing on Linux

First install GVim, git and optional dependencies:

    sudo pacman -S gvim git ctags curl ack python2
    sudo apt-get install vim vim-gtk git exuberant-ctags perl ack-grep curl python2 wmctrl

Download the configuration:

    $ bash <(curl -s https://raw.github.com/dbakker/vimfiles/master/install.sh)

Install linters for Syntastic:

    sudo apt-get install php5-dev php-pear 
    sudo pear channel-discover pear.phpmd.org
    sudo pear channel-discover pear.pdepend.org
    sudo pear install --alldeps phpmd/PHP_PMD
    sudo apt-get install pyflakes clang puppet-lint 

## Installing on Windows

Manually install (or maybe use [Chocolatey](http://chocolatey.org/)):

  * [GVim](http://guessurl.appspot.com/?q=download+gvim)
  * [Msysgit](http://guessurl.appspot.com/?q=download+msysgit) (git for windows)
  * [Exuberant tags](http://guessurl.appspot.com/?q=download+exuberant+tags) (for tag navigation)
  * [Mingw](http://guessurl.appspot.com/?q=download+mingw) (if you add it to your PATH it enables Unix commands)
  * [Strawberry Perl](http://strawberryperl.com/) (for Ack and general use, add to PATH)
  * [Python 2 (32-bit)](http://www.python.org/getit/) (useful for some plugins,
    the 32-bit version is necessary if Vim is 32-bit)

Then download the settings:

    cd %UserProfile%
    git clone https://github.com/dbakker/vimfiles.git .vim
    echo source ~/.vim/.vimrc > .vimrc

then manually add the plugins.

It might be a good idea to create a .vim/local.vim file with a subset of these:

    set mouse= " Disable mouse (for laptops with touchpads)
    set foldcolumn=3 " Allows mouse to click open folds
    set ff=unix " Force unix line endings
    set shellslash " Use / instead of \ in paths; useful with Cygwin

## Setting up CTags for standard libraries
This configuration automatically looks in `~/.vim/local/tags/[language]` when
working on a code of that language. This is useful for having a quick look
at the description or implementation of something out of a standard library.

These options are optimized on the fact that the sources won't change and that
we are not interested in their private variables/methods.

    cd ~/.vim/local/tags
    ctags -o python --excmd=number --python-kinds=-i -R path\to\python\lib
    ctags -o java --excmd=number --file-scope=no --java-kinds=-p -R path\to\java\source

## Setting file/folder specific scripts
Vim searches for file/folder specific scripts to execute. To edit or create one, use
`:EditScript` or `:EditScript file/folder`. Scripts created for a specific folder will
be executed whenever one of its files is opened. The scripts themselves will be
stored in the ~/.vim/local directory so they won't clutter your filesystem.

This feature is interesting for overriding settings, for example:

    let b:projectroot='/path/' " Override the path detected by GuessProjectRoot
    setl tags^=/path/tags
    setl bufhidden=delete " Useful for documentation that you don't need to keep open
    setl textwidth=80
    setl tabstop=2 softtabstop=2 shiftwidth=2
    setl noexpandtab
    setl makeprg=make
    Wrap

## For scavengers

If you are hungry for more, some other cool places to check out are:

  * [Vim Tips Wiki](http://vim.wikia.com/wiki/Vim_Tips_Wiki)
  * [Derek Wyatt videos](http://guessurl.appspot.com/?q=derek+wyatt+advanced+videos)
  * [Tpope dotfiles](https://github.com/tpope/tpope)
  * [Spf13 vimfiles](https://github.com/spf13/spf13-vim/)
  * [AndrewRadev vimfiles](https://github.com/AndrewRadev/Vimfiles)

