if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <host> <port> [notebook-dir]"
    return 1
fi

(
    ssh -t "$1" "~/conda/bin/zsh -lic 'cd ${3-.} && trun jupyter-$2 jupyter notebook --no-browser --port=$2'" || export SILENT=1
    tunnel "$2" "$1" "$2" &&
    sleep 1 &&
    ssh -t "$1" "~/conda/bin/zsh -lic 'jupyter server list'" | grep "localhost:$2" | cut -d' ' -f1
)

