#!/bin/bash
# Read-only status of a run: task markers, queue and accounting counts.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/path_guard.sh"
run=$(realpath "${1:?RUN_DIR required}")
require_package_path "$run/code"
cd "$run"
date -u --iso-8601=seconds
jobs=$(cut -f2 metadata/array_jobs.tsv | paste -sd, -)
[[ ! -f metadata/process_job_id.txt ]] || jobs="$jobs,$(cat metadata/process_job_id.txt)"
cat metadata/array_jobs.tsv; [[ ! -f metadata/process_job_id.txt ]] || printf 'process\t%s\n' "$(cat metadata/process_job_id.txt)"
printf 'SUCCESS=%s FAILURE=%s LOCKED=%s\n' "$(find tasks -name SUCCESS -type f | wc -l)" \
  "$(find tasks -name failure.rds.txt -type f | wc -l)" "$(find tasks -name worker.lock -type d | wc -l)"
printf 'QUEUE\n'; squeue -r -h -j "$jobs" -o '%T' 2>/dev/null | sort | uniq -c || true
printf 'ACCOUNTING\n'; sacct -X -n -j "$jobs" --format=State --parsable2 | sort | uniq -c
printf 'NONEMPTY_STDERR=%s\n' "$(find logs -name '*.err' -size +0c | wc -l)"
