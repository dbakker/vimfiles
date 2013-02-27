#!/bin/bash
[ -z `gvim --serverlist` ] && gvim || gvim --remote-send ":sil call foreground()<CR>"
