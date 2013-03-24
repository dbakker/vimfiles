#!/bin/bash
if [ -z `gvim --serverlist` ]; then
    gvim
else
    if [ -z `which wmctrl`]; then
        gvim --remote-send "<ESC>:call foreground()<CR><C-L>"
    else
        wmctrl -x -a gvim
    fi
fi
