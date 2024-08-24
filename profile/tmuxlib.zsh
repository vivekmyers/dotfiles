function tx {
    if [ -z $1 ]; then
        1="$(basename $PWD)"
    fi
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
    local name="$1"
    shift
    tmux new-session -d -s "$name" && tmux send-keys -t "$name" "$*" C-m
}

function tkrun {
    local name="$1"
    shift
    tmux kill-session -t "$name" 2>/dev/null
    trun "$name" "$@"
}

function _tinf {
    arg=$(printf "%-14s " "$1" | cut -c 1-14)
    pids=( $(tmux list-panes -t $1 -F "#{pane_pid}" ) ) 
    for i in $(seq 1 $((${#pids[@]}))); do
        pid=${pids[$i]}
        echo -n "$arg"
        if [[ $i -lt $((${#pids[@]} - 1)) ]]; then
            arg='  ├────────── '
        else
            arg='  └────────── '
        fi
        child=$(pgrep -P "$pid" | head -n1)
        if [[ -n "$child" ]]; then
            echo -n "$child" ':'
            ps -o command -p "$child" | awk 'NR>1'
        else
            echo "$pid" ':'
        fi
    done 
}

function tinf {
    args=("$@")
    if [ -z $1 ]; then
       args=($(tmux list-sessions -F "#{session_name}")) 
    fi
    ( printf "%-14s" "NAME";
      echo $'PID:CMD'
    rep _tinf "$args[@]" ) | column -ts:
}

function tkx {
    if [ -z $1 ]; then
        1="$(basename $PWD)"
    fi
    ( tmux kill-session -t $1 ) 2>/dev/null
    tmux new -s $1
}


function tc {
    tmux -CC attach || tmux -CC
}


function ta {
    if [ -z $1 ]; then
        tmux attach
    else
        tmux attach -t $1
    fi
}

function tsh {
    command ssh -t $1 "tmux -CC attach || tmux -CC"
}
