#compdef tx

local state
local -a options
local -a letters

_arguments \
    '1: :->session' 

case $state in
  (session) _arguments ':function:($(echo $(basename $PWD)) $(tmux ls | perl -lane '"'"'$F[0]=~/(.*):/;print $1'"'"'))' ;;
esac

