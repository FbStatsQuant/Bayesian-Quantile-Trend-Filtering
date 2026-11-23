# E-07 Tuning-free individual sampler: proposal

*Engineering, 2026-11-23. Requested by Felipe via HQ. Individual sampler only; the joint sampler comes later.*
- **Budget:** ≤ 40 NOTS core-hours, phase-gated. Estimates use measured per-fit rates.
- **Advisors:** Fable 5.2 (Claude Work, effort high) and Astra 6.2 (Codex, high). Their memos are in `advisors/`. Every finding was re-derived or checked; the rulings are in §7.
- **The paper sampler is untouched.** All work is on a copy (`sampler/`). Items that would change the paper's reported results are marked **[HQ]**.

## 0. Goal and constraints
- **The user supplies** y, τ and optionally k (default k = 2). Everything else is a default prior or automatic.
- **Felipe's non-negotiables:** the Gibbs structure, a P-MALA-like θ update (a preconditioned MALA; the preconditioner may change), then λ | θ and σ | θ.
- **Two σ treatments are presented side by side** (§3):
  - **P:** σ learned under a prior.
  - **F:** σ fixed above σ̄ with λ learned. This is the setting the theory proves.

## 1. What the evidence already says
1. **The paper's P-MALA is correct at its own priors, but slow.**
   - It agrees with the exact Gibbs sampler at b₀ = 1 (E-02 §4, E-04).
   - Its ESS/s is 135–280× lower (Δ², log λ) at n = 500, and up to ≈ 6400× lower at 8k.
2. **It breaks for any n-shrinking b₀** (E-05).
   - Starting θ at y lets λ | θ = y overwrite λ₀ at sweep 1.
   - Local moves then cannot escape: λ̄ is 0.004× the true value at n = 2k, and Δ² is 7× worse.
   - Raising the cap or setting λ₀ does not help.
   - **ASIS is not enough either:** ESS(log λ) ≈ 2–25 per 10–20k sweeps.
3. **Learning λ under b₀ = n^{−5/2} reaches the theory's scale.** With exact Gibbs, λ̄ ∝ n^{2.54} (sin) and n^{2.14} (PQ) (E-02 §3, lamxl). A fixed b₀ gives n^{3/4}.
4. **The learned σ sits at σ₀ = E ρ_τ, below σ̄ = τ(1−τ)/f_min, for every log-concave law** (statements §A4).
5. **Spread law:** rough spread ≈ 0.3·κ^{−5/6}·λ^{−1/3}, with κ = f/σ (E-02 P1). A larger σ widens the bands even at fixed λ.

