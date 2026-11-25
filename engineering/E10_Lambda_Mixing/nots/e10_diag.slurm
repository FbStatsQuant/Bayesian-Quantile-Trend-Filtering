#!/bin/bash
# E-10 diagnostics on NOTS (1 core per task).  Array index -> e10_diag.R arguments:
#   0: proj | 1-8: exact <1-8> | 9-14: cross <tau 0.5/0.75/0.95> <new|old first> | 15-16: exact <9-10> (controls)
#   RUN=$HOME/BQTF/runs/E10-lambdamix-<date>
#   sbatch --array=0-14 --job-name=bqtf-e10-diag -o $RUN/diag/logs/%x_%A_%a.out --export=ALL,RUN=$RUN $RUN/code/nots/e10_diag.slurm
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=01:30:00
set -euo pipefail
: "${RUN:?RUN not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
CODE="${CODE:-$RUN/code_diag}"; i=${SLURM_ARRAY_TASK_ID:-0}
tag="${SLURM_JOB_ID}_$i"; export E10_CODE="$CODE" E10_OUT="$RUN/diag" TMPDIR="$HOME/BQTF/tmp/tmp_$tag"
mkdir -p "$TMPDIR" "$RUN/diag/logs"
taus=(0.5 0.5 0.75 0.75 0.95 0.95); firsts=(new old new old new old)
if [ "$i" -eq 0 ]; then a="proj"; elif [ "$i" -le 8 ]; then a="exact $i"; elif [ "$i" -le 14 ]; then j=$((i - 9)); a="cross ${taus[$j]} ${firsts[$j]}"; else a="exact $((i - 6))"; fi
echo "[$(date -Is)] host=$(hostname) task=$i args=$a"
Rscript "$CODE/e10_diag.R" $a
rm -rf "$TMPDIR"
echo "[$(date -Is)] done"
