#!/bin/bash

function rcadd {
    while read line; do
        eval "$line" &&
        echo "$line" >> ~/.local/etc/profile ||
        exit $?
    done
}

function rcdel {
    sed -n '$p' ~/.local/etc/profile
    sed -i '' '$d' ~/.local/etc/profile
}

function rcedit {
    vim +'set ft=bash' ~/.local/etc/profile
    source ~/.local/etc/profile
}

function rcat {
    cat ~/.local/etc/profile
}

if [[ ! -f ~/.local/etc/profile ]]; then
    touch ~/.local/etc/profile
fi
source ~/.local/etc/profile


function mkhome {
    echo "$(readlink -f ${1-$PWD})" > ~/.local/etc/autohome
}

function rmhome {
    rm ~/.local/etc/autohome
}

function echohome {
    [[ -f ~/.local/etc/autohome ]] && cat ~/.autohome
}

if [[ -f ~/.local/etc/autohome ]]; then
    cd $(cat ~/.local/etc/autohome)
fi

function getfrom {
    loc="$1:$(command ssh $1 'cat ~/.local/etc/autohome')"
    if [[ -n $2 ]]; then
        loc="$loc/$2"
    fi
    rsync -avz $loc .
    open "$(basename $1/$2)"
}

