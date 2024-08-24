for x in "$@"; do
    echo "Packing $x"
    prefix=${x%.*}
    prefix=${prefix##*/}
    typ=$(whence -wa $x | tail -n1 | cut -d' ' -f2)
    if [ "$typ" = "none" ]; then
        echo "No such command: $x"
        continue
    fi
    if [ "$typ" = "builtin" ]; then
        echo "Cannot pack built-in command: $x"
        continue
    fi
    if [ "$typ" = "function" ]; then
        autoload +X $x
        (
            echo "#!/bin/zsh"
            echo
            which $x
            echo
            echo "$x "'$@'
        ) > $prefix.zsh
        echo "Wrote $prefix.zsh"
    fi
    if [ "$typ" = "command" ]; then
        loc=$(which -a $x | tail -n1)
        if [ ! -f "$loc" ]; then
            echo "Could not find $x"
            continue
        fi
        if ! grep -q "ASCII text" <<< $(file $loc); then
            echo "Packing binary $x"
            cp $loc $prefix
            echo "Wrote $prefix"
        elif grep -Eq "^#!.*bin.*[^a-z]sh" $loc; then
            cat $loc > "$prefix.sh"
            echo "Wrote $prefix.sh"
        elif grep -Eq "^#!.*bin.*[^a-z]bash" $loc; then
            cat $loc > "$prefix.sh"
            echo "Wrote $prefix.sh"
        elif grep -Eq "^#!.*bin.*[^a-z]zsh" $loc; then
            cat $loc > "$prefix.zsh"
            echo "Wrote $prefix.zsh"
        elif grep -Eq "^#!" $loc; then
            cat $loc > "$x"
            echo "Wrote $x"
        else
            (
                echo "#!/bin/bash"
                echo
                cat $loc
            ) > "$prefix.sh"
            echo "Wrote $prefix.sh"
        fi
    fi
done
