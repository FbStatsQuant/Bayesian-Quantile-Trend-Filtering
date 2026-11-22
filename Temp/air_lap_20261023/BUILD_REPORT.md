# BUILD REPORT: Air_sim_Lap (Onizuka Laplace BQTF add-on), 2026-10-23

Package: `/home/fb31/projects/Quant_Reg/Air_sim_Lap/` on NOTS (`Driver/` = driver + validation flow, `Onizuka/` = worker + sampler source).
Raw outputs: `/scratch/fb31/qr_data/air_sim_lap/RUN_NAME/{tasks,logs}`, symlinked from `Driver/runs/RUN_NAME/`.
Nothing outside the contract paths was modified. Production NOT submitted.

## 1. Files and changes vs Air_sim

Folder `Individual/` of Air_sim is named `Driver/` here; `ADMM/` and all PMALA files are absent. Line counts are `diff` additions/deletions vs the Air_sim file of the same name.

| File | Change |
|---|---|
| `Driver/common_air.R` | UNCHANGED (+0/-0; sha256 equals production `Air_sim/Individual/common_air.R`: `b12396de72540d518cf92ed279ae765236774bad349ea1d3086d76efb1ad21ac`). simulate_air, air_metrics, run_air_task untouched |
| `Driver/config.R` (+19/-27) | method `onizuka_lap` only; `onizuka = list(sampler="BQTF.MCMC.Lap.multi", mc=8000, burn=2000, sig.init=c(1,1), sparse=FALSE)`; 300-task grid (seed fastest, then tau); batch `02:00:00`, `2G`, job name `air_lap`, `%400`; pmala/admm settings removed; validate_config adapted |
| `Driver/process_lap.R` (NEW) | `process_campaign_lap()` = `process_campaign()` of common_air.R copied by script, with only the paired-vs-pmala block (and its CSV / results.rds entry) removed; summary.csv code path identical, so columns are identical (pmala/admm/onizuka-sigma2/tau2 columns are NA) |
| `Driver/process_results.R` (+8/-7) | sources process_lap.R, calls `process_campaign_lap` |
| `Driver/make_tables.R` (+7/-4) | label `onizuka_lap`; paired table optional (skipped when the CSV is absent) |
| `Driver/run_task.sh` (+3/-5) | `onizuka_lap` -> `Onizuka/worker_onizuka_lap.R` |
| `Driver/validate.sh` (+15/-18) | folders Driver+Onizuka; validation overrides only `seeds 1:2`, `onizuka mc 60 / burn 20` (6 tasks); marker check on `tasks/onizuka_lap`; scratch default `air_sim_lap`; hash approval flow unchanged |
| `Driver/validate_checks.R` (+46/-62) | new checks: common_air.R sha256 == production; simulate_air text == `onizuka_air_sim.R`; BQTF-function.R sha256; Lap function signature; cfg spec; 300-task grid order; worker source scan (set.seed immediately before the exact call) |
| `Driver/submit.sh`, `seal.sh`, `retry.sh`, `status.sh`, `path_guard.sh`, `environment.sh`, `slurm/*.slurm` | path/folder/method renames only (Driver, Onizuka; Air_sim_Lap; scratch `air_sim_lap`); GLPK module dropped from environment.sh (ADMM only) |
| `Driver/README.md` | rewritten for the add-on |
| `Onizuka/worker_onizuka_lap.R` (NEW; derived from `worker_onizuka.R`) | loads unchanged BQTF-function.R via `sys.source` with a `library` shim skipping only `Bessel` (absent on NOTS, as in Extreme_Onizuka); `set.seed(seed + 1000)`, then `BQTF.MCMC.Lap.multi(X = seq_len(n), Y = y, TForder = 2, pp = tau, mc = 8000, sparse = FALSE, sig.init = c(1, 1))`; retained draws 2001-8000; est = colMeans; lo/hi = `quantile(., 0.025/0.975)` per column, exactly as the HS worker; sigma2/tau2 diagnostics = NA |
| `Onizuka/source/BQTF-function.R`, `Onizuka/source/onizuka_air_sim.R` | byte-identical copies (`cmp` against Air_sim/Onizuka/source) |

RNG: `simulate_air` (inside `run_air_task`) sets Mersenne-Twister / Inversion / Rejection; the worker then does `set.seed(seed + 1000)`, as the HS worker does.

## 2. BQTF hash check

```
58e073e2da8297ff6bacfcf598252c2a429cbd9e276252b4522f910185633553  Extreme_Onizuka/source/BQTF-function.R
58e073e2da8297ff6bacfcf598252c2a429cbd9e276252b4522f910185633553  Air_sim/Onizuka/source/BQTF-function.R
58e073e2da8297ff6bacfcf598252c2a429cbd9e276252b4522f910185633553  Air_sim_Lap/Onizuka/source/BQTF-function.R
```
All three equal (also re-checked inside the validation job by `validate_checks.R`).

## 3. Seal and validation

- Sealed combined package hash (`cat Driver/SHA256SUMS Onizuka/SHA256SUMS | sha256sum`):
  `76e0df10a9fc2e4d5c17bb407babe7df896652190d4e5d23ff185dfd33877646`
  = `Driver/validation/APPROVED_PACKAGE_SHA256` (verified equal after validation and after the pilot).
