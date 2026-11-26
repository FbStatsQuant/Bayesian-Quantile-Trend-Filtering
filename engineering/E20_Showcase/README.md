# E-20 README showcase

Three Bayesian quantile trend filtering fits on the same 1,000 observations
illustrate the joint noncrossing fit and the two separate fits at the
0.10 and 0.90 quantiles. The data and posterior summaries are inputs to the
public README figure.

## Data

The data seed is `1`. The runner calls the original paper campaign's
`simulate_data(seed = 1L, n = 1000L, tau = 0.5, baseline_id = "VS",
noise_id = "Normal")`
from the [October individual sampler snapshot](../../experiments/interior_quantiles/individual_nots_20261003/source/Individual_Sampler_PMALA_Augmented.R)
at `2ed6baec9fe8e5673419b2b93b0de821db5a337c`. The
[E-14 data wrapper](../E14_Inner_Rerun/e14_data.R) uses the same function
with `n = 500L`. The function itself accepts `n` and needs no changes.
With integer grid `x = 1, ..., 1000` and `u = x / 1000`, the noiseless
signal is `2 + sin(4*u - 2) + 2*exp(-30*(4*u - 2)^2)`. Independent Gaussian
errors have mean zero and pointwise standard deviation `(1 + u^2)/4`.
The generator uses Mersenne-Twister, Inversion and Rejection. Its `tau`
argument affects only its conditional quantile output. The showcase
exports the generator's noiseless `baseline` as `truth`.

## Samplers

Both samplers and their C++ kernels are loaded from commit
`63f2a56205b8d2ec311565db8c98874cd96754b2`. The joint run uses
[Joint_Sampler_PMALA_Augmented.R](../../method/joint/Joint_Sampler_PMALA_Augmented.R).
The individual runs reuse the loader and follow the sampler call in
[e14_run.R](../E14_Inner_Rerun/e14_run.R) with the shared showcase data.

| Setting | Joint | Individual |
| --- | --- | --- |
| Levels per fit | 0.10 and 0.90 | One fit per level |
| Chain seed | 10003 | 10001 for 0.10, 10002 for 0.90 |
| Trend filtering | Order 2, third differences | Same |
| Lambda prior | Gamma shape 1, rate 0.01 | Gamma shape 1, rate 0.001 |
| Sigma prior | Inverse-Gamma shape 0.1, scale 0.1 | Same |
| Sweeps, burn-in, retained draws | 30,000, 10,000, 20,000 | Same |
| Initial state | Ordered running-median pilot (window 51) shifted by residual quantiles, with sigma from mean check loss and latent variables drawn conditionally | Same initialization at the fitted level |
| Initial lambda and step size | 997 and 0.2 | Same |
| Warm sweeps | 200 conditional MAP sweeps with gamma = 10,000 and lambda held at 997 | Same |
| Sigma guard | During burn-in, reset to initial sigma above 10 times initial sigma | Same |
| P-MALA | One Metropolis-corrected move per sweep and level | One Metropolis-corrected move per sweep |
| Metric | Curvature, kappa = 3, fixed-metric constant = 10,000 (inactive) | Same |
| ADMM | 150 iterations, automatic rho, tolerance 0 | Same |
| Adaptation | Target 0.5, gain 1 times sweep to the power −0.6, step bounds [1e-8, 100], enabled throughout | Same |
| ASIS | Enabled, `asis_q = "auto"` resolves to spline dimensions 10, 20, 40 cycled per sweep | Enabled, `asis_q = "fixed"` cycles through spline dimensions 10, 20, 40 |
| Additional controls | Ordered box, unbounded prox tried first, IPM method 1 with 100 iterations, tolerance 1e-8 and trace off, zeta scale 1 | Prior scale `"none"`, conditional MAP mode off, lambda jump off (scale 0.3), 0 extra theta block moves (mode `"mala"`) |

Both samplers use the E-13a warm solver with 300 ADMM iterations, residual
tolerance 1e-6 and a 200-iteration IPM fallback at tolerance 1e-8. The
individual call passes glmgen controls `max_iter = 2000L` and
`obj_tol = 1e-8`, which apply to the optional trend-filter initialization.
The runner uses Mersenne-Twister, Inversion and Rejection for the chain seeds.

