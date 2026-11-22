#!/bin/bash
set -euo pipefail
root=/home/fb31/projects/Quant_Reg/Inner_Individual
run="$root/runs/VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z"
date -u --iso-8601=seconds
printf 'QUEUE_COUNTS\n'
squeue -r -h -j 1786240 -o '%T' | sort | uniq -c
printf 'ACCOUNTING_COUNTS\n'
sacct -X -n -j 1786240 --format=State --parsable2 | sort | uniq -c
printf 'PROCESS_JOB\n'
squeue -j 1786241 -o '%.24i %.12T %.12M %.35R'
printf 'SUCCESS_COUNT='; find "$run/tasks" -name SUCCESS -type f | wc -l
printf 'FAILURE_COUNT='; find "$run/tasks" -name failure.rds.txt -type f | wc -l
printf 'MONITOR\n'
tail -16 "$run/metadata/monitor/driver.log"
printf 'SAMPLE_FIT_LOG\n'
if [[ -f "$run/logs/inner_individual_1786240_1.out" ]]; then tail -4 "$run/logs/inner_individual_1786240_1.out"; fi
printf 'NONEMPTY_STDERR_COUNT='; find "$run/logs" -name '*.err' -size +0c | wc -l
printf 'HOME_QUOTA\n'; quota -s 2>/dev/null | head -5
