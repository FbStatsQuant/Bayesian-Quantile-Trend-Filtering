#!/bin/bash
#SBATCH --job-name=S_b00005_process
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
source "$run/code/path_guard.sh"
require_package_path "$run/code"
cd "$run/code"
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/logs/process_${SLURM_JOB_ID}_exit.txt"' EXIT
sha256sum --check --quiet SHA256SUMS
source ./environment.sh
sacct -j "$(cut -f2 "$run/metadata/array_jobs.tsv" | paste -sd, -)" --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS --parsable2 > "$run/metadata/array_accounting.txt"
Rscript --vanilla ./process_results.R "$run" ${2:-}