The [paper's “Extreme, joint” row](../../paper/sections/appendix_pmala.tex)
and the [upper-level campaign configuration](../../experiments/joint_upper_levels/config.R)
agree on the VS rate 0.01, the priors, order, sweep counts, ASIS and target
acceptance. The campaign README references an older paper value of 0.001.
The current joint script defaults to 1e-5, so the runner passes 0.01
explicitly. The paper's general settings prose and the October joint
snapshot initialize sigma at 1. The requested current joint sampler
initializes sigma from the data pilot and holds lambda during warm-up
through its built-in E-13a initialization.

## Run provenance

| Runner version | SHA-256 |
| --- | --- |
| Individual 0.10 pilot at launch | `e82c322e3a8ba2c24c226fd886e708d14ae2a1f2dd0b230d4b3eaa2795347aac` |
| Individual 0.90, joint and export (committed runner) | `7dc60d18301d7c51d2c70aff718e8274b9d8bda12d0d4a48697e4eca157adde5` |

The pilot launched with repository HEAD
`b7a183aac6c77b67a0cc4ba31a46baf3810e450c` and recorded the HEAD at
completion, `fa95b975c5d8c7e2f0b6371653023da822fa272a`, in its RDS.
The individual 0.90 and joint fits recorded that same commit at launch.
All three fits ran on Owls with R version 4.6.0 (2026-04-24).
An edit to the open script caused a parse error after the pilot finished
and published the RDS. The RDS was successfully read and validated. The
pilot SHA-256 is from its reconstructed launch file, recovered by reversing
the recorded edits. Those edits changed when HEAD is recorded, how the CSV
is published and checked, and whether a completed fit may replace an
existing RDS. The fitting settings and calculations are identical.

Wall and CPU time are measured for each sampler call, from initialization
through its final sweep. CPU time is user plus system time. Acceptance and
`coda::effectiveSize` for lambda use the 20,000 retained sweeps. Sigma
guard counts cover burn-in, when the guard is enabled.

The initial joint projection was 2h 24m. It used the archived seed-1
Normal six-level joint runtime (4,499.618 seconds), scaled to two levels
and by the ratio of the E-20 pilot to the E-14 seed-1 Normal 0.05 chain
(764.339 / 132.743). This estimate assumed the joint cost scaled with
the individual cost across sample sizes and compute environments.
The measured joint fit took 53m 00s wall time, about 91 minutes under
that projection. The individual 0.90 and joint jobs emitted Rcpp
temporary-directory cleanup warnings after writing their RDS files and
both exited successfully.

## Reproduce on Owls

From the repository root, use the Owls wrapper. Run the first command by
itself to measure the pilot before launching the other fits.

```sh
mkdir -p runs/E20-showcase-20261126
export TMPDIR="$PWD/runs/E20-showcase-20261126"
~/.config/bvs-hq/owls/owls_run -j 1 -- Rscript --vanilla engineering/E20_Showcase/e20_run.R individual-q10
~/.config/bvs-hq/owls/owls_run -j 1 -- Rscript --vanilla engineering/E20_Showcase/e20_run.R individual-q90
~/.config/bvs-hq/owls/owls_run -j 1 -- Rscript --vanilla engineering/E20_Showcase/e20_run.R joint
~/.config/bvs-hq/owls/owls_run -j 1 -- Rscript --vanilla engineering/E20_Showcase/e20_run.R export
```

Each fit writes a compact RDS with the shared data, posterior summaries,
settings, timing, diagnostics and full lambda and sigma traces. Running
a fit or export again replaces its previous output after success. The kernel
source copies and run logs are under `runs/E20-showcase-20261126/`.

## Export

`curves.csv` contains 2,000 rows, one per method and grid point. Each
quantile estimate is the posterior mean of the 20,000 retained draws, and
its pointwise credible limits are the 2.5th and 97.5th percentiles (R
quantile type 7). The joint rows use both levels of the same fit. The
individual rows pair the two independent fits by grid index. The band
fraction counts observations between the two posterior means, inclusive.
The committed runner completed its export step on Owls from the saved
RDS files. All 2,000 rows and their curve values were checked against the
saved summaries.

## Results

| Fit | Quantile | Wall (s) | CPU (s) | Acceptance | Lambda ESS | Sigma guards |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Individual | 0.10 | 764.339 | 760.552 | 0.49460 | 115.479 | 0 |
| Individual | 0.90 | 525.596 | 523.366 | 0.50210 | 74.777 | 0 |
| Joint (one fit) | 0.10, 0.90 | 3180.236 | 3161.486 | 0.49980, 0.49995 | 161.002, 99.729 | 0, 0 |

| Method | Grid points with q10 > q90 | Fraction of observations inside [q10, q90] |
| --- | ---: | ---: |
| Joint | 0 / 1,000 | 0.809 |
| Individual | 0 / 1,000 | 0.802 |