## 2. Ranked improvements
| # | Improvement | Rationale | Expected effect | Cost | Risk | Paper results? |
|---|---|---|---|---|---|---|
| **1** | **Collapsed (λ, θ) block** replaces ASIS: redraw the mixing scales, set tⱼ = λ²sⱼ, slice-sample log λ with θ integrated out, then draw θ exactly given (λ, t, z) (Knorr-Held & Rue 2002) | ASIS rescales signal and noise together, so λ barely moves (E-05). The collapsed step is an exact Gibbs block with nothing to tune | ESS(log λ) per sweep up 60–95×, per second 24–32×. Escapes the E-05 trap in < 10 sweeps instead of 250–1000 (Fable, local, 1 seed; to be confirmed in G0) | Low–medium: log det from the banded factorisation, slice sampler | Low; exactness test in G0 | Target unchanged; algorithm description changes **[HQ]** |
| **2** | **θ move in the exact conditional metric P = W + D′diag(1/s)D**, banded O(n). Presented as the P-MALA family member with the exact preconditioner and implicit-midpoint step h = 2, so acceptance is 1. A tunable member (r = (1 − h/2)/(1 + h/2) > 0) and a **hybrid** (the paper's P-MALA move plus item 1) are kept as options | Given (z, s), θ is Gaussian. The preconditioned-Langevin (OU) transition with h = 2 is an exact independent draw. No step size, cap or ADMM | Gibbs-level ESS/s for θ: 150–6000× the paper's P-MALA (E-02 §4) | Low (exists in `e02_lib.R`) | **Whether this counts as "P-MALA-like" is Felipe's call.** The hybrid is the fallback | Target unchanged **[HQ]** |
| **3** | **One scale-free λ prior:** λ ~ Gamma(2, s_y·n^{−5/2}), with s_y = 1.4826·MAD(D³y)/√20 (a robust noise scale). Run on y/s_y and map back | Oracle λ ≍ n^{5/2}/V. b₀ has units of y, so a fixed b₀ is a different prior when y is rescaled. n^{−5/2} keeps constant prior mass on the oracle window. a₀ = 2 as in the proof | Replaces the per-signal b₀. On S, the paper's b₀ caps λ about 10× below its data value. One seed: S MSE equal at τ = ½ and halved at 0.95; VS unchanged | Two lines | Ties or quantised y (MAD = 0, then fall back to IQR(y)/1.349); VS bump over-smoothing (checked on the grid) | **Yes, mainly S [HQ]** |
| **4** | **σ, Option P:** σ ~ IG(0.1, 0.1·s_y), joint (σ, z) \| θ draw. **Option F:** σ fixed. Oracle 1.1σ̄ in simulation; plug-in σ = 2·τ(1−τ)·maxᵤ ŝ(u) in real use (§3) | No smooth prior can move σ: 46–525 nats against it at n = 500. F is the theorem's setting | P ≈ the paper's σ (σ ≈ σ₀). F: wider bands, theory-covered; VS MSE 2.4–2.7× worse on 1 seed | Low | F's accuracy cost on bumps; plug-in variance at extreme τ | P: no change. F: new arm **[HQ]** |
| **5** | **Automatic operation:** 4 chains from dispersed λ₀ = m × {10⁻², 1, 10², 10⁴}, θ₀ = y; blocks of 1000 sweeps, first half discarded; stop when rank-normalised split-R̂ ≤ 1.01 and bulk ESS ≥ 400 for log λ, σ, ‖Dθ‖₁, Q(θ) and θ at 9 points; cap 50k sweeps with a warning | After items 1–2 nothing remains to tune. Dispersed starts catch the E-05-type trap | No user-set run length; ≈ 2–4k sweeps per chain at n = 500 | Low | Common-mode trapping (4 chains guard against it) | Run lengths only |
| 6 | MH-only fallback: an uncapped twin metric W + (λ²/2)D′D by QR, plus an exact null-space block, plus item 1 | Only if Felipe rejects items 2 and the hybrid | ESS/s stays 150–1000× below item 2 | Medium | — | — |

### 2.1 Units and scale invariance
- **Units:**
  - θ, σ, ‖Dθ‖₁ and b_σ carry the units of y. λ carries 1/y and b₀ carries y.
  - Only the penalty Λ = λσ and the log-posterior are unit-free.
  - So the paper's b₀ = 10⁻³ and b_σ = 0.1 change meaning when y is rescaled.
- **Default:**
  - Transform x = (y − median y)/s_y, fit with unit-free hyperparameters, then map back: θ = median + s_y·θₓ, σ = s_y·σₓ, λ = λₓ/s_y.
  - This is exactly equivariant under y ↦ a + by (b > 0).
- **Why the noise scale s_y rather than a spread of y** (Astra proposed IQR(y)/1.349; ruled in §7):
  - The prior mean λ = a₀n^{5/2}/(c·s_y) corresponds to the oracle at V = c·s_y/a₀.
  - Under-guessing V costs only (a₀ − 1)·log(ratio) against a likelihood shape of m ≈ 497.
  - Over-guessing V makes b₀ a cap (E-02 §3: λ ≲ (0.27nκ^{1/6}/b₀)^{3/4}).
  - So err toward a small b₀. The noise scale is the smaller and more stable of the two, and it exists for Cauchy.

## 3. The σ treatments, side by side
**Option P (σ prior).**
- σ ~ IG(0.1, 0.1·s_y). This is the paper's prior made scale-invariant, and the stand-in until HQ forwards the VP's recommendation (`writing/W01_Statements/reviews/VP_SIGMA_PRIOR.md`). The VP prior drops into the same slot.
- **Finding (verified):** at n = 500 the σ-likelihood loses n(log R + 1/R − 1) nats between σ₀ and Rσ₀: 46 at R = 1.59, 141 at 2.36, 525 at 6.7.
  - So no smooth prior moves σ off σ₀.
  - Only a hard floor σ ≥ σ_lo can, and the posterior then sits within ≈ 0.5% of σ_lo, which is Option F.
  - The P arm therefore reproduces the paper's σ. It is honestly outside the proved range: (A4) fails at σ₀ for all three paper families.

**Option F (σ fixed, λ learned; the D1 prior from item 3).**
- **F-oracle (simulation):** σ = 1.1σ̄, with σ̄ = τ(1−τ)/f_min from `writing/W01_Statements/simulation_laws.R`.
- **F-plugin (real use):** σ_F = c·τ(1−τ)·maxᵤ ŝ(u).
  - ŝ(u) is a Hendricks–Koenker sparsity: quantile regressions of the pilot residuals on (1, u, u²) at τ ± h_HS (Hall–Sheather bandwidth). The pilot is the posterior mean of a short Option-P run.
  - Bias is upward for log-concave noise (Jensen: the sparsity is convex in t). Measured population ratio 1.00–1.46.
  - Sampling noise dominates. With c = 1.1, P(σ_F ≥ σ̄) is only 0.10–0.99 across the cells (Beta at τ ≤ ½ is the worst, because f_min sits at u = 1). **With c = 2 it is ≥ 0.98 in almost all cells, 0.68 at Beta, τ = 0.05.**
  - **Default c = 2 in real use.** Following Astra, F abstains (and falls back to P with a warning) when a window holds fewer than 5 expected observations beyond τ ± h. That applies at τ = 0.99, where only about 5 exceedances exist in total.
- **What we report:** σ_F/σ̄ per cell; P(σ_F > σ̄); the abstention rate; and the share inside the P2 interval once Theory states it (Tuesday). The plug-in is a data-dependent σ, which the theorem does not cover unless P2 holds and σ_F lands in its interval.

**Final table for Felipe** (filled after G1):

| | Option P | Option F |
|---|---|---|
| Accuracy (MSE/MAD vs O) | | |
| 95% band coverage / width | | |
| ESS/s, runtime | | |
| Tuning-free? | yes (prior defaults) | yes (plug-in, with abstention) |
| Theory coverage | none at σ₀ (A4 fails); empirical support from the E-06 σ₀ arm | Theorem B (Gaussian/Laplace), A (pending L10); plug-in only via P2 |
| Recommendation | | |

## 4. Validation grid and cost
- **Truths:** f_VS and f_S. These are the only baselines in the paper and in its production code (`experiments/interior_quantiles/individual_nots_20261003/config.R`: `baselines = c("VS", "S")`).
- **Noise:** the paper's three families, generated by the paper's own `simulate_data`.
- **Levels:** τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95, 0.99}, with 0.99 reported separately. That makes 36 cells, at n = 500 and k = 2.
- **Arms, on the same seeds:**
  - **O:** the original sampler with the paper's priors and lengths (VS: Gamma(1, 1e-3), ASIS, 30k/10k; S: Gamma(1, 5e-4), no ASIS, 20k/5k; σ ~ IG(0.1, 0.1)).
  - **P**, **F-oracle** and **F-plugin**: the new sampler, items 1–5.
