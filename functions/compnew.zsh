#!/bin/zsh

if [[ ! -n "$1" ]]; then
    echo "Usage: compnew <name>"
    return 1
fi

if ! command -v $1; then
    echo "Function file not found: $base"
    return 1
fi

target="$CONFIGDIR/completions/$1.zsh"
vim "$target"

[[ -f "$target" ]] &&
( commit_config >~/.local/var/compnew.$1.log 2>&1 & ) &&
{ ! command -v "_$1" || unset -f "_$1" ; } &&
autoload -Uz "_$1" &&
rehash
