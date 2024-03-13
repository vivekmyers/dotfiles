if [ -z $1 ]; then
    echo "Usage: prep <cmd> <arg1> <arg2> ..."
    return
fi

local cmd=$1
shift

local pids=()
for i in $@; do
    eval "$cmd '$i' &"
    pids+=($!)
done

trap 'kill ${pids[@]} 2> /dev/null' EXIT INT
wait 

trap - EXIT INT