- **Measures:**
  - MSE and MAD of the posterior mean against Q_τ (paper definitions), plus the posterior-median MSE for the figures.
  - 95% band coverage and width (MCIW).
  - ESS/s (log λ, Δ², θ at 9 points); runtime and sweeps to the stopping rule.
  - The cells where a new arm loses to O: a paired seed-wise comparison, flagged when worse beyond 2 MC SE.
- **Measured rates (NOTS, n = 500):**
  - **O:** ≈ 139 s per 30k sweeps (E-02 pvg), so ≈ 140 s (VS) and ≈ 95 s (S) per fit.
  - **New sampler:** ≈ 1.5 ms per sweep with item 1 (Fable, local R), × 4 chains × ≈ 3k sweeps ≈ 20 s per fit, plus ≈ 2 s for the plug-in pilot. Re-measured in G0 before G1 is sized.

| Phase | Content | Core-h |
|---|---|---|
| **G0** exactness and speed | VS, S × Gaussian × τ ∈ {0.05, 0.5, 0.95} × 3 seeds: O vs hybrid vs new at the paper's priors (same target), all within MC error. E-05 cells (n = 2k, start θ = y): new λ̄ = Gibbs λ̄. n = 4 quadrature test of the collapsed step (Astra). Timing re-measured | ≈ 4 |
| **G1** full grid | 36 cells × 10 seeds × {O, P, F-oracle, F-plugin}. Prior sensitivity: c ∈ {0.1, 10}, a₀ = 1 on 6 cells × 10 seeds. Invariance: y × {10⁻³, 10³} on 2 cells | O ≈ 12 + new ≈ 8 + sensitivity ≈ 1 = **≈ 21** |
| **G2** plug-in study | 36 cells × 200 datasets: σ_F/σ̄, P(σ_F > σ̄), abstention. Pilot fits only, with no long MCMC | ≈ 3 |
| **G3** stopping rule | 36 cells × 3 seeds against a 50k-sweep reference; pass if every estimate is within 0.1 posterior sd | ≈ 3 |
| **G4** figures (§5) | Seed 1 of G1; no new MCMC | ≈ 0 |
| **Total** | | **≈ 31** (cap 40) |

