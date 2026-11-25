# E-15 extreme individual-sampler provenance

## Published values

[published_values.csv](published_values.csv) records all 36 individual MSE
and 48 individual crossing entries, with the printed value, unrounded
source mean, source SE, seed count, and source path. All 84 match the
current TeX at its displayed precision. The main MSE tables use four
decimal places. The four crossing tables use two.
[Main VS](../../paper/sections/simulations.tex#L104) ·
[Main S](../../paper/sections/simulations.tex#L138) ·
[Appendix crossing definition and tables](../../paper/sections/appendix_simulations.tex#L144)

| Published entries | Source |
| --- | --- |
| MSE at 0.96, 0.97, 0.98, 0.99 | The October 7 run `extreme_individual_VS_S_10k3k_20261007`. The October 8 summary and the October 23 consolidated MSE input have identical values for these 24 cells. |
| MSE at 0.90, 0.93 | The October 21 extension `extreme_individual_VS_S_10k3k_tau090_093_20261021`. Its archived combined output is `summary/tables_tau090_093_with_joint/mse_tau090_093_all_methods.csv`. Both October 23 MSE inputs agree for these 12 cells. |
| Neighbor and all-level crossings | The October 7 individual run. The October 8 aggregate columns and the four October 8 wide crossing CSVs agree for all 48 values. |

[October 7 completion](../../experiments/extreme_quantiles/DEPLOYMENT_NOTES.md#L7) ·
[October 8 aggregate](../../experiments/extreme_quantiles/tables_20261008/summary_all_methods.csv) ·
[October 23 consolidated MSE](../../experiments/extreme_quantiles/tables_20261023/mse_consolidated_oct7.csv) ·
[October 23 all-method MSE](../../experiments/extreme_quantiles/tables_20261023/mse_all_levels_all_methods.csv) ·
[Archived October 21 output](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256#L1201)

The October 23 generator formats the consolidated MSE CSV at four decimals.
The 4-versus-6-level builder identifies the two individual campaigns
separately and enforces 100 seeds per cell. Its October 7 individual
snapshot agrees exactly with the October 8 aggregate. The October 2
`joint_upper_levels` campaign ran 300 VS joint tasks and provides context
for the joint results. The two individually fitted levels were supplied by
the October 21 extension.
[MSE generator](../../experiments/extreme_quantiles/tables_20261023/gen_tex.R#L16) ·
[4-versus-6-level generator](../../experiments/extreme_quantiles/tables_4lev_20261023/paper_tables_4lev_vs_6lev.R#L1) ·
[October 7 snapshot](../../experiments/extreme_quantiles/tables_4lev_20261023/inputs/individual_oct7_summary.csv) ·
[October 2 joint design](../../experiments/joint_upper_levels/README.md#L6)

## Inclusion and crossings

**Use all seeds 1–100 per cell.** The October 7 config sets that seed grid
and the processor enumerates it for every method. Incomplete or invalid
tasks stop aggregation. The cell check requires 100 MSE records, 100
crossing records, and exactly the configured MSE seed IDs. The frozen
October 21 worker, processor, and common code have the same SHA-256s as
the October 7 versions. The archived October 21 config has a distinct
hash, and all 12 October 21 published MSE source rows explicitly report
100 seeds. This also establishes the individual sample size independently
of competitor convergence flags.
[Config](../../experiments/extreme_quantiles/packages/Extreme_Individual/config.R#L8) ·
[Task grid](../../experiments/extreme_quantiles/packages/Extreme_Individual/config.R#L45) ·
[Processor entry point](../../experiments/extreme_quantiles/packages/Extreme_Individual/process_results.R#L9) ·
[Completeness and averaging](../../experiments/extreme_quantiles/packages/Extreme_Individual/common_extreme.R#L163) ·
[October 21 frozen package](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256#L1135)

The worker saves posterior means with `colMeans(fit$theta)`. The original
processor checks the response is identical for each signal, noise, and
seed. For each method it stacks the posterior means from the same seed
at levels 0.96–0.99. A pair contributes one at each index where the lower
quantile curve is strictly above the higher quantile curve. Each level
receives the sum of its adjacent pair counts or its counts with all other
reported levels. The sum is computed within each replication before it is
averaged. Both tables use all 100 seeds in every cell, and both exclude
0.90 and 0.93.
[Posterior means](../../experiments/extreme_quantiles/packages/Extreme_Individual/worker_pmala.R#L52) ·
[Pairing and averages](../../experiments/extreme_quantiles/packages/Extreme_Individual/common_extreme.R#L149) ·
[Crossing function](../../experiments/extreme_quantiles/packages/Extreme_Individual/common_extreme.R#L47)

Historical per-seed posterior means were unavailable in the checkout.
The PC archive manifest lists the October 7 `per_seed_crossings.csv`,
which stores computed counts. The locally available October 8 aggregates
reproduce 48 of 48 printed crossing cells. The new builder calls the
original crossing function. On a 72-fit synthetic fixture, independent
hand counts verified both adjacent and non-adjacent inversions, ties,
seed averages, and exclusion of 0.90 and 0.93. The fixture also verified
all six layouts, competitor rows, the Markdown summary, health counts,
claim generation, and rejection of an incomplete grid.
[PC archive summary entries](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256#L1128)

## Settings relative to the interior runs

| Setting | Published extreme individual | Published interior VS / S | E-15 individual |
| --- | --- | --- | --- |
| Gamma λ prior rate | 0.01 VS, 0.001 S | 0.001 VS, 0.0005 S | 0.001 for both signals |
| Total sweeps / burn-in | 10,000 / 3,000 for both | 30,000 / 10,000 VS, 20,000 / 5,000 S | 30,000 / 10,000 for both |
| ASIS | Off for both | On for VS, off for S | Spline-held ASIS with `asis_q = "fixed"` for both |
| Acceptance target | 0.55 | 0.50 for both | 0.50 from the updated sampler settings |
| Initialization and warm-up | Starts at y and updates λ during 200 warm sweeps | Same as extreme | Data-based start and holds λ during 200 warm sweeps |
| MCMC seed | Data seed + 1000 | Data seed + 1000 | 10001 + zero-based E-15 task index |
| Data seeds, size, order, σ prior | 1–100, 500, 2, IG(0.1, 0.1) | Same as extreme | Same as extreme |

The October 7 and 21 archived sampler snapshots match each other and the
local legacy source rendered with CRLF line endings. The old worker uses
that source's saved call with explicit overrides for order, λ prior rate
and run length. The archived October 21 config is indexed on the PC.
[Legacy overrides](../../experiments/extreme_quantiles/packages/Extreme_Individual/worker_pmala.R#L38) ·
[Legacy sampler settings](../../experiments/extreme_quantiles/packages/Extreme_Individual/source/Individual_Sampler_PMALA_Augmented.R#L82) ·
[Archived sampler hashes](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256#L1099) ·
[Interior settings](../E14_Inner_Rerun/README.md#e-14-interior-quantile-rerun) ·
[E-15 settings](e15_run.R#L52)

## Build after GO

```bash
Rscript --vanilla engineering/E15_Extreme_Individual/e15_tables.R runs/E15-extreme-indiv-20261125/
```

The script reads `out/*.rds` from the run directory. It writes the six
LaTeX fragments and comparison CSV under this project's `out/`.
It also writes `old_vs_new_mse.md` and fills in the new-value column of
[recomputed_claims.md](recomputed_claims.md). The Markdown comparison
pads the four-decimal published MSEs to six decimals and uses those
published values as the ratio denominators. For VS, the ratio combines
the prior-rate, sampler and chain-length changes. For S, both fits use
the same prior rate. The LaTeX fragments retain
the paper's four-decimal MSE and two-decimal crossing formats. For the
health lines, supply an `e15_attempts.csv` in the run directory with one
row per signal and columns `signal,n_failed_attempts,n_rerun`.
The median λ ESS comes from each fit's saved `lambda_ess`.
