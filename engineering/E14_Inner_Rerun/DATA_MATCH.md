# E-14 interior simulation data and tables

## Generator and seeds

[e14_data.R](e14_data.R) loads the `simulate_data` definition from the original
[PMALA sampler snapshot](../../experiments/interior_quantiles/individual_nots_20261003/source/Individual_Sampler_PMALA_Augmented.R#L145).
The definition is byte-identical in the top-level campaign and the `VS_b0001`,
`S_b00005`, and `S_b0001` snapshots. The
[original worker](../../experiments/interior_quantiles/individual_nots_20261003/worker.R#L37)
passes the replication number (1 through 100) directly as the data seed. The
generator resets Mersenne-Twister / Inversion / Rejection at each call. Signal,
noise family, and quantile level never change the seed. The original worker
separately seeds the sampler at `seed + 1000L`.

The grid is `u = i / 500`. VS uses
`2 + sin(4 * u - 2) + 2 * exp(-30 * (4 * u - 2)^2)`. S uses
`sin(2 * pi * i / 500)`, preserving the original order of operations.
Gaussian noise uses one vectorized `rnorm` call with SD `(1 + u^2) / 4`.
Beta noise draws one `rbeta(1, 1, 11 - 10*u)` per grid point. Mixed-normal
noise draws one uniform to choose the component, then one Gaussian at each
point. The means are −0.2 with probability `u` and 0.2 otherwise, with
variance 0.5 in either component. The true curve adds the corresponding
conditional noise quantile to the signal, using the original `qnorm`,
`qbeta`, or `uniroot` on `[-10, 10]`. The same response is used at all
five levels.

## Exact comparisons

All 12 production-size cases matched bit for bit in both response and truth
against the original PMALA generator and the original ADMM driver's data
block run on Owls. The hashes below use the little-endian IEEE-754 double
bytes of each vector. `Normal` is the campaign label for Gaussian noise.

| Signal | Noise | Seed | τ | Response SHA-256 | Truth SHA-256 |
| --- | --- | ---: | ---: | --- | --- |
| VS | Normal | 1 | 0.05 | `ac6b4690da43297d4066060d435ed7bfcf497d70f5328ca9ece8ec36481ed5a0` | `9d244a92abf5d7d05618f6f85b205378305ea52fb7fd6458f5ce106a8a41c401` |
| VS | Normal | 37 | 0.25 | `5914295d57cb5126c853699ae6f0b926a34a926ada7a96617c82a9e78e04c9f7` | `c67ae6f9680d385698c28c42d94597d7720a7646ba844c849a03cb2f9615fbf4` |
| VS | Beta | 1 | 0.50 | `1474771809f3d91f5e99e28dc1812fa6000069079fa09e7893505c498219a7d0` | `d86df0d438dcfae673fc0bd672db9d7b19efe2f17560d910b879c5accffab479` |
| VS | Beta | 37 | 0.75 | `fa7eb72e702a73e3cdd96864525b3d2efa9226c782814430a0435374dc08190e` | `06de1541fdda3fea9d509d80a548f38ee4e07041ab12dedfd1fa0b60dbf3fbb7` |
| VS | Mixed | 1 | 0.95 | `e9cf9db6ae5f00735b4506d04fd53befd1ef3a9676365dbe3245915475697f9f` | `092a29e9363923890c87f3a00b874a2601c031cdc8a662022926db2a56675c3c` |
| VS | Mixed | 37 | 0.05 | `d28748116fd346611c3be4e45f3b8cbfd5c3170c1ca00854539bfcf70f48b28e` | `57868e7b8602d2cf526863e9d2cb00161a3a63aa6c2e7c7ca537add10fdb5d92` |
| S | Normal | 1 | 0.25 | `4de5d9b706d4f3948dbc53246f3b3bd2dda174035b379215097e51aa3c4cb8e4` | `db1cffae57b935f335593a6d63cf7c4fbe6bc65caa530520f39721ad35acb915` |
| S | Normal | 37 | 0.50 | `a9b263bc7adc6f17ac5ef9f01eb0d217fd1f515438069821b0c4408585af9a90` | `2985d851de5ee7f7d09b86f0ff22610b868a343f92e8cfcb2b4d082db298c1db` |
| S | Beta | 1 | 0.75 | `9d133a7ccf5deaf65fc595100eeb34d9e42633236532536256aa267f2a72e5d0` | `5d862b4a27bdf736437ba9e9db05d908c0c5a49f8ae0c61132b7e1ccad458e30` |
| S | Beta | 37 | 0.95 | `6f29a70ad4946bf85d08b3c15308259aaca0099877d4deef1762323371daa868` | `fddd62fad5514fde44ce6e98179795b3fc874aca63409c2123988c4dd655347c` |
| S | Mixed | 1 | 0.05 | `6bbea35cd7e78a6b81686aede523c00bd318278b3c10176048de716bdcb149c5` | `d0624300adb6806311e40fa35bf207431d2b3182f684835f1b1f17d3d28c7e07` |
| S | Mixed | 37 | 0.25 | `8eb9dddc134bc8d2c610a3540dbb6435700afe2847a76b57e15bbbcadba74db3` | `7ee08541d494dd3ee9ee40a55c29e8f560b124c836dadaabedb15b1a45a1fe73` |

The five quantile curves in the three saved n=500 joint pilot RDS files and
their responses also matched bit for bit. The original NOTS validation
archive contains 60 n=32 data files. Across that archive 25 responses and
44 truth curves matched bit for bit, and the maximum absolute difference in
either vector was 4.44 × 10⁻¹⁶. The archive records R 4.5.2 on NOTS and the
local check used R 4.6.0 on Owls. The cross-environment differences are at
floating-point precision. The original production per-seed responses
were unavailable in the repository.

### Reproduce the checks

Run from the repository root. The archive extraction only selects generated
data files. The R check loads generator definitions and saved data.

```bash
campaign=experiments/interior_quantiles/individual_nots_20261003
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
tar -xzf "$campaign/deployment/validation_1785936.tar.gz" -C "$scratch" \
  --wildcards '*/generated_data.rds'
timeout 4s Rscript --vanilla - "$scratch" <<'RS'
campaign <- "experiments/interior_quantiles/individual_nots_20261003"
source("engineering/E14_Inner_Rerun/e14_data.R")
snapshot <- readLines(file.path(campaign, "source", "Individual_Sampler_PMALA_Augmented.R"))
start <- grep("^simulate_data <- function", snapshot)
end <- min(which(snapshot == "}" & seq_along(snapshot) > start))
eval(parse(text = snapshot[start:end]))
driver <- readLines("method/admm_qtf/ADMM_QTF_Individual.R")
data_expr <- parse(text = driver[grep("^x_idx <-", driver):(
  grep("^##  3\\. Building", driver) - 2L)])
hash <- function(x) digest::digest(writeBin(x, raw(), endian = "little"),
  algo = "sha256", serialize = FALSE)
g <- expand.grid(seed = c(1L, 37L), noise = c("Normal", "Beta", "Mixed"),
  signal = c("VS", "S"), stringsAsFactors = FALSE)
g$tau <- rep(c(.05, .25, .50, .75, .95), length.out = nrow(g))
for (i in seq_len(nrow(g))) {
  with(g[i, ], {
    new <- e14_make_data(signal, noise, seed, tau)
    old <- simulate_data(seed, 500L, tau, signal, noise)
    admm <- list2env(list(n_data = 500L, baseline_key = signal,
      noise = noise, seed = seed, tau = tau))
    eval(data_expr, admm)
    stopifnot(identical(new, old, num.eq = FALSE), identical(new$y, admm$y, num.eq = FALSE),
      identical(new$truth, admm$Q_true, num.eq = FALSE))
    cat(sprintf("| %s | %s | %d | %.2f | `%s` | `%s` |\n",
      signal, noise, seed, tau, hash(new$y), hash(new$truth)))
  })
}

folder <- commandArgs(trailingOnly = TRUE)[1L]
archive_data <- list.files(folder, "generated_data[.]rds$", recursive = TRUE, full.names = TRUE)
stopifnot(length(archive_data) == 60L)
check_stored <- function(stored_y, stored_truth, new) {
  c(y_exact = identical(stored_y, new$y, num.eq = FALSE),
    truth_exact = identical(stored_truth, new$truth, num.eq = FALSE),
    y_max_abs = max(abs(stored_y - new$y)),
    truth_max_abs = max(abs(stored_truth - new$truth)))
}
report <- function(checks) {
  print(colSums(checks[, 1:2, drop = FALSE]))
  print(apply(checks[, 3:4, drop = FALSE], 2L, max))
  stopifnot(max(checks[, 3:4]) < 1e-12)
}
report(t(vapply(archive_data, function(file) {
  id <- tail(strsplit(file, "/", fixed = TRUE)[[1L]], 6L)
  tau <- as.numeric(sub("tau_", "", id[3L]))
  seed <- as.integer(sub("seed_", "", id[4L]))
  stored <- readRDS(file)
  stopifnot(length(stored$y) == 32L)
  check_stored(stored$y, stored$truth, simulate_data(seed, 32L, tau, id[1L], id[2L]))
}, numeric(4L))))
cat(length(archive_data), "stored validation data objects checked\n")

pilot <- list()
for (file in Sys.glob("experiments/pilots/joint_results_joint/joint_summary*.rds")) {
  stored <- readRDS(file)
  for (i in seq_len(nrow(stored$res))) {
    d <- stored$res[i, ]
    new <- e14_make_data(d$baseline, d$noise, d$seed, d$tau)
    pilot[[length(pilot) + 1L]] <- check_stored(stored$y, stored$truth[, i], new)
  }
}
report(do.call(rbind, pilot))
cat(length(pilot), "stored n=500 joint pilot curves and responses checked\n")
RS
```

## PMALA replication rule

E-14 PMALA means over all 100 seeds, exactly as the current paper's PMALA
entries. [valid_reps.csv](valid_reps.csv) marks all 3,000 keys `kept=TRUE`.
ADMM convergence governs competitor eligibility. The table builder carries
the published competitor values forward and aggregates the new Bayesian-PMALA
results over the 100 required seeds in each cell.

The paper's PMALA settings match the October 12 VS and S campaign configs,
including the two prior rates, sweep counts, and ASIS settings. Both configs
set `seeds = 1:100`. Both production processors require
`nrow(d) == length(cfg$seeds)` and `identical(sort(d$seed), cfg$seeds)`
before averaging. The campaign READMEs likewise say the final averages
use all 100 seeds. [Paper settings](../../paper/sections/simulations.tex#L19) ·
[VS config](../../experiments/interior_quantiles/individual_nots_20261003/VS_b0001/config.R#L8) ·
[VS processor](../../experiments/interior_quantiles/individual_nots_20261003/VS_b0001/process_results.R#L85) ·
[VS run notes](../../experiments/interior_quantiles/individual_nots_20261003/VS_b0001/README.md#L26) ·
[S config](../../experiments/interior_quantiles/individual_nots_20261003/S_b00005/config.R#L8) ·
[S processor](../../experiments/interior_quantiles/individual_nots_20261003/S_b00005/process_results.R#L85) ·
[S run notes](../../experiments/interior_quantiles/individual_nots_20261003/S_b00005/README.md#L25)

The earlier October 3 MSE updater also enforces 100 seeds. Its inputs
are the 15k/3k campaign with rate 0.01, and it corroborates the workflow.
[Updater campaign](../../experiments/interior_quantiles/individual_nots_20261003/deployment/paper_mse_tables.py#L8) ·
[Updater seed check](../../experiments/interior_quantiles/individual_nots_20261003/deployment/paper_mse_tables.py#L18)

All 90 CSV values match the current six TeX tables, and the 30 MSE values
also match the October 23 pre-edit manuscript snapshot. No production
`average_metrics.csv`, per-seed results, or summary RDS for the October 12
VS and S campaigns was found in the checkout, Git history, or the sealed
NOTS archive file list. This verifies the aggregation rule at code level
and the published transcription. Independently reproducing the 90 means
would require the campaign outputs.
[October TeX snapshot](../../paper/history/extreme_six_levels_20261023/before/sections/simulations.tex) ·
[Sealed file list](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256)

### Legacy campaign search on 2026-11-25

One read-only SSH session through `ops/bin/sshlock` confirmed that
`/home/fb31/projects/Quant_Reg` is absent on NOTS. The
[deletion receipt](../../ops/ledger/deleted/legacy-quant-reg-20261122.json)
records the removal of the last 721 files that morning after checks against
the verified PC archive. The [archive index](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/INDEX.md)
lists `Inner_admm` and `Inner_onizuka` with zero files. The
[sealed manifest](../../engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256)
has no entries under either folder. Its interior files are under
`Inner_Individual` and `Inner_Joint`. The archived `paper_mse_tables` output
was generated by copying the competitor values from TeX and substituting
PMALA means over its 100 seeds per cell.
[Archived MSE builder](../../experiments/interior_quantiles/individual_nots_20261003/deployment/paper_mse_tables.py)

The local ADMM driver labels `exp(seq(-4, 8, length.out = 25))` as the NOTS grid.
It offers several algorithms, defaults to LP, and does not pin the original
production algorithm, backend, stopping tolerances, iteration cap, or
warm-start policy. Those settings determine the recorded convergence flags.
The archived `Extreme_admm` and `Air_sim` code belong to separate experiments.
Neither reconstruction branch had the required competitor inputs, so the
search yielded no timing estimate for the historical grid.

The next evidence source is the original per-seed files alongside the
comparison workbooks in Felipe's PC OneDrive. The September
[table script](../../paper/history/simulation_revision_20260914/revise.py#L7)
points to `NOTS Data/BQTF/Individual Comparisons/Individual_Comparison_n500_v2.xlsx`.
That workbook revision is a lead to the original records. A recovered mask
should reproduce the current ADMM, Laplace, and horseshoe means at the
displayed six-decimal precision. For a reconstruction from original ADMM
settings, require each ADMM mean to round to its published value (absolute
difference at most `5e-7`), and retain the per-candidate flags.

### September source acceptance test

The candidate mask from September run `qtf_brantley_20260908_run01`
**fails the current paper acceptance test**. The two read-only inputs remain
under `tmp/E14_admm_mask/`. The ADMM source on the owner's OneDrive is
`Quantile Regression/Others/BQTF/ADMM/qtf_brantley_20260908_run01/summary/`.

| Input | SHA-256 |
| --- | --- |
| `partial_summary.rds` | `141bfd13dcd9579e9f51ff51cdd814de2c46a04361710ec6354da1834260bc07` |
| `onizuka_inner_quantiles_summary.xlsx` | `1d4809eb726931a1aae88e57e2dae071c324e268c53628a9e67a7af6bad46423` |

For VS and S, ADMM `task_status` records 2,596 valid, 360 errors, and 44
unusable runs. The valid keys agree exactly with the `per_seed` rows and the
included and excluded seed lists in `summary`. The errors all say
`error: worker error record exists`. The unusable cases all say
`unusable: worker diagnostics failed` (2 VS, 42 S). Neither message identifies
the failed diagnostic or λ candidate. These records establish the September
status mask. Per-candidate flags or worker logs are needed to verify whether
the paper's specific rule accounts for the exclusions.

| Signal | Noise | τ = 0.05 | 0.25 | 0.50 | 0.75 | 0.95 |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| VS | Beta | 100 | 100 | 99 | 100 | 99 |
| VS | Mixed | 98 | 99 | 100 | 100 | 100 |
| VS | Normal | 99 | 100 | 100 | 99 | 100 |
| S | Beta | 55 | 64 | 72 | 74 | 68 |
| S | Mixed | 79 | 82 | 88 | 81 | 80 |
| S | Normal | 66 | 75 | 75 | 76 | 68 |

The candidate kept counts across cells are 55 minimum, 93 median, and
100 maximum. The Onizuka workbook marks all 3,000 tasks per method valid.
The audit used its posterior-mean rows, joined by signal, noise, τ, and
seed, and averaged the stored metrics over the selected seeds. The
ADMM metrics were MSE and MAD. Its interval widths and coverage are absent.
The test compared each mean formatted to six decimals with the exact text
in [published_values.csv](published_values.csv).

| Method | Current paper matches on ADMM-valid seeds | Current paper matches on own valid seeds | Max absolute discrepancy under either rule |
| --- | ---: | ---: | ---: |
| ADMM | 1 / 60 | 1 / 60 | 0.227125077 |
| Onizuka (Laplace) | 0 / 90 | 5 / 90 | 0.149883959 |
| Onizuka (Horseshoe) | 0 / 90 | 4 / 90 | 0.156461566 |
| Total | 1 / 240 | 10 / 240 | |

[mask_acceptance.csv](mask_acceptance.csv) lists the published and
recomputed values for all 240 comparisons under both rules. For example,
the September ADMM mean MSE for VS Beta at τ = 0.05 is 0.235180
versus 0.008055 in the current paper, although all 100 seeds are valid
in that September cell.

As a provenance check, the same inputs reproduce all 240 displayed
competitor entries in the September
[workbook extract](../../paper/history/simulation_revision_20260914/table_source.json)
when each method uses its own valid seeds. The ADMM-valid rule reproduces
115 of those 240 entries. This identifies the September competitor
dataset. E-14 uses the October PMALA replication rule above.

## Published values

[published_values.csv](published_values.csv) contains 330 displayed means from
the [main tables](../../paper/sections/simulations.tex#L25) and the
[appendix tables](../../paper/sections/appendix_simulations.tex#L16), plus 30
ADMM MCIW rows with missing values. The six tables show no SEs. The October
joint reference agrees with all 240 displayed competitor values, and all 90
PMALA means differ. For example, VS Beta at 0.05 has MSE 0.000546 in the
reference and 0.000541 in the current paper. The September workbook extract
differs at published precision in 320 of the 330 displayed cells. Neither
reference supplies SEs for the current tables. The current TeX governs the
CSV and the table layout.

## Table builder

Run from the repository root after the 3,000 production results have arrived.

```bash
Rscript --vanilla engineering/E14_Inner_Rerun/e14_tables.R runs/E14-inner-rerun-20261125/
```

The builder reads the run's `out/` subdirectory and the checked-in
`valid_reps.csv`. A direct result folder is also supported.
The builder writes `pmala_old_vs_new.csv`, `health.csv`, and `run_issues.csv`
in `engineering/E14_Inner_Rerun/out/` by default. An optional second
argument selects a different new output directory, and an optional third
argument selects a different replication manifest. The ratio uses the unrounded new mean divided by
the displayed old mean. The comparison and health files identify kept and
available runs and count unresolved seeds. Unreadable or unkeyed files appear
in the issue report, along with keyed failures, duplicates, and missing runs.
With an unresolved mask or incomplete retained results, the command returns
a nonzero exit status after writing the reports. The six LaTeX fragments
are emitted when the mask is resolved and kept fits are complete.

[process_results.R](../../experiments/interior_quantiles/individual_nots_20261003/process_results.R#L33)
recomputes the metrics with the following lines from
[common.R](../../experiments/interior_quantiles/individual_nots_20261003/common.R#L65).

```r
curve_metrics <- function(est, lo, hi, truth) c(
  MSE = mean((est - truth)^2), MAD = mean(abs(est - truth)),
  MCIW = mean(hi - lo), coverage = mean(truth >= lo & truth <= hi))
```

The original `est` is the posterior mean. The bounds are type-7 pointwise
quantiles at 0.025 and 0.975. The builder recomputes MSE, MAD, and MCIW from the
saved vectors and checks the worker's stored metrics. It uses the same across-seed
averaging and SE calculation as
[process_results.R](../../experiments/interior_quantiles/individual_nots_20261003/process_results.R#L57).

```r
    out[[paste0("mean_", key)]] <- mean(d[[key]])
    out[[paste0("se_", key)]] <- sd(d[[key]]) / sqrt(nrow(d))
```

The synthetic test used 20 temporary RDS files with 19 kept seeds, verified
all six LaTeX layouts, checked all three metrics, their SEs and ratios, and
verified the diagnostic summaries. Further checks covered a missing result,
a worker failure record, a duplicate, a wrong stored metric, an unreadable file,
and the unresolved mask. The fixture files and generated output were removed.

A second CLI test used 3,000 synthetic RDS files with the checked-in
all-seeds manifest. Each of the 30 cells used 100 fits. All six LaTeX
fragments preserved the original layout and competitor rows, and the
old-vs-new ratios and health counts matched the fixture values.

## Note added 2026-11-26 (E-19 preflight)

The bit-for-bit matches above were measured on Owls. The same generator and seeds on NOTS compute nodes give some vectors that differ in the last bits: the CPUs' math libraries round differently (`qbeta`, `uniroot`, `log`/`exp`). The archived E-14 truth was generated on NOTS. It is bit-identical to the Owls regeneration in 1,000 of the 3,000 tasks. The other 2,000 differ by at most 8.9e-16 in absolute value: 0% of the Beta tasks match, 20% of the Mixed and 80% of the Normal. The evidence is in [truth_owls_vs_e14.csv](../E19_Default_Prior/preflight/truth_owls_vs_e14.csv). These differences are numerical, not statistical.
