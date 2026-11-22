# E-02 Contraction-rate simulations: report

*Engineering, 2026-11-22. Spec: HQ default grid plus Theory T-03 (statement v2). Sampler: exact banded Gibbs, certified fit by E-04 (`../E04_Sampler_Check/REPORT.md`). Compute: NOTS Slurm, about 104 core-hours so far (ceiling 200). Raw outputs: `/projects/ml75/fb31/BQTF/runs/E02-rates-20261122` (they go to the PC via E-01 when sealed). Tables are in `tables/` and figures in `figs/`.*

## Setup
- **Posterior.** ALD working likelihood at fixed σ = σ₀ = E ρ_τ(ε − q_τ) (the KL projection), with a Laplace prior on D⁽³⁾θ, flat on quadratics. λ is fixed (frozen arms) or ~Gamma(1, b₀) (learned arms).
- **Penalty and curvature.** MAP penalty λσ on the raw ‖D⁽³⁾θ‖₁. κ = f_ε(q_τ)/σ₀ is 16 for N(0, 0.25²) and 4 for N(0, 0.5²).
- **Truths.** quad (V = 0), sin (V ≈ 157), and two C¹ piecewise quadratics with knots at 0.3/0.55/0.8: PQT (V = 26) and pq.
- **Grids.**
  - Raw: λ = n^a.
  - Calibrated: λσ₀ = 2000·(n/500)^a, the MAP oracle at n = 500.
- **Sizes.** n = 250…32k, 10–20 seeds per cell, each seed paired across a and n.
- **Measures.**
  - Δ²ₙ(δ) = n⁻¹Σ min(|δᵢ|, δᵢ²) against the true τ-quantile.
  - Centre: ‖θ̄ − θ*‖²ₙ.
  - Rough spread: posterior variance after removing a least-squares quadratic from each centred draw.
  - Risk: the posterior mean of Δ².
  - The MAP error.
  - λ‖Dθ‖₁/m.
  - ESS of Δ² (≥ 110 per 5000 in every cell); R-hat ≤ 1.003 (E-04 C).
- **Slopes.** Log–log slopes in n with paired bootstrap 95% CIs over seeds.

## 1. P1: spread law, rough spread ≈ 0.3·κ^(−5/6)·λ^(−1/3), flat in n (`figs/fig_P1.png`)
All cells in the many-mode regime (n·λ^(−1/3) ≥ 10):

| Sweep | Truths | κ | n | Slope in λ | C = rough·κ^(5/6)·λ^(1/3) |
|---|---|---|---|---|---|
| T3lam (λ = 10³…10⁹) | sin, PQT | 16 | 1k / 4k | −0.371…−0.372 / −0.353 | 0.353 / 0.361 |
| Qlam (quad, V = 0) | quad | 4, 16 | 1k / 4k | −0.372…−0.385 / −0.353…−0.359 | 0.342–0.361 |
| lamcurve (calibrated ±2 decades) | quad, sin, pq | 4 | 2k / 8k | −0.372 / −0.365 | 0.347–0.352 |

- **Flat in n.** rough(n = 4k)/rough(n = 1k) is 1.01–1.04 up to λ = 10^4.5.
- **Collapse.** Below n·λ^(−1/3) ≈ 3 the rough spread collapses, exactly at Theory's boundary.
- **Along λ = c·n^a** (calibrated pq, n ≥ 2k), the rough-spread slopes are within 0.016 of −a/3 for every a between 9/4 and 8/3 (table §2).
- **Raw grid** (λ = n^a): the slopes fall short of −a/3 at a ≥ 15/7. Those cells have n·λ^(−1/3) < 10 (saturation), so they are not used for rate claims.

## 2. Bias law on the kinked truth: VP (bias² ∝ λ^(5/3)n^(−5)), ℓ₁ excluded (`figs/fig_kink.png`)
**Mechanism.**
1. **Gaussian twin.** tⱼ is frozen at 2/λ², on paired data with raw λ = n^a, n = 1k/4k/16k. On PQT, the Laplace÷twin ratios are 0.98–1.00 for bias², 1.00–1.05 for rough spread and 0.99–1.00 for risk/MSE, at every a ∈ {2, 9/4, 5/2, 8/3}.
2. **Bias equivalence.** On noiseless PQ, the Rao-Blackwellised posterior-mean bias² ÷ the spline bias² (S = κ(κI + λ²/2·D′D)⁻¹) is **0.996–1.013 in all 16 cells**.

**Slopes** (calibrated pq, κ = 4, n = 2k…32k, 20 seeds; every cell has n·λ^(−1/3) ≥ 19 and w/n ≤ 0.04):

| a | Bias² (= spline) | VP 5a/3 − 5 | ℓ₁ a − 3 | Rough spread | −a/3 | Risk | MAP Δ² |
|---|---|---|---|---|---|---|---|
| 9/4 | **−1.247** | −1.250 | −0.750 | −0.734 [−0.742, −0.726] | −0.750 | −0.728 | −0.921 |
| 2.4 | **−1.007** | −1.000 | −0.600 | −0.785 | −0.800 | −0.778 | −0.928 |
| 5/2 | **−0.851** | −0.833 | −0.500 | −0.819 [−0.829, −0.810] | −0.833 | −0.811 | −0.925 |
| 2.6 | **−0.704** | −0.667 | −0.400 | −0.854 | −0.867 | −0.844 | −0.879 |
| 8/3 | **−0.602** | −0.556 | −0.333 | −0.876 [−0.886, −0.867] | −0.889 | −0.867 | −0.821 |

