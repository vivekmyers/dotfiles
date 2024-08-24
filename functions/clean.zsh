function mark_clean {
    local not=$1
    if [[ -n "$not" && ! -e "$not" ]]; then
        echo "File not found: $not"
        return
    fi

    if [[ -n "$not" ]]; then
        echo "$not" >> .registry
        cat .registry | sort | uniq > .registry.tmp
        mv .registry.tmp .registry
    fi
}

function mark_dirty {
    local not=$1
    if [[ -n "$not" && ! -e "$not" ]]; then
        echo "File not found: $not"
        return
    fi

    if [[ -n "$not" ]]; then
        cat .registry | sed "/$not/d" > .registry.tmp
        mv .registry.tmp .registry
    fi
}


(
    cd

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -d|--delete) clean=1 ;;
            -t|--trash) trash=1 ;;
            -s|--scratch) scratch=1 ;;
            -k|--keep) mark_clean "$2"; shift ;;
            -m|--mark) mark_dirty "$2"; shift ;;
            -h|--help) help=1 ;;
        esac
        shift
    done

    if [[ -n "$clean" && -n "$trash" ]]; then
        echo "Cannot clean and trash at the same time"
        return
    fi

    if [[ -n "$help" ]]; then
        echo "Usage: clean [OPTION] [FILES]"
        echo "  -d, --delete   Clean junk files"
        echo "  -t, --trash    Move junk files to trash"
        echo "  -s, --scratch  Move junk files to scratch"
        echo "  -k, --keep     Mark file as not junk"
        echo "  -m, --mark     Mark file as junk"
        echo "  -h, --help     Display this help message"
        echo "Default: List junk files"
        return
    fi


    exec 3</dev/tty || exec 3<&0

    bash -c 'diff <(cat .registry | sort) <(printf "%s\n" * .* | sort) | grep ">" | cut -c 3-' | while read file; do
        if [[ "$file" == "." || "$file" == ".." ]]; then
            continue
        fi
        if [[ -n "$trash" ]]; then
            trash "$file" && echo "Trashed: $file" || echo "Failed to trash: $file"
        elif [[ -n "$scratch" ]]; then
            safe_copy "$file" ~/scratch <&3 && rm -f "$file" &&
                { echo "Moved: $file" || echo "Failed to move: $file"; }
        elif [[ -n "$clean" ]]; then
            read -q "ans?Delete $file? [y/N] " <&3
            echo
            if [[ "$ans" == "y" ]]; then
                rm -rf "$file" &&
                echo "Deleted: $file" ||
                echo "Failed to delete: $file"
            else
                echo "Keeping: $file"
            fi
        else
            echo "$file"
        fi
    done 
)
