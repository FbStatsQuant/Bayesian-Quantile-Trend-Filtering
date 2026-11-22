#!/bin/bash
#SBATCH --job-name=joint_paper_compare
#SBATCH --partition=commons
#SBATCH --account=commons
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
set -euo pipefail
run=$(realpath "${1:?RUN_DIR required}")
source "$run/code/environment.sh"
cd "$run"
sha256sum --check metadata/comparison_source_SHA256SUMS
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/comparison_exit.txt"' EXIT
Rscript --vanilla "$run/postprocess/compare_paper.R" "$run"
sha256sum summary/comparison_paper_table2.* > metadata/comparison_output_SHA256SUMS
