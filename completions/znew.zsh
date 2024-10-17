#compdef znew

local state
local -a options
local -a letters

_arguments '*: :($(ls ~/config/functions | xargs basename -s .zsh))'
