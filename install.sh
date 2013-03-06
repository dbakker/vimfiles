#!/bin/bash
# Usage: install.sh [bundle URI]
# Updates the bundle dir with the archive at the given URI if necessary

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

[ -z $BUNDLE_URL ] && exit 0

# Download a newer version of my plugins if available
if [ -f $BUNDLE_FILE ]; then
  MODDATE=`date -r $BUNDLE_FILE`
  curl -s -z $BUNDLE_FILE -o -L $BUNDLE_URL
else
  MODDATE=0
  curl -s -o $BUNDLE_FILE -L $BUNDLE_URL
fi

# Integrity check
if ! tar -tJf $BUNDLE_FILE>/dev/null; then
  echo Could not update bundle>&2
  rm $BUNDLE_FILE 2>/dev/null
  exit 1
fi

if [ "$MODDATE" != "`date -r $BUNDLE_FILE`" ]; then
  rm -rf ~/.vim/bundle/*
  pushd ~/.vim/bundle>/dev/null
  tar -xJf $BUNDLE_FILE
  popd>/dev/null
fi
