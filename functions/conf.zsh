load utils

function exedit {
    local file="$(which $@ 2>/dev/null)"
    test -f "$file" && {
        if [[ -n "$PRINT" ]]; then
            echo "$file"
        else
            vim +'set ft=bash' "$(readlink -f $file)"
        fi
        endconf "$file"
    }
}

function editor { 
    test -f "$1" && {
        if [[ -n "$PRINT" ]]; then
            echo "$@"
        else
            vim +"set ft=bash" +"filetype detect" "$@"
        fi
    }
}

function endconf {
    if [[ -z "$PRINT" ]]; then
        ( commit_config "$1" & ) >> ~/.local/var/commit_config.log 2>&1
    fi
    test -z "$CONFCONT" && exit;
}

function tryedit {
    if [[ -n "$1" ]] && [[ -f "$1" ]]; then
        editor "$(readlink -f $1)"
        endconf "$1"
    fi
}

(

    while :; do
        case "$1" in
            -h|--help)
                echo "Usage: conf [-pc] [name]"
                echo "Edit configuration files"
                exit 0
                ;;
            -p|--print)
                shift
                export PRINT=1
                ;;
            -c|--continue)
                shift
                export CONFCONT=1
                ;;
            -pc|-cp)
                shift
                export PRINT=1
                export CONFCONT=1
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ ! -n "$1" ]]; then
        endconf
    fi
    if [[ "$1" == "makefile" ]] || [[ "$1" == "make" ]]; then
        tryedit ~/config/makefile
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
    PRINT=$PRINT editdef "$1"
    exedit "$1"
    exit 1
) &&
if [[ -z "$PRINT" ]]; then
    reprof
fi

