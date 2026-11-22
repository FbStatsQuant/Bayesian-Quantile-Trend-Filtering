# method/

The canonical sampler code. One copy; the frozen copies inside `experiments/*/source/` document what each campaign ran.

| Folder | Entry point | What |
|---|---|---|
| `individual/` | `Individual_Sampler_PMALA_Augmented.R` (+ `prox_admm_metric.cpp`, `pmala_exact_methods_note.md`) | single-quantile exact augmented P-MALA; one Gibbs sweep = P-MALA on the trend, conjugate/ASIS updates for latents, lambda, sigma |
| `joint/` | `Joint_Sampler_PMALA_Augmented.R` (+ `prox_box_metric.cpp`) | non-crossing joint sampler over an ordered set of levels. Needs `../individual/` (the C++ kernel `prox_admm_metric.cpp` is `#include`d and the R functions are read from the individual script) |
| `admm_qtf/` | `ADMM_QTF_Individual.R` | ADMM quantile trend filtering baseline (non-Bayesian) |

## Run and test

```sh
cd method/individual && Rscript Individual_Sampler_PMALA_Augmented.R test      # "all tests passed", about 100 s
cd method/joint      && Rscript Joint_Sampler_PMALA_Augmented.R test_prox      # needs R package clarabel
cd method/joint      && Rscript Joint_Sampler_PMALA_Augmented.R test           # kernel + exactness tests (longer)
```

Run with no argument, each script fits one simulated data set with the settings block at the top of the file and writes `results_*/` next to itself (git-ignored).

## Defaults = paper defaults

Since E-03 the settings block of `individual/Individual_Sampler_PMALA_Augmented.R` equals the production configuration of the interior-quantile campaign: order 2 (k = 2, third differences), b0 = 0.01, ASIS on, target acceptance 0.50, 30,000 sweeps with 10,000 burn-in, seed 1, tau 0.5. The sampler body is unchanged.

## Dependencies

R >= 4.4: `Rcpp`, `RcppArmadillo`, `glmgen`, `Matrix`; joint tests also `clarabel`. A C++17 compiler. On Windows the scripts fall back to a mingw `g++` if `Rcpp::sourceCpp` fails.
