#!/bin/bash
# This is the only production submission entry point. No jobs are submitted on upload.
# Usage: bash submit.sh RUN_NAME   (MAX_RUNNING=400 by default: total concurrent tasks;
#        AFTER_JOB=ID holds the arrays until that job, e.g. validation, finishes successfully;
#        TASK_FILTER='R condition on baseline/noise/batch/seed' runs only those tasks (pilot):
#        no processing job is submitted, since process_results.R requires the full grid)
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
name=${1:-interior_$(date -u +%Y%m%dT%H%M%SZ)}
max_running=${MAX_RUNNING:-400}
after_job=${AFTER_JOB:-}
export TASK_FILTER=${TASK_FILTER:-}
[[ -z "$after_job" || "$after_job" =~ ^[0-9]+$ ]] || { echo 'AFTER_JOB must be a job ID' >&2; exit 2; }
[[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || { echo 'Invalid run name' >&2; exit 2; }
run="$package/runs/$name"
raw="${RAW_BASE:-/scratch/fb31/qr_data/inner_joint}/$name"
mkdir -p "$package/runs" "$(dirname "$raw")"
[[ ! -e "$run" && ! -e "$raw" ]] || { echo 'Run or raw directory already exists; choose a new name' >&2; exit 2; }
mkdir "$run" "$raw"
mkdir -p "$run/code" "$run/logs/slurm" "$run/logs/shell" "$run/metadata" "$run/tasks" "$run/summary"
ln -s "$raw" "$run/raw"
cp -a "$package/source" "$package/slurm" "$package/paper_reference" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/"*.py "$package/README.md" "$run/code/"
cd "$run/code"
source ./environment.sh
# Configuration and dependency preflight before any sbatch calls.
Rscript --vanilla -e 'source("config.R"); source("common.R"); source("check_defaults.R"); validate_config(cfg); check_sampler_defaults(cfg); stopifnot(identical(cfg$seeds, 1:100)); for (p in c("glmgen", "Rcpp")) stopifnot(requireNamespace(p, quietly=TRUE)); saveRDS(cfg, "../metadata/config.rds"); dput(cfg, file="../metadata/config.txt"); g <- task_grid(cfg); f <- Sys.getenv("TASK_FILTER"); if (nzchar(f)) { keep <- eval(parse(text = f), g); stopifnot(is.logical(keep), length(keep) == nrow(g), !anyNA(keep), any(keep)); g <- g[keep, ]; rownames(g) <- NULL; cat("TASK_FILTER", f, "\n") }; write.csv(cbind(index = seq_len(nrow(g)), g), "../metadata/task_index.csv", row.names = FALSE); write_task_index(g, "../metadata/task_index.tsv"); for (b in names(cfg$batches)) cat("BATCH", b, "target", cfg$batches[[b]]$targets, "| levels", cfg$batches[[b]]$taus, "\n"); cat("TASKS", nrow(g), "\n"); capture.output(sessionInfo(), file="../metadata/sessionInfo.txt")' | tee "$run/metadata/default_checks.txt"
n_tasks=$(wc -l < "$run/metadata/task_index.tsv")
n_half=$((n_tasks / 2))
# The grid is baseline-major, so the second half of the index is exactly the S baseline.
if [[ -z "$TASK_FILTER" ]] && ! { [[ "$n_tasks" -gt 0 && $((n_tasks % 2)) == 0 ]] &&
        awk -F'\t' -v h="$n_half" '($1 <= h) != ($2 == "VS") { exit 1 }' "$run/metadata/task_index.tsv"; }; then
  echo 'task_index.tsv is not split VS | S at its midpoint' >&2; exit 2
fi
chmod a-w "$run/metadata/task_index.tsv" "$run/metadata/task_index.csv"
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
cp SHA256SUMS "$run/metadata/source_SHA256SUMS"
chmod -R a-w "$run/code"
{ date -u --iso-8601=seconds; hostname; uname -a; module list; df -h "$raw"; scontrol show config | grep -Ei 'MaxArraySize|MaxJobCount'; } > "$run/metadata/environment.txt" 2>&1
printf '%q ' "$0" "$@" > "$run/metadata/submission_command.txt"; printf '\n' >> "$run/metadata/submission_command.txt"
printf 'MAX_RUNNING=%s\nAFTER_JOB=%s\nTASK_FILTER=%s\n' "$max_running" "$after_job" "$TASK_FILTER" >> "$run/metadata/submission_command.txt"
printf '%s\n' "$raw" > "$run/metadata/raw_location.txt"
cd "$run"
: > metadata/array_jobs.tsv
# One array over all tasks when the site allows it; otherwise one array per baseline
# (offset 0 / n_tasks/2), splitting the concurrency cap between them.
max_array=$(scontrol show config | awk -F= '/^MaxArraySize/ {gsub(/ /, "", $2); print $2}')
if [[ -n "$TASK_FILTER" ]] || { [[ "$max_array" =~ ^[0-9]+$ ]] && ((max_array > n_tasks)); }; then
  parts=("all 1-$n_tasks 0 $max_running")
else
  half=$((max_running / 2))
  parts=("VS 1-$n_half 0 $half" "S 1-$n_half $n_half $half")
fi
for part in "${parts[@]}"; do
  read -r label range offset cap <<< "$part"
  cmd=(sbatch --parsable --array="${range}%${cap}" --chdir="$run")
  [[ -n "$after_job" ]] && cmd+=(--dependency="afterok:$after_job")
  cmd+=("$run/code/slurm/array.slurm" "$run" "$offset")
  printf '%q ' "${cmd[@]}" >> metadata/launch_commands.txt; printf '\n' >> metadata/launch_commands.txt
  job=$("${cmd[@]}")
  printf '%s\t%s\t%s\t%s\n' "$label" "${job%%;*}" "$offset" "$cap" | tee -a metadata/array_jobs.tsv
done
if [[ -n "$TASK_FILTER" ]]; then
  printf 'Submitted pilot run (%s tasks, no processing job): %s\nRaw draws: %s\nArrays:\n%s\n' "$n_tasks" "$run" "$raw" "$(cat metadata/array_jobs.tsv)"
  exit 0
fi
deps=$(cut -f2 metadata/array_jobs.tsv | paste -sd: -)
cmd=(sbatch --parsable --dependency="afterany:$deps" --chdir="$run" "$run/code/slurm/process.slurm" "$run")
printf '%q ' "${cmd[@]}" >> metadata/launch_commands.txt; printf '\n' >> metadata/launch_commands.txt
job=$("${cmd[@]}")
printf '%s\n' "${job%%;*}" > metadata/process_job_id.txt
printf 'Submitted run: %s\nRaw draws: %s\nArrays:\n%sProcessing job: %s\n' "$run" "$raw" "$(cat metadata/array_jobs.tsv)" "$job"
