for file in "$@"; do
    # if eval "test ! -z \$LOAD_$file"; then
    #     continue
    # fi
    if [ -e "$ZSH/custom/$file.zsh" ]; then
        source $ZSH/custom/$file.zsh
        eval "LOAD_$file=1"
        continue
    fi
    if [ -e "$HOME/.local/etc/$file.zsh" ]; then
        source $HOME/.local/etc/$file.zsh
        eval "LOAD_$file=1"
        continue
    fi
    return 1
done
