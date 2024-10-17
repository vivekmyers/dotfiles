#!/bin/zsh

if [[ ! -n "$1" ]]; then
    echo "Usage: znew <name>"
    return 1
fi
target="$CONFIGDIR/functions/$1.zsh"
vim "$target"

[[ -f "$target" ]] &&
( commit_config >~/.local/var/znew.$1.log 2>&1 & ) &&
{ ! command -v "$1" || unset -f "$1" ; } &&
autoload -Uz "$1" &&
rehash

