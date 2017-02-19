Dbakker's Vim settings
======================
Hope you find something useful!

Installing on Linux
-------------------
First install GVim, git and optional dependencies::

  sudo pacman -S gvim git ctags curl ack python2
  sudo apt-get install -y vim vim-gtk git exuberant-ctags perl python2 curl
  sudo apt-get install -y silversearcher-ag par python-pip pandoc xclip jq

Install my settings::

  git clone --depth 1 https://github.com/dbakker/vimfiles ~/.vim
  vim +Helptags +qall

It's also possible to install and run from a different location::

  git clone --depth 1 https://github.com/dbakker/vimfiles ~/.dbakker-vim
  vim -u ~/.dbakker-vim/vimrc

Install optional linters for Syntastic_::

  sudo apt-get install -y devscripts  # for "checkbashims"
  sudo pip install pep8 flake8 autopep8

Plugin architecture
-------------------
I commit the contents of plugins under `bundle/` (instead of fetching them
during install), this has 4 benefits:

#. It makes it possible to get all settings using just a simple `git clone`.
#. Plugins are automatically "locked" at a specific revision (similar to git submodules)
#. It doesn't matter if a source repository is down, rebased or deleted.

In short, you always have working versions of plugins.

Setting up CTags for standard libraries
---------------------------------------
This configuration automatically looks in `~/.vim.local/tags/[language]` when
working on a code of that language. This is useful for having a quick look at
the description or implementation of something out of a standard library.

These options are optimized on the fact that the sources won't change and that
we are not interested in their private variables/methods::

  cd ~/.vim.local/tags
  ctags -o python --excmd=number --python-kinds=-i -R path\to\python\lib
  ctags -o java --excmd=number --file-scope=no --java-kinds=-p -R path\to\java\source

Setting file/folder specific scripts
------------------------------------
Vim searches for file/folder specific scripts to execute. To edit or create one,
use `:EditScript` or `:EditScript file/folder`. Scripts created for a specific
folder will be executed whenever one of its files is opened. The scripts
themselves will be stored in the ~/.vim/local directory so they won't clutter
your filesystem.

This feature can be used to override settings, e.g.:

.. sourcecode:: vim

  let b:projectroot='/path/' " Override the path detected by GuessProjectRoot
  setl tags^=/path/tags
  setl bufhidden=delete " Useful for documentation that you don't need to keep open
  setl textwidth=79
  setl tabstop=2 softtabstop=2 shiftwidth=2
  setl noexpandtab
  Wrap

Note that for indentation related settings,
`editorconfig <https://github.com/editorconfig/editorconfig-vim>` seems like
a decent alternative.

For scavengers
--------------
Some cool places for more snippets:

* `Reddit's Vim subreddit <https://www.reddit.com/r/vim/>`_
* `Vim Tips Wiki <http://vim.wikia.com/wiki/Vim_Tips_Wiki>`_
* `Tpope dotfiles <https://github.com/tpope/tpope>`_
* `Spf13 vimfiles <https://github.com/spf13/spf13-vim/>`_
* `AndrewRadev vimfiles <https://github.com/AndrewRadev/Vimfiles>`_

.. _Syntastic: https://github.com/scrooloose/syntastic
