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
First manually install GVim.

Then install msysgit, and follow the installation instructions for
[Vundle for Windows](https://github.com/gmarik/vundle/wiki/Vundle-for-Windows).

Then download the settings:

    cd %UserProfile%
    git clone git://github.com/dbakker/vimfiles.git .vim
    echo source ~/.vim/.vimrc > .vimrc
    git clone git://github.com/gmarik/vundle.git .vim/bundle/vundle

Start vim, and install the plugins:

    :BundleInstall

then restart vim.

It might be a good idea to create a .vim/local.vim file:

    set ffs=dos " Force CR, LF line endings
