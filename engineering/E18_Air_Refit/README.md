# E-18 air-quality refit

## Stage 1 settings

| Item | E-18 |
|---|---|
| Data | Table 2, Brantley §4.2 design, 100 seeds, 500 observations per seed |
| Estimand | Baseline plus `0.25 * qnorm(tau)` |
| Quantiles | 0.01, 0.05, 0.10 |
| Sampler | Individual PMALA at `63f2a56205b8d2ec311565db8c98874cd96754b2` |
| Prior | `k = 2`, `a0 = 1`, `b0 ∈ {1e-3, 1e-4, 1e-5, 1e-6}`, `sigma ~ IG(0.1, 0.1)` |
| Initialization and warm-up | Pinned data-based `pilot_fit`, 200 warm sweeps with λ held at its initial value |
| Sampling | 30,000 sweeps including 10,000 burn-in, acceptance target 0.50 |
| λ update | `asis = TRUE`, `asis_q = "fixed"` with dimensions 10, 20, 40, block move off |
| Numerical controls | Same pinned defaults, solver, safeguards, and σ burn-in guard as E-14/E-17 |
| Seeds | Data seeds 1–100. MCMC seed `seed + 1000` from the original air driver, shared across rates and levels for each data seed. |
| Stage 1 point estimate | Posterior mean over 20,000 draws |
| Coverage | Fraction of the 500 true quantile ordinates covered by 95% pointwise intervals from all retained draws |
| ESS | `coda::effectiveSize` on 666 retained entries of the every-30th-sweep trace for log λ and θ. Save median and 5th percentile of the 500 pointwise θ ESS values and ESS of the summed squared error in θ. The extra `lambda_ess_e14` field uses untransformed λ and all retained draws, as in the E-14 per-fit output. |

Every Stage 1 rate and level uses the exact archived Table 2 observations
and baseline. [DATA_MATCH.md](DATA_MATCH.md) documents the regeneration
check and the benchmark's provenance. Published ADMM at 0.05 uses 99
replications. Its omitted seed is unavailable in the retained summary.
The old method results are reported on their documented denominators.

MSE is the mean squared error against the true quantile. CL is mean check
loss on the observations. CAA averages sensitivity and specificity for
true signal `s > 0.5` and predicted signal `y - fit > h`, with
`h ∈ {0.5, 0.75, 1, 1.2}`. Report CAA over seeds with both classes and
report the denominator. For the archived data, 91 of 100 seeds qualify.

## Preregistered Stage 1 selection

Choose the rate with the smallest arithmetic mean MSE over all 100 seeds
separately at each level. Report every pairwise rate contrast as the mean
of the 100 within-seed MSE differences, with paired SE
`sd(difference) / sqrt(100)`. Also report the best single rate by first
averaging each seed's MSE equally over the three levels, then averaging
over seeds. Use those seed-level averages for the common-rate paired SE.
Break an exact tie in favor of the larger rate. Retain completed fits
with diagnostic flags and report those flags. Withhold selection if a
fit fails or is missing. The Engineering head and Felipe choose the rate
for Stage 2.

## Stage 1 pilot and accounting

Six full-length fits, all on data seed 1 and MCMC seed 1001. Slurm array
indices are `0,100,200,900,1000,1100`. The first three are at 1e-3 and the
last three at 1e-6, in level order 0.01, 0.05, 0.10 within each rate.

Use one CPU per task and record Slurm TotalCPU and batch MaxRSS. All six
must complete, have post-burn-in acceptance in [0.4, 0.6], and have zero
σ guards. Run `Rscript --vanilla e18_stage1.R RUN_DIR --pilot` with the
snapshot script path, and pass the task accounting to Sol-B's resource
checker. Report λ and θ ESS even when a gate fails. Wait for the
Engineering head to clear the pilot and budget before launching Stage 1.

With endpoint pilot CPU times `c[tau, rate]` in seconds, the projection
for a separate 1,200-fit array plus the pilot is
`sum(c) / 3600 + 400 * sum_tau(mean(c[tau, ])) / 3600`.
All six pilots count toward the 80-core-hour cap. A 153-second per-fit
rate would give 51.3 core-hours including the pilot. That reference is
the paper's E-14 median wall time at n = 500, used here as a preliminary
one-core CPU proxy. Use measured Slurm CPU for approval, and allow for
array retries and any benchmark rerun within the same cap.

