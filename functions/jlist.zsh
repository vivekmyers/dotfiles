
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <host>"
    return 1
fi

ssh -t "$1" "~/conda/bin/zsh -lic 'jupyter server list'"

