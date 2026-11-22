#!/bin/bash
set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
run=runs/VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z
date -u --iso-8601=seconds
sacct -j 1786241 --format=JobID,State,ExitCode,Elapsed,MaxRSS --parsable2
tail -8 "$run/logs/inner_individual_process_1786241.out"
cat "$run/logs/inner_individual_process_1786241.err"
if [[ -f "$run/logs/process_1786241_exit.txt" ]]; then cat "$run/logs/process_1786241_exit.txt"; fi
find "$run/summary" -name SUCCESS -type f -print
