#!/bin/bash
# Usage: pending.sh SLURM_ARRAY_JOB_ID
set -euo pipefail
(( $# == 1 ))
[[ $1 =~ ^[0-9]+$ ]]
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
remote=$(cat <<'REMOTE'
set -euo pipefail
job=$1
date -Is
squeue --noheader --partition=commons --states=PENDING --format='%F|%i|%V|%R|%Q' |
    awk -F'|' -v job="$job" '
        NF == 5 {position++}
        $1 == job {printf "Job %s | submitted %s | reason %s | position %d in squeue listing | priority %s\n",
                         $2,$3,$4,position,$5}
    '
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e18-pending "$1"
bash "$root/engineering/E17_b0_1e5/ops/nots.sh" control "$cmd"
