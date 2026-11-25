# E-14 Interior quantile rerun

The 3,000 Bayesian-PMALA chains cover VS and S at `n = 500`, trend filtering
order 2, five quantiles (0.05, 0.25, 0.50, 0.75, 0.95), three noises
(`Normal`, `Beta`, `Mixed`), and data seeds 1–100. Slurm indices are 0–2999.
Seed varies fastest, then quantile, noise, and signal, in the orders listed
above. The chain seed is `10001 + index`, set after data generation with
Mersenne-Twister, Inversion, and Rejection RNG settings. For example, index 0
is `VS_Normal_t05_s001`, with chain seed 10001.

Each chain runs 30,000 sweeps with 10,000 discarded as burn-in, including
200 warm sweeps. Both signals use the spline-held ASIS move
(`asis = TRUE`, `asis_q = "fixed"`, cycling through dimensions 10, 20, and
40), no θ block move, and diminishing adaptation throughout the run.
The σ prior is IG(0.1, 0.1). The λ prior is Gamma with shape 1 and rate
0.001 for VS or 0.0005 for S. The remaining settings come from the pinned
sampler script.

Each successful task writes an `out/<id>.rds` containing the posterior mean
(`est`), pointwise 95% interval (`lo`, `hi`, R quantile type 7), truth,
metrics, diagnostics, sampler commit, and host. The λ and σ traces keep at
most 1,000 points over the full chain with their sweep indices. λ ESS uses
`coda::effectiveSize` on the full post-burn-in λ trace. `seconds` measures
the sampler's elapsed time. Caught R errors write `out/<id>.fail.rds` and
return a nonzero status. An interruption before the runner can write a
file leaves a missing ID and a Slurm log. Reruns skip existing success
files and clear the failure marker when a retry succeeds.

## Metric definitions

The original [`process_results.R`](../../experiments/interior_quantiles/individual_nots_20261003/process_results.R)
recomputes metrics with the following call and averages them over seeds in
each cell.

```r
    recalculated <- curve_metrics(x$est, x$lo, x$hi, x$dat$truth)
```

```r
  for (key in c("MSE", "MAD", "MCIW", "coverage")) {
    out[[paste0("mean_", key)]] <- mean(d[[key]])
    out[[paste0("se_", key)]] <- sd(d[[key]]) / sqrt(nrow(d))
  }
```

The corresponding equations are defined in the original
[`common.R`](../../experiments/interior_quantiles/individual_nots_20261003/common.R).

```r
curve_metrics <- function(est, lo, hi, truth) c(
  MSE = mean((est - truth)^2), MAD = mean(abs(est - truth)),
  MCIW = mean(hi - lo), coverage = mean(truth >= lo & truth <= hi))
```

## Snapshot and Slurm

The approved sampler commit is `63f2a56205b8d2ec311565db8c98874cd96754b2`.
Transfer the code by Git bundle between submissions. Verify the bundle in
the source repo and on NOTS, then compare the resulting NOTS checkout's
HEAD to the advertised Owls HEAD. Assemble the snapshot from the
verified NOTS checkout. Set `SNAPSHOT` to an empty staging directory
under `$HOME/BQTF`.

```bash
set -euo pipefail
sampler_commit=63f2a56205b8d2ec311565db8c98874cd96754b2
engineering_commit=$(git rev-parse --verify HEAD)
git merge-base --is-ancestor "$sampler_commit" "$engineering_commit"
e14=engineering/E14_Inner_Rerun
original=experiments/interior_quantiles/individual_nots_20261003/source
git archive "$sampler_commit" method/individual/Individual_Sampler_PMALA_Augmented.R \
    method/individual/prox_admm_metric.cpp method/joint/prox_box_metric.cpp |
    tar -xf - -C "${SNAPSHOT:?}"
git archive "$engineering_commit" "$e14/e14_run.R" "$e14/e14_check.R" "$e14/e14.slurm" \
    "$e14/e14_data.R" "$original/Individual_Sampler_PMALA_Augmented.R" |
    tar -xf - -C "$SNAPSHOT"
printf 'Sampler-Commit: %s\nEngineering-Commit: %s\n' "$sampler_commit" "$engineering_commit" \
    > "$SNAPSHOT/run_manifest.dcf"
```

Copy the snapshot contents into `$RUN/code` and create `$RUN/logs` before
submission. The pilot uses the separate `E14-inner-rerun-20261125-pilot`
run directory and task indices `0,700,1400,1900,2000,2700`, covering both
signals and each noise with low, middle, and high quantiles. Submit the
full array only if all six tasks finish, all have zero σ guards and
acceptance between 0.4 and 0.6, and the mean per-task CPU time projects
to at most 150 core-hours for 3,000 tasks. Size the final memory request
from the pilot's largest MaxRSS with headroom.

Pilot array `2890600` passed on 2026-11-25. All six tasks completed with
zero σ guards and post-burn-in acceptance of 0.49585–0.50080. Mean CPU
time was 140.780 s per task, projecting to 117.3 core-hours. The largest
Slurm MaxRSS was 507,664 KiB (495.8 MiB) and the longest task took 150 s.
The full array requests 768 MiB, one core, and 15 minutes per task.
At 600 concurrent tasks the array requests 450 GiB of the 2,304 GiB
commons per-user memory cap.

```bash
RUN="$HOME/BQTF/runs/E14-inner-rerun-20261125"
code="$RUN/code/engineering/E14_Inner_Rerun"
mkdir -p "$RUN/logs"
sbatch --array=0-2999%600 --export="ALL,RUN=$RUN" \
    --output="$RUN/logs/%x_%A_%a.out" "$code/e14.slurm"
```

The job uses the GCC/14.3.0 and R/4.5.2 modules and reads packages from
`/home/fb31/R/library`. Its task-specific temporary files and Rcpp cache
go under `$HOME/BQTF/tmp/<array_jobid>_<taskid>`. The exit handler retries
directory cleanup on NFS.

Once the array has finished, run the checker to list missing IDs,
failure files, and a command to resubmit the missing tasks with the same
throttle. It exits with status 1 while any tasks are missing or failure
markers remain.

```bash
Rscript --vanilla "$code/e14_check.R" "$RUN" 600
```

## Production results

Array `2890616` completed all 3,000 tasks. Slurm `sacct` reported
510,754.292 seconds of `TotalCPU` summed over the array tasks, or
141.876192 core-hours. Including the six-run pilot, the total was
142.110826 core-hours. The completeness checker found zero missing IDs
and zero failure files. No retries were submitted.

The per-run `e14_summary.csv` includes pointwise coverage computed from
the saved intervals and truth. The λ and σ means use the 666 retained
post-burn-in draws per run. There were no σ guards and all acceptance
rates fell between 0.48570 and 0.51975. All 3,000 runs recorded 200 IPM
fallbacks during warm start.

The 3,000 RDS files, `e14_summary.csv`, and `e14_health.csv` were copied
to `runs/E14-inner-rerun-20261125/` on Owls. All 3,002 entries in
`E14_RESULTS.sha256` verified on both hosts. The manifest's own SHA-256
was `bb73840afc2e0691ef8a169cdf2cc87036ec9f71ac643d24f08cd34b56d67fe1`.
The NOTS run was then sealed with `ops/seal_run.sh`. All 6,013 entries
in its sealed manifest verified.
