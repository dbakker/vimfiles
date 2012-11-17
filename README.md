# Vim configuration

This Vim configuration uses git & the [Vundle plugin](http://guessurl.appspot.com/?q=vundle).

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

then restart Vim.

## Doing a full install on Windows

Manually install:

  * [GVim](http://guessurl.appspot.com/?q=download+gvim)
  * [Msysgit](http://guessurl.appspot.com/?q=download+msysgit) (git for windows)
  * [Exuberant tags](http://guessurl.appspot.com/?q=download+exuberant+tags) (for tag navigation)
  * [Mingw](http://guessurl.appspot.com/?q=download+mingw) (if you add it to your PATH it enables unix commands)

Then download the settings:

    cd %UserProfile%
    git clone git://github.com/dbakker/vimfiles.git .vim
    echo source ~/.vim/.vimrc > .vimrc
    git clone git://github.com/gmarik/vundle.git .vim/bundle/vundle

Start Vim, and install the plugins:

    :BundleInstall

then restart Vim.

It might be a good idea to create a .vim/local.vim file with a subset of these:

    set mouse= " Disable mouse (for laptops with touchpads)
    set foldcolumn=3 " Allows mouse to click open folds
    set ff=unix " Force unix line endings
    set shellslash " Use / instead of \ in paths; don't combine with cmd.exe

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
be executed whenever one of its files is opened.

This feature is interesting for overriding global settings such as `makeprg`, `tags`,
`expandtab`, `shiftwidth`, `textwidth` and so on. Some other interesting settings:

    let b:projectroot='/path/' " Override the path detected by GuessProjectRoot
    setl bufhidden=delete " Useful for documentation that you don't need to keep open
    Wrap

