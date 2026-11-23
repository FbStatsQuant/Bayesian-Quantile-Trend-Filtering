# E-07 advisor memo: tuning-free individual sampler (Fable, 2026-11-23)

*Analysis only. Evidence: the brief's files plus three local checks (one core via `owls_run`, about 3 CPU-minutes in total). Scripts (temporary): `/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/48abe8ec-7d18-4e2d-acb5-26b0069945e7/scratchpad/` (`check1_sparsity.R`, `check1b.R`, `check2b.R`, `check3_default.R`, `bq.cpp`). **[guess]** = not verified.*

## Bottom line
1. **The λ problem is a sampler problem with a cheap exact fix (R1):** update λ with θ integrated out. Measured: 60–95× more ESS(log λ) per sweep than ASIS, and the E-05 start (θ = y, λ = m) reaches the posterior in under 10 sweeps, not 250–1000.
2. **With R1, one scale-free λ prior replaces the per-signal b₀ (R2).** VS stays as it is; λ on S rises about 10×.
3. **No smooth prior can move σ (R3).** Option P means σ ≈ σ₀; only Option F matches the theorems. F costs accuracy on VS, and the factor 1.1 is too small once σ̄ is estimated.

## R1. Collapsed λ step; θ drawn in the exact conditional metric (Q3; R2 depends on it)

**Default sweep** (same posterior: same Laplace prior and hyperpriors):
1. s | θ, λ: 1/sⱼ ~ InvGauss(λ/|Dθ|ⱼ, λ²), clamp-free (`draw_iw_exact`).
2. θ | z, s ~ N(P⁻¹Wr, P⁻¹), P = W + D′diag(1/s)D, by the banded QR of `banded_ls.cpp`.
3. σ | θ, then z | θ, σ (R3).
4. λ | θ ~ Gamma(a₀ + m, b₀ + ‖Dθ‖₁).
5. **Collapsed step (replaces ASIS).** Redraw s | θ, λ and set tⱼ = λ²sⱼ. Holding t fixed, slice-sample log λ from

   log p(λ | t, z, y) = (a₀ − 1) log λ − b₀λ + m log λ − ½ log det P_λ + ½ r′W P_λ⁻¹W r,  P_λ = W + λ²D′diag(1/t)D,

   then draw θ | λ, t, z as in step 2.

**Derivation.** Laplace(λ) is N(0, sⱼ) mixed over sⱼ ~ Exp(rate λ²/2). With sⱼ = tⱼ/λ², tⱼ ~ Exp(½) is free of λ. Given (t, λ, z), θ is Gaussian with precision P_λ and integrates out in closed form, which gives the display. As λ → ∞, m log λ − ½ log det P_λ tends to a constant, so b₀ > 0 sets the tail (cf. the propriety proposition). Step 5 is an exact Gibbs draw of (λ, θ) | t, z with nothing to tune: the block update of Knorr-Held & Rue (2002).

**Why ASIS fails.** It rescales the whole non-polynomial part of θ, signal included, so the likelihood allows only tiny moves in λ. Step 5 lets θ re-equilibrate.

**Is it P-MALA-like?** Given (z, s), the Langevin diffusion preconditioned by P is an Ornstein–Uhlenbeck process whose exact transition is accepted with probability 1. Step 2 is its infinite-step limit: no step size, cap or ADMM. **Whether that meets the non-negotiable is Felipe's call.** Fallback (hybrid): keep the paper's P-MALA move as Block 1 and put step 5 in place of ASIS. Same target; about 9× slower per sweep **[guess, from 371 s per 30k sweeps]**.

**Evidence (check 2;** sin truth, N(0, 0.5²), τ = ½, σ = σ₀, b₀ = n^(−5/2), start θ = y, λ = m; the same Gibbs sweep with ASIS or with step 5):

| n | λ move | ESS(log λ) per 1k kept | ESS per second | Sweeps to reach the bulk | Mean log λ (MC se) |
|---|---|---|---|---|---|
| 500 | ASIS | 10 | 13 | 245 | 11.907 (0.020) |
| 500 | step 5 | 639 | 319 | 6 | 11.935 (0.005) |
| 2000 | ASIS | 3 | 1.3 | 982 | 15.13 (0.08) |
| 2000 | step 5 | 283 | 40 | 8 | 15.17 (0.014) |

The two agree (|z| ≤ 1.4). ASIS at n = 2000 reproduces E-02's 25 per 10k.

- **Expected ESS/s against the Gibbs reference:** log λ 24–32× (table); θ at least equal per sweep **[guess; not measured]**.
- **Cost:** return log det from the banded QR (≈ 10 lines); about 9 banded solves per sweep; 1.5 ms per sweep at n = 500 in R.
- **Risk:** the stencil is hard-coded for k = 2; the P-MALA label.
- **Paper:** target unchanged, and E-04 row B already shows Gibbs = P-MALA at the paper's settings. The algorithm description changes: **HQ approval**.

