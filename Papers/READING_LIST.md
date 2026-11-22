# BQTF reference library: reading list

One line per paper: what it gives us, and which section of the T-03 memo uses it (`Theory/T03_Feasibility/MEMO.md`).

**Sources.** Every PDF here is a legitimate open copy, from arXiv, an author or institution page, or a file Felipe added himself.

**Not obtained.** Li & Shao (2001), *Gaussian processes: inequalities, small ball probabilities and applications*. Fill & Torcaso is used as its substitute.

## Core theory: posterior contraction and misspecification

- `Ghosal_2007_ConvergenceRatesNoniid.pdf`. Ghosal & van der Vaart (2007, Ann. Statist.), *Convergence rates of posterior distributions for noniid observations*. The general contraction theorem for independent, non-identically distributed / fixed-design data (prior mass, sieve, tests). It is the backbone that Theorem A adapts, with tests replaced by a uniform excess-loss event. Used in §3 and §6.
- `Syring_Martin 2023.pdf`. Syring & Martin (2023, Bernoulli), *Gibbs posterior concentration rates under sub-exponential type losses*. At fixed σ our posterior is a check-loss Gibbs posterior. Its Lemma 1 (evidence lower bound) and sieve bookkeeping are reused; its MGF/Bernstein route fails for the check loss (see T-02). Used in §3 and §6 (L6).
- `Sriram_2013_PosteriorConsistencyMisspecifiedALD.pdf`. Sriram, Ramamoorthi & Ghosh (2013, Bayesian Anal.), *Posterior consistency of Bayesian quantile regression based on the misspecified ALD*. The only consistency result under a misspecified ALD (parametric). Its §6 identifies σ₀ as the KL projection for a learned σ. Used in §2 and §3 (σ stage).
- `Large Prior.pdf`. Bedoya & Li, *Large series priors for adaptive and optimal Bayesian nonparametric regression*. The house template: the style of Assumptions 1–3 and of Theorem 1, Corollary 1. Our prior is a large series prior with a Laplace coefficient prior that fails its WG3–WG5 conditions. Used in §1 and §6.

## Laplace-prior behaviour: the main risk and the positive results

- `Castillo_2015_BayesianLinearRegressionSparsePriors.pdf`. Castillo, Schmidt-Hieber & van der Vaart (2015, Ann. Statist.), *Bayesian linear regression with sparse priors*. Theorem 7 shows that the Bayesian-lasso (Laplace) posterior is suboptimal although its mode is optimal. This is the template for our spread floor λ^{−1/3} and the main risk to any fast-rate claim. Used in §0, §4, §5 and §7.
- `Agapiou_2021_pExponentialPriorsContraction.pdf`. Agapiou, Dashti & Helin (2021, Bernoulli), *Rates of contraction of posterior distributions based on p-exponential priors*. Contraction for p-exponential (p = 1: Laplace) priors, with the two-level Talagrand-type concentration we need for the sieve (Lemma L7). Used in §4 and §6.
- `Agapiou_2024_LaplacePriorsSpatialInhomogeneity.pdf`. Agapiou & Wang (Bernoulli), *Laplace priors and spatial inhomogeneity in Bayesian inverse problems*. Minimax rates for rescaled Besov B¹₁-type (Laplace) priors over spatially inhomogeneous classes, which are close to the total-variation scale. It is positive evidence that Laplace-type priors can do well when scaled correctly. Used in §4 and §6.
- `Giordano_2023_BesovLaplacePriors.pdf`. Giordano (2023, EJS), *Besov–Laplace priors in density estimation*. Optimal and adaptive rates for Besov–Laplace priors, including a hierarchical version (relevant to the Gamma hyperprior on λ). Used in §4 and §5 (Stage B preview).

## Basis, small-ball and trend filtering

- `TF_2014.pdf`. Tibshirani (2014, Ann. Statist.), *Adaptive piecewise polynomial estimation via trend filtering*. The falling-factorial lasso form (Lemma 2), the penalty scaling n^{15/7}, the minimax rate n^{−6/7} for k = 2, and the comparison with locally adaptive regression splines. Used in §1 and §5.
- `Wang_2014_FallingFactorialBasis.pdf`. Wang, Smola & Tibshirani (2014, ICML), *The falling factorial basis and its statistical applications*. The basis characterization (θ = Hα, with H the inverse of D up to scaling) and the closeness to truncated power splines. Used in §1 (L1). Padilla's Lemma 19 cites it for ‖P_R δ‖∞.
- `Fill_2004_SmallDeviationsIntegratedBrownianSheets.pdf`. Fill & Torcaso (arXiv 2003, published 2004), *Mellin-transform asymptotics for small deviations in L² of integrated Brownian sheets*. Exact L² small deviations of m-times integrated Brownian motion (the d = 1 case; it cites Chen & Li and Sytaja). For m = 2 it gives the exponent ε^{−2/5} used in Lemma L3. Used in §4.

## Quantile trend filtering and competitors

- `Padilla_Risk Bounds for Quantile Trend Filtering.pdf`. Madrid Padilla & Chatterjee (2022, Biometrika), *Risk bounds for quantile trend filtering*. Assumption A, the Huber loss Δ²ₙ, Lemma 13 (margin), Theorem 7 and Proposition 2 (localized widths), and the slow and fast rates. This is the frequentist benchmark and the source of the uniform excess-loss event (L2, L8). Used in §2, §3, §5 and §6.
- `Brantley_2020.pdf`. Brantley, Guinness & Chi (2020, AOAS), *Baseline drift estimation for air quality data using quantile trend filtering*. The frequentist method (ADMM, non-crossing constraints, eBIC). It contains no theory. It supplies the MAP connection and the joint constraint set C for Stage B3.
- `Onizuka_2023.pdf`. Onizuka, Hashimoto & Sugasawa (2023/24), *Fast and locally adaptive Bayesian quantile smoothing using calibrated variational approximations*. The same model class (ALD likelihood with Laplace or horseshoe priors on differences), with no contraction theory. It is the closest prior art (T-01) and the source of the calibration caveat in §3.
- `Kowal_Dynamic_Shrinkage.pdf`. Kowal, Matteson & Ruppert (2019, JRSS-B), *Dynamic shrinkage processes*. Shrinkage-prior trend filtering under a Gaussian likelihood. Its theorems are prior shrinkage profiles, not contraction. Background only.
- `Pereyra 2016.pdf`. **This file is actually** Durmus, Moulines & Pereyra (2016/18), *Efficient Bayesian computation by proximal MCMC: when Langevin meets Moreau*. Moreau–Yosida and MYULA theory. It concerns computation only and plays no role in the contraction memo.
