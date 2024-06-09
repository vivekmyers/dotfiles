#!/bin/bash

tpus=( anikait-tpu-{4-y,9-x} aviral-tpu-{14,16,17,22,4,5} bridge-tpu-{10,6,8,9} charlie-tpu2 marwa-language mitsuhiko-tpu-1 rail-pod-6 charles-sun-tpu-1 )

trap end 0 INT 
function end {
    pkill -P $$
    pkill -9 -P $$
}

function check {
    response="$(timeout -s 9 15s \
        gcloud alpha compute tpus tpu-vm ssh "$1" \
        -- 'sudo lsof -w /dev/accel'$2 2>&1)"
    code=${PIPESTATUS[0]}
    lines[$2]="$(echo "$response" | grep -E 'dev|ERROR' | wc -l | xargs)"
    users[$2]="$(echo "$response" | grep dev | awk 'NR>1 {print $3}' | sort | uniq | paste -sd, -)"
    test "${lines[$2]}" = 0 && users[$2]="----------"
}

function row {
    printf "%-10.10s %-18.18s %-10.10s %-10.10s %-10.10s %-10.10s\n" $@
}

for tpu in "${tpus[@]}"; do
    (
        lines=()
        users=()
        for i in {0..3}; do check $tpu $i; done
        total=$(IFS='*'; echo $((${lines[*]})))
        cores=( $(for i in {0..3}; do test "${lines[$i]}" = 0 && echo $i; done) )
        case $total:$code in
            *:137) row timeout: $tpu ;;
            0:*) ( IFS=''; row free: $tpu "${users[@]}" ) ;;
            *:0) ( IFS=','; row busy: $tpu "${users[@]}" ) ;;
            *:*) row error: $tpu "($code)" ;;
        esac
    ) &
done

wait