## R2. λ ~ Gamma(2, s_y·n^(−(k+½))), s_y = 1.4826·MAD(D^(k+1)y)/√C(2k+2, k+1) (Q1)

For k = 2: b₀ = s_y·n^(−5/2), divisor √20. The same prior under Options P and F.

**Units.** θ, σ, ‖Dθ‖₁ and b_σ are in units of y. So λ is in 1/y, b₀ in y, and Λ = λσ is unit-free. The paper's b₀ = 10⁻³ is a different prior when y is rescaled. **Standardisation:** run on y/s_y with unit-free hyperparameters and map back (θ·s_y, σ·s_y, λ/s_y). s_y estimates the noise scale: D^(k+1) of independent noise has variance C(2k+2, k+1)·Var(ε), a smooth signal adds O(V/n³), and the MAD exists for Cauchy. I scale by s_y, not σ: V is in y units at every τ, while σ changes 4–20× with τ and between P and F.

**Constants.** The prior mean of λ is a₀n^(5/2)/(c·s_y): the oracle n^(5/2)/V at V = c·s_y/a₀. Errors are asymmetric. Guessing V too small costs (a₀ − 1)·log(ratio), against m = 497 in the likelihood shape. Guessing too large makes b₀ a cap, λ ≲ (0.27nκ^(1/6)/b₀)^(3/4) (E-02 §3). So err small: **c = 1**. n^(−5/2) is the slowest decay that keeps constant prior mass on the oracle window for every V (b₀λ_or = c·s_y/V). **a₀ = 2** matches the proof; 1 versus 2 moves the conditional shape from 498 to 499.

**Evidence (check 3;** paper data, Gaussian noise, n = 500, seed 1, R1 sampler, 2500 sweeps; **one seed, indicative**). F uses 1.1σ̄ with the true σ̄.

| Cell (signal, τ) | Arm | λ | σ | MSE | MCIW | Coverage |
|---|---|---|---|---|---|---|
| VS, 0.5 | P, paper b₀ = 10⁻³ | 1.96e3 | 0.137 | 0.0041 | 0.281 | 0.958 |
| | P, default | 2.27e3 | 0.137 | 0.0040 | 0.278 | 0.966 |
| | F, default | 4.02e3 | 0.345 | 0.0098 | 0.399 | 0.932 |
| VS, 0.95 | P, paper | 2.02e3 | 0.033 | 0.0378 | 0.247 | 0.776 |
| | P, default | 2.44e3 | 0.033 | 0.0376 | 0.234 | 0.746 |
| | F, default | 1.09e4 | 0.253 | 0.1019 | 0.618 | 0.762 |
| S, 0.5 | P, paper b₀ = 5×10⁻⁴ | 1.55e4 | 0.136 | 0.0018 | 0.205 | 0.960 |
| | P, default | 1.53e5 | 0.136 | 0.0018 | 0.150 | 0.954 |
| | F, default | 1.51e5 | 0.345 | 0.0019 | 0.225 | 1.000 |
| S, 0.95 | P, paper | 8.08e3 | 0.033 | 0.0299 | 0.211 | 0.810 |
| | P, default | 7.95e4 | 0.034 | 0.0153 | 0.167 | 0.840 |
| | F, default | 1.15e5 | 0.253 | 0.0148 | 0.377 | 0.954 |

- The paper's two b₀ values are two caps: binding on S (b₀λ ≈ 8; λ is 10× below its data-driven value), nearly idle on VS (b₀λ ≈ 2; λ moves 16–21%).
- **Not chosen:** compound Gamma (D1 is decided, and the cap is already idle). **Cost:** two lines. **Risk:** s_y on heavily tied data.
- **Paper: changes results** (mainly S): **HQ approval**. It needs R1: with the paper's P-MALA a small b₀ fails (E-05). **[guess]** That is why S needed its own b₀.

## R3. σ (Q2)

**Option P: σ ~ IG(0.1, 0.1·s_y).** Draw σ | θ ~ IG(a_σ + n, b_σ + Q(θ)), then z | θ, σ: a joint draw of (σ, z) | θ (the code conditions σ on z).

