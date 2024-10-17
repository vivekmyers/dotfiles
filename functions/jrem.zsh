if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <host> <port> [notebook-dir]"
    return 1
fi

(
    if ssh "$1" "nc -z localhost $2"; then
        echo "Port $2 is already in use on $1"
        export SILENT=1
    else
        ssh "$1" "~/conda/bin/zsh -lic 'cd ${3-.} && tkrun jupyter-$2 nocorrect jupyter notebook --no-browser --port=$2'"
    fi
    tunnel "$2" "$1" "$2" &&
    sleep 2 &&
    ssh "$1" "~/conda/bin/zsh -lic 'nocorrect jupyter server list'" | grep "localhost:$2" | cut -d' ' -f1
)

