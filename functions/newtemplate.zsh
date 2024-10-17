#!/bin/zsh


if [[ $# -lt 2 ]]; then
    echo "Usage: newtemplate <template_name> <file_name> ..."
    return 1
fi

if [[ -e ~/templates/$1 ]]; then
    echo "Template exists"
    return 1
fi

template_dir=~/templates/$1
mkdir $template_dir

shift
for file in $@; do
    cp $file $template_dir
done

( cd $template_dir; git add . )

