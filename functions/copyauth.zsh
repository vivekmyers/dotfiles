src="$1"
shift

for dst in "$@"; do
    if [[ src == "localhost" ]]; then
        key="$(cat ~/.ssh/id_rsa.pub)"
    else
        key="$(ssh "$src" 'cat ~/.ssh/id_rsa.pub')"
    fi &&
    ssh -J "$src" "$dst" 'tmp="$(mktemp)" &&
        trap "rm -f $tmp" EXIT &&
        ( cat ~/.ssh/authorized_keys &&
          echo "'$key'" ) > "$tmp" &&
        cat "$tmp" | sort | uniq > ~/.ssh/authorized_keys' &&
    echo "Key copied from $src to $dst" || {
        echo "Failed to copy key from $src to $dst"
        return 1
    }
done
