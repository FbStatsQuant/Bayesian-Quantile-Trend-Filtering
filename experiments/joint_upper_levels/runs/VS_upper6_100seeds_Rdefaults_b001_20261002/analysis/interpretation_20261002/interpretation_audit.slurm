#!/bin/bash
#SBATCH --job-name=joint_interpretation
#SBATCH --partition=debug
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=6G
#SBATCH --time=00:15:00
#SBATCH --output=audit_%j.out
#SBATCH --error=audit_%j.err
set -euo pipefail
root=${1:?RUN_ROOT required}
out=${2:?AUDIT_DIR required}
cd "$out"
source "$root/code/environment.sh"
sha256sum --check SOURCE_SHA256SUMS
date -u --iso-8601=seconds > started_utc.txt
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > exit_status.txt' EXIT
Rscript --vanilla interpretation_audit.R "$root" "$out"
sha256sum ./*.csv audit.rds > OUTPUT_SHA256SUMS