- **Variance dominates the risk.** At n = 32k, bias² (2×10⁻⁸ at a = 5/2) is 4 orders of magnitude below the posterior-mean error. So the risk slope tracks −a/3, and **the risk-minimising a cannot be identified at n ≤ 32k**: a = 3 wins at every n ≥ 1000. The VP optimum at 5/2 follows from the bias slope plus P1, not from risk minimisation.
- **MAP vs posterior.** The MAP beats the posterior (P4): at 15/7, the slopes are −0.90 vs −0.69, against predictions of −0.857 vs −0.714.

**Smooth truth (sin), bias-dominated corner.** On the raw grid at a ≥ 5/2 (λ‖Dθ‖₁/m 1.25–1.56, w/n ≥ 0.13), the Laplace posterior has 15–52% less bias² than its twin, at the cost of 1.15–2.5× its rough spread. This is ℓ₁ adaptivity, consistent with the upper bound. λ‖Dθ‖₁/m > 1 is a bias-dominance diagnostic; the cap test shows it is not numerical.

## 3. Learned λ (σ = σ₀) and the free check
**Fixed b₀: λ̄ ∝ n^(3/4).**
- Slope 0.745 at b₀ = 1 and 0.75 at b₀ = 10⁻³, for both sin and PQ.
- λ̄ ≈ 60 and ≈ 10⁴ at n = 500, as predicted by λ ≈ (0.27·n·κ^(1/6)/b₀)^(3/4).
- λ̄ is well inside its cap (a₀ + m)/b₀: 5–10% at b₀ = 1, and about 0.4% at the paper's b₀ = 10⁻³ (VS data, λ̄ ≈ 2.1×10³).
- σ̄/σ₀ = 0.97–1.01.

**b₀ = n⁻², quad (κ = 4).**
- λ̄ = 0.82–0.97 × 0.45·n^(9/4), slope 2.257 [2.233, 2.278].
- Identical from either start (λ₀ = m or 0.3·n^(9/4)); ESS(log λ) 540–1300.

**b₀ ∈ {n⁻², n^(−5/2)}, sin and PQ** (long chains, 114/120 seeds drift-clean):
- sin slope 2.52 / 2.53; PQ 2.32 / 2.14.
- PQ/sin ratio at n^(−5/2): 9.96 → 4.69 → 3.29.
- This is **not a bias-law test**: the λ conditional responds to the ℓ₁ norm of the draws, and PQ self-tunes to (n³/V)^(3/4) (Theory).

**Effect of b₀ ∝ n⁻² on the posterior.** Concentration improves about 8× (Δ² 0.008 → 0.001 at n = 500, sin).

**Mixing.**
- ESS(log λ) falls to about 25 per 10k at n = 2k and about 8 at n = 8k (sin).
- Repeating the conjugate + interweaving λ moves (1, 5 or 20 per sweep) does **not** help (ESS ≈ 25 in every case): the λ–θ coupling dominates.
- The remedy is longer runs, about 8× at n = 2k and 25× at n = 8k: minutes to about an hour per chain on one core. The 10–25× chains for the deciding cells are running. θ summaries are unaffected (ESS(Δ²) 1100–1900).

## 4. P-MALA vs Gibbs (learned λ and σ; paper's sampler, unmodified; sin, N(0, 0.5²), 30k sweeps, 5 reps)

| b₀ | n | Per-sweep speed-up (Gibbs) | ESS/s gain: Δ² / log λ / θᵢ | P-MALA ÷ Gibbs: λ̄ / Δ² |
|---|---|---|---|---|
| 1 | 500 / 2k / 8k | 5.1 / 7.4 / 11.3 | 157 / 135 / 283 · 444 / 237 / 1050 · 1006 / 401 / 3131 | 0.98–1.00 / 1.00–1.01 |
| n⁻² | 500 / 2k / 8k | 6.8 / 9.7 / 12.5 | not comparable (P-MALA not converged) | **0.51 / 0.004 / 0.00003** · **1.27 / 6.3 / 23** |

- **At the paper's b₀ = 1 the samplers agree; the paper's numbers stand.** Gibbs is a large optional efficiency gain.
- **At b₀ = n⁻², P-MALA in the paper's run length does not converge for n ≳ 2k.** λ stays near its start, because of the capped preconditioner and local moves (E-04 §4). A b₀ ∝ n⁻² recommendation needs the Gibbs sampler, or a P-MALA fix (raise the cap, start near the posterior λ, run far longer).

## Caveats
- **Clamps.** All runs used the production latent clamps; their effect is ≤ 2% (E-04 B2). New runs default to clamp-free draws.
- **Seeds.** The same seed is used across n, so all slope CIs use a paired bootstrap.
- **Not run (budget).** p1x and p2 (t₂, τ = 0.9, extra orders on the default grid) were cut for budget; only partial outputs exist. The Cauchy arm is in T3, but not yet summarised here.
