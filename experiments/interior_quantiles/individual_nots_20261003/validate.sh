#!/bin/bash
# To be submitted on NOTS only, after explicit deployment approval.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
[[ -n ${SLURM_JOB_ID:-} ]] || { echo 'Requires a NOTS Slurm allocation' >&2; exit 2; }
cd "$package"
sha256sum --check SHA256SUMS
source ./environment.sh
package_hash=$(sha256sum SHA256SUMS | cut -d' ' -f1)
run="$package/validation/check_$(date -u +%Y%m%dT%H%M%SZ)_${SLURM_JOB_ID}"
mkdir -p "$run/code" "$run/logs" "$run/metadata" "$run/tasks" "$run/raw" "$run/summary"
cp -a "$package/source" "$package/slurm" "$package/paper_reference" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/"*.py "$package/README.md" "$run/code/"
cd "$run/code"
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/validation_exit.txt"' EXIT
printf 'job_id=%s\nhost=%s\nstarted_utc=%s\n' "$SLURM_JOB_ID" "$(hostname)" "$(date -u --iso-8601=seconds)" > "$run/metadata/job.txt"
printf '%q ' "$0" "$@" > "$run/metadata/command.txt"; printf '\n' >> "$run/metadata/command.txt"
for f in ./*.sh ./slurm/*.slurm; do bash -n "$f"; done
Rscript --vanilla -e 'for(f in list.files(".", pattern="[.]R$", recursive=TRUE, full.names=TRUE)) {parse(f); cat("PARSE_OK", f, "\n")}'
Rscript --vanilla preflight.R > "$run/logs/preflight.txt" 2>&1
# Validation settings are confined to this separate copied code/config snapshot.
# Two seeds in every one of the 30 cells exercise paired data and standard errors.
cat >> config.R <<'EOF'
cfg$validation <- TRUE
cfg$n <- 32L
cfg$seeds <- 1:2
cfg$sampler$gibbs_iter <- 40L
cfg$sampler$gibbs_burn <- 12L
cfg$sampler$warm <- 3L
EOF
Rscript --vanilla -e 'source("config.R"); source("common.R"); validate_config(cfg); saveRDS(cfg,"../metadata/config.rds"); dput(cfg,file="../metadata/config.txt"); write.csv(task_grid(cfg),"../metadata/task_manifest.csv",row.names=FALSE)'
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
cp SHA256SUMS "$run/metadata/source_SHA256SUMS"
chmod -R a-w "$run/code"
for task in $(seq 1 60); do
  bash ./run_task.sh "$run" "$task" > "$run/logs/task_${task}.out" 2> "$run/logs/task_${task}.err"
done
# Completed tasks must reject reruns.
if bash ./run_task.sh "$run" 1 > "$run/logs/duplicate.out" 2>&1; then
  echo 'ERROR: completed task was overwritten' >&2; exit 1
fi
# Processing must fail on an incomplete run and write no averages.
marker="$run/tasks/S/Mixed/tau_0.95/seed_002/SUCCESS"
mv "$marker" "${marker}.saved"
if Rscript --vanilla process_results.R "$run" > "$run/logs/missing_task.out" 2>&1; then
  echo 'ERROR: incomplete run accepted' >&2; exit 1
fi
[[ -z $(find "$run/summary" -name average_metrics.csv -print -quit) ]]
mv "${marker}.saved" "$marker"
Rscript --vanilla process_results.R "$run" > "$run/logs/process.out" 2>&1
Rscript --vanilla validate_outputs.R "$run" > "$run/logs/raw_validation.out" 2>&1
find "$run/tasks" "$run/summary" "$run/logs" -type f -print0 | sort -z | xargs -0 sha256sum > "$run/metadata/validation_outputs_SHA256SUMS"
cd "$package"
sha256sum --check SHA256SUMS
[[ $(sha256sum SHA256SUMS | cut -d' ' -f1) == "$package_hash" ]]
printf '%s\n' "$package_hash" > "validation/APPROVED_PACKAGE_SHA256.tmp_${SLURM_JOB_ID}"
mv "validation/APPROVED_PACKAGE_SHA256.tmp_${SLURM_JOB_ID}" validation/APPROVED_PACKAGE_SHA256
printf 'VALIDATION_SUCCESS %s\n' "$run"
