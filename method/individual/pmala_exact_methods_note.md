# Exact augmented P-MALA for Bayesian quantile trend filtering — algorithm changes, their justification, and the multi-seed evidence

Date: 2026-09-25. Scripts: `Individual_Sampler_PMALA_Augmented.R`, `prox_admm_metric.cpp`, `variants_cells.R` (Simulations/Individual; variants_cells.R is no longer in the project).
Rule governing every choice below: one default per sampler, fixed before seeing any dataset, identical across S and VS, all noise types
and all quantile levels; a change is evaluated on all 30 cells before adoption, never on the cell that motivated it.

## 1. The sampler (one Gibbs sweep)

Model: y_i = theta_i + e_i, e_i ~ ALD(0, sigma, tau); p(theta | lambda) ∝ lambda^m exp(-lambda ||D theta||_1), D = (k+1)-th differences,
m = n - k - 1; lambda ~ Gamma(a0 = 1, b0 = 1e-3); sigma ~ IG(0.1, 0.1). Normal–exponential augmentation (Kozumi–Kobayashi):
z_i | sigma ~ Exp(mean sigma), y_i | theta_i, z_i ~ N(theta_i + psi z_i, t2 sigma z_i) — exact, no new hyperparameters.

1. theta | z, lambda, sigma — P-MALA in the curvature metric. Conditional negative log-density U_z(theta) = sum_i a_i (theta_i - r_i)^2 / 2
   + lambda ||D theta||_1 with a_i = 1 / (t2 sigma z_i), r_i = y_i - psi z_i. Proposal theta* ~ N(T(theta), delta P^{-1}),
   T = prox of the WHOLE conditional in the P-norm (banded ADMM, 150 iterations, cold start — a deterministic map),
   P = diag(a) + kappa (lambda^2 / 2) D'D with kappa = 3, gamma = delta / 2. Exact Metropolis–Hastings against U_z.
2. z_i | theta, sigma — GIG(1/2, ·, ·), i.e. inverse-Gaussian on 1/z_i; clipped to [1e-8, 1e4] (numerical safeguard).
3. lambda | theta — Gamma(a0 + m, b0 + ||D theta||_1) (sufficient parameterisation),
   THEN the ASIS step (new, adopted): holding u~ = lambda D theta and the polynomial part of theta fixed, redraw lambda from
   p(lambda) exp{-sum_i a_i (theta_i(lambda) - r_i)^2 / 2}, theta(lambda') = theta_par + (lambda / lambda')(theta - theta_par),
   by slice sampling on log lambda; theta is rescaled accordingly.
4. sigma | theta — IG(0.1 + n, 0.1 + sum rho_tau(y - theta)) (collapsed over z; z is redrawn immediately after).

Start: theta0 = y, sigma0 = z0 = 1, lambda0 = m; 200 warm sweeps use the deterministic conditional-MAP step in place of the MH move.
delta: Robbins–Monro on log delta towards acceptance 0.5, diminishing gain, for the whole run. 30 000 sweeps, 10 000 burn-in.

## 2. Changes evaluated this round (30 cells, seed 1, 30k/10k) — `variant_adoption_summary.csv`

| variant | MSE gm ratio vs default | cells > 1.25x worse | lambda-ESS (median) | lambda-ESS / hour | theta-ESS | seconds |
|---|---|---|---|---|---|---|
| default (before) | 1.000 | 0 | 4.9 | 50 | 62 | 352 |
| early exit tol 1e-8 | 1.020 | 1 | 5.9 | 53 | 63 | 397 |
| **ASIS lambda (adopted)** | 0.963 | 0 | 9.8 | **87** | 69 | 404 |
| K = 3 theta moves | 0.975 | 0 | 11.7 | 33 | 173 | 1264 |
| K = 5 | 0.948 | 0 | 15.2 | 26 | 264 | 2089 |
| ASIS + K = 3 | 0.938 | 0 | 20.3 | 57 | 173 | 1275 |
| joint (lambda, theta) jump | 0.955 | 0 | 7.4 | 28 | 83 | 960 |
| jump + ASIS | 0.959 | 0 | 10.4 | 39 | 100 | 963 |

Seed-to-seed sd of log MSE within a cell is 0.4 (campaign, 100 seeds), so single-seed MSE ratios in 0.62–1.26 are ties; adoption
was decided on efficiency at equal wall time. Why each change was tried and what was found:

- Shared factorisation + fused move (kept as code, neutral): forward prox, noise and reverse prox now run on one banded Cholesky of the
  ADMM system and one of the metric (`pmala_move`). Bit-identical to the separate calls (unit test 5). Justification: the paper's
  "reuse of a banded factorisation" claim is now literally true for the MH kernel.
