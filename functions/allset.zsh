commit_config

hosts=(
    rnn
    brc
    datacol
    newton1
    newton2
    newton3
    vrbm.net
    eecs
)

for host in ${hosts[@]}; do
    echo "Setting up $host"
    setup $host
done
