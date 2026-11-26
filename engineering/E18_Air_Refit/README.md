# E-18 air-quality refit

## Stage 1 settings

| Item | E-18 |
|---|---|
| Data | Table 2, Brantley §4.2 design, 100 seeds, 500 observations per seed |
| Estimand | Baseline plus the fixed NOTS R 4.5.2 value of `0.25 * qnorm(tau)` from [table2_offsets.csv](table2_offsets.csv) |
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
check and the benchmark's provenance. HQ approved reusing the sealed
Onizuka Laplace records, the 299-fit ADMM refit, and the published
Onizuka HS aggregates. ADMM timed out at τ = 0.05, seed 62. Report
each method's sample size. Paired ADMM and Laplace comparisons use
common successful seeds and defined pairs for CAA.

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

Stage 1 (`a0 = 1`) is closed at 77.4 of 80 core-hours.

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
`--admm-sim=DIR`. The table includes all four rates and
all three benchmarks at each level. It reads Laplace per-replication
metrics from the sealed archive. When an approved refit has yet to be
supplied, its row records its pending status. The HS row is from the
original run; per-replication values not retained, so no paired comparison.
The report writes
`paired_pmala_benchmarks.csv` with seed-matched differences and
`discarded_reps.csv` with the method, level, seed, and recorded reason
for each excluded benchmark replication in the supplied runs.
Next to coverage the PMALA summary shows the median and 10th percentile
of log-λ ESS and of per-fit median pointwise θ ESS, the median of the
per-fit 5th-percentile pointwise θ ESS, and the fraction of successful
fits with log-λ ESS below 20.
For a terminal Stage 1 production array with failed tasks, Sol-B can
use `ops/collect.sh --allow-failures RUN_ID EXPECTED_FITS` to collect
verified available outputs and terminal Slurm accounting. Missing
task outputs enter the selector as failed rows.