- **Gates:**
  - **G0 → G1:** all three samplers agree at the paper's priors; new ESS/s ≥ 10× O; the E-05 trap is escaped.
  - **G1 → G4:** HQ's review of the losing cells.
- **Trim order:** G3 first, then G1 to 5 seeds. A larger n (2000) is added only if more than 4 core-h remain.

## 5. Final stage: figures for Felipe (only after G1 shows the new sampler is better)
- **One ggplot2 PNG per cell** (300 dpi, 36 cells, seed 1) in `figures/`. Each shows:
  - the data as light points and the true Q_τ;
  - the posterior median and shaded 95% band of **Option P** and of **Option F**;
  - the **original** sampler's fit;
  - each fit's MSE in the subtitle;
  - theme_minimal, the Okabe–Ito palette, and a title like "VS · Gaussian · τ = 0.95".
- **One faceted truth × noise overview per τ** (6 PNGs).
- **Size and reporting:** keep the total under ≈ 5 MB (otherwise ask HQ), and report the absolute paths.

## 6. Decisions needed from HQ / Felipe
1. **Is item 2 "P-MALA-like" enough?**
   - It is the preconditioned-Langevin family with the exact metric and h = 2, accepted with probability 1.
   - The alternatives: the hybrid, which keeps the paper's P-MALA move with item 1 in place of ASIS, or a tunable r > 0.
   - G0 runs all three, so the decision can wait for its numbers.
2. **Item 3 changes the paper's S results** (λ about 10× higher). Should the paper keep its runs and describe the new default as a recommendation, or re-run? Engineering suggests keeping the paper runs and adding the default as a method recommendation, pending the G1 evidence.
3. **The VP's σ-prior recommendation** for Option P, when ready.

