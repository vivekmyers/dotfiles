#!/bin/zsh

tmpfile=$(mktemp /tmp/tpu_list.XXXXXX)

extract_ssh() {
    echo "$1" | awk -v name="$2" -v RS=" " '
BEGIN {
    host = ""; user = ""; port = ""; identity = ""; delete options;
}
{
    if ($0 ~ /^ssh$/) { next; }
    else if ($0 ~ /^[^-]/) {
        split($0, parts, "@");
        user = parts[1];
        host = parts[2];
    }
    else if ($0 ~ /^-p$/) { getline; port=$0; }
    else if ($0 ~ /^-i$/) { getline; identity=$0; }
    else if ($0 ~ /^-o$/) { getline; split($0, opt, "="); options[opt[1]] = opt[2]; }
}
END {
    printf "Host %s\\n",name;
    printf "\\tHostName %s\\n",host;
    if (user != "") printf "\\tUser %s\\n",user;
    if (port != "") printf "\\tPort %s\\n", port;
    if (identity != "") printf "\\tIdentityFile %s\\n", identity;
    for (o in options) printf "\\t%s %s\\n",o,options[o];
}'
}

update_tpu_list() {
    TPUS=$(gcloud compute tpus list --zone=$1 --format="value(name)")

    for TPU in ${(f)TPUS}; do
        echo "Getting $TPU..."
        gcloud_ssh_command="gcloud compute tpus tpu-vm ssh --zone $1 $TPU"
        echo exit | eval "${gcloud_ssh_command}" 2>&1 > /dev/null
        raw_ssh_command=$(eval "${gcloud_ssh_command} --dry-run")
        echo $(extract_ssh $raw_ssh_command $TPU) >> $tmpfile
    done
}

update_tpu_list us-central1-a
update_tpu_list us-central2-b
update_tpu_list europe-west4-b

chmod 600 $tmpfile
mv $tmpfile ~/.ssh/config_tpus

rm ~/.ssh/google_compute_known_hosts
