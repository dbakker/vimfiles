# Vim configuration

This vim configuration uses git & the Vundle plugin.

To just install the basic standalone .vimrc use:

    curl -o ~/.vimrc https://raw.github.com/dbakker/vimfiles/master/.vimrc

## Doing a full install on Linux

First install gvim, git and optionally exuberant tags:

    sudo pacman -S gvim git ctags

Then download the settings:

    cd
    git clone git://github.com/dbakker/vimfiles.git .vim
    ln -s .vim/.vimrc .vimrc
    git clone git://github.com/gmarik/vundle.git .vim/bundle/vundle
    gvim -c "BundleInstall"

then restart vim.

## Doing a full install on Windows

Manually install:
  * GVim
  * Msysgit (git for windows)
  * Ctags (for tag navigation)
  * Mingw (if you add it to your PATH it enables unix commands)

Then download the settings:

    cd %UserProfile%
    git clone git://github.com/dbakker/vimfiles.git .vim
    echo source ~/.vim/.vimrc > .vimrc
    git clone git://github.com/gmarik/vundle.git .vim/bundle/vundle

Start vim, and install the plugins:

    :BundleInstall

then restart vim.

It might be a good idea to create a .vim/local.vim file with a subset of these:

    set mouse=a " Enable mouse (annoying on laptops with touchpads)
    set foldcolumn=3 " Allows mouse to click open folds
    set ffs=dos " Force CR, LF line endings
    set shellslash " Use / instead of \ in paths; don't combine with cmd.exe

## Setting up CTags for standard libraries
This configuration automatically looks in `~/.vim/local/tags/[language]` when
working on a code of that language. This is useful for having a quick look
at the description or implementation of something out of a standard library.

    cd ~/.vim/local/tags
    ctags -o python --python-kinds=-i -R path\to\python\lib
    ctags -o java --java-kinds=-p -R path\to\java\source

