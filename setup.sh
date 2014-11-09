#!/usr/bin/env bash
( cd bundle/vimproc && make -f make_unix.mak )
( cd bundle && [ ! -d jedi-vim ] && git clone --recursive --depth 1 https://github.com/davidhalter/jedi-vim && rm -rf jedi-vim/.git)
[ -e ~/.ctags ] || ln -s ~/.vim/ctagsrc ~/.ctags

vim +Helptags +qall

wait
