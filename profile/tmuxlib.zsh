function tx {
    tmux attach -t $1 || tmux new -s $1
}

function tk {
    if [ $1 == "-a" ]; then
        tmux kill-server
    else
        tmux kill-session -t $1
    fi
}

function tl {
    tmux list-sessions
}

function tmv {
    tmux rename-session -t $1 $2
}

function tnew {
    tmux new -s $1
}

function trun {
    tmux new -s $1 -d "$@"
}

function _tinf {
    pid=$(tmux list-panes -t $1 -F "#{pane_pid}")
    child=$(pgrep -P "$pid")
    echo -n "$1" ':'
    if [[ -n "$child" ]]; then
        echo -n "$child" ':'
        ps -o command -p "$child" | awk 'NR>1'
    else
        echo "$pid" ':'
    fi
}

function tinf {
    args=("$@")
    if [ -z $1 ]; then
       args=($(tmux list-sessions -F "#{session_name}")) 
    fi
    ( echo $'NAME:PID:CMD'
    rep _tinf "$args[@]" ) | column -ts:
}

function tkx {
    if [ -z $1 ]; then
        echo "No session specified"
        return 1
    fi
    tmux kill-session -t $1 &&
    tmux new -s $1
}

function ta {
    if [ -z $1 ]; then
        tmux attach
    else
        tmux attach -t $1
    fi
}
