
function eq {
    mkdir -p equations
    printf '%s\n' '$'"$2"'$' > "equations/$1.tex"
    rm -f "build/$1.pdf"
    make "build/$1.pdf"
    plac "$1"
}

eq "$@"
