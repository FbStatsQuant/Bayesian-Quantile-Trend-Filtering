#!/bin/bash
# Read the live shared queue before any submission, once NOTS access is authorized.
set -euo pipefail
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
bash "$root/engineering/E17_b0_1e5/ops/nots.sh" control 'bash -s' <<'REMOTE'
set -euo pipefail
date -Is
squeue -h -r -u fb31 -p commons -o '%F|%a|%j|%T|%C' |
    awk -F'|' 'NF==5 {
        key=$1 "|" $2 "|" $3 "|" $4
        tasks[key]++; cpus[key]+=$5; total++
    } END {
        printf "Commons submitted tasks: %d\n",total
        for (key in tasks) printf "%s|tasks=%d|requested_cpus=%d\n",key,tasks[key],cpus[key]
    }'
REMOTE
