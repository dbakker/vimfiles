#!/bin/bash
# Usage: install.sh

BUNDLE_URL=$1
BUNDLE_FILE=~/.vim/local/bundle.tar.xz

if [ ! -d ~/.vim ]; then
  git clone --recursive https://github.com/dbakker/vimfiles.git ~/.vim || exit 1
  pushd ~/.vim>/dev/null
    git remote set-url origin git@github.com:dbakker/vimfiles.git
  popd>/dev/null
else
  pushd ~/.vim>/dev/null
  git pull
  popd>/dev/null
fi

[ -f ~/.vimrc ] || ln -s ~/.vim/.vimrc ~/.vimrc

if [ -d ~/.vim/bundle/.git ]; then
  pushd ~/.vim/bundle>/dev/null
  git pull origin master -f
  popd>/dev/null
else
  [ -d ~/.vim/bundle ] && rm -rf ~/.vim/bundle
  git clone https://github.com/dbakker/vimfiles-plugins ~/.vim/bundle
fi
