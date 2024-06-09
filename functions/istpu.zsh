cat ~/.ssh/config_tpus | grep ^Host | awk '{print $2}' | grep -q "$1"
