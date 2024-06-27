setup "$1"
yes | ( expose 2345 "$2" -J "$1" )
yes | ( ssh -t "$1" "zsh -ic 'setup $2'" )

