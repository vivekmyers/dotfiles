sess="$1"
shift

port=$(($RANDOM % 1000 + 2000))
CMD=( autossh -M $port )

$CMD $@ -- "tmux attach -t $sess || tmux new -s $sess"
