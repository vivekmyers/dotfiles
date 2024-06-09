(
    cat ~/.ssh/config_tpus | grep ^Host | awk '{print $2}' | while read host; do
        if ssh -q -o ConnectTimeout=1 $host true; then
            echo $host
        fi & 
    done
    wait
)
