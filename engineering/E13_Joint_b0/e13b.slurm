#!/bin/bash
# E-13a phase 2 on NOTS: one task of e13b_run.R per array index (1 core), or one check (E13B_MODE=check, indices 1-7).
# Runs from the code snapshot $RUN/code (after) and $RUN/code_before (commit 772a4a3); writes only under $RUN and $HOME/BQTF/tmp/<per-task>.
#   RUN=$HOME/BQTF/runs/E13b-joint-b0-fix-20261125
#   checks:     sbatch --array=1-7   --mem=4G --time=01:00:00 --job-name=bqtf-e13b-check --export=ALL,RUN=$RUN,E13B_MODE=check ...
#   joint:      sbatch --array=1-12  --mem=4G --time=03:00:00 --job-name=bqtf-e13b-joint --export=ALL,RUN=$RUN ...
#   individual: sbatch --array=13-44 --mem=2G --time=00:45:00 --job-name=bqtf-e13b-ind   --export=ALL,RUN=$RUN ...
#   (each with -o $RUN/logs/%x_%A_%a.out $RUN/code/engineering/E13_Joint_b0/e13b.slurm)
#SBATCH --partition=commons
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
set -euo pipefail
: "${RUN:?RUN not set}"
module purge >/dev/null 2>&1
module load GCC/14.3.0 R/4.5.2
export R_LIBS_USER=/home/fb31/R/library
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
i=${SLURM_ARRAY_TASK_ID:?array index}
tag="${SLURM_ARRAY_JOB_ID:-$SLURM_JOB_ID}_$i"
export E13_ROOT="$RUN/code" E13_BEFORE_ROOT="$RUN/code_before" E13_OUT="$RUN" TMPDIR="$HOME/BQTF/tmp/e13b_$tag" R_USER_CACHE_DIR="$HOME/BQTF/tmp/e13b_$tag/cache"
mkdir -p "$TMPDIR" "$R_USER_CACHE_DIR" "$RUN/logs" "$RUN/out" "$RUN/crash" "$RUN/checks"
cleanup() { for t in 1 2 3 4 5; do rm -rf "$TMPDIR" 2>/dev/null && return 0; sleep 10; done; echo "WARN: could not remove $TMPDIR" >&2; }   # NFS .nfs* files linger a few s
trap cleanup EXIT
echo "[$(date -Is)] host=$(hostname) task=$i mode=${E13B_MODE:-run}"
E=$E13_ROOT/engineering/E13_Joint_b0
if [ "${E13B_MODE:-run}" = check ]; then
  case $i in
    1) cd "$E13_ROOT/method/individual" && Rscript Individual_Sampler_PMALA_Augmented.R test ;;
    2) cd "$E13_ROOT" && Rscript "$E/e13b_joint_tests.R" ;;
    3) cd "$E13_ROOT" && E13_ZOUT="$RUN/checks/zdraw_ks.csv" Rscript "$E/e13b_zdraw_test.R" ;;
    4) cd "$E13_ROOT" && Rscript "$E/e13b_warm_check.R" ind hold ;;
    5) cd "$E13_ROOT" && Rscript "$E/e13b_warm_check.R" ind draw ;;
    6) cd "$E13_ROOT" && Rscript "$E/e13b_warm_check.R" joint hold ;;
    7) cd "$E13_ROOT" && Rscript "$E/e13b_warm_check.R" joint draw ;;
  esac
else
  cd "$E13_ROOT"
  Rscript "$E/e13b_run.R" task "$i" "${E13_ITER:-30000}" "${E13_BURN:-10000}"
fi
echo "[$(date -Is)] done"