No smooth prior matters. The factor σ^(−n)e^(−nσ₀/σ) loses n(log R + 1/R − 1) nats between σ₀ and Rσ₀: 46 at R = 1.59, 141 at 2.36, 525 at 6.7 (n = 500; R from the statements' Table 4). Only a truncation σ ≥ σ_lo can offset that, and then σ sits within σ_lo/(n(1 − 1/R′)) ≈ 0.3–0.5% of σ_lo, which is Option F. Paper: no change (σ = 0.137 in both P arms).

**Option F: σ_F = c·τ(1 − τ)·max_u ŝ(u),** ŝ(u) = x(u)′[β̂(τ + h) − β̂(τ − h)]/(2h), x(u) = (1, u, u²). These are quantile regressions of the pilot residuals at τ ± h (Hendricks–Koenker, as in `summary.rq(se = "nid")`), with the Hall–Sheather h. Pilot: the posterior mean of a 500-sweep Option-P run.

- **Its bias is upward (derivation).** The quotient averages the sparsity s(t) = 1/f(F⁻¹(t)) over [τ − h, τ + h]. For log-concave noise f(F⁻¹(t)) is concave in t, because its derivative (log f)′(F⁻¹(t)) decreases. So s is convex and the average is ≥ s(τ). Check 1: population ratio 1.000–1.46 in all 18 cells.
- **Sampling noise dominates.** P(σ_F ≥ σ̄) in check 1 (true quantile removed, the best case; 200 datasets per cell, n = 500):

| c | Gaussian | Mixed normal | Beta, τ ≤ 0.5 | Beta, τ ≥ 0.75 |
|---|---|---|---|---|
| 1.1 | 0.53–0.70 | 0.87–0.99 | 0.10–0.30 | 0.67–0.83 |
| 2 | 0.98–1.00 | 0.99–1.00 | 0.68 (τ = 0.05), 0.91, 0.99 | 0.98–1.00 |

- Beta is hard because f_min sits at the boundary point u = 1 and the sparsity rises 10× across u. A u-free Siddiqui estimate reaches only 0.2–0.3 of σ̄ there.
- **Recommendation:** c = 1.1 with the true σ̄ in simulations; **c = 2 in real use**.
- **Cost of F (check 3):** on VS, MSE is 2.4–2.7× worse and Λ = λσ is 4–35× larger, because λ does not fall when σ rises. On S, MSE is equal. Bands are 1.4–2.6× wider; coverage rises on S (0.84 → 0.95 at τ = 0.95) but not on VS.
- **Paper:** a new arm that changes results: **HQ approval**.

## R4. Tuning-free operation (Q4)
- After R1 there is no step size, warm sweep, cap or ADMM budget. Start: θ = y, σ = mean ρ_τ(y − median).
- Four chains from λ₀ = m × {10⁻², 1, 10², 10⁴}, in blocks of 1000 sweeps, first half discarded.
- Stop when rank-normalised split-R̂ ≤ 1.01 and bulk ESS ≥ 400 (Vehtari et al. 2021) for log λ, σ, ‖Dθ‖₁, Q(θ) and θ at 9 equispaced points. Cap at 50k sweeps, with a warning.
- Expected: 2–4k sweeps per chain at n = 500 **[guess from checks 2–3]**. Paper: run lengths only.

## R5. Only if an MH-corrected Langevin move must be the sole θ update (not recommended)
- Uncapped twin metric W + (λ²/2)D′D by QR; an exact draw of the 3 polynomial coefficients, c | θ⊥, z ~ N((N′WN)⁻¹N′W(r − θ⊥), (N′WN)⁻¹); start at the pilot mean.
- Expected: ESS/s stays 150–1000× below Gibbs (E-02 §4). A Langevin step in m ≈ 500 non-Gaussian directions needs δ ≈ m^(−1/3) ≈ 0.13 (the paper adapts to 0.1–0.2), so about 4/δ ≈ 30 sweeps per independent draw, at 300 solves each. **[guess]** λ still collapses without step 5.

## Pilot experiments (37 of 40 core-hours; n = 500 unless stated)
1. **R1 exactness and speed (8 h).** VS, S × Gaussian × τ ∈ {0.05, 0.5, 0.95} × 5 seeds at the paper's priors: paper P-MALA (30k), hybrid (30k), R1 (10k). Pass: MSE, MCIW, coverage and the posterior means of λ and σ within MC error. Add E-05's cells (n = 2k, 8k; start θ = y): R1 must match the Gibbs λ̄.
2. **R2 on all 36 cells (9 h).** 20 seeds, 6k sweeps; arms: paper b₀, default, c ∈ {0.1, 10}, a₀ = 1. Adopt by the methods note's rule (no cell worse beyond seed noise). Add an invariance test, y × {10⁻³, 10³}.
3. **R3 on all 36 cells (9 h).** P default, F at 1.1σ̄ (true), F plug-in at c = 2; 20 seeds; MSE, MCIW, coverage. Also P(σ_F ≥ σ̄) with the real pilot, 500 datasets per cell.
4. **R4 stopping rule (3 h).** 36 cells × 3 seeds against a 50k-sweep reference; pass if every estimate is within 0.1 posterior sd.
5. **R5 (8 h), only if Felipe rejects both R1 and the hybrid.**

**Not verified here:** any P-MALA run, the real pilot for σ_F, k ≠ 2, heavy tails, and more than one seed for check 3.
