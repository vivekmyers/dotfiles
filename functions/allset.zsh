commit_config

trap 'kill $$' INT

hosts=(
    rnn
    brc
    datacol
    newton1
    newton2
    newton3
    vrbm.net
    eecs
    shallow
)

tpus=(
    $(listtpus)
)

for host in ${hosts[@]}; do
    echo
    echo "$(tput setaf 1)$(tput bold)Setting up $host$(tput sgr0)"
    timeout 300 zsh -lic "setup $host" 
done

for tpu in ${tpus[@]}; do
    echo
    echo "$(tput setaf 1)$(tput bold)Setting up $tpu$(tput sgr0)"
    timeout 300 zsh -lic "setup $host" 
done

