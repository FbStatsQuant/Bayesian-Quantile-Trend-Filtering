#!/bin/bash
# Validation of the individual job, inside a Slurm allocation (sbatch slurm/validate.slurm PACKAGE_DIR).
# Separate snapshot under validation/, tiny settings (n = 500 as in production, seeds 1-2, 60 sweeps, 20 burn-in, 11-point
# lambda grid), all 192 tasks of the four methods run sequentially, then: generator equivalence checks,
# duplicate-run refusal, refusal to average an incomplete run, processing, a dry run of the batch chain
# with a stub sbatch, and `sbatch --test-only` of the real production array options. Nothing is queued.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
[[ -n ${SLURM_JOB_ID:-} ]] || { echo 'Requires a NOTS Slurm allocation' >&2; exit 2; }
base=$(dirname "$package"); folders=(Extreme_Individual Extreme_admm Extreme_Onizuka)
source "$package/environment.sh"
for d in "${folders[@]}"; do (cd "$base/$d" && sha256sum --check --quiet SHA256SUMS); done
combined=$(cd "$base" && cat Extreme_Individual/SHA256SUMS Extreme_admm/SHA256SUMS Extreme_Onizuka/SHA256SUMS | sha256sum | cut -d' ' -f1)
run="$package/validation/check_$(date -u +%Y%m%dT%H%M%SZ)_${SLURM_JOB_ID}"
mkdir -p "$run/code" "$run/metadata" "$run/summary" "$run/tasks" "$run/logs"
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/validation_exit.txt"' EXIT
for d in "${folders[@]}"; do
  mkdir "$run/code/$d"
  (cd "$base/$d" && tar --exclude=./runs --exclude=./validation -cf - .) | (cd "$run/code/$d" && tar -xf -)
done
cd "$run/code"
for f in $(find . -name '*.sh' -o -name '*.slurm'); do bash -n "$f"; done
Rscript --vanilla -e 'for (f in list.files(".", pattern = "[.]R$", recursive = TRUE)) { parse(f); cat("PARSE_OK", f, "\n") }'
EXTREME_BASE_DIR="$base" Rscript --vanilla Extreme_Individual/validate_checks.R 2>&1 | tee "$run/logs/validate_checks.txt"
grep -q VALIDATE_CHECKS_SUCCESS "$run/logs/validate_checks.txt"
# Production batch table from the untouched config (for the --test-only check below).
Rscript --vanilla -e 'source("Extreme_Individual/config.R"); source("Extreme_Individual/common_extreme.R"); validate_config(cfg)
  b <- batch_table(cfg); b$concurrency <- cfg$concurrency
  write.table(b, "../metadata/production_batches.tsv", sep = "\t", quote = FALSE, row.names = FALSE)'
cat >> Extreme_Individual/config.R <<'EOF'
# ---- validation-only overrides (this snapshot only) ----
cfg$validation <- TRUE
cfg$seeds <- 1:2
cfg$mcmc_iter <- 60L
cfg$mcmc_burn <- 20L
cfg$pmala_validation_overrides <- list(warm_sweeps = 5L)
cfg$admm$lambda_grid <- exp(seq(-2, 8, by = 1))
EOF
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
chmod -R a-w "$run/code"
Rscript --vanilla -e 'source("Extreme_Individual/config.R"); source("Extreme_Individual/common_extreme.R"); validate_config(cfg)
  write.table(task_grid(cfg), "../metadata/task_manifest.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
  b <- batch_table(cfg); b$concurrency <- cfg$concurrency
  write.table(b, "../metadata/batches.tsv", sep = "\t", quote = FALSE, row.names = FALSE)'
ntask=$(($(wc -l < "$run/metadata/task_manifest.tsv") - 1))
for i in $(seq 1 "$ntask"); do
  bash ./Extreme_Individual/run_task.sh "$run" "$i" > "$run/logs/task_$i.out" 2> "$run/logs/task_$i.err" \
    || { echo "VALIDATION FAILED at task $i" >&2; tail -n 30 "$run/logs/task_$i.err" >&2; exit 1; }
done
echo "ALL $ntask TASKS OK"
if bash ./Extreme_Individual/run_task.sh "$run" 1 > "$run/logs/duplicate.out" 2>&1; then echo 'ERROR: completed task was overwritten' >&2; exit 1; fi
marker=$(find "$run/tasks/onizuka_hs" -name SUCCESS -print -quit)   # -quit, not | head: no SIGPIPE under pipefail
mv "$marker" "$marker.saved"
if Rscript --vanilla Extreme_Individual/process_results.R "$run" > "$run/logs/missing_task.out" 2>&1; then echo 'ERROR: incomplete run accepted' >&2; exit 1; fi
[[ -z $(find "$run/summary" -name summary.csv -print -quit) ]]
mv "$marker.saved" "$marker"
Rscript --vanilla Extreme_Individual/process_results.R "$run" 2>&1 | tee "$run/logs/process.out"
grep -q PROCESS_SUCCESS "$run/logs/process.out"
# Dry run of the whole chain with a stub sbatch that records the commands instead of queueing.
stub="$run/metadata/sbatch_stub.sh"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >> %q\necho 900$RANDOM\n' "$run/metadata/stub_commands.txt" > "$stub"; chmod +x "$stub"
: > "$run/metadata/array_jobs.tsv"
nb=$(($(wc -l < "$run/metadata/batches.tsv") - 1))
for b in $(seq 1 $((nb + 1))); do SBATCH="$stub" bash ./Extreme_Individual/chain.sh "$run" "$b"; done
cat "$run/metadata/stub_commands.txt"
[[ $(grep -c -- '--array=' "$run/metadata/stub_commands.txt") -eq "$nb" ]]
# The real scheduler must accept the production array options (validated only, nothing is queued).
command -v sbatch
while IFS=$'\t' read -r b method first last time mem name conc; do
  [[ "$b" == batch ]] && continue
  sbatch --test-only --chdir="$run" --job-name="$name" --time="$time" --mem="$mem" --array="${first}-${last}%${conc}" \
    --output=/dev/null "$run/code/Extreme_Individual/slurm/array.slurm" "$run" 2>&1 | tee -a "$run/logs/test_only.txt"
done < "$run/metadata/production_batches.tsv"
cd "$package"
for d in "${folders[@]}"; do (cd "$base/$d" && sha256sum --check --quiet SHA256SUMS); done
[[ $(cd "$base" && cat Extreme_Individual/SHA256SUMS Extreme_admm/SHA256SUMS Extreme_Onizuka/SHA256SUMS | sha256sum | cut -d' ' -f1) == "$combined" ]]
printf '%s\n' "$combined" > "validation/APPROVED_PACKAGE_SHA256.tmp_$SLURM_JOB_ID"
mv "validation/APPROVED_PACKAGE_SHA256.tmp_$SLURM_JOB_ID" validation/APPROVED_PACKAGE_SHA256
echo "VALIDATION_SUCCESS $run"