- First validation job 2369234 FAILED after 2 s on a bug in my new check (formals() applied to an unevaluated function expression); fixed, re-sealed, re-run.
- Validation job **2369703**: COMPLETED, 48 s. Success marker line:
  `VALIDATION_SUCCESS /home/fb31/projects/Quant_Reg/Air_sim_Lap/Driver/validation/check_20261023T164618Z_2369703`
  Contents: all `CHECK_OK` lines, `VALIDATE_CHECKS_SUCCESS`, `ALL 6 TASKS OK`, duplicate-run refusal, incomplete-run refusal, `PROCESS_SUCCESS`, `TABLES_WRITTEN`, and `sbatch --test-only` accepted the production array options (`--array=1-300%400 --time=02:00:00 --mem=2G`).
  Versions: R 4.5.2, MASS 7.3.65, GIGrvg 0.8, invgamma 1.2, MCMCpack 1.7.1; Bessel absent (shim).
  (Validation MSE values use mc = 60 and are meaningless by design.)

## 4. Pilot (seed 1, all 3 taus, production settings: mc 8000, burn 2000)

Command: `bash submit.sh air_lap_pilot_seed1_20261023 1`. Array job **2369751** (tasks 1-3), processing job **2369752**; all COMPLETED, exit 0:0. Run dir: `Driver/runs/air_lap_pilot_seed1_20261023`; summary `summary/attempt_20261023T165733_1878053/`.

| tau | MSE | CL | CAA 0.5 | CAA 0.75 | CAA 1 | CAA 1.2 | coverage | MCIW | seconds | peak RSS (sacct MaxRSS) |
|---|---|---|---|---|---|---|---|---|---|---|
| 0.01 | 0.063086 | 0.0052117 | 0.63481 | 0.67136 | 0.65930 | 0.64277 | 0.370 | 0.20698 | 435.3 (elapsed 7:18) | 368,376 K (0.35 GB) |
| 0.05 | 0.039560 | 0.0244889 | 0.66549 | 0.68701 | 0.64169 | 0.63128 | 0.616 | 0.22534 | 515.4 (elapsed 8:38) | 363,228 K |
| 0.10 | 0.036870 | 0.0439497 | 0.68651 | 0.66221 | 0.64491 | 0.63128 | 0.670 | 0.22396 | 555.8 (elapsed 9:18) | 363,080 K |

Per-task time 7-9 min (within 2 h limit), RSS 0.36 GB (within 2 G). `onizuka_sigma2_mean` / `onizuka_tau2_mean` = NA, processing tolerated them. lo <= est <= hi in all three tasks.

## 5. Data identity

The production raw task outputs under `/scratch/fb31/qr_data/air_sim/` NO LONGER EXIST (the directory is absent on NOTS; scratch purge). The stored `y` of the production `onizuka_hs` tasks is therefore taken from the processed `results.rds` of `Air_sim/Individual/runs/air_n500_100seeds_20261008/summary/partial_20261008T193132_2370943/` (`$data[[seed]]$y`, which `process_partial.R` filled from each task's stored `result.rds` and verified identical across all methods per seed). Output of the check (Air_sim_Lap `simulate_air`, seeds 1-3, tau 0.05; y does not depend on tau):

```
reference per_task rows (onizuka_hs, tau 0.05): seeds 1,2,3, MSE 0.07220956, 0.22193132, 0.14106759
seed 1 tau 0.05: identical(y) = TRUE | identical(theta) = TRUE | identical(s) = TRUE | n = 500
seed 2 tau 0.05: identical(y) = TRUE | identical(theta) = TRUE | identical(s) = TRUE | n = 500
seed 3 tau 0.05: identical(y) = TRUE | identical(theta) = TRUE | identical(s) = TRUE | n = 500
```
Also, the `y` stored in the pilot's own task results (seed 1, tau 0.01/0.05/0.10) is `identical()` to the production y for seed 1 (three TRUE).

## 6. Column identity

```
template ncol: 43  pilot ncol: 43
identical(names(pilot), names(template)) = TRUE
identical raw CSV header lines = TRUE
```
Template: `.../air_n500_100seeds_20261008/summary/partial_20261008T193132_2370943/summary.csv`; pilot: `.../air_lap_pilot_seed1_20261023/summary/attempt_20261023T165733_1878053/summary.csv`.

## 7. Production submit command (NOT submitted)

```
ssh nots 'cd /home/fb31/projects/Quant_Reg/Air_sim_Lap/Driver && bash submit.sh air_lap_n500_100seeds_20261023'
```
It checks SHA256SUMS and `validation/APPROVED_PACKAGE_SHA256` (currently matching), freezes a read-only code snapshot into `runs/air_lap_n500_100seeds_20261023/code`, submits one array `1-300%400` (02:00:00, 2G, partition/account commons) and a processing job `afterany` the array (summary at `runs/air_lap_n500_100seeds_20261023/summary/attempt_*/{summary.csv,per_task_metrics.csv,tables/}`). Raw outputs go to `/scratch/fb31/qr_data/air_sim_lap/air_lap_n500_100seeds_20261023/`. Estimated total compute: 300 tasks x ~8-9 min. A `sbatch --test-only` for the array at submission time reported an estimated start of 2026-10-28 because the commons queue is saturated by other campaigns (`2365494`, `2365495`, `2368829` ...); not a package problem.

## 8. Notes / caveats

- Scratch purge risk: `/scratch/fb31/qr_data/air_sim` was gone; copy `air_sim_lap` results out of scratch soon after the production run.
- Only login node `10.226.96.48` was unreachable for part of the session; the `10.226.96.46` node worked (same filesystem).
- Pilot and validation run directories remain in `Driver/runs/` and `Driver/validation/` (excluded from seals and snapshots). The failed validation attempt `check_20261023T161554Z_2369234` was left in place.
- Staged copies of the files I wrote locally: `Temp/air_lap_20261023/stage/`.
