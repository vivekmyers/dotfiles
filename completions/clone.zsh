#compdef clone

local state
local -a repos

IFS=$'\n' repos=($(gh repo list --json name,description,owner --limit 50 | jq -r 'to_entries | .[] | (.value.name + ":[\(.value.owner.login)~\(.key)] " + .value.description)'))

_arguments \
'1: :->repo' \
'2: :->target'

case $state in
  (repo) _describe 'repo' repos -o nosort ;;
  (target) _files -/'' ;;
esac

