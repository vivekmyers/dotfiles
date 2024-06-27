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

succ=()
fail=()

for host in ${hosts[@]}; do
    echo
    echo "Setting up $host"
    if timeout 300 zsh -lic "setup $host"; then
        succ+=($host)
    else
        fail+=($host)
    fi
done

for tpu in ${tpus[@]}; do
    echo
    echo "Setting up $tpu"
    if timeout 300 zsh -lic "setup $host"; then
        succ+=($tpu)
    else
        fail+=($tpu)
    fi
done

echo
echo

for host in ${succ[@]}; do
    echo "Successfully set up $host"
done

for host in ${fail[@]}; do
    echo "Failed to set up $host"
done