## 7. Advisor findings and rulings (Felipe's rule: verify each one; disagreements flagged)
| # | Advisor | Finding | My check | Ruling |
|---|---|---|---|---|
| F-R1 | Fable | A collapsed (λ, θ) \| t, z block replaces ASIS; log p(λ \| t, z, y) = (a₀ − 1 + m) log λ − b₀λ − ½ log det P_λ + ½ r′WP_λ⁻¹Wr | Re-derived. t = λ²s ~ Exp(½) is free of λ. The Gaussian prior on Dθ given (λ, t) contributes λ^m. Integrating θ gives the log det and quadratic terms. A valid blocked Gibbs step on (θ, λ, t, z) | **Accept** (item 1). Speed claims are from one local seed; G0 confirms |
| F-R1b | Fable | The exact θ draw is the infinite-step limit of the P-preconditioned Langevin (OU) move | Agrees with Astra's implicit-midpoint form: r = (1 − h/2)/(1 + h/2) = 0 at h = 2, reversible with acceptance 1 | **Accept** as the framing; the decision goes to Felipe (§6.1) |
| F-R2 | Fable | λ ~ Gamma(2, s_y·n^{−5/2}), s_y = 1.4826·MAD(D³y)/√20 | Var(D³ε) = (1 + 9 + 9 + 1)·Var ε = 20·Var ε ✓. Units ✓. The asymmetric cost of mis-guessing V ✓ | **Accept** (item 3), with an IQR fallback when MAD = 0 |
| F-R3a | Fable | No smooth σ prior moves σ: n(log R + 1/R − 1) nats | Recomputed: 500·(log 1.59 + 1/1.59 − 1) = 46.3 ✓ | **Accept** |
| F-R3b | Fable | The plug-in bias is upward for log-concave noise | f∘F⁻¹ has derivative (log f)′∘F⁻¹, which is decreasing, so it is concave. 1/(concave > 0) is convex, and Jensen gives a window average ≥ the centre ✓ | **Accept**. c = 2 in real use (from its hit-rate table; G2 re-measures) |
| F-R3c | Fable | F costs 2.4–2.7× MSE on VS (λ does not fall as σ rises) | One seed only. Plausible, since Λ = λσ rises 4–35× | **Provisional**; G1 decides with 10 seeds |
| F-R4 | Fable | 4 chains with dispersed λ₀, θ₀ = y, split-R̂ ≤ 1.01 and bulk ESS ≥ 400, cap 50k | Consistent with Vehtari et al. (2021). θ₀ = y is safe once the collapsed step is in (its check: < 10 sweeps) | **Accept** (item 5); G3 tests it |
| F-R5 | Fable | MH-only fallback | — | **Accept as a contingency only** |
| A-1 | Astra | Gamma(2, n^{−5/2}) on standardised y, with s = IQR(y)/1.349 | Units ✓, a₀ = 2, c = 1 ✓. But IQR(y) includes the signal's range, so for VS it is several times the noise scale. That makes b₀ larger and nearer to a cap (§2.1) | **Accept** the form and the standardisation; **modify** the scale to Fable's noise-based s_y (the disagreement is recorded; G1's invariance and sensitivity arms cover it) |
| A-2a | Astra | P: a weak prior cannot bridge the gap; only a concentrated prior can | Agrees with F-R3a. The prior that "moves" σ in its sensitivity identity is data-dependent (it uses q), so it is not a valid prior | **Accept** the conclusion |
| A-2b | Astra | Collapsed σ \| θ, then refresh z | Valid. The code's σ \| θ, z is also valid Gibbs | **Accept** (joint (σ, z) \| θ, as in item 4) |
| A-2c | Astra | F plug-in: windowed local-linear sparsity, maximum over u; abstain when there are fewer than 5 tail observations per window | The abstention is sound, especially at τ = 0.99. The windowed estimator has no measured hit rate yet | **Accept** the abstention; **test** its estimator against Fable's HK quadratic in G2 (cheap) |
| A-3 | Astra | An implicit-midpoint Langevin move with h = 1 (r = ⅓) on the augmented Gaussian conditional, acceptance 1 | Verified reversible: an AR(1) toward μ with innovation variance (1 − r²)G⁻¹ leaves N(μ, G⁻¹) invariant. But for a Gaussian conditional, r = 0 (h = 2) dominates r > 0 | **Accept** the family; **reject** r = ⅓ as the default (it is strictly slower); r is kept as an option for §6.1 |
| A-4 | Astra | 4 dispersed chains from MAP starts; stop on the slowest of log λ, log σ, roughness, polynomial coefficients and θ at 5 points | Consistent with F-R4. MAP starts are unnecessary given the collapsed step, but harmless | **Accept** (merged into item 5, θ₀ = y). Polynomial coefficients are added to the monitored set |
| A-P | Astra | Pilots: quadrature 2 h, kernels 12 h, plug-in 6 h, screen 20 h | Merged with Fable's pilots into G0–G3 (≈ 31 core-h) | **Accept**, merged |
