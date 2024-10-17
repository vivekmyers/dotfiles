#!/bin/zsh

target=.
[[ -n "$1" ]] && target="$1"

(
    cd "$target"
    local TMP=$(mktemp -d)
    mkfifo "$TMP/pipe"
    if command -v inotifywait &>/dev/null; then
        CMD="inotifywait -m . -e create,modify"
    else
        CMD="while :; do fswatch .; done"
    fi
    zsh -c "$CMD" > "$TMP/pipe" & pid=$!
    trap "rm -rf $TMP; kill $pid 2>/dev/null; return" EXIT INT TERM

    tput reset
    while read file; do
        dd bs=64k if="$TMP/pipe" iflag=nonblock status=noxfer &>/dev/null
        file="$(echo "$file" | perl -pe 's|^.*[ /]([^ /]+)$|\1|')"
        if [[ "$file"  =~ .*\.\(png\|jpe\?g\|tiff\|gif\)$ ]]; then
            tput cup 0 0;
            imgcat --height $(($(tput lines)-1)) --width $(tput cols) "$file"
        fi
        if [[ "$file"  =~ .*\.\(pdf\)$ ]]; then
            convert -density 300 $file "$TMP/$file.png" 2>/dev/null && {
                tput cup 0 0;
                imgcat --height $(($(tput lines)-1)) --width $(tput cols) "$TMP/$file.png";
            }
        fi
    done < $TMP/pipe
)
