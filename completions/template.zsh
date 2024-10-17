#compdef template


function _template() {
  local state

  _arguments \
    '1:template:->template'\
    '2:target:->directory'\
    '-f:force:->flags'

    # some var can be any string -{A}={B} for {A} and {B} letters
  case $state in
      (template) _arguments '1:template:($(ls $HOME/resources/templates))' ;;
      (directory) _files -/'' ;;
      (flags) _arguments '-f: :->flags' ;;
  esac
}

_template "$@"
