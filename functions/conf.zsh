load utils

function exedit {
    local file="$(which $@ 2>/dev/null)"
    test -f "$file" && vim +'set ft=bash' "$(readlink -f $file)"
}

function editor { 
    echo "$@" | grep -qE "vim" && $EDITOR "$@" ||
    $EDITOR +"set ft=bash" +"filetype detect" "$@"
}

function endconf {
    ( commit_config "$1" & ) >> ~/.local/var/commit_config.log 2>&1
    test -z "$CONFCONT" && reprof;
}

function tryedit {
    if [[ -n "$1" ]] && [[ -f "$1" ]]; then
        editor "$(readlink -f $1)"
        endconf "$1"
    fi
}

function conf {
    if [[ ! -n "$1" ]]; then
        endconf
    fi
    if [[ "$1" == "makefile" ]] || [[ "$1" == "make" ]]; then
        vim ~/config/makefile
        endconf
    fi
    tryedit "$HOME/.$1"
    tryedit "$HOME/.$1rc"
    tryedit "$CONFIGDIR/$1"
    tryedit "$CONFIGDIR/functions/$1.zsh"
    tryedit "$CONFIGDIR/rc/$1"
    tryedit "$CONFIGDIR/rc/$1rc"
    tryedit "$HOME/etc/$1"
    tryedit "$HOME/etc/$1rc"
    #tryedit "$HOME/bin/$1.sh"
    tryedit "$HOME/.$1/config"
    for f in $fpath; do
        tryedit "$f/$1"
    done
    tryedit "$HOME/.vim/$1"
    tryedit "$HOME/.vim/autoload/$1"
    tryedit "$(sourced | grep -E "/$1$|/$1\.[^.]*$" | tail -n1)"
    editdef "$1" && endconf "$1"
    exedit "$1" && endconf "$1"
    return 1
}

conf "$@"
