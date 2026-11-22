#!/bin/bash
set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
run=runs/VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z
grep -qx 'exit_status=0' "$run/logs/process_1786241_exit.txt"
mapfile -t markers < <(find "$run/summary" -name SUCCESS -type f)
[[ ${#markers[@]} == 1 ]]
summary=$(dirname "${markers[0]}")
sha256sum --check --quiet "$summary/OUTPUT_SHA256SUMS"
wc -l "$summary/average_metrics.csv" "$summary/per_seed_metrics.csv" "$summary/task_status.csv"
head -4 "$summary/average_metrics.csv"
tar -czf deployment/completed_1786240_audit.tar.gz "$run/code" "$run/metadata" "$run/summary" "$run/logs" "$run/tasks"
sha256sum deployment/completed_1786240_audit.tar.gz > deployment/completed_1786240_audit.tar.gz.sha256
cat deployment/completed_1786240_audit.tar.gz.sha256
du -h deployment/completed_1786240_audit.tar.gz
