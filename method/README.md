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
cd method/joint      && Rscript Joint_Sampler_PMALA_Augmented.R test_prox      # needs clarabel, about 70 s including compilation
cd method/joint      && Rscript Joint_Sampler_PMALA_Augmented.R test           # kernel + exactness tests (longer)
```

Run with no argument, each script fits one simulated data set with the settings block at the top of the file and writes `results_*/` next to itself (git-ignored).

## Defaults = paper defaults

Since E-03 the settings block of `individual/Individual_Sampler_PMALA_Augmented.R` equals the production configuration of the interior-quantile campaign: order 2 (k = 2, third differences), b0 = 0.01, ASIS on, target acceptance 0.50, 30,000 sweeps with 10,000 burn-in, seed 1, tau 0.5. The sampler body is unchanged.

## Dependencies

R >= 4.4: `Rcpp`, `RcppArmadillo`, `glmgen`, `Matrix`; joint tests also `clarabel`. A C++17 compiler. On Windows the scripts fall back to a mingw `g++` if `Rcpp::sourceCpp` fails.

Install `glmgen` 0.0.3 from GitHub with the `remotes` package:

```r
remotes::install_github("glmgen/glmgen", ref = "9e6061503d6dd103712a0c07f6be7293c1c58aaf", subdir = "R_pkg/glmgen", upgrade = "never")
```

Install `clarabel` with `install.packages("clarabel")`. The CRAN source package
declares Cargo, `rustc` >= 1.70.0, and GNU Make. Version 0.11.3 passed the
joint optimisation-kernel tests with R 4.6.0 and Rust 1.100.0. [CRAN package requirements](https://CRAN.R-project.org/package=clarabel)

To use the checkout's local R library from the repository root, prepend
`ops/Rlib` to R's existing user-library search path:

```sh
mkdir -p ops/Rlib
r_user_libs="$(Rscript -e 'cat(Sys.getenv("R_LIBS_USER"))')"
export R_LIBS_USER="$PWD/ops/Rlib:$r_user_libs"
Rscript -e 'install.packages("clarabel", lib = "ops/Rlib", repos = "https://cloud.r-project.org")'
```

## Bitwise tests and compiler flags
Some tests check exact (bitwise) identities, e.g. joint P1 "free box = unbounded kernel" and the J = 1 draw-for-draw check. They pass with the default flags on Owls. On compilers that contract floating-point expressions into FMA instructions by default (seen with GCC 14 on NOTS), P1 differs at 2e-16 and its bitwise assertion fails. That is a rounding difference, not a correctness one. To reproduce the bitwise tests there, build with FMA contraction off, through a user Makevars:
```
CXXFLAGS=-O2 -ffp-contract=off
CXX17FLAGS=-O2 -ffp-contract=off
```
(`export R_MAKEVARS_USER=/path/to/Makevars`). With that, `Rscript Joint_Sampler_PMALA_Augmented.R test_prox` prints "all optimisation-kernel tests passed" (E-03 smoke test, 2026-11-22).
