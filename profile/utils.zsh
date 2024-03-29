function trash {
    ext=""
    mkdir -p ~/.trash
    for x in "$@"; do
        y="$x"
        while [[ -f ~/.Trash/$x ]] || [[ -d ~/.Trash/$x ]]; do
            ext="-new"
            if [[ ${x%%.*} = $x ]]; then
                x="$x$ext"
            else
                x="${x%%.*}${ext}.${x##*.}"
            fi
        done
        args="'${y}' ~/.Trash/'$(basename "$x")'"
        echo "mv $args" | bash
    done
}

function edit {
    local file="$(which $@ 2>/dev/null)"
    test -f "$file" && $EDITOR +'set ft=bash' "$file"
}


function ml {
    mv -t "$2" "$1" &&
    dst="$2/$(basename "$1")" &&
    ln -s "$(readlink -f "$dst")" "$1"
}

function setup {
    local sock="$HOME/.ssh/sockets/setup:%r@%h:%p"
    commit_config &&
    ssh -nNfM -S "$sock" "$1" &&
    rsync -e "ssh -S $sock" -Oavz --delete --exclude ".git" --exclude cache ~/config/ "$1:~/config/" &&
    ssh -S "$sock" "$1" "cd ~/config && make ${2-all} $(test -n "$3" && echo "CONDA_PREFIX=$3")" &&
    ssh -O exit -S "$sock" "$1"
}

function copy_setup {
    ssh -O exit "$1" 2>/dev/null
    ( syncrc "$1" &&
      rsync -avz ~/bin/conda_setup.sh "$1:~/bin/" &&
    ssh "$1" "$(typeset -f install_conda reprof xlink); overwrite=$overwrite install_conda $2" )
}

function syncrc {
  ( cd ~
    for host in "$@"; do
        rsync --exclude '__pycache__' --exclude '.DS_Store' --exclude '.*.sw*' --exclude 'conda_setup.sh' --exclude 'cache' --exclude '*.log' \
            -avz .profile bin .zshrc .condarc .vimrc .tmux.conf \
            .gitconfig .gitignore_global .vim .zplug .omz environment.yml \
            "$host:~/"
    done )
}

function reprof {
    exec env -i $SHELL -l
}

