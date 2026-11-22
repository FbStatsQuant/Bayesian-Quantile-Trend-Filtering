#!/bin/bash
# Small implementation checks only, kept entirely separate from production runs.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
run="$package/validation/check_$(date -u +%Y%m%dT%H%M%SZ)_${SLURM_JOB_ID:-manual}"
mkdir -p "$run/code" "$run/logs/shell" "$run/metadata" "$run/tasks" "$run/raw" "$run/summary"
cp -a "$package/source" "$package/slurm" "$package/paper_reference" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/"*.py "$package/README.md" "$run/code/"
cd "$run/code"
source ./environment.sh
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/validation_exit.txt"' EXIT
for f in ./*.sh ./slurm/*.slurm; do bash -n "$f"; done
python3 -m py_compile ./status.py
Rscript --vanilla -e 'for(f in list.files(".", pattern="[.]R$", recursive=TRUE, full.names=TRUE)) {parse(f); cat("PARSE_OK", f, "\n")}; for(p in c("glmgen", "Rcpp")) {stopifnot(requireNamespace(p,quietly=TRUE)); cat(p, as.character(packageVersion(p)), "\n")}; source("config.R"); source("common.R"); source("check_defaults.R"); validate_config(cfg); check_sampler_defaults(cfg); stopifnot(identical(cfg$seeds, 1:100))'
# The Slurm lookup must reproduce task_grid() exactly for every production index, under both
# launch layouts (one array, or one array per baseline with an offset).
Rscript --vanilla -e 'source("config.R"); source("common.R"); g <- task_grid(cfg); write_task_index(g, "../metadata/task_index.tsv"); write.table(cbind(seq_len(nrow(g)), g), "../metadata/grid_R.tsv", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)'
n_tasks=$(wc -l < "$run/metadata/task_index.tsv"); n_half=$((n_tasks / 2))
for i in $(seq 1 "$n_tasks"); do
  SLURM_ARRAY_TASK_ID=$i DECODE_ONLY=1 bash slurm/array.slurm "$run" 0
done > "$run/metadata/grid_slurm.tsv"
diff --strip-trailing-cr "$run/metadata/grid_R.tsv" "$run/metadata/grid_slurm.tsv"
for offset in 0 "$n_half"; do
  for i in $(seq 1 "$n_half"); do
    SLURM_ARRAY_TASK_ID=$i DECODE_ONLY=1 bash slurm/array.slurm "$run" "$offset"
  done
done > "$run/metadata/grid_slurm_split.tsv"
diff --strip-trailing-cr "$run/metadata/grid_R.tsv" "$run/metadata/grid_slurm_split.tsv"
if SLURM_ARRAY_TASK_ID=$((n_tasks + 1)) DECODE_ONLY=1 bash slurm/array.slurm "$run" 0 2>/dev/null; then
  echo 'ERROR: lookup accepted an out-of-range index'; exit 1
fi
echo "INDEX_DECODER_OK $n_tasks"
# Two distinct seeds exercise averages and uncertainty calculations; all baselines/noises/batches.
cat >> config.R <<'EOF'
cfg$n <- 32L
cfg$seeds <- 1:2
cfg$raw_keep_every <- 5L
cfg$sampler$gibbs_iter <- 24L
cfg$sampler$gibbs_burn <- 8L
cfg$sampler$warm <- 3L
EOF
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
Rscript --vanilla -e 'source("config.R"); source("common.R"); g <- task_grid(cfg); write.table(g, "../metadata/tiny_tasks.tsv", sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)'
n_tiny=$(wc -l < "$run/metadata/tiny_tasks.tsv")
last_batch=$(tail -n 1 "$run/metadata/tiny_tasks.tsv" | cut -d' ' -f3)
export RUN="$run"
xargs -P "${SLURM_CPUS_PER_TASK:-4}" -L 1 bash -c 'bash ./run_task.sh "$RUN" "$0" "$1" "$2" "$3" > "$RUN/logs/$0_$1_$2_$3.out" 2> "$RUN/logs/$0_$1_$2_$3.err"'   < "$run/metadata/tiny_tasks.tsv"
n_ok=$(find "$run/tasks" -name SUCCESS | wc -l)
[[ "$n_ok" == "$n_tiny" ]] || { echo "ERROR: only $n_ok of $n_tiny tiny tasks succeeded"; exit 1; }
# The processor must reject incomplete experiments.
gap="$run/tasks/S/Mixed/$last_batch/seed_002"
mv "$gap/SUCCESS" "$gap/SUCCESS.saved"
if Rscript --vanilla ./process_results.R "$run" > "$run/logs/missing_task.out" 2>&1; then
  echo 'ERROR: processor accepted a missing task'; exit 1
fi
[[ ! -e "$run/summary/average_metrics_targets.csv" ]]
mv "$gap/SUCCESS.saved" "$gap/SUCCESS"
Rscript --vanilla ./process_results.R "$run" > "$run/logs/processing.out" 2>&1
Rscript --vanilla ./validate_outputs.R "$run"
find "$run/tasks" "$run/summary" -type f -print0 | sort -z | xargs -0 sha256sum > "$run/metadata/validation_outputs_SHA256SUMS"
echo "VALIDATION_SUCCESS $run"
