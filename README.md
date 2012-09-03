# Vim configuration

This vim configuration uses git & the Vundle plugin.

To just install the basic standalone .vimrc use:

    curl -o ~/.vimrc https://raw.github.com/dbakker/vimfiles/master/.vimrc

## Doing a full install on Linux

First install gvim, git and optionally exuberant tags:

    sudo pacman -S gvim git ctags

Then download the settings:

    cd
    git clone https://github.com/dbakker/vimfiles.git .vim
    ln -s .vim/.vimrc .vimrc
    git clone https://github.com/gmarik/vundle.git .vim/bundle/vundle

start up vim and do:

    :BundleInstall

then restart vim.

## Doing a full install on Windows
First manually install GVim.

Then install msysgit, and follow the installation instructions for
[Vundle for Windows](https://github.com/gmarik/vundle/wiki/Vundle-for-Windows).

Then download the settings:

    cd %UserProfile%
    git clone https://github.com/dbakker/vimfiles.git .vim
    mklink .vimrc .vim/.vimrc
    git clone https://github.com/gmarik/vundle.git .vim/bundle/vundle

start up vim and do:

    :BundleInstall

then restart vim.
