#!/bin/bash
# Usage: install.sh

[ $USER == "root" ] && echo You should not install this for the root account. && exit 1

if [ ! -d ~/.vim ]; then
  git clone --recursive https://github.com/dbakker/vimfiles.git ~/.vim || exit 1
  git clone --recursive https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim || exit 1
  pushd ~/.vim>/dev/null
    git remote set-url origin git@github.com:dbakker/vimfiles.git
    git remote add https https://github.com/dbakker/vimfiles.git
  popd>/dev/null
  vim -c "silent! NeoBundleInstall" -c quit
else
  pushd ~/.vim>/dev/null
  git pull https master
  popd>/dev/null
  vim -c "silent! NeoBundleUpdate" -c quit
fi

[ -f ~/.vimrc ] || ln -s ~/.vim/.vimrc ~/.vimrc
