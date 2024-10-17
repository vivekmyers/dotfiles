
#compdef gif2mp4

local state
local -a options
local -a letters

_arguments \
    '1: :->gif' \
    '2: :->mp4' \


case $state in
    (gif) _arguments '*:gif:($(ls | grep -i "\.gif$"))' ;;
    (mp4) _arguments '*:mp4:($(ls | grep -i "\.mp4$"))' ;;
    (*) _files ;;
esac


