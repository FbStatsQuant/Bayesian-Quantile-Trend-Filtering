#!/bin/bash
# Validation of the joint job, inside a Slurm allocation (sbatch slurm/validate.slurm PACKAGE_DIR).
# Separate snapshot under validation/, tiny settings (n = 500 as in production, seeds 1-2, 60 sweeps, 20 burn-in, 5 warm
# sweeps), all 12 tasks run sequentially, then: generator equivalence, identical shared code with
# Extreme_Individual, duplicate-run refusal, refusal to average an incomplete run, processing (crossings
# of the joint posterior means must be zero), a stub-sbatch dry run of the chain, and `sbatch --test-only`
# of the production array options. Nothing is queued.
set -euo pipefail
package=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$package/path_guard.sh"
[[ -n ${SLURM_JOB_ID:-} ]] || { echo 'Requires a NOTS Slurm allocation' >&2; exit 2; }
source "$package/environment.sh"
(cd "$package" && sha256sum --check --quiet SHA256SUMS)
hash=$(sha256sum "$package/SHA256SUMS" | cut -d' ' -f1)
base=$(dirname "$package")
cmp "$package/common_extreme.R" "$base/Extreme_Individual/common_extreme.R"
run="$package/validation/check_$(date -u +%Y%m%dT%H%M%SZ)_${SLURM_JOB_ID}"
mkdir -p "$run/code/Extreme_Joint_Sampler" "$run/metadata" "$run/summary" "$run/tasks" "$run/logs"
trap 'rc=$?; printf "exit_status=%s\nfinished_utc=%s\n" "$rc" "$(date -u --iso-8601=seconds)" > "$run/metadata/validation_exit.txt"' EXIT
(cd "$package" && tar --exclude=./runs --exclude=./validation -cf - .) | (cd "$run/code/Extreme_Joint_Sampler" && tar -xf -)
cd "$run/code"
for f in $(find . -name '*.sh' -o -name '*.slurm'); do bash -n "$f"; done
Rscript --vanilla -e 'for (f in list.files(".", pattern = "[.]R$", recursive = TRUE)) { parse(f); cat("PARSE_OK", f, "\n") }'
Rscript --vanilla - <<'EOF' 2>&1 | tee "$run/logs/validate_checks.txt"
source("Extreme_Joint_Sampler/config.R"); source("Extreme_Joint_Sampler/common_extreme.R")
old <- setwd("Extreme_Joint_Sampler/source/Joint")
lines <- readLines("Joint_Sampler_PMALA_Augmented.R", warn = FALSE); main <- grep("^# ---- Main", lines); stopifnot(length(main) == 1L)
env <- new.env(parent = globalenv()); eval(parse(text = lines[seq_len(main - 1L)]), envir = env); setwd(old)
for (b in c("VS", "S")) for (nz in c("Normal", "Beta", "Mixed")) for (s in 1:3) {
  mine <- simulate_extreme(s, 500L, b, nz, cfg$fit_taus); ref <- env$simulate_data(s, 500L, cfg$fit_taus, b, nz)
  stopifnot(identical(mine$y, ref$y), identical(unname(mine$truth), unname(ref$truth)))
}
cat("CHECK_OK simulate_extreme == Joint simulate_data (y and six-level truth)\n")
mx <- parse(text = lines[main:length(lines)])
is_fit <- vapply(mx, function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("fit")), logical(1))
stopifnot(sum(is_fit) == 1L); call <- mx[[which(is_fit)]][[3]]
stopifnot(identical(call[[1]], as.name("gibbs_joint_pmala")), all(c("tau_list", "b0", "gibbs_iter", "gibbs_burn") %in% all.vars(call)), env$order == 2L)
cat("CHECK_OK joint Main call found:\n"); print(call)
saved <- mget(setdiff(all.vars(call), c("dat", "y")), envir = env)
cat("SAVED JOINT SETTINGS (before campaign overrides of tau_list, b0, gibbs_iter, gibbs_burn):\n"); str(saved)
cat("VALIDATE_CHECKS_SUCCESS\n")
EOF
grep -q VALIDATE_CHECKS_SUCCESS "$run/logs/validate_checks.txt"
Rscript --vanilla -e 'source("Extreme_Joint_Sampler/config.R"); source("Extreme_Joint_Sampler/common_extreme.R"); validate_config(cfg)
  b <- batch_table(cfg); b$concurrency <- cfg$concurrency
  write.table(b, "../metadata/production_batches.tsv", sep = "\t", quote = FALSE, row.names = FALSE)'
