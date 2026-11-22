#!/bin/bash
# Read-only progress report:  bash status.sh RUN_DIR
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
echo "== completed tasks by method (SUCCESS markers)"
for m in pmala admm onizuka_lap onizuka_hs joint; do
  [[ -d "$run/tasks/$m" ]] || continue
  printf '%-12s %s\n' "$m" "$(find "$run/tasks/$m" -name SUCCESS | wc -l)"
done
echo "== failed attempts (exit_status=1)"
grep -rl 'exit_status=1' "$run/tasks" --include=exit_status.txt 2>/dev/null | wc -l
echo "== chain log"; tail -n 5 "$run/metadata/chain_log.tsv" 2>/dev/null || true
echo "== queue"; squeue -u "$USER" -h -r -o '%j %T' | sort | uniq -c
