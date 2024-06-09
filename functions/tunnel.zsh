if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <local port> <remote host> <remote port>"
    return 1
fi

listeners=( $(lsof -i ":$1" | grep LISTEN | awk 'NR>1 {print $2}' | sort -n | uniq) )

if [ ${#listeners[@]} -gt 0 ]; then
    if [[ -n "$SILENT" ]]; then
        return 0
    fi
    for listener in "${listeners[@]}"; do
        read -k "REPLY?Kill process $(ps -p $listener | awk 'NR==2{print $4"["$1"]"}') listening on port $1? [y/N] "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill $listener
        else
            return 1
        fi
    done
fi

port=$((($RANDOM % 1000) + 2000))
autossh -M $port -qf -gNC -L "${1}:localhost:${3}" "$2"
