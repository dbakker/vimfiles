#!/bin/bash
# Usage: install.sh

BUNDLE_FILE=~/.cache/vim/bundle.zip

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

[ -d ~/.vim/bundle ] && rm -rf ~/.vim/bundle
[ -d ~/.cache/vim ] || mkdir -p ~/.cache/vim
curl -s -o $BUNDLE_FILE -L https://github.com/dbakker/vimfiles-plugins/archive/master.zip
unzip -d ~/.vim -qq $BUNDLE_FILE
mv ~/.vim/vimfiles-plugins-master ~/.vim/bundle
