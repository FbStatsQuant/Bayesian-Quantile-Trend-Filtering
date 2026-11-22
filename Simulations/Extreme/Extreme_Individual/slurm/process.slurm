#!/bin/bash
# Verifies and summarises the whole individual run. Submitted by chain.sh after the last batch.
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=06:00:00
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
source "$run/code/Extreme_Individual/path_guard.sh"
require_extreme_path "$run/code"
cd "$run/code"
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/process_${SLURM_JOB_ID}_exit.txt"' EXIT
sha256sum --check --quiet SHA256SUMS
source Extreme_Individual/environment.sh
sacct -j "$(cut -f3 "$run/metadata/array_jobs.tsv" | paste -sd, -)" --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS \
  --parsable2 > "$run/metadata/array_accounting.txt" || true
Rscript --vanilla Extreme_Individual/process_results.R "$run"
