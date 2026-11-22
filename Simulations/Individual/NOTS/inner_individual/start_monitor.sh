#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/path_guard.sh"
run=$(realpath "${1:?RUN_DIR required}")
require_inner_individual_path "$run/code"
cd "$run/code"
sha256sum --check --quiet SHA256SUMS
mkdir -p "$run/metadata/monitor"
[[ ! -e "$run/metadata/monitor/launch_pid.txt" ]] || { echo 'Monitor already launched; inspect it before retrying' >&2; exit 2; }
printf 'nohup python3 %q %q\n' "$run/code/monitor.py" "$run" > "$run/metadata/monitor/launch_command.txt"
nohup python3 "$run/code/monitor.py" "$run" > "$run/metadata/monitor/driver.log" 2>&1 < /dev/null &
printf '%s\n' "$!" | tee "$run/metadata/monitor/launch_pid.txt"
