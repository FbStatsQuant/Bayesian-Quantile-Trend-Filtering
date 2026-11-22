#!/bin/bash
# Small implementation checks only, kept entirely separate from production runs.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
run="$package/validation/check_$(date -u +%Y%m%dT%H%M%SZ)_${SLURM_JOB_ID:-manual}"
mkdir -p "$run/code" "$run/logs" "$run/metadata" "$run/tasks" "$run/raw" "$run/summary"
cp -a "$package/source" "$package/slurm" "$run/code/"
cp "$package/"*.R "$package/"*.sh "$package/README.md" "$run/code/"
cd "$run/code"
source ./environment.sh
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/validation_exit.txt"' EXIT
for f in ./*.sh ./slurm/*.slurm; do bash -n "$f"; done
Rscript --vanilla -e 'for(f in list.files(".", pattern="[.]R$", recursive=TRUE, full.names=TRUE)) {parse(f); cat("PARSE_OK", f, "\n")}; for(p in c("glmgen", "Rcpp")) {stopifnot(requireNamespace(p,quietly=TRUE)); cat(p, as.character(packageVersion(p)), "\n")}; source("config.R"); source("common.R"); validate_config(cfg); stopifnot(identical(cfg$seeds, 1:100))'
# Two distinct seeds exercise averages and uncertainty calculations; all noises/taus.
cat >> config.R <<'EOF'
cfg$n <- 32L
cfg$seeds <- 1:2
cfg$sampler$gibbs_iter <- 24L
cfg$sampler$gibbs_burn <- 8L
cfg$sampler$warm <- 3L
EOF
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
for noise in Normal Beta Mixed; do
  for seed in 1 2; do
    bash ./run_task.sh "$run" "$noise" "$seed" > "$run/logs/${noise}_${seed}.out" 2> "$run/logs/${noise}_${seed}.err"
  done
done
# The processor must reject incomplete experiments.
mv "$run/tasks/Mixed/seed_002/SUCCESS" "$run/tasks/Mixed/seed_002/SUCCESS.saved"
if Rscript --vanilla ./process_results.R "$run" > "$run/logs/missing_task.out" 2>&1; then
  echo 'ERROR: processor accepted a missing task'; exit 1
fi
[[ ! -e "$run/summary/average_metrics_tau096_099.csv" ]]
mv "$run/tasks/Mixed/seed_002/SUCCESS.saved" "$run/tasks/Mixed/seed_002/SUCCESS"
Rscript --vanilla ./process_results.R "$run" > "$run/logs/processing.out" 2>&1
Rscript --vanilla ./validate_outputs.R "$run"
find "$run/tasks" "$run/summary" -type f -print0 | sort -z | xargs -0 sha256sum > "$run/metadata/validation_outputs_SHA256SUMS"
echo "VALIDATION_SUCCESS $run"