cat >> Extreme_Joint_Sampler/config.R <<'EOF'
# ---- validation-only overrides (this snapshot only) ----
cfg$validation <- TRUE
cfg$seeds <- 1:2
cfg$mcmc_iter <- 60L
cfg$mcmc_burn <- 20L
cfg$joint_validation_overrides <- list(warm_sweeps = 5L)
EOF
find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
chmod -R a-w "$run/code"
Rscript --vanilla -e 'source("Extreme_Joint_Sampler/config.R"); source("Extreme_Joint_Sampler/common_extreme.R"); validate_config(cfg)
  write.table(task_grid(cfg), "../metadata/task_manifest.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
  b <- batch_table(cfg); b$concurrency <- cfg$concurrency
  write.table(b, "../metadata/batches.tsv", sep = "\t", quote = FALSE, row.names = FALSE)'
ntask=$(($(wc -l < "$run/metadata/task_manifest.tsv") - 1))
for i in $(seq 1 "$ntask"); do
  bash ./Extreme_Joint_Sampler/run_task.sh "$run" "$i" > "$run/logs/task_$i.out" 2> "$run/logs/task_$i.err" \
    || { echo "VALIDATION FAILED at task $i" >&2; tail -n 30 "$run/logs/task_$i.err" >&2; exit 1; }
done
echo "ALL $ntask TASKS OK"
if bash ./Extreme_Joint_Sampler/run_task.sh "$run" 1 > "$run/logs/duplicate.out" 2>&1; then echo 'ERROR: completed task was overwritten' >&2; exit 1; fi
marker=$(find "$run/tasks/joint" -name SUCCESS | head -n 1)
mv "$marker" "$marker.saved"
if Rscript --vanilla Extreme_Joint_Sampler/process_results.R "$run" > "$run/logs/missing_task.out" 2>&1; then echo 'ERROR: incomplete run accepted' >&2; exit 1; fi
[[ -z $(find "$run/summary" -name summary.csv -print -quit) ]]
mv "$marker.saved" "$marker"
Rscript --vanilla Extreme_Joint_Sampler/process_results.R "$run" 2>&1 | tee "$run/logs/process.out"
grep -q PROCESS_SUCCESS "$run/logs/process.out"
Rscript --vanilla -e 'f <- list.files(commandArgs(TRUE)[1], "^summary.csv$", recursive = TRUE, full.names = TRUE); s <- read.csv(f)
  stopifnot(all(s$mean_crossings_all == 0)); cat("CHECK_OK joint posterior means never cross\n")' "$run/summary"
stub="$run/metadata/sbatch_stub.sh"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >> %q\necho 900$RANDOM\n' "$run/metadata/stub_commands.txt" > "$stub"; chmod +x "$stub"
: > "$run/metadata/array_jobs.tsv"
nb=$(($(wc -l < "$run/metadata/batches.tsv") - 1))
for b in $(seq 1 $((nb + 1))); do SBATCH="$stub" bash ./Extreme_Joint_Sampler/chain.sh "$run" "$b"; done
cat "$run/metadata/stub_commands.txt"
[[ $(grep -c -- '--array=' "$run/metadata/stub_commands.txt") -eq "$nb" ]]
command -v sbatch
while IFS=$'\t' read -r b method first last time mem name conc; do
  [[ "$b" == batch ]] && continue
  sbatch --test-only --chdir="$run" --job-name="$name" --time="$time" --mem="$mem" --array="${first}-${last}%${conc}" \
    --output=/dev/null "$run/code/Extreme_Joint_Sampler/slurm/array.slurm" "$run" 2>&1 | tee -a "$run/logs/test_only.txt"
done < "$run/metadata/production_batches.tsv"
cd "$package"
sha256sum --check --quiet SHA256SUMS
[[ $(sha256sum SHA256SUMS | cut -d' ' -f1) == "$hash" ]]
printf '%s\n' "$hash" > "validation/APPROVED_PACKAGE_SHA256.tmp_$SLURM_JOB_ID"
mv "validation/APPROVED_PACKAGE_SHA256.tmp_$SLURM_JOB_ID" validation/APPROVED_PACKAGE_SHA256
echo "VALIDATION_SUCCESS $run"
