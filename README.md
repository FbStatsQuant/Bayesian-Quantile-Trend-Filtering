# Bayesian Joint Quantile Trend Filtering

[![R >= 4.4](https://img.shields.io/badge/R-%E2%89%A5%204.4-276DC3)](https://www.r-project.org/)
[![Lean 4](https://img.shields.io/badge/Lean-v4.35.0--rc2-0f4c81)](https://lean-lang.org/)
[![Theorems 1-2 verified in Lean](https://img.shields.io/badge/Theorems%201%E2%80%932-verified%20in%20Lean-2e7d32)](#formal-verification-in-lean)
[![License: MIT (code)](https://img.shields.io/badge/license-MIT%20%28code%29-lightgrey)](#citation-and-license)

This repository has the code, the paper and the Lean proofs for
**Bayesian Joint Quantile Trend Filtering via Proximal MCMC with Sequential Gibbs Sampling**,
by Felipe Bedoya, Meng Li (Department of Statistics, Rice University) and
Eric C. Chi (School of Statistics, University of Minnesota).

## The main idea behind this project

Quantile trend filtering estimates a conditional quantile by combining the
check loss with an ℓ1 penalty on the differences of order k+1 of the trend. It returns a point
estimate, and the penalty has to be selected. We give it a Bayesian counterpart: an asymmetric
Laplace working likelihood, a Laplace prior on the differences, and priors on the penalty and the
scale. The output is a posterior, with no cross-validation. A joint version fits several quantile levels together, and its draws never cross.

Theorem 1 takes independent observations, k ≥ 1, and true quantiles whose total variation of
order k+1 is bounded (V* ≤ V̄). For a fixed scale and a deterministic penalty of order
n^((2k+1)/2), the posterior contracts around them at the rate n^(-(2k+1)/(2k+2)) in the Δ²ₙ
loss: n^(-5/6) for k = 2, with no logarithmic factor. The noise needs local bounds on its
distribution functions near the quantile, and no moment. Theorem 2 gives the same rate at every
level of the non-crossing joint posterior at once, for finitely many fixed levels, with no
additional separation assumption. Both theorems are machine-checked in Lean 4
([`lean/`](lean)). The theorems hold the penalty and the scale fixed; the samplers place priors
on both, and that case is not covered.

The normal-exponential representation of that likelihood makes the conditional
of the trend a weighted quadratic plus the ℓ1 difference penalty. A proximal Metropolis-adjusted
Langevin step updates the trend; its proximal map is a weighted trend filtering problem on this
whole conditional, not on a smoothed check loss, and the accept-reject step uses the exact
density. For one level the map is a fixed number of banded ADMM iterations, so a sweep is linear
in n: a median 2.0 ms at n = 250 and 36.6 ms at n = 4,000 (τ = 0.5, k = 2, one laptop core). In the joint sampler the map is box-constrained: the same ADMM when no
bound binds, otherwise banded interior-point steps, each linear in n.

![Two panels: a shaded band between two estimated quantile curves with the data points on top, for children's height by age and for data simulated from an explicit function](examples/readme_figures/reference_outputs/readme_combined.png)

*Bands between jointly sampled 0.1 and 0.9 quantile curves; both fits are by the joint sampler, and the curves cannot cross. (a) Height of 4,817 Dutch children; the band holds 80.5% of them (nominal 80%). (b) n = 1,000 points simulated from the explicit function f(u) = 2 + sin(4u − 2) + 2·exp(−30(4u − 2)²), with u = i/1000, plus Gaussian errors with standard deviation (1 + u²)/4; the band holds 80.9% of the points (nominal 80%); dotted: f.*

In the peak-detection simulation of Brantley et al. (2020) for air-quality sensors, the MSE for
the peak-free baseline is 0.0232 for the sampler against 0.0302 for ADMM quantile trend filtering
at τ = 0.01, 0.0143 against 0.0127 at τ = 0.05, and 0.0128 against 0.0114 at τ = 0.10; the sampler
learns the penalty instead of selecting it on a grid. The two methods are comparable: the paired
MSE differences are within two standard errors of zero at all three levels, and the check loss and
the peak-detection accuracy are mixed. On one day of fenceline sensor data, aggregated into 8,640
ten-second blocks, the sampler's baselines at τ = 0.01, 0.05 and 0.10 run beneath the plumes;
0.9%, 5.9% and 11.6% of the block values fall below them. The three levels are fitted separately.

## Our work

The samplers and the proofs run on a laptop. The simulation campaigns ran on a Slurm
cluster from frozen packages; each experiment folder ships its summaries. The task runners under
`engineering/` are records of the runs they made; to rerun one, see
[`engineering/README.md`](engineering/README.md#rerunning-older-experiments-after-f12).

| In the paper | Folder | How to run | Time |
|---|---|---|---|
| Section 2, Algorithms 1–2: the two samplers | [`method/`](method) | from the repository root: `Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test`; `Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox` | about 5 min (individual, including compilation); about 70 s (joint, including compilation) |
| Section 3 and Appendix A: Theorems 1 and 2 | [`lean/`](lean) | in `lean/`: `lake exe cache get`, `lake build`, `lake env lean AxiomCheck.lean` | about 15–20 min on 3 cores, with the prebuilt Mathlib |
| Section 4.1 and Appendix D: simulations at interior levels (Tables 1–2) | [`experiments/interior_quantiles/`](experiments/interior_quantiles) (the individual-sampler package of 2026-10-03) | shipped: `paper_reference/simulations.tex` and `paper_reference/appendix_pmala.tex` in that package. Full run, on a Slurm cluster: `bash submit.sh RUN_NAME` from the package folder | 3,000 cluster tasks |
| Section 4.1 and Appendix D: joint estimation of extreme upper levels (Tables 3–4), crossing tables | [`experiments/extreme_quantiles/`](experiments/extreme_quantiles), [`experiments/joint_upper_levels/`](experiments/joint_upper_levels) | shipped: `experiments/extreme_quantiles/tables_20261023/mse_consolidated_oct7.csv`, `experiments/extreme_quantiles/tables_20261008/crossings_*.csv`, `experiments/joint_upper_levels/paper_reference/table2_mse.csv`. Full joint run, on a Slurm cluster: `cd experiments/joint_upper_levels && bash submit.sh RUN_NAME` | 300 cluster tasks for the joint run |
| Section 4.2: cost per sweep (Table 5, Figures 1–2) | [`paper/`](paper) (Table 5) | the paper's cost table is the reference; `experiments/scalability/` is a historical record and does not run | |
| Section 4.3: air-quality simulation (Table 6) | [`experiments/air_simulation/`](experiments/air_simulation), [`engineering/E18_Air_Refit/`](engineering/E18_Air_Refit) | shipped: `engineering/E18_Air_Refit/results_a0_n/paper_air_table.csv` and `paired_pmala_minus_admm.csv`. Full refit, on a Slurm cluster: see [`engineering/E18_Air_Refit/README.md`](engineering/E18_Air_Refit/README.md) | 300 cluster fits |
| Section 4.4: air-quality sensor data | [`applications/Air Quality/`](applications/Air%20Quality), [`engineering/E18_Air_Refit/`](engineering/E18_Air_Refit) | from the repository root: `Rscript paper/figures/make_spod_pmala_figure.R` redraws the figure from the shipped curves (`engineering/E18_Air_Refit/results_a0_n/spod_curves.csv`). The fits ran on a Slurm cluster: see the E-18 README | six chains of 37–49 min each for the fits |
| Section 4.4 and Appendix E: growth centiles | [`applications/Growth/`](applications/Growth) | in `applications/Growth/`: `Rscript Growth_plots_k2.R` redraws the figures of the shipped joint-sampler fit and overwrites `results_joint_k2/figures/growth_joint_*`; `Rscript Growth_Joint_PMALA_k2.R sex=boy out=results_refit/boy` refits the boys into a new folder | a few seconds for the figures; about 40 min on one core for the refit, which reproduces the shipped fit's diagnostics |
| The figure above | [`examples/readme_figures/`](examples/readme_figures) | `Rscript examples/readme_figures/make_readme_figures.R` | under 30 s on one core |
| The paper | [`paper/`](paper) | read `main.pdf`, or in `paper/`: `latexmk -pdf main.tex` | |

The linked folders contain the settings, scripts, or shipped outputs for each result.

The growth fit shipped in `applications/Growth/results_joint_k2/` is a joint-sampler fit of five
levels. The growth figures of the paper come from fits of one level at a time, and the script that
draws them is not in this repository; the same holds for the figures `spod_*` and `scal_*`.

## Formal verification in Lean

Both contraction theorems of the paper are proved in [Lean 4](https://lean-lang.org/) with Mathlib, in [`lean/`](lean). A proof assistant checks every step of a proof down to the axioms, so the theorems do not rest on a referee having read the appendix line by line.

### What is proved

| Paper | In plain words | Lean statement | Proved by |
|---|---|---|---|
| Theorem 1, σ = 1 | For independent data whose distribution functions grow at least and at most linearly near the τ-quantile (Assumptions A and B), a true trend whose total variation of order r = k + 1 (the paper's TV^(r)) is at most V̄, and a penalty λ = c·n^((2k+1)/2), the expected posterior mass of the trends whose loss Δ²ₙ exceeds M·n^(−(2k+1)/(2k+2)) is at most C·n^(−1/(2k+2)). There is no logarithmic factor. | `MainStatement` | `main_theorem` |
| Theorem 1, any fixed scale σ₀ > 0 | The same bound, with constants that may also depend on σ₀. | `MainStatementScale` | `main_theorem_scale` |
| Theorem 2, unit scales | For J quantile levels fitted jointly under the non-crossing constraint, the same bound holds for the largest of the J losses, so all levels contract at the same rate at once. | `JointStatement` | `joint_theorem` |
| Theorem 2, any fixed scales σ₀ⱼ > 0 | The same, with a separate scale at each level. | `JointStatementScale` | `joint_theorem_scale` |

The observations need not be identically distributed and no moment is assumed. The asymmetric Laplace density is a working likelihood only.

In Theorem 2 the true quantile curves are not assumed to be separated, and nothing is assumed about independence across levels: every level uses the same observations.

The four statements are collected in [`lean/BQTF/Spec.lean`](lean/BQTF/Spec.lean). [`lean/docs/statements.md`](lean/docs/statements.md) explains each one in plain mathematics, so you can compare it with the paper without reading Lean.

### Why you can trust it

- **No `sorry`.** Nothing is left unproved.
- **Standard axioms only.** `#print axioms` on each of the four theorems lists `propext`, `Classical.choice` and `Quot.sound`, the three axioms of ordinary mathematics in Lean, and nothing else. This was last checked, with a full build and the source scan, at commit f64025a. No Lean source, lakefile, manifest or toolchain file has changed since.
- **The statements are pinned.** [`lean/AxiomCheck.lean`](lean/AxiomCheck.lean) contains lines such as `example : MainStatement := main_theorem`. They compile only if each theorem has exactly the type written in `Spec.lean`, so a proof of something weaker cannot pass under the same name.
- **Independent final audit: CLEAN.** A reviewer who wrote none of the proofs compared the four compiled statements with the paper, hypothesis by hypothesis, and reran the axiom check and the source scan. The verdict: all four Lean statements imply their paper counterparts, with no gap in any of them.
- **Every module was reviewed.** Every source file is covered by a dated code review in [`lean/notes/reviews/`](lean/notes/reviews), written by a reviewer who did not write that file. The statements were audited separately, in [`lean/notes/audits/`](lean/notes/audits). Every finding was ruled on.

### Classical results proved from scratch

No classical result enters as a hypothesis. Where Mathlib did not have a result the proofs need, it is proved in this repository:

| Result | Lean declaration | File |
|---|---|---|
| Efron–Stein inequality, one-sided form | `BQTF.Prob.efronStein_oneSided` | `lean/BQTF/Prob/EfronStein.lean` |
| Rademacher contraction principle (Ledoux–Talagrand, Theorem 4.12) | `BQTF.Prob.contraction_abs` | `lean/BQTF/Prob/Contraction.lean` |
| Symmetrization for finite empirical processes (van der Vaart and Wellner, Lemma 2.3.6) | `BQTF.Prob.symmetrization_finset` | `lean/BQTF/Prob/Symmetrization.lean` |
| Eckart–Young tail bound for singular values (Frobenius form) | `BQTF.Lin.eckartYoung_tail` | `lean/BQTF/Lin/EckartYoung.lean` |
| Prékopa–Leindler inequality: the functional form on ℝ, tensorized to the product Laplace law on ℝᵈ. The proof uses it as joint log-concavity of the Laplace slice mass. | `BQTF.PL.pl_one`, `BQTF.PL.plProp_Qlam`; applied in `BQTF.prekopa_laplace` | `lean/BQTF/Shift/PrekopaLaplace/OneDim.lean`, `…/Tensor.lean`, `lean/BQTF/Shift/PrekopaLaplace.lean` |

### What the formalization changed in the paper

Formalizing the proofs found eleven places where the paper's argument needed a fix, numbered C-01 to C-11 in [`lean/notes/PAPER_CORRECTIONS.md`](lean/notes/PAPER_CORRECTIONS.md): missing cases, side conditions that were not stated, and intermediate claims that were wrong as written. None changes the statement of a theorem or a rate. All eleven are now in the paper, and each was checked against the Lean declaration that settles it.

Three examples:

- **C-06.** The variance bound for a supremum used a two-sided change bound that holds only one-sided. The fix uses the one-sided Efron–Stein inequality; the bound is unchanged.
- **C-07.** A second-moment bound was proved only for positive shifts, and the printed formula was false for negative ones. The fix adds the negative case with the same constant.
- **C-02 and C-11.** The theorems take the expectation of the posterior probability of a set, but the paper never said that this probability is a measurable function of the data. Lean proves it as part of each conclusion.

### Where Lean differs from the paper

Both theorems have the paper's hypotheses and conclusions. [`lean/docs/statements.md`](lean/docs/statements.md) lists every difference, D1 to D12, with its direction:

- **Equivalent reformulations** (D1, D2, D4, D5, D9), for example the assumptions stated coordinate by coordinate and the posterior written with its normalizer.
- **Stronger conclusions** (D3, D8): measurability of the posterior mass is proved as part of the theorem.
- **Safe generalizations** (D6, D7, D11): the level spacing enters through a lower bound, both in Theorem 2 and in the gap lemma, and the number of levels is any natural number.
- **Lemma sup** (D12) is proved on the paper's named event, as `supNorm_concentration_events`, so it matches the paper.
- **One difference is weaker than the paper** (D10). Two constants that the paper gives explicitly in appendix lemmas are existential in Lean: C_E in Lemma evid and C_pr in Proposition prior. A third, the quad-shift coefficient, is a different explicit constant, in place of the paper's eventual bound of 2. So the Lean versions of those standalone lemmas say less than the paper's. The two theorems are not affected: their constants are existential in the paper too, and the final audit traced that the weaker lemmas suffice.

### Build and check

You need [elan](https://github.com/leanprover/elan). It installs the toolchain pinned in `lean/lean-toolchain` (`leanprover/lean4:v4.35.0-rc2`). Mathlib is pinned in `lean/lake-manifest.json`, at revision `065356127b1dc0016f66b7283ce0ce2c4055aa55` (input revision `v4.35.0-rc2`).

```sh
cd lean
lake exe cache get              # prebuilt Mathlib; without it Mathlib compiles for hours
lake build                      # ends with "Build completed successfully"
lake env lean AxiomCheck.lean   # prints the axioms each main theorem uses
sha256sum -c SHA256SUMS.txt     # the Lean sources are the ones we checked
```

With the prebuilt Mathlib, `lake build` takes about 15–20 minutes on 3 cores.

The third command should print four lines, each ending in `[propext, Classical.choice, Quot.sound]`.

### Module map

```
lean/
├── BQTF/                  the development
├── BQTF.lean              imports every module
├── AxiomCheck.lean        type and axiom checks for the four theorems
├── docs/statements.md     the statements in plain mathematics, and the differences from the paper
├── notes/                 statement audits, per-module reviews, paper corrections, work logs
├── PLAN.md                the module plan the formalization followed
├── lakefile.toml, lake-manifest.json, lean-toolchain
└── SHA256SUMS.txt
```

A rough map of `lean/BQTF/`:

| Files | Content |
|---|---|
| `Spec.lean` | The four statements and the definitions they use |
| `Basic.lean`, `Coord.lean` | Norms, the prior in difference coordinates; the posterior as a ratio and its properness (Lemma coord) |
| `CheckLoss.lean` | The check loss and its moments (Lemma check) |
| `Gram.lean`, `Falling.lean`, `Smooth.lean`, `Interp.lean`, `SplineApprox.lean` | The polynomial Gram constant (g_r > 0), falling factorials, the smoothed truth (Lemma smooth), the interpolation inequality, spline approximation (Lemma F) |
| `Width.lean`, `Concentration.lean`, `Score.lean` | The width bound, concentration of the empirical process, the score events |
| `SmallBall.lean`, `QuadShift.lean`, `PriorMass.lean`, `Prior/`, `Denominator.lean` | Small-ball probability, the quadratic-shift lemma, prior mass (Proposition prior), the lower bound on the denominator (Lemma evid; `Prior/` holds the prior matrix and smoothing window at which it applies Proposition prior) |
| `Localization.lean`, `Shells.lean` | Localization of the posterior to the set K(ρₙ, Tₙ) (Proposition local), and the bound on the shells outside it (Proposition shell) |
| `Main.lean` | Theorem 1 at σ = 1 |
| `Reduction.lean`, `Scale/` | Theorem 1 at a general scale, by rescaling the data |
| `Joint/` | Theorem 2: the product posterior and its conditioning on the non-crossing set, the gap between levels, sup-norm concentration, transfer, and the two joint theorems (`Joint/Main.lean`) |
| `Prob/` | Efron–Stein, the contraction principle, symmetrization |
| `Lin/` | Eckart–Young, the Gaussian small-ball bound, the Laplace scale mixture |
| `Shift/` | Prékopa–Leindler for the Laplace measure, Rademacher maxima, slice bounds |
| `Asym/` | Helpers for Localization, Shells, Denominator, Theorem 1 and the sup-norm lemma. The 8 files cover asymptotic rate bounds (`Rates`, `LocalRates`, `ShellRates`), the Laplace moment generating function and product integrals (`Laplace`), measurability and exponential integrals of the check-loss increments (`CheckIntegrals`), the local prior mass in polynomial coordinates (`LocalMass`), and continuity, closedness and norm identities (`LocalGeometry`, `Vector`). |

The work logs and reviews in [`lean/notes/`](lean/notes) record how the development was built and checked.

## Quick start

You need R 4.4 or later with the packages `Rcpp`, `RcppArmadillo`, `glmgen` and `Matrix`, and a
C++17 compiler. The C++ kernels compile themselves the first time a sampler runs. All commands are
typed at the repository root unless a `cd` is shown.

**Check the samplers.**

```sh
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test    # prints "all tests passed"; about 5 min including compilation
Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox         # needs the R package clarabel; prints "all optimisation-kernel tests passed"; about 70 s
```

If a bitwise test fails by about 2e-16, see the compiler note in [`method/README.md`](method/README.md).

**Fit one quantile trend.**

```sh
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R
```

This simulates one data set, runs the sampler with the settings block at the top of the file
(order k = 2, penalty prior λ ~ Gamma(1, 10⁻³), 30,000 sweeps with 10,000 burn-in) and writes a
summary and a plot to `method/individual/results_pmala_aug/`. To change the signal, the noise, the
sample size or the quantile level, edit the settings block. `Rscript
method/joint/Joint_Sampler_PMALA_Augmented.R` does the same for several levels at once, with
λ ~ Gamma(1, 10⁻²). Each default matches the paper's runs of that sampler; the paper's scripts set
their own priors: rates 10⁻³ and 5·10⁻⁴ for the two interior-quantile signals, and
Gamma(n, 10⁻²) for the air-quality data (Section 4.3). On one core of a workstation the default
run takes about 7.5 minutes for the individual sampler and about 28 minutes for the joint sampler,
which needs the R package `clarabel` and writes to `method/joint/results_joint/`.

**Redraw the figure above.**

```sh
Rscript examples/readme_figures/make_readme_figures.R    # draws from the saved curves; needs ggplot2
```

**Redraw the growth centiles** from the shipped joint-sampler fit:

```sh
cd applications/Growth && Rscript Growth_plots_k2.R    # a few seconds; overwrites results_joint_k2/figures/growth_joint_*
```

**Check the proofs.** Install [elan](https://github.com/leanprover/elan), then

```sh
cd lean
lake exe cache get              # prebuilt Mathlib; without it Mathlib compiles for hours
lake build                      # about 15-20 min on 3 cores; ends with "Build completed successfully"
lake env lean AxiomCheck.lean   # four lines, each ending in [propext, Classical.choice, Quot.sound]
sha256sum -c SHA256SUMS.txt     # the Lean sources are the ones we checked
```

**Build the paper.** `cd paper && latexmk -pdf main.tex`

## Requirements

- **R** 4.4 or later, with a C++17 compiler: `Rcpp`, `RcppArmadillo`, `glmgen`, `Matrix`. The
  joint sampler's tests also need `clarabel`, and the figure scripts need `ggplot2`.
- `glmgen` is not on CRAN. Install it with
  `remotes::install_github("glmgen/glmgen", ref = "9e6061503d6dd103712a0c07f6be7293c1c58aaf", subdir = "R_pkg/glmgen", upgrade = "never")`.
- **Lean**: [elan](https://github.com/leanprover/elan) installs the pinned toolchain
  (`leanprover/lean4:v4.35.0-rc2`); `lake` fetches the Mathlib revision pinned in
  `lean/lake-manifest.json`.
- **LaTeX**: only to recompile the paper. TeX Live with `algorithmicx`, `bbm` and `bbold`.
- The simulation campaigns ran on a Slurm cluster from frozen packages. Each experiment folder
  ships its summaries, so the paper's tables can be compared without rerunning them.

## Shipped outputs

- [`examples/readme_figures/reference_outputs/`](examples/readme_figures/reference_outputs): the
  saved curves behind the figure above (small CSV files, no posterior draws) and the image.
- [`applications/Growth/results_joint_k2/`](applications/Growth/results_joint_k2): the joint
  growth fit: curve summaries, sampler diagnostics and the crossing counts (all zero).
- [`experiments/`](experiments): for each campaign, the frozen package, the summaries and the
  tables. [`experiments/README.md`](experiments/README.md) maps every table of the paper to its
  folder.
- [`lean/`](lean): the checked sources with their SHA-256 list, and the reviews in `lean/notes/`.

## Repository structure

```
paper/           the manuscript: main.pdf, main.tex, sections/, figures/
method/          the samplers: individual/, joint/, and the ADMM baseline admm_qtf/
lean/            Lean 4 proofs of Theorems 1 and 2
experiments/     the simulations of the paper: frozen packages, summaries, tables
applications/    real data: Growth/, Air Quality/
examples/        the figure on this page, with the curves it is drawn from
```

The folders `engineering/`, `theory/` and `writing/` hold the project's working records (task
notes, pilot runs, reviews), `literature/` the reading list, and `archive/` superseded material.
They are not needed to use the method or to reproduce the paper.

## Data

- **Growth.** `applications/Growth/data/fdgs.csv` is the Fifth Dutch Growth Study sample
  (Schönbeck et al., 2013) as distributed with the R package `mice` (van Buuren and
  Groothuis-Oudshoorn, 2011), exported from version 3.19.0. `mice` is distributed under the GNU
  GPL (version 2 or later); the package states no separate licence for the data.
- **Air quality.** The source is Brantley, Guinness and Chi (2020), "Baseline drift estimation for
  air quality data using quantile trend filtering", *The Annals of Applied Statistics* 14(2),
  585–604: readings of low-cost SPod sensors, which record every second at the perimeter of
  industrial facilities to detect emissions of volatile organic compounds, provided to those
  authors by the U.S. Environmental Protection Agency. The repository ships the derived 10-second
  series used in the paper (June 15, sensor d, n = 8,640) as a small CSV,
  `applications/Air Quality/spod_s08_d_2018-06-15_10s.csv`, with one row per 10-second block
  (columns `offset_seconds`, `n_readings`, `imputed`, `pid_block_mean_counts`,
  `pid_standardized`) and a `DATA.md` next to it. The raw 1-Hz files are not redistributed, so the
  scripts that made the CSV document the steps but cannot be rerun from this repository:
  [`engineering/E18_Air_Refit/e18_prepare_spod.R`](engineering/E18_Air_Refit/e18_prepare_spod.R)
  forms the 10-second blocks (it drops 30 readings recorded as "N/A" and fills the 19 empty blocks
  by interpolation), and [`engineering/H_RW/export_spod.R`](engineering/H_RW/export_spod.R) writes
  the CSV.

## Citation and license

`CITATION.cff` has the reference; GitHub shows it under "Cite this repository".

The code is MIT-licensed (see [`LICENSE`](LICENSE)). The manuscript text under [`paper/`](paper)
is not covered by that licence: all rights reserved until publication. Third-party data stay
under their providers' terms.

Questions or problems? Please open an issue.
