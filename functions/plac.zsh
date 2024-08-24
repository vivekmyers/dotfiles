#!/bin/zsh

function getsize {
    identify -verbose "$1" | awk '/Print size:/{print $3}' | awk -Fx '{
        x = int($1*1000);
        y = int($2*1000);
        if (y > 200) { x=int(x*200/y); y=200; }
        print x"x"y;
    }'
}

plac () {
    if [[ -f "$1" ]]; then
        local size="$(getsize "$1")"
        local arg="$(basename "${1%.*}")"
    elif [[ -f "$1.pdf" ]]; then
        local size="$(getsize "$1.pdf")"
        local arg="$(basename "${1%.*}")"
    elif [[ -f "build/$1.pdf" ]]; then
        local size="$(getsize "build/$1.pdf")"
        local arg="$(basename "${1%.*}")"
    elif [[ -f "equations/build/$1.pdf" ]]; then
        local size="$(getsize "build/$1.pdf")"
        local arg="$(basename "${1%.*}")"
    else
        local size="${2-$((100+25*(${#1}-1)))}x${3-100}"
        local arg="$1"
    fi
    echo "size: $size"
	local outfile="$HOME/resources/placeholders/placeholder_$arg.pdf"
	magick -size "${size}" -density 300 -background lime -gravity Center caption:"${arg}" "${outfile}"
    osascript -e 'set the clipboard to (POSIX file "'$outfile'")' 
    shortcuts run 'Clipit' --input-path "${outfile}"

	echo "${outfile}"
}

plac $@
