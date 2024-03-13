for file in "$@"; do
    if [ -e "$ZSH/custom/$file.zsh" ]; then
        source $ZSH/custom/$file.zsh
        continue
    fi
    if [ -e "$HOME/.local/etc/$file.zsh" ]; then
        source $HOME/.local/etc/$file.zsh
        continue
    fi
    return 1
done
