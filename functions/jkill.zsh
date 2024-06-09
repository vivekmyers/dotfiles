
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <host> [port]"
    return 1
fi

ssh -t "$1" "~/conda/bin/zsh -lic 'tmux ls | cut -d: -f1 | grep jupyter-$2 | xargs -I{} tmux kill-session -t {}'"