## Run and report

The snapshot freezes the sampler, both compiled solver sources and the
archived inputs. Sol-B handles NOTS deployments. Worker arguments are
`STAGE RUN_DIR ZERO_BASED_INDEX`. Successful and failed workers record
their task keys. Use `sim` with indices 0–1199 for production and run
`e18_stage1.R RUN_DIR` to write per-fit metrics, all 12 cell summaries,
the published comparison, an explicit issue list, and the paired
selection tables. If a new ADMM comparison is needed, `admm-sim` with
indices 0–299 runs the original driver call using detrendr revision
`17e3e7c`, third differences and the original 15-point eBIC grid.

## Stage 2 preparation

Stage 2 awaits the Engineering head's GO. Prepare the input after GO
using `e18_prepare_spod.R OUTPUT_RDS` from the repo root. On Owls invoke
R through `~/.config/bvs-hq/owls/owls_run -j 1`. Copy the same prepared
`spod_blocks.rds` to each authorized NOTS run directory. Prepare a
`STAGE2_GO.dcf` per authorized run with fields `Run` (the run directory's
basename) and `Input-SHA256` (the prepared file SHA-256).

Source is [S08_2018-06-15.csv](../../applications/Air%20Quality/S08_2018-06-15.csv),
sensor `d PID (counts)`. Treat the timestamps as local clock labels.
The source has 86,213 records, four of which belong to June 16. The
86,209 in-day records have distinct seconds and finite readings.
Form clock-aligned 10-second blocks for June 15, from 00:00:00 through
23:59:59. Average the available readings in each of the 8,624
nonempty blocks. Six of those blocks have fewer than ten readings.
Linearly interpolate the 16 empty block means between their neighboring
nonempty block means. Keep the number of readings and interpolation
flag for each block. Center all 8,640 block means by their arithmetic
mean and scale by their sample SD. The manuscript states that the
series was standardized. The original generator is unavailable.

Use the same individual sampler controls as Stage 1, at n = 8,640.
The two independent chain seeds are 1001 and 1002 for each level and
rate. The stage `real` uses indices 0–23. The real pilot uses indices
`0,2,4`, chain 1 at 1e-3 for all three levels, with the fixed algorithm
and planned run length. If authorized with an approximately 45-minute
wall allocation, any timed-out pilot remains incomplete and its
500-sweep progress logs give an initial CPU projection. Record the
timeout, last completed sweep, Slurm TotalCPU and MaxRSS. Report
stalls, low acceptance, and log-λ drift to the Engineering head.
Changing the sampler controls requires the Engineering head's approval
before a run.

The paper reports 44–53 minutes per fit for 6,000 sweeps of the old
sampler. At that per-sweep speed, 24 fits of 30,000 sweeps would cost
88–106 core-hours before pilots and ADMM. A retained θ matrix alone
requires about 1.29 GiB at the new run length. After three 45-CPU-minute
pilots the 40-core-hour cap leaves under 94.4 CPU minutes per full fit
before ADMM. Base the production decision on measured pilot timing
and memory, and the remaining budget.

Stage `admm-real` uses indices 0–2 on the same processed series.
It calls detrendr revision `17e3e7c` with eBIC on `exp(-2:12)`. The
report compares selected λ to 54.6, 1096.6 and 1096.6 at the paper's
rounding and records any discrepancy. The archived paper provides
no original processed series or preprocessing code to verify its
handling of the missing seconds.

`e18_real_report.R RUN_DIR [ADMM_RUN_DIR]` reads both result sets, reports issues and
produces calibration, threshold, pairwise crossing, and chain health
CSVs. Include `spod_blocks.rds` and `STAGE2_GO.dcf` when collecting the
PMALA run. The plot fits are pointwise posterior medians from the two
pooled 666-draw chains, transformed back to PID counts. The detrended
series and its type-7 percentile thresholds are in counts. Report
strict crossings for each of the three level pairs and the number of
distinct crossed grid points. Log-λ diagnostics include ESS and
classic Gelman–Rubin R-hat over the retained thinned chains, early
and late λ medians, and traces. Report each chain's θ ESS, acceptance,
guards, and elapsed time. The baseline and detrended figures are
generated for all four rates and ADMM.
