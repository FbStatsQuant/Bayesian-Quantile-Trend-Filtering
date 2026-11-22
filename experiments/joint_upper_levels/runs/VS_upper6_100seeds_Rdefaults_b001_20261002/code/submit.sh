#!/bin/bash
# This is the only production submission entry point. No jobs are submitted on upload.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
name=${1:-VS_upper6_$(date -u +%Y%m%dT%H%M%SZ)}
[[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || { echo 'Invalid run name' >&2; exit 2; }
run="$package/runs/$name"
raw="${RAW_BASE:-/scratch/fb31/qr_data/joint_sampler}/$name"
mkdir -p "$package/runs" "$(dirname "$raw")"
[[ ! -e "$run" && ! -e "$raw" ]] || { echo 'Run or raw directory already exists; choose a new name' >&2; exit 2; }
mkdir "$run" "$raw"
mkdir "$run/code" "$run/logs" "$run/metadata" "$run/tasks" "$run/summary"
ln -s "$raw" "$run/raw"
cp -a "$package/source" "$package/slurm" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/README.md" "$run/code/"
cd "$run/code"
source ./environment.sh
# Configuration and dependency preflight before any sbatch calls.
Rscript --vanilla -e 'source("config.R"); source("common.R"); source("check_defaults.R"); validate_config(cfg); check_sampler_defaults(cfg); stopifnot(identical(cfg$seeds, 1:100)); for (p in c("glmgen", "Rcpp")) stopifnot(requireNamespace(p, quietly=TRUE)); saveRDS(cfg, "../metadata/config.rds"); dput(cfg, file="../metadata/config.txt"); capture.output(sessionInfo(), file="../metadata/sessionInfo.txt")' | tee "$run/metadata/default_checks.txt"
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
cp SHA256SUMS "$run/metadata/source_SHA256SUMS"
chmod -R a-w "$run/code"
{ date -u --iso-8601=seconds; hostname; uname -a; module list; df -h "$raw"; } > "$run/metadata/environment.txt" 2>&1
printf '%q ' "$0" "$@" > "$run/metadata/submission_command.txt"; printf '\n' >> "$run/metadata/submission_command.txt"
printf '%s\n' "$raw" > "$run/metadata/raw_location.txt"
cd "$run"
: > metadata/array_jobs.tsv
printf 'sbatch --parsable --chdir=%q %q %q\n' "$run" "$run/code/slurm/all_noises.slurm" "$run" >> metadata/launch_commands.txt
job=$(sbatch --parsable --chdir="$run" "$run/code/slurm/all_noises.slurm" "$run")
job=${job%%;*}
printf 'all_noises\t%s\n' "$job" | tee -a metadata/array_jobs.tsv
deps=$(cut -f2 metadata/array_jobs.tsv | paste -sd: -)
printf 'sbatch --parsable --dependency=afterany:%s --chdir=%q %q %q\n' "$deps" "$run" "$run/code/slurm/process.slurm" "$run" >> metadata/launch_commands.txt
job=$(sbatch --parsable --dependency="afterany:$deps" --chdir="$run" "$run/code/slurm/process.slurm" "$run")
printf '%s\n' "${job%%;*}" > metadata/process_job_id.txt
printf 'Submitted run: %s\nRaw draws: %s\nProcessing job: %s\n' "$run" "$raw" "$job"
