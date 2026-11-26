# Table 2 data match

E-18 uses the archived Table 2 inputs for bitwise identity. The
archive is
[results.rds](../../experiments/air_simulation/onizuka_laplace_20261023/attempt_20261023T171713_511660/results.rds)
with SHA-256 `4e4dd9fccd4bb83df3905cafb1b4260358069b6b5b9d982aa45ec4412397e9ba`.
Its `data[[seed]]` entries hold the 500 observations (`y`), baseline
(`theta`) and signal (`s`) for each of the 100 seeds.

Both repository drivers' `simulate_air()` functions, sourced by
extracting their assignments, regenerate bitwise identical values to
each other on Owls for all 100 seeds. They use the Mersenne-Twister,
Inversion and Rejection RNG settings and `set.seed(seed)`; the data
draws are independent of the quantile level. The spline baseline
uses a Poisson+1 basis dimension and exponential coefficients, and the
signal is a binomial count of Gaussian peaks. Gaussian noise has
standard deviation 0.25.

The regenerated and archived arrays agree to numerical precision on
Owls. The archived run used R 4.5.2 with FlexiBLAS/OpenBLAS. The
comparison is shown below. E-18 loads the sealed archive directly to
avoid introducing the observed floating-point differences.

| Field | Seeds bitwise identical to archive | Maximum absolute difference |
|---|---:|---:|
| Observations | 0/100 | 1.776357e-15 |
| Baseline | 0/100 | 1.776357e-15 |
| Signal | 67/100 | 8.881784e-16 |

[table2_data_sha256.csv](table2_data_sha256.csv) records SHA-256 hashes
of the archived vectors and all 300 quantile curves, encoded as
little-endian IEEE-754 doubles. The derived quantile offset can vary by
a few ULPs across R builds. Data identity is enforced bitwise on the
observations and archived baseline. Fits and reports add the fixed
R 4.5.2 NOTS offset from [table2_offsets.csv](table2_offsets.csv) to
that baseline, so truth hashes are also reproducible. Workers record
the local R version and 17-digit `qnorm(tau)`, and require the local
offset to agree with the fixed value within 64 machine epsilons.
On Owls R 4.6.0, the local offsets differ from these archived values by
0, 2, and 1 ULP respectively. At each level the recorded offset was the
only double within eight ULPs of the Owls value that reproduced all
100 archived Laplace MSEs bitwise.
The check confirms that true signal labels are unchanged by
regeneration, and independently reproduces MSE, CL and the four CAA
values for all 300 archived Laplace fits (tolerance 1e-12).

## HQ benchmark reuse audit

The October 23 Laplace archive records the SHA-256
`b12396de72540d518cf92ed279ae765236774bad349ea1d3086d76efb1ad21ac`
for `Driver/common_air.R`. The historical
[build report](../../experiments/air_simulation/onizuka_laplace_20261023/BUILD_REPORT.md)
records the identical generator hash from the October 8 campaign, the
cross-method data equality check in that campaign's original processing
step, and the direct equality of `y`, `theta` and `s` to the October
8 archive at seeds 1–3. The October 8 per-replication archive and the
ADMM per-seed mask are unavailable in this checkout. The preserved
October 8 and October 23 summaries reproduce **72 of 72** printed values in
[Table 2](../../paper/sections/air_simulation.tex), at 4 decimals for
MSE, 5 for CL, and 3 for CAA. The audit also reaggregates the archived
Laplace per-replication metrics and reproduces **18 of 18** of its
published means at that precision.

| Method | Exact regeneration on Owls | Reaggregation from original per-replication metrics | HQ reuse verdict |
|---|---|---|---|
| ADMM | Fails the exact comparison on the common input | Original archive unavailable. The aggregate summary matches 18/18 values. τ = 0.05 has 99 replications, with 90 defined CAA values and an unknown omitted seed. | Approved to refit with `admm-sim`. |
| Onizuka HS | Fails the exact comparison on the common input | Original archive unavailable. The aggregate summary matches 18/18 values. | Approved to refit with `onizuka-hs`. |
| Onizuka Laplace | Regeneration differs by at most 1.8e-15 | 300/300 original rows verified, 18/18 reaggregated means match at paper rounding. | **REUSE (HQ ruling 11-26)** |

The archived Laplace fits ran on the sealed Table 2 data. The audit
verified the archive and vector hashes, checked all 300 per-replication
records, and reproduced all 18 published means at the printed precision.
HQ accepted the regeneration difference as BLAS roundoff. All E-18
fits read the sealed vectors, so that difference cannot affect this
comparison. Stage 1 reads the archived Laplace records directly for
both the table and the paired comparisons.

The reference values and SEs are in
[published_stage1.csv](published_stage1.csv) and are kept separate
from new benchmark results. All E-18 workers read the same sealed
Table 2 input archive and verify the observation and truth hashes
before fitting. The archived Laplace and HS sampler source is
[BQTF-function.R](../../experiments/extreme_quantiles/packages/Extreme_Onizuka/source/BQTF-function.R).
Its SHA-256 matches both historical air packages according to the
build report. HQ approved the ADMM and HS refits using the sealed
inputs and the published driver settings.

## Reproduce

From the repository root, run

```sh
~/.config/bvs-hq/owls/owls_run -j 1 Rscript --vanilla engineering/E18_Air_Refit/e18_verify_data.R
```

This validates the archived file SHA-256, compares both generators to one
another and to the stored vectors, checks the archived Laplace metrics,
and rebuilds the two audit CSVs. It runs no sampler.
