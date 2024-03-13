(
    tput reset &&
    tmp="$(mktemp)" &&
    trap 'rm -f "$tmp"' EXIT &&

    while true; do
        echo -n "" > "$tmp" &&
        eval "$@" | for i in $(seq $(($(tput lines)))); do
            IFS= read -r line
            printf "%.$(($(tput cols)-1))s\n" "$(printf "%-$(tput cols)s" "$line")" >> "$tmp"
        done &&
        truncate -s -1 "$tmp" &&
        tput cup 0 0 &&
        cat "$tmp" &&
        sleep 1 || break
    done
)
