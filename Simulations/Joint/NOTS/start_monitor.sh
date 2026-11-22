#!/bin/bash
set -euo pipefail
run=${1:?RUN_DIR required}
array=${2:?ARRAY_JOB_ID required}
process=${3:?PROCESS_JOB_ID required}
compare=${4:?COMPARISON_JOB_ID required}
mkdir -p "$run/metadata/monitor"
printf '%q ' python3 -u "$run/postprocess/monitor.py" "$run" "$array" "$process" "$compare" > "$run/metadata/monitor/launch_command.txt"
date -u --iso-8601=seconds > "$run/metadata/monitor/started_utc.txt"
nohup python3 -u "$run/postprocess/monitor.py" "$run" "$array" "$process" "$compare" > "$run/metadata/monitor/monitor.log" 2>&1 < /dev/null &
echo $! | tee "$run/metadata/monitor/pid.txt"