- Residual-based early exit (not adopted): a deterministic stopping rule on the iterate keeps T a fixed map (MH exactness untouched) and
  reaches ||T - T_ref|| = 3e-8 in 7 iterations on a test problem, but on the real chains it saved nothing at a 150-iteration budget
  (the residual computation costs more than the skipped iterations). Default tol = 0.
- ASIS for lambda (adopted): the conjugate draw moves lambda only a few percent per sweep because posterior draws carry
  ||D theta||_1 ≈ m / lambda (measured: S_D / (m / lambda) = 1.0–1.1 in every cell), so lambda's statistic is locked to lambda.
  Interweaving with the ancillary parameterisation moves lambda and theta together along that ridge (Yu & Meng 2011).
  Effect: lambda-ESS per hour 87 vs 50, half-chain |log(lambda_h1 / lambda_h2)| median 0.10 vs 0.26. Exactness: unit test 6
  (ASIS-interwoven chain vs grid integration at n = 4, E lambda 3.300 ± 0.010 vs 3.287).
- K theta-moves per sweep (not adopted as default): raises theta-ESS 3–4x but costs 3.6–6x; lower ESS per hour for both theta and lambda.
- Joint (lambda, theta) Metropolis jump (not adopted): lambda' = lambda exp(s xi), theta* proposed from the prox at lambda' — exact
  (unit test 7), acceptance tuned to 0.25, but the adapted log-step s settles at 0.075, i.e. the joint move cannot jump far either;
  lambda-ESS per hour 28–39.

## 3. Multi-seed comparison against the campaign (seeds 1–10, identical datasets, n = 500, k = 2) — `pmala_exact_vs_campaign_10seeds.csv`

300 chains, zero failures, acceptance 0.47–0.52, median 371 s per chain; theta-ESS median 67, log-lambda ESS median 9.2 per 20k kept.
Competitor values are the campaign's own per-task results for the same seeds (individual sampler, Onizuka horseshoe / Laplace, ADMM-eBIC).
Ratios are geometric means of the 10 paired per-seed MSE ratios; "significant" = paired t on log ratios beyond ±2.

| subset | vs individual (gm / median / sig. better / sig. worse) | vs Onizuka HS | vs ADMM |
|---|---|---|---|
| interior tau 0.25–0.75 (18 cells) | 0.92 / 1.07 / 5 / 9 | 0.85 / 0.87 / 9 / 5 | 0.86 / 1.06 / 9 / 9 |
| tails tau 0.05, 0.95 (12) | 0.68 / 1.24 / 2 / 7 | 0.96 / 0.99 / 4 / 1 | 1.10 / 1.31 / 2 / 6 |
| S baseline (15) | 1.19 / 1.25 / 3 / 8 | 0.75 / 0.74 / 13 / 0 | 1.96 / 1.96 / 0 / 14 |
| VS baseline (15) | 0.56 / 1.16 / 4 / 8 | 1.05 / 1.06 / 0 / 6 | 0.46 / 0.38 / 11 / 1 |

Row minima: ADMM 15 cells (all S), individual 9 (VS Normal/Mixed), Onizuka HS 6 (VS Beta, VS Normal 0.05); the exact sampler is never
the row minimum; its paired ratio to the individual sampler lies in [0.8, 1.25] in 14 of 30 cells, below 0.8 in 7 (VS Beta, S Mixed
interior, VS Normal 0.05) and above 1.25 in 9 (S Beta at all levels, S/VS tails); it beats the horseshoe in 14 of 15 S cells.
Coverage of 95% intervals: median 0.91 interior, 0.69 at the tails (individual sampler: 0.89 / 0.65; horseshoe: 0.94 / 0.72).

Reading: at interior levels the exact sampler is between the individual sampler and the horseshoe — 16–24% worse than the individual
sampler on VS Normal/Mixed, 36–51% worse on S Beta, 16–25% better on S Mixed and at parity on S Normal (0.94–0.98) — and it is the only sampler that does not fail
on VS Beta tau ≤ 0.25 (individual sampler 0.171 and 0.010 vs 0.0003 and 0.0009). Its systematic loss is the extreme quantiles on the
smooth signal (1.25–2.3x the individual sampler on S at tau = 0.95, 1.24–1.59x at tau = 0.05), where the exact posterior mean follows individual extreme
observations; that is the same tail weakness measured in the previous 3-seed run and is a property of the posterior under this prior,
not of the kernel.

## 4. Exactness record

`Rscript Individual_Sampler_PMALA_Augmented.R test` runs 9 checks: ALD augmentation identity; GIG conditional; prox = glmgen at P = I;
metric prox is the minimiser; P-MALA vs closed-form Gaussian (lambda = 0); P-MALA vs grid integration at n = 4 (fixed metric and
curvature metric); fused move bit-identical + early exit accuracy; ASIS-interwoven chain vs grid; joint jump move vs grid. All pass.
