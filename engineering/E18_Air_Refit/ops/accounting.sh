#!/bin/bash
# Usage: accounting.sh SLURM_JOB_ID [SLURM_JOB_ID ...]
set -euo pipefail
(( $# ))
for id in "$@"; do [[ $id =~ ^[0-9]+$ ]]; done
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
ids=$(IFS=,; printf '%s' "$*")
bash "$root/engineering/E17_b0_1e5/ops/nots.sh" control \
    "sacct -j $ids -n -P --format=JobID%48,State%32,TotalCPU,ElapsedRaw,MaxRSS,AllocTRES%64,ExitCode,Submit,Eligible,Start,End"
