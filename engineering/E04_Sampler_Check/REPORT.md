# E-04 Sampler fitness check

*Engineering, 2026-11-22. Scope: is each sampler that E-02 relies on sound for **our** study? Structural soundness only. Evidence is in `/projects/ml75/fb31/BQTF/runs/E02-rates-20261122/{e04,logs}`, the scripts are `e04_*.R` here, and the changes are listed in `CHANGES.md`. The independent review is `REVIEW_ASTRA.md`.*

## Verdicts
| Sampler | Used for | Verdict |
|---|---|---|
| **Banded Gibbs** (`E02_Rate_Sims/e02_lib.R::run_gibbs_frozen` + `banded_ls.cpp`), fixed and learned λ/σ | every E-02 arm | **Fit for E-02**, with change X: clamp-free exact latents are the default for runs launched from now on. All E-02 runs so far used the production clamps, which move E-02 quantities ≤ 2% (B2), so they stand. |
| **Paper's Bayesian-PMALA** (`method/individual/…`, unmodified) | paper results; E-04 reference | **Fit, and the paper's reported results stand.** Not used for E-02's rate grids because of mixing (below). |
| **Exact P-MALA kernel at fixed λ, σ** (`run_frozen`, the paper's C++ kernel) | validation reference only | **Fit as a reference** (exact, but slow). |

## 1. Right target
At fixed (λ, σ), Gibbs targets π(θ) ∝ exp{−Σρ_τ(yᵢ−θᵢ)/σ − λ‖D⁽³⁾θ‖₁}: flat on quadratics, with the MAP penalty λσ on the raw ‖D⁽³⁾θ‖₁. λ and σ are not updated unless their flags are set, and nothing rescales them. Astra confirms each piece algebraically:
- both mixtures integrate to the ALD and to the Laplace;
- the perturb-and-solve draw has mean Q⁻¹Wr and covariance Q⁻¹;
- the difference stencil is exact;
- λ | θ ~ Gamma(a₀+m, b₀+‖Dθ‖₁);
- the interweaving Jacobian is right;
- σ ~ IG(a_σ + 3n/2, …).

Astra's only exactness caveat is the latent clamps. Their effect was measured at ≤ 2% (§2, row B2), and clamp-free exact draws are the default for new runs.

## 2. Gibbs against independent references (agreement table)
| Check | Setting | Result |
|---|---|---|
| **A2: exact posterior** (4-d grid, converged to 0.002 sd) | n = 4, λ = 5, σ = 0.3, τ ∈ {0.5, **0.9**}; 400k draws, batch-means MC errors | Gibbs means within \|z\| ≤ 2.2 of exact, and P-MALA within ≤ 2.5 (8 coordinates each). Posterior sd matches to ±1%. |
| **A3: exact posterior at high penalty** (rotated-coordinate quadrature, t gridded at the 1/λ scale; converged to ≤ 0.0012 sd) | n = 4, λ ∈ {10³, 10⁶}, τ ∈ {0.5, 0.9}; 400k draws, batch-means MC errors | Gibbs \|z\| ≤ 2.13, sd ±1%. Production and clamp-free Gibbs are identical (no clamp binds). P-MALA's means are fine (\|z\| ≤ 2.4), but at λ = 10⁶ its sd is 6–10% low: it under-explores outside its tuning (cf. §4). |
| **Long chains, fixed λ** | n = 250/500, Λ ∈ {20, 450, 2000}, τ ∈ {0.5, 0.9}, Gaussian and t₂; P-MALA 400k sweeps | Δ² agrees to z = −0.61…0.23. Band width (ciw95) agrees within 0.6%. Pointwise means differ by at most 0.009 (< 0.1 posterior sd). |
| **B: paper settings** | the paper's VS generator, n = 500, τ = 0.5, learned λ and σ, b₀ ∈ {1, 10⁻³}, 4 chains per sampler | λ̄ 55.7 / 55.8 and 2069 / 2056; Δ² 0.02977 / 0.02974 and 0.00977 / 0.00973; coverage 0.972 / 0.970 and 0.970 / 0.968; pointwise mean differences ≤ 0.09 posterior sd; band \|z\| ≈ 1 (as expected with 4-chain SEs). |
| **B2: clamps** (production vs clamp-free, paired) | Cauchy arm, λ = 10⁹, τ = 0.9, control | Clamp hits: z ≈ 10⁻⁷, 1/s ≈ 1.6×10⁻⁴. Δ², centre and λ‖Dθ‖₁/m change ≤ 2% (29 of 30 comparisons have \|z\| < 2); rough spread −1…−1.8%. |
| **C: convergence of the plotted functional** | 4 dispersed starts (MAP, y, LS quadratic, jitter) at n = 500/4k/16k, a = 15/7 and 3 | R-hat(Δ²) ≤ 1.003. ESS of Δ² is 630–1400 per 5000 draws, per chain. |

## 3. Right outputs
- **Target of Δ²ₙ:** computed against the true τ-quantile θ* = f(uᵢ) + F_ε⁻¹(τ).
- **ESS:** the headline ESS (Δ², on the unthinned trace) was correct. A secondary midpoint ESS was mis-scaled ×thin (Astra 6, which I had also found) and is fixed.
- **Burn-in and thinning:** adequate, per C. Every E-02 cell reports ESS(Δ²); none fell below ~110 per 5000.
- **Seeds:** independent across replicates. The same seed is used across n and a by design (paired), so the slope bootstrap now resamples replicates jointly across n (CHANGES.md).
- **λ mixing in learned-λ arms** with b₀ ∝ n⁻²: ESS(log λ) can fall to about 8 per 10k at n = 8k (smooth truth). It is not fixed by repeating λ moves (ESS ≈ 25 for 1, 5 or 20 repeats at n = 2k). The remedy is longer runs (about 8× at n = 2k, 25× at n = 8k), or a joint (λ, s) move (untested). θ summaries are unaffected, with ESS(Δ²) ≈ 1100–1900. Low-ESS cells are flagged in E-02.

## 4. P-MALA at large λ, and paper risk
P-MALA's poor mixing at large λ is a regime outside its tuning, not a defect. The MH kernel is exact for any proximal-map accuracy, and it passed every agreement check above. Two causes:
- **(i) Capped preconditioner.** The curvature preconditioner M = W + κλ²DᵀD/2 is capped at 10⁸, so for λ ≳ 8×10³ the proposal no longer matches the rough-direction scale, and δ adapts down.
- **(ii) Local moves.** Its Langevin moves are local, so global smooth-direction functionals such as Δ² mix slowly at any λ: ESS 18/3000 at n = 500, 2/3000 at n = 4k.
- **Direct evidence:** at λ = 10⁶ (A3) its posterior sd comes out 6–10% low after 400k sweeps, even at n = 4.

**The paper's reported results are not affected.** At the paper's settings the learned λ is about 56 (b₀ = 1) or about 2×10³ (b₀ = 10⁻³), below the cap. P-MALA and Gibbs agree within MC error on every reported quantity (row B). The low ESS lengthens the run time but doesn't move any reported number. Gibbs is about 300–450× more efficient in ESS/s for λ and Δ². That is an optional improvement for the paper, not a correction.

## 5. Gate status
E-02 results may now be used as evidence. All of them were produced with the clamped latents, whose effect is ≤ 2% (B2); new runs default to clamp-free latents. Low-λ-ESS learned-λ cells carry their flags.
