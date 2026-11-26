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
check and the benchmark's provenance. All three archived benchmarks
failed HQ's reuse standard. Published ADMM at 0.05 uses 99 replications.
Its omitted seed is unavailable in the retained summary. Use new fits
for the comparison and retain the published numbers as historical
reference. Any paired PMALA–ADMM result uses the common successful
seeds at its level and rate, with a further restriction to defined
pairs for CAA. Report both methods' sample sizes.

MSE is the mean squared error against the true quantile. CL is mean check
loss on the observations. CAA averages sensitivity and specificity for
true signal `s > 0.5` and predicted signal `y - fit > h`, with
`h ∈ {0.5, 0.75, 1, 1.2}`. Report CAA over seeds with both classes and
report the denominator. For the archived data, 91 of 100 seeds qualify.

## Preregistered Stage 1 selection (HQ-approved, Felipe amendment 11-26)

Compute mean MSE and coverage over successful fits and report their
counts from the 100 planned seeds per cell. A cell is ineligible if
more than five fits fail or are missing, any σ-guard event is recorded
after burn-in, or its median post-burn-in acceptance is outside
[0.4, 0.6]. List every cell and all its eligibility reasons. The pilot
still requires zero guards over the entire chain.

At each level, find the eligible rate with minimum mean MSE. Use the
larger rate as the pairing reference if the minimum is tied. For each
rate form seed-matched differences against the reference and report
their mean and paired SE, `sd(difference) / sqrt(100)`. With failed fits,
form differences on the common successful seeds and report their count
alongside the SE, using the specified denominator of `sqrt(100)`. The
admissibility gap uses the difference of the two cell means over their
respective successful seeds. Admit an eligible rate when its gap is at
most one paired SE. Always admit the eligible reference. Among the
admissible rates, choose the one whose mean 95% pointwise coverage is
closest to 0.95, taking the larger rate on a tie.

Select a triple in level order 0.01, 0.05, 0.10. Its spread
`max(b0) / min(b0)` must be at most 10, so it spans at most two
adjacent grid values.

1. Among triples admissible at each level, minimize the arithmetic
   mean of the three absolute coverage errors `abs(coverage - 0.95)`.
2. If none qualify, consider triples eligible at each level.
   Minimize the geometric mean of the three ratios of MSE to the
   minimum eligible MSE at that level.
3. If there is no eligible triple within the spread limit, record
   three NA rates and escalate to HQ.

Both rankings break a tie by smallest spread first, then by larger
rates in lexicographic level order (0.01, 0.05, 0.10).

The review artifact is the production `per_fit.csv`. It contains one
row per planned fit, including failure and missing flags. Commit the
CSV after production and keep the RDS files in the run folder.
`Rscript --vanilla engineering/E18_Air_Refit/e18_select.R PER_FIT_CSV`
recreates `selection_trace.csv` (cells), `selection_triples.csv`
(candidate scores, ranks and tie-breaks) and `selected_b0.csv`
(final triple with the branch) alongside the input using only that
CSV. The report table marks the independent per-level coverage
choice and the selected rate at each level. Run the synthetic test on Owls with
`~/.config/bvs-hq/owls/owls_run -j 1 Rscript --vanilla engineering/E18_Air_Refit/test_e18_select.R`.

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
the side-by-side comparison, an explicit issue list, and the selection
trace. Supply separately collected benchmark results with
`--admm-sim=DIR --onizuka-hs=DIR --onizuka-lap=DIR`. The table includes
all four rates and all three benchmark rows at each level. Before refits
are supplied, a benchmark row records its pending status.
For a terminal Stage 1 production array with failed tasks, Sol-B can
use `ops/collect.sh --allow-failures RUN_ID EXPECTED_FITS` to collect
verified available outputs and terminal Slurm accounting. Missing
task outputs enter the selector as failed rows.

The `admm-sim` stage with indices 0–299 runs the original driver call
using detrendr revision `17e3e7c`, third differences and the original
15-point eBIC grid. For Onizuka, `onizuka-hs` and `onizuka-lap` each
use indices 0–299, the archived sampler source hash, `TForder = 2`,
`sig.init = c(1, 1)`, `sparse = FALSE`, 8,000 draws and 2,000 burn-in.
These need the original MASS, GIGrvg, invgamma and MCMCpack packages.
Historical timings suggest about 1.0 core-hour for ADMM, 0.44 for HS,
and 60.8 for Laplace on one core per fit. With the 51.3-core-hour PMALA
proxy, all refits together would exceed the 80-core-hour cap. Bring
measured timing and the benchmark budget to HQ before submitting a
benchmark campaign.

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

`e18_real_report.R RUN_DIR SELECTED_B0_CSV [ADMM_RUN_DIR]` reads both result sets, reports issues and
produces calibration, threshold, pairwise crossing, and chain health
CSVs. Include `spod_blocks.rds` and `STAGE2_GO.dcf` when collecting the
PMALA run. The selected PMALA plots and diagnostics use each level's
rate from `selected_b0.csv`. The plot fits are pointwise posterior medians from the two
pooled 666-draw chains, transformed back to PID counts. The detrended
series and its type-7 percentile thresholds are in counts. Report
strict crossings for each of the three level pairs and the number of
distinct crossed grid points. Log-λ diagnostics include ESS and
classic Gelman–Rubin R-hat over the retained thinned chains, early
and late λ medians, and traces. Flag `STOP_rhat` when log-λ R-hat
exceeds 1.1. A chain with no change in λ or with no change in the
full θ vector across all retained sweeps is a stall. Flag it in
the worker log and in chain health. The report saves diagnostics
and exits with a STOP when either condition holds. Report each
chain's θ ESS, acceptance, guards, and elapsed time. The baseline
and detrended figures also cover all four constant-rate views and ADMM.
