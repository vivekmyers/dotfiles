#compdef compnew

local state

_arguments '*: :($(print -rC1 -- ${commands} | sed "s|.*/||"))'
