#!/bin/bash
#SBATCH --job-name=joint_VS_process
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
cd "$run/code"
sha256sum --check SHA256SUMS
source ./environment.sh
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/logs/process_${SLURM_JOB_ID}_exit.txt"' EXIT
sacct -j "$(cut -f2 "$run/metadata/array_jobs.tsv" | paste -sd, -)" --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS --parsable2 > "$run/metadata/array_accounting.txt"
Rscript --vanilla ./process_results.R "$run"
find "$run/summary" -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > "$run/summary/SHA256SUMS"
