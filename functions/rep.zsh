if [ -z $1 ]; then
    echo "Usage: rep <cmd> <arg1> <arg2> ..."
    return
fi

cmd=$1
shift

for i in $@; do
    $cmd $i
done