The `admm-sim` stage uses indices 0–299 and runs
`detrendr::get_trend_BIC` separately for each level and seed. The
[air driver](../../experiments/air_simulation/drivers/admm_air_sim.R)
uses detrendr revision `17e3e7c`, third differences, eBIC with
`gamma = 1` and `df_tol = 1e-9`, and the 15-point grid
`500^seq(0, 1.4, length.out = 15)`. It leaves solver selection and
failure handling to detrendr. The pinned package does not return a
per-candidate convergence flag. E-18 records failed calls and missing
or unusable outputs, and adds no convergence-based discard rule.
[Pinned grid search](https://github.com/halleybrantley/detrendr/blob/17e3e7c/R/get_trend_BIC.R),
[pinned solver wrappers](https://github.com/halleybrantley/detrendr/blob/17e3e7c/R/solve_functions.R).

The former estimate of 0.44 core-hours for an HS refit is invalid.
The array used 23.6 core-hours in about five minutes and completed
zero fits. HQ selected the published HS aggregates.

Before production, every array, including benchmark arrays, must
complete a measured one-fit pilot on a compute node. The pilot must
load every runtime library, including GLPK for ADMM, and record
CPU, elapsed wall time, and peak RSS. Run the full six-fit PMALA
pilot gates as specified for the simulation designs.

## Stage 2 preparation

HQ approved Stage 2′ on 2026-11-26 after confirming the Stage 1′
triple `(1e-2, 1e-2, 1e-2)`. Prepare the input using
`e18_prepare_spod.R OUTPUT_RDS` from the repo root. On Owls invoke
R through `~/.config/bvs-hq/owls/owls_run -j 1`. Copy the same prepared
`spod_blocks.rds` to each authorized NOTS run directory. Prepare a
`STAGE2_GO.dcf` per authorized run with fields `Run` (the run directory's
basename) and `Input-SHA256` (the prepared file SHA-256).

Source is [S08_2018-06-15.csv](../../applications/Air%20Quality/S08_2018-06-15.csv),
sensor `d PID (counts)`. Treat the timestamps as local clock labels.
The source has 86,213 records, four of which belong to June 16. The
86,209 in-day records have distinct seconds. Drop the 30 literal `N/A`
readings from 13:01:48 to 13:02:17, leaving 86,179 numeric readings.
Form clock-aligned 10-second blocks for June 15, from 00:00:00 through
23:59:59. Average the available readings in each of the 8,621
nonempty blocks. Six of those blocks have fewer than ten readings.
Linearly interpolate the 19 empty block means between their neighboring
nonempty block means. Keep the number of readings and interpolation
flag for each block. Center all 8,640 block means by their arithmetic
mean and scale by their sample SD. The manuscript states that the
series was standardized. The original generator is unavailable.
The three newly empty blocks start at 13:01:40, 13:01:50, and 13:02:00.
The prepared-input SHA-256 is
`7034864ae177b222d19d2df68347d1112f5491703fbeb5636adff05a07b76261`.
Input correction approved by the Engineering head 2026-11-26 (`35cc297`),
with the worker unchanged (`9730ff1`).

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
exceeds 1.1 in a gated cell. Stage 2′ treats that flag as a checkpoint
and applies the curve agreement checks below. A chain with no change in
λ or with no change in the full θ vector across all retained sweeps is
a stall. Flag it in the worker log and in chain health. The report saves
diagnostics and exits with a STOP on a stall. Report each
chain's θ ESS, acceptance, guards, and elapsed time. The baseline
and detrended figures also cover all four constant-rate views and ADMM.

## Diagnostic decision rule (HQ, 2026-11-26)

The decision uses mean MSE at τ = 0.05 on seeds 1–5. The reference
is the published old-PMALA MSE of 0.0138.

- **PRIOR.** Arm 4 (`a0 = n`) has mean MSE ≤ 0.021, and arms 2 and 3
  both stay above 0.021. Proceed to Stage 1′.
- **CONVERGENCE.** Arm 2 or arm 3 reaches mean MSE ≤ 0.021 with
  `a0 = 1`. Stop and report to HQ for Felipe's decision.
- **BOTH or NEITHER.** Stop and report to HQ.

Report arm 5 in every case.

**2026-11-26 owner decision.** Before the diagnostic completed, Felipe
approved `a0 = n`. This supersedes the Stage 1′ gate in `d1a8776`.
The diagnostic was finished for the record under its original
numerical rule, with one τ = .01 arm 5 seed omitted under the CPU cap.

## Stage 1′ and Stage 2′

Felipe approved `a0 = n` and the Stage 1′ pilot. Production still
requires the pilot gates and budget approval. Stage 2′ requires
separate authorization.
The sampler stays pinned at `63f2a56`. The sealed inputs, fixed truth
offsets, sweep counts, interweaving, and acceptance target are unchanged.
Stage 1′ sets `a0 = n = 500`. For each of the three levels and five rates
`b0 ∈ {1e-2, 1e-3, 1e-4, 1e-5, 1e-6}`, use seeds 1–100 (1,500 fits).
Stage 2′ sets `a0 = n = 8640` and fits both chains at each of the 15 cells
(30 runs). Use `E18-prime-*` run IDs and `sim-prime` or `real-prime` as
the worker stage. The grids and fit outputs record `a0` explicitly.

Use the selection rule in commit `e18e52f`, with the same seed-paired
MSE, eligibility gates, coverage ranking, spread limit of 10, tie-breaks,
and escalation for an NA triple. The five-rate grid is the only change
to the candidates. Run `e18_stage1.R RUN_DIR --admm-sim=ADMM_RUN_DIR` on
the collected `E18-prime-*` run. It emits the 15 coverage and ESS cell
rows, the benchmark table, and the selection trace, triples and
selected rates.

The Stage 1′ pilot uses seed 1 at `b0 = 1e-2` and `1e-6` at each level,
indices `0,100,200,1200,1300,1400`. The existing six-fit acceptance and
guard gates apply. Record measured Slurm TotalCPU and MaxRSS. Run
`ops/pilot_resources.py sim-prime ACCOUNTING_FILE` to project the total
as `sum(pilot CPU seconds) / 3600 + 1500 * mean(pilot CPU seconds) / 3600`.
The dedicated 80-core-hour cap includes this pilot and is separate from
the closed Stage 1 budget. If the projection exceeds 80, stop
and report it to HQ. Keep all five rates and 100 replications per cell.

Stage 2′ has a separate 40-core-hour cap for its 30 runs, including its
pilot and associated work. Once Stage 1′ selects the triple, start
with the standing one-fit compute-node pilot. Record MaxRSS and CPU
and verify the existing real-data gates before production.

`b0 = 1e-2` is the edge of the pre-registered grid; not extended (HQ 2026-11-26).

Stage 2′ workers already save `theta_thin` as 666 retained draws by
8,640 points per fit. The matrix is about 46 MB (43.9 MiB) before RDS
compression, or 1.38 GB (1.29 GiB) across all 30 outputs before
metadata. The worker holds the full 20,000 by 8,640 retained matrix
in memory during fitting. That matrix alone is 1.29 GiB. The worker
also needs space for R and validation temporaries, so use the pilot's
measured MaxRSS with headroom to size the production memory request.

At each level, the reported curve is the pointwise posterior median
of the two pooled, equally sized thinned chains at the rate chosen
by Stage 1′. Existing `spod_quantiles_*` and `spod_detrended_*` plots
use these pooled curves. Each `spod_chain_overlay_*` figure overlays
the two separate chain medians on the observed PID series at the
selected rate for that level. `spod_pmala_figure6.pdf` places the
detrended panels on the left and the fitted curves on the right for the
REPORT levels.

For every level and rate, `spod_cell_health.csv` reports the median,
90th percentile and share above 1.1 of pointwise θ R-hat. As in arm
4b, use coda's classic Gelman–Rubin point estimate on four halves
of 333 draws, with no extra burn-in or transform. Summaries use
finite R-hat values and report the nonfinite count. θ R-hat is
descriptive. The log-λ R-hat across both chains is reported for every
rate. `STOP_rhat` flags the formal checkpoint above 1.1 at `b0 = 1e-2`.
The stall checks apply to every chain. The same CSV reports the maximum and RMS
chain-median gap in PID counts and divided by the IQR of observed
PID counts. It gives the fraction strictly below each chain median
and the pooled median, with signed differences from nominal τ.
The `selected_for_real` field identifies the rates used in the
reported curves.

Both prime stages retain `n_ipm_fallback` and
`n_warm_ipm_unconverged` in the per-fit RDS and CSV outputs
(`per_fit.csv` and `spod_chain_health.csv`). `pmala_cells.csv`
and `spod_cell_health.csv` summarize the median, minimum, maximum
and share at 200 of 200 for each counter and cell, over successful
fits. In Stage 2′ the per-fit table flags 200 of 200 for each chain
and cell. `spod_chain_warm_summary.csv` also summarizes each chain
across cells and gives the successful and planned fit counts.

Stage 2′ PMALA reports have no ADMM dependency. Keep the existing ADMM
figure unless an independent `admm-real` refit takes minutes and adds
no delay. If approved, run the one-fit compute-node preflight first
and provide the separate ADMM directory as the third reporter argument.
Onizuka uses the approved original benchmarks throughout.

### Stage 2′ curve agreement (HQ, 2026-11-26)

At each τ for `b0 = 1e-2`, apply these checks even when log-λ R-hat
is above 1.1. The checkpoint requires reporting the checks and calls
for no rerun. A stall still blocks the Writing export.

- For each chain, report the mean and 5th–95th percentiles of λ over its
  666 retained post-burn draws. Standardize each value using the
  Gamma prior mean `a0 / b0` and SD `sqrt(a0) / b0`, with `a0 = 8640`.
- Use raw PID counts throughout the curve checks. `T95` is the 95th
  percentile of `y − pooled median`. Report the RMS chain-median gap
  in counts, divided by `IQR(y)`, and divided by `T95`. Also report
  the largest absolute chain-median gap in counts.
- Calibration is the fraction of observations strictly below the curve.
  Report it for A, B, and pooled, and give the absolute A/B difference.
- Each chain detects grid points where its residual is strictly above
  its own 95th percentile. The Jaccard index divides the size of the
  intersection of those detection sets by the size of their union.
  Also report Jaccard with the pooled `T95` applied to both chains.
  An empty union gives an undefined Jaccard. Quantiles use R type 7.

`report/spod_decision_by_tau.csv` marks a level **REPORT** when all three
conditions hold. RMS is at most `0.05 × T95`, the calibration difference
is at most `0.01`, and own-threshold Jaccard is at least `0.90`. All other
levels are **HOLD**. The run diagnostics retain all levels. Figure 6 and
the Writing CSVs omit HOLD levels, and `spod_writing_scope.md` lists the
included and omitted levels.

After collection and reporting, run the Writing export from the repo
root with the Owls wrapper.

```bash
~/.config/bvs-hq/owls/owls_run -j 1 Rscript --vanilla \
  engineering/E18_Air_Refit/e18_paper_air.R \
  runs/E18-prime-sim-20261126/report "$REAL_RUN"
```

The export writes the Table 2 estimates and SEs, the paired PMALA-minus-ADMM
differences over common seeds, and the warm-up summary for both prime stages
under `results_a0_n/`. It also writes `spod_curves.csv`, with 8,640 local
clock labels, the observed block means in PID counts, and the Figure 6
pointwise medians for the REPORT levels at `b0 = 1e-2`.
The pointwise 95% limits use type-7 quantiles of the same 1,332 pooled
draws. Medians and limits are back-transformed using the prepared center
and scale. The per-cell Stage 2′ diagnostics are in
`$REAL_RUN/report/spod_diagnostics_by_cell.csv`. Fit core-hours use Slurm
`TotalCPU` from the collected production array's `slurm_accounting.psv`.
Report pilot CPU separately. The Writing export requires all 30 chain
reports, applies the curve decisions, and checks `STOP_stall` before
writing the CSVs.

## Fit reproducibility

Bitwise replay of fitted chains is limited to the same CPU or node
family with the same software and settings. Across node families,
individual fits can differ by Monte Carlo-sized amounts. In NOTS
E-14 replay job `2921171` under R 4.5.2, VS Mixed at τ = 0.25, seed 1
(index 1100), was identical. S Beta at τ = 0.50, seed 1 (index 2200),
changed in MSE from 0.000318 to 0.000385. S Gaussian at τ = 0.75,
seed 1 (index 1800), changed from 0.00222 to 0.00204.

## E-19 (planned, conditional; HQ 2026-11-26)

If E-18 settles on an `(a0, b0)` pair for the air data, E-19 will test
that same pair on the §4.1 interior VS and S baselines with the E-14
design. Compare paired runs on `(signal, noise, tau, seed)`. If the
setting performs well, it becomes the paper's default. Otherwise the
paper keeps separate settings and explains why. HQ fixed the acceptance
criteria before any E-19 fit. They are pre-registered in
[E19_Default_Prior/README.md](../E19_Default_Prior/README.md)
(`49e625d`). The E-18 export keeps explicit `a0` and `b0` columns.

| E-18 `per_fit.csv` | E-14 `runs/E14-inner-rerun-20261125/e14_summary.csv` | Definition or source |
|---|---|---|
| `tau`, `seed`, `commit` | Same names | Pair E-19 with E-14 using these design keys plus `signal` and `noise`. Record the sampler commit for provenance. |
| `a0`, `b0` | E-14 run configuration | Original E-14 uses `a0 = 1`, `b0 = 1e-3` for VS and `5e-4` for S. |
| `mse` | `MSE` | Mean squared difference of posterior mean and true quantile. |
| `coverage` | `coverage` | Derived from each E-14 RDS and materialized in this collected CSV. Both use coverage of the true quantile by the inclusive type-7 2.5% and 97.5% pointwise limits over all retained draws. |
| `acc_post` | `acc_post` | Mean acceptance after burn-in. |
| `lambda_ess` | Recompute from per-fit RDS | coda ESS of log λ on the 666 retained entries of the every-30th-sweep trace. The E-14 RDS field named `lambda_ess` itself uses untransformed λ and all retained draws, matching E-18's separate `lambda_ess_e14`. |
| `theta_ess_median`, `theta_ess_p05` | Unavailable | E-14 has no θ ESS field. |
| `n_sigma_guard_postburn`, `n_sigma_guard` | `n_sigma_guard` | E-14 records the full count only. The pinned guard fires during burn-in, so the post-burn count is zero by construction in both designs. |
| `n_ipm_fallback`, `n_warm_ipm_unconverged` | `n_ipm_fallback` | E-14 records the fallback count. The warm-IPM nonconvergence count is unavailable in the E-14 export. |
| `seconds` | `seconds` | E-14 stores sampler elapsed time. E-18's CSV includes fit summaries in elapsed time. Use the E-18 RDS field `sampler_seconds` for like-for-like timing. |