function install_conda {
    ( 
        LOC="${1-$HOME/conda}"
        cd ~
        test -n "$overwrite" && rm -rf "$LOC" 
        test ! -e "$LOC" && (
            wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
            bash Miniforge3.sh -b -p "$LOC"
            rm Miniforge3.sh
        )
        sed 's|\$HOME/conda|'"$LOC"'|g' ~/bin/conda_setup.sh > ~/bin/.tmp.sh
        mv ~/bin/.tmp.sh ~/bin/conda_setup.sh
        "$LOC/bin/mamba" install -y zsh
        "$LOC/bin/mamba" env update -f ~/environment.yml
        export PATH="$HOME/.local/bin:$LOC/bin:$PATH"
        xlink tmux vim zsh wormhole conda-minify pipdeptree node npm black pipx pipreqs
        pipx install imgcat
    )
    if ! [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        reprof
    fi
}

function commit_config {
    find $CONFIGDIR -type f -name "*.sw[klmnop]" -delete -print | xargs -n1 -I{} echo "Deleted: {}"
    find $CONFIGDIR -name .DS_Store -delete -print | xargs -n1 -I{} echo "Deleted: {}"
    find $CONFIGDIR -name .git | while read line; do
        zsh -c "load utils; cd "$(dirname $line)" && git add . && acom"
    done
    zsh -c 'cd $CONFIGDIR && make'
}

function dl {
    target="$(readlink "$1")" &&
    unlink "$1" &&
    mv "$target" "$1"
}

function expose_ssh_port {
    function log {
        command echo ;
        command echo "$(hostname): $@" ;
    }

    ( log "adding own key to authorized_keys..." &&
        yes '' | ssh-keygen -N '' )

    (  cat ~/.ssh/authorized_keys ~/.ssh/id_rsa.pub | sort | uniq > ~/.ssh/authorized_keys.tmp &&
      mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys )

    ( log "forwarding port $1 to 22 with ssh..." && 
      export CMD=( ssh -o ExitOnForwardFailure=yes -fTN -L "*:${1}:localhost:22" localhost ) &&
      command "${CMD[@]}" && log "adding crontab entry: $(printf '%q ' "${CMD[@]}")" &&
      ( crontab -l ; echo "* * * * * $(printf '%q ' "${CMD[@]}")" ) | sort | uniq | crontab - )
}

function expose {
    if [[ -n "$2" ]]; then
        host=$1
        shift
        ssh -t "$@" "$(typeset -f expose_ssh_port); expose_ssh_port $host"
    else
        echo "Usage: expose <port> <host>"
        return 1
    fi ;
}

function sname {
    ssh -G "$1" | sed '/^hostname /!d;s/.* //'
}

function xlink {
    mkdir -p "$HOME/.local/bin"
    for x in "$@"; do
        cmd="$(readlink -f $(which "$x"))"
        if [[ -x "$cmd" ]]; then
            ln -sf "$cmd" "$HOME/.local/bin/$x"
        else
            echo "Command not found: $x"
            return 1
        fi
    done
}

function sourced {
    $SHELL -lixc "command -v conda && conda activate $CONDA_DEFAULT_ENV; exit" 2>&1 | sed -nE 's/^([^ ]*>|[+]*)( \. | source )(.*)$/\3/p' | grep -vE 'compdump|cache' 
}

function findsource {
    for x in $(sourced); do
        local lines=( $(sed -nE "/$1/=" "$x") )
        for line in "${lines[@]}"; do
            echo "$x:$line"
            awk "NR==$line" "$x" | grep -E --color=always "$1"
            echo
        done
    done
}

function editdef {
    local args=()
    for x in $(sourced); do
        local lines=( $({ cat "$x"; echo; } | sed -nE "/$1/{N; /^$1 *\( *\)( *(\n)*)*\{|^function *$1 *( *\( *\) *)?( *(\n)*)*\{|^export *$1=|^alias *$1=/=; }") )
        for line in "${lines[@]}"; do
            args=( $x "$(($line-1))" )
        done
    done
    test -n "$args" && $EDITOR +'set ft=bash' -c "${args[2]}" -c "norm! zz" "$(readlink -f ${args[1]})" &&
    source "${args[1]}"
}

function xinstall {
    for cmd in "$@"; do
        local file="$CONFIGDIR/bin/$(basename "$cmd")" &&
        if [[ -f "$file" ]]; then
            echo "File already exists: $file"
            return 1
        fi
        cp "$cmd" "$file" &&
        chmod +x "$file" &&
        rehash &&
        commit_config "$cmd" &&
    done
}

function znew {
    if [[ ! -n "$1" ]]; then
        echo "Usage: znew <name>"
        return 1
    fi
    target="$CONFIGDIR/functions/$1.zsh"
    vim "$target"

    [[ -f "$target" ]] &&
    commit_config "$1" &&
    unset -f "$1" &&
    autoload -Uz "$1" &&
    rehash 
}

function xnew {
    if [[ ! -n "$1" ]]; then
        echo "Usage: xnew <name>"
        return 1
    fi
    target="$CONFIGDIR/bin/$1"
    if [[ ! -e "$target" ]]; then
        extra=+"norm! i#!/bin/bashcc"
    fi
    vim +"set ft=bash" $extra "$target"

    [[ -f "$target" ]] &&
    chmod +x "$target" &&
    rehash &&
    commit_config "$1"
}

function libnew {
    if [[ ! -n "$1" ]]; then
        echo "Usage: libnew <name>"
        return 1
    fi
    target="$CONFIGDIR/profile/$1.zsh"
    vim "$target"

    [[ -f "$target" ]] &&
    source "$target" &&
    commit_config "$1"
}

function deswap {
    find "${1-$PWD}" -maxdepth 1 -type f -name "*.sw[klmnop]" -print -delete
}

function terms {
    yes '-' |  head -n$(tput lines) | awk 'NR>2' | xargs printf "%-$(tput cols)s\n" | tr ' ' '-'
}

function pkey {
    cat ~/.ssh/id_rsa.pub
}

function asrm {
    mkdir -p $HOME/.local/var

    for arg in "$@"; do
        target="${arg%/}.$RANDOM" &&
        mv "$arg" "$target" &&
        eval "nohup rm -rvf '$target' &>$HOME/.local/var/asrm.log &"
    done 
}

