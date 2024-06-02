if test -f "$1"; then
    spath=$(realpath "$1")
elif test -d "$1"; then
    spath=$(realpath "$1/$VIMSESSION")
elif test -f "$VIMSESSION"; then
    spath=$(realpath "$VIMSESSION")
else
    echo "No session file found"
    return 1
fi

if [[ "$(realpath "$spath")" != "$(realpath "$VIMSESSION")" ]]; then
    ln -sf "$spath" "$VIMSESSION"
fi
vim -S "$spath"

