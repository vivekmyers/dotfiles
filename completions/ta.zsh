#compdef ta

local state

_arguments \
    '1: :->session' 

case $state in
  (session) _arguments ':function:($(tmux ls | perl -lane '"'"'$F[0]=~/(.*):/;print $1'"'"'))' ;;
esac

