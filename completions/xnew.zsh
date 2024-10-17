#compdef xnew

function _znew {
  local state

  _arguments \
    '*: :->function' \

  case $state in
      (function) _arguments '*:function:($(ls $HOME/config/bin | xargs basename -s .sh))' ;;
  esac
}

_znew "$@"
