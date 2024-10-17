#!/bin/zsh

if [[ ! -n "$1" ]]; then
    echo "Usage: xnew <name>"
    return 1
fi
local target="$CONFIGDIR/bin/$1"
local extra=""
# if [[ ! -e "$target" ]]; then
#     local extra=+"norm! i#!/bin/bash
# cc
# "
# fi
vim +"set ft=bash" $extra "$target"

[[ -f "$target" ]] &&
chmod +x "$target" &&
rehash &&
( commit_config >~/.local/var/xnew.$1.log 2>&1 & )


