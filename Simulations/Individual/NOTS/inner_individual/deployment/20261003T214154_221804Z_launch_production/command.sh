#!/bin/bash
set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
name=VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z
bash submit.sh "$name" 2>&1 | tee "deployment/production_submission_${name}.log"
run="$PWD/runs/$name"
bash start_monitor.sh "$run"
scontrol show job "$(cut -f2 "$run/metadata/array_jobs.tsv")"
squeue -u fb31 -o '%.28i %.26j %.12T %.10M %.30R'
