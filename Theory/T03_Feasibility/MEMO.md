# T-03 Week-1 feasibility memo: posterior contraction for BQTF

*Theory Department. Draft v1, 2026-11-22; due 2026-11-28.*

**Scope.** Feasibility calculations, heuristics and statements only. No proofs.

**Sources.** Numerical checks are in `scratch/`, with scripts and `.out` files listed in Appendix B. E-02 results from Engineering are pending; Appendix C lists what they will confirm or refute.

**Conventions.**
- D := D⁽³⁾, unscaled (rows −1, 3, −3, 1), with m = n − 3.
- TV⁽³⁾(θ) = n²‖Dθ‖₁, Padilla's convention with r = 3.
- ‖v‖²ₙ = n⁻¹Σvᵢ² and Δ²ₙ(v) = n⁻¹Σ min(|vᵢ|, vᵢ²).
- **Stage A** is σ fixed (ω := 1/σ) and λ = λₙ deterministic. The posterior is

  Πₙ(dθ | y) ∝ exp{−ω Σᵢ ρ_τ(yᵢ − θᵢ)} · exp{−λ‖Dθ‖₁} dθ.

- κ := ω·f(θ*), the local curvature per observation of the working log-likelihood.
- "≍" hides constants and polylog factors.

---

## 0. Bottom line

1. **Best rate for the model as is (Stage A): ε²ₙ ≍ V\*^{1/4} n^{−3/4}, attained at λₙ ≍ (n³/V\*)^{3/4} ≈ n^{9/4}.** For general λ the rate is

   ε²ₙ(λ) ≍ max{ κ^{−5/6} λ^{−1/3}, (λ/κ) V\* n^{−3} },

   which is consistent for 1 ≪ λ ≪ n³. The first term is the posterior **spread**. It does not depend on the truth and comes from the prior's small-ball geometry. The second term is the **shift/bias**, driven by the truth through V\* = TV⁽³⁾(θ\*).

2. **The full posterior is slower than the minimax rate n^{−6/7}.** It is also slower than the MAP (Padilla's PQTF). At Padilla's tuning λσ ≍ n^{15/7}, the posterior contracts at n^{−5/7}, not n^{−6/7}. This is the trend-filtering analogue of the Bayesian-lasso phenomenon (Castillo, Schmidt-Hieber and van der Vaart 2015). The Laplace prior leaves roughly n·λ^{−1/3} rough modes un-shrunk, so the spread floor λ^{−1/3} does not depend on how sparse the knots of θ\* are. **We should not promise the fast rate (s/n)·log for this prior.**

3. **What is provable, by route:**
   - A crude total-variation-ball sieve proves **n^{−2/3}** at λ ≍ n^{7/3}. This route is low-risk, and it confirms the VP's claim.
   - A two-level (Talagrand) sieve for the exponential (Laplace) measure should prove the full **n^{−3/4}**. This sieve is the natural Laplace analogue of the RKHS sieve used for Gaussian priors.

   Both routes replace Hellinger tests by a uniform excess-check-loss event (Padilla-type) plus a convexity argument for the far region. Stage A then needs **no moment conditions**, matching Padilla's Assumption A. It does need an **upper** density bound near θ\*.

4. **Gamma hyperprior on λ (Stage B preview), a theory–practice tension.** An exact virial identity together with the spread law predicts that a learned λ under Gamma(a₀, b₀) settles at

   λ ≈ (0.27·n·κ^{1/6}/b₀)^{3/4}.

   This matches the paper's own report of λ ≈ 50–75 under Gamma(1, 1) at n = 500 (the prediction is ≈ 53). With b₀ fixed this is λ ≍ n^{3/4}, which gives a posterior rate of only about n^{−1/4}. **Reaching the n^{−3/4} regime needs b₀ ≲ n^{−2}.** There is heuristic evidence that b₀ → 0 then makes λ self-tune to the oracle (n³/V\*)^{3/4}, which would be a genuine selling point.

5. **Advisor heuristics.** All five are confirmed. One is refined: the n ≪ λ lower window is not needed for the rate, and its source looks like an artefact of an ℓ∞ bound. A sixth item (σ₀ needs a moment condition) is also confirmed. Details are in Appendix A.

---

## 1. The prior as a basis system (Large Prior style)

**Falling-factorial representation** (Tibshirani 2014, Lemma 2, with k = 2; verified to machine precision in `scratch/ff_basis_check.py`). θ = Hα, with H ∈ ℝ^{n×n}:

- H_{ij} = (i/n)^{j−1} for j ≤ 3;
- H_{ij} = (i−j+1)(i−j+2)/n² for i ≥ j ≥ 4, and 0 otherwise.

Then D⁽³⁾H = [0 | (2/n²)I_{n−3}], so α_j = (n²/2)(D⁽³⁾θ)_{j−3} for j ≥ 4. **Our prior is exactly:**

- α_1, α_2, α_3 (the quadratic part): flat (improper);
- α_j, j = 4, …, n: iid Laplace with rate λ′ := 2λ/n².

This is a large series prior in the sense of Large Prior §2: a deterministic dictionary of size Jₙ = n (b = 1), with columns approximately (x − t_j)²₊ (truncated quadratics, the k = 2 falling factorials), and an iid product prior on the coefficients.

**Analogue of LP Assumption 1 (basis).** max_j ‖h_j‖_{2,n} ≤ K = 1. Exactly: the quadratic columns have norm ≤ 1; for j ≥ 4 the norm is ≈ ((1 − t_j)⁵/5)^{1/2} ≤ 0.447 (measured 0.404 at n = 50 and 0.442 at n = 400). It holds trivially. Note that cond(H) grows like n³ (1e5 at n = 50, 5e7 at n = 400). That matters for computation, not for the statements.

**Analogue of LP Assumption 2 (approximability of θ\*).** For our prior the natural condition is **ℓ₁-approximability**, not sparsity. The representation is exact, with no approximation error:

- ‖α\*_{4:n}‖₁ = (n²/2)‖Dθ\*‖₁ = V\*/2;
- ‖α\*_{1:3}‖∞ ≤ C(B) when ‖θ\*‖∞ ≤ B.

For a piecewise quadratic with s knots, α\* additionally has s + 3 nonzeros, with ‖α\*‖∞ = O(max jump in θ″). The Laplace prior can only use this through the ℓ₁ norm (see §4).

**Why LP's Theorem 1 does not apply.** LP Assumption 3 (WG3) needs P(|α_j| > δₙ) ≤ Jₙ^{−(1+μ)} with δₙ = ε̃ₙ/Jₙ. Under Laplace(2λ/n²) that probability is exp(−2λδₙ/n²). At λ ≍ n^{9/4} and ε̃ ≍ n^{−3/8}, the exponent is ≍ n^{−9/8} → 0, so the probability → 1. WG3 would need λ ≳ n³ log n/ε̃, and then the shift cost λ‖Dθ\*‖₁ exceeds the budget nε². **No single λ satisfies WG3–WG5.** This is the formal reason the Laplace prior cannot reach LP's sparse-regression rate. LP's proof template (prior mass, then evidence lower bound, then sieve, then tests) still structures our argument (§6).

**Comparison with Tibshirani (2014): what transfers.**
- Penalty scaling: TF's penalty (n^k/k!)·λ_TF·‖D^{k+1}β‖₁ with λ_TF ≍ n^{1/(2k+3)} corresponds, at k = 2, to n^{15/7} on ‖D⁽³⁾θ‖₁. That is our MAP penalty λσ (Padilla adds (log n)^{1/7}). This transfers.
- The minimax rate n^{−(2k+2)/(2k+3)} = n^{−6/7} over F_k(C), with linear smoothers suboptimal. This transfers as the benchmark.
- For k = 2, trend filtering ≠ locally adaptive regression splines (G ≠ H) but the two are asymptotically equivalent. This is irrelevant here: our prior is defined through H.
- What does **not** transfer is the step from MAP to posterior. TF's rate is a property of the mode. The full posterior adds the spread term, which is invisible in Tibshirani's analysis. "A very similar problem up to misspecification" is right for the MAP. For the posterior there is a second, prior-induced difference that is as important as misspecification.

---

## 2. Truth class and assumptions; where θ\* enters

**Data.** y₁, …, yₙ are independent on the grid xᵢ = i/n. θ\*ᵢ is a τ-quantile of yᵢ. All probability statements are under the true P₀ (§3).

**(A±) Two-sided local margin.** There are L, f, f̄ > 0 such that for all n, all i and all |δ| ≤ L:

f|δ| ≤ |Fᵢ(θ\*ᵢ + δ) − Fᵢ(θ\*ᵢ)| ≤ f̄|δ|.

The lower half is Padilla's Assumption A: it gives identification and the margin. **The upper half is new and needed.** It makes the excess-risk neighbourhoods {m ∨ v ≤ ε²} contain ‖·‖ₙ-balls: m ≤ (f̄/2)‖δ‖²ₙ near θ\*, and v ≤ ‖δ‖²ₙ always. Without it, the neighbourhoods are only guaranteed to contain ℓ₁-balls of radius ε², the prior-mass cost rises, and the rate degrades. The upper half is mild: any density bounded above near the quantile will do.

**(T) Truth class.** Θ(V\*, B) := {θ : TV⁽³⁾(θ) ≤ V\*, ‖θ‖∞ ≤ B}, with V\* allowed to grow slowly. The fast-rate class "piecewise quadratic, s knots, minimum spacing" is optional. Under this prior it gives the **same** rate with V\* ≍ s·(jump size), so ε² ≍ s^{1/4}n^{−3/4} (§5). That is a negative structural result we should state honestly.

**Where θ\* enters the argument.** Felipe asked that the structure of the quantiles play an active role.

1. **Identification.** θ\* is the unique minimizer of the expected check risk M(θ) (the lower half of A±).
2. **Prior-mass set.** The shift cost λ‖Dθ\*‖₁ = λV\*n^{−2} is where V\* enters the rate. The quadratic part of θ\* is free under the flat prior, but B controls the improper-prior bookkeeping.
3. **Bad set.** The margin M(θ\* + δ) − M(θ\*) ≥ c₀ n Δ²ₙ(δ) (Padilla Lemma 13) defines the shells {Δ²ₙ > Mε²} that are to be shown negligible.
4. **Sieve.** The sieve is centred at θ\*, with the ℓ₁-component of its radius ≍ nε²/λ. At the optimum its ℓ∞ footprint is n³ε²/λ ≍ V\*, which is what makes the L² corollary cheap (§6).
5. **Tuning.** The optimal λ ∝ (n³/V\*)^{3/4}: smoother quantile curves allow stronger smoothing and a faster rate.

**Upper density bound: yes, needed** (A±, upper half). **Moments: none for Stage A.** Every step uses only bounded check-loss differences (|ℓ_θ − ℓ_θ\*| ≤ |θ − θ\*|) and convexity, so Cauchy errors are allowed.

**σ stage (B).** Fix σ₀ := lim n⁻¹Σᵢ E ρ_τ(εᵢ). This is the ALD-scale KL projection (Sriram et al. 2013, §6). It requires **sup_i E|εᵢ|^{1+η} < ∞** and σ₀ ∈ (0, ∞). Assumption A alone allows Cauchy noise, for which σ₀ = ∞ and the learned σ diverges, sending ω → 0. That confirms the advisor's point.

---

## 3. Misspecification

- **All probability is under P₀**, the true product law of y. The ALD is a working likelihood. The posterior is the Gibbs posterior exp{−ω n R̂ₙ(θ)}Π(dθ), with R̂ₙ the empirical check risk (an exact identity at fixed σ; T-02).
- **Target.** θ\* := argmin_θ M(θ), with M(θ) = Σᵢ E₀[ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)]. M(θ) is finite without moments, since its terms are bounded by |θᵢ − θ\*ᵢ|. By (A±) the minimizer is the vector of true τ-quantiles. At fixed σ it is also the KL projection of P₀ onto the ALD location family.
- **KL balls are replaced by excess-risk neighbourhoods** Gₙ = {θ : m(θ) ∨ v(θ) ≤ ε²}, where m = n⁻¹M and v = n⁻¹Σᵢ Var(ℓ_θ − ℓ_θ\*). These enter only the evidence lower bound (Syring–Martin Lemma 1, whose Chebyshev argument holds for independent, non-identical data).
- **Hellinger tests are replaced by a uniform excess-loss event.** With P₀-probability → 1, uniformly over the sieve shell {θ ∈ 𝔅ₙ : Δ²ₙ(θ − θ\*) ≥ Mε²}, the empirical excess risk R̂ₙ(θ) − R̂ₙ(θ\*) ≥ ½ c₀ Δ²ₙ(θ − θ\*). This comes from symmetrization plus contraction (the check loss is 1-Lipschitz) and the localized Rademacher width of the shell, as in Padilla's Theorem 7 and Proposition 2. It holds without moments. The far region is handled by **convexity** of R̂ₙ and log-concavity of the posterior (Padilla's line-segment trick). That replaces the MGF/Bernstein bounds which fail for the check loss (Syring–Martin §3.2.1).
- **σ₀ as KL projection (Stage B).** For fixed θ = θ\*, argmax_σ of the expected ALD log-likelihood is σ₀ (Sriram et al. 2013, eq. (5)–(6)). Integrating σ out gives the θ-marginal ∝ (b_σ + nR̂ₙ(θ))^{−(n+a_σ)}, an effective learning rate ω̂ ≈ 1/σ₀ (T-02).
- **We will NOT claim** that credible sets have frequentist coverage. Under misspecification the posterior spread is set by ω and the prior, not by the sampling variance; the sandwich mismatch is known (Sriram 2015; Yang, Wang and He 2016). We also will not claim BvM, or adaptivity to the fast-rate class.

---

## 4. Prior mass: small-ball and shift (verified)

Write θ = Nc + Su, where u = Dθ has iid Laplace(λ) entries, S is a right-inverse of D (thrice summation, the falling-factorial columns), and N spans the quadratics. The quadratic part is optimized out (flat prior).

**Centred small-ball (verified).** Define φ(ε) := −log P(‖P⊥Su‖ₙ ≤ ε). Then

**φ(ε) ≍ C · (n^{5/2}/(λε))^{2/5}**, valid for 1/λ ≪ ε ≪ n^{5/2}/λ.

- *Heuristic.* Partial sums scale as Su ≈ √2·λ⁻¹n^{5/2}·(twice-integrated Brownian motion), whose L² small-ball exponent is ε^{−2/5}.
- *Verified.*
  - (i) Gaussian increments with the Laplace variance, using the exact eigenstructure and a saddle-point evaluation. φ depends on (n, λ, ε) **only through x = n^{5/2}/(λε)**, identically across n = 500–16000 and λ = n² to n^{2.5}. The local slope d log φ/d log x falls 0.56 → 0.48 → 0.43 → 0.41 → **0.404**, and C ≈ 0.76 in the deep regime (`small_ball*.out`).
  - (ii) Laplace against Gaussian increments by Monte Carlo (4×10⁵ draws, n = 400 and 1600). The small-ball probabilities agree to within 1–3%, with Laplace slightly larger, as expected (`small_ball_laplace_vs_gauss.out`).
- *Caveat.* At the operating point x = n^{5/8} (≈ 75 at n = 1000), practical sample sizes are pre-asymptotic: φ = O(1), and only about 1–3 effective rough modes remain. This matters for reading E-02.

**Shift cost (exact).** For any set B, Π(u\* + B) ≥ e^{−λ‖u\*‖₁}Π(B), with λ‖u\*‖₁ = λV\*n^{−2}. This follows from the triangle inequality on the Laplace density. It is the cost that makes the truth's structure enter.

**Effect on the rate.** The GGV/Gibbs budget is log Π(Gₙ) ≳ −Cnωε². The two costs give:

- small-ball: (n^{5/2}/(λε))^{2/5} ≤ nωε² ⟺ **ε² ≳ ω^{−5/6}λ^{−1/3}** (n cancels exactly);
- shift: λV\*n^{−2} ≤ nωε² ⟺ **ε² ≳ λV\*/(ωn³)**.

Balancing the two gives λ\* ≍ ω^{1/8}(n³/V\*)^{3/4} and ε\*² ≍ ω^{−7/8}V\*^{1/4}n^{−3/4}.

**Independent confirmation: the posterior spread really scales like λ^{−1/3}.** This was checked with the actual Laplace prior, a Gaussian likelihood with κ = 16, and an exact Park–Casella Gibbs sampler (`laplace_gibbs_bigJ.out`). The rough spread is defined as the posterior variance after removing quadratics.

| n | slope in log λ (λ = 10²–10⁵) | Laplace/Gaussian-analogue spread | rough spread at λ = 10⁴ |
|---|---|---|---|
| 1000 | −0.347 | 0.92–0.98 | 1.65e−3 |
| 2000 | −0.338 | 0.96–0.99 | 1.69e−3 |
| 4000 | −0.335 | 0.97–0.99 | 1.70e−3 |

The spread is flat in n, as predicted. The Gaussian analogue (`spread_gaussian_analog.out`) gives rough ≈ 0.35·κ^{−5/6}λ^{−1/3} exactly, with slope −0.355 in λ and −0.82 in κ. **So the prior-mass rate is also the actual posterior spread, not a proof artefact.** For bias-free truths the n^{−3/4} rate at the optimal fixed λ is very likely sharp for this prior.

**Bias side (measured, noiseless MAP).** For S and PQ at μ = λ/κ ≤ n^{1.75}, the k = 2 MAP bias² is 2–10% of the worst-case bound 2μV\*n^{−3} and decreases in n at fixed a (`map_bias.out`). The worst case over Θ(V\*, B) is what a class-uniform theorem must use. Smooth truths may do better (an upside, not claimed).

---

## 5. Rate table (Stage A: σ fixed, ω ≍ 1, V\* ≍ 1; λ = n^a, equivalently λσ ≍ n^a)

| a (λ ≍ n^a) | predicted posterior rate ε² | provable, crude TV sieve | provable, two-level sieve | comment |
|---|---|---|---|---|
| a ≤ 0 | no contraction | — | — | spread O(1) |
| 0 < a < 9/4 | n^{−a/3} (spread-limited) | n^{−2a/7} | n^{−a/3} | |
| 2 | n^{−2/3} | n^{−4/7} | n^{−2/3} | |
| 15/7 (Padilla/TF tuning) | **n^{−5/7}** | n^{−30/49} | n^{−5/7} | MAP attains n^{−6/7}(log n)^{1/7} here |
| **9/4** | **n^{−3/4} (best)** | n^{−9/14} | **n^{−3/4}** | optimal fixed λ |
| 7/3 | n^{−2/3} (bias-limited) | **n^{−2/3}** (crude optimum) | n^{−2/3} | VP's crude-sieve point |
| 9/4 < a < 3 | n^{−(3−a)} | same | same | shift/bias-limited |
| a ≥ 3 | no contraction | — | — | bias O(1) |

The crude column comes from the entropy of the TV⁽³⁾ ball of radius ≍ n³/λ, which is the ℓ₁ size of typical posterior draws, since λ‖Dθ‖₁ ≈ m by the virial identity below. Its entropy (n³/(λε))^{1/3} ≤ nε² gives ε² ≳ λ^{−2/7}, and Padilla's Proposition 2 width gives the same exponent. The two-level sieve has an ℓ₁-component of radius only nε²/λ plus an ellipsoid. Its entropy is ≲ nλ^{−1/3} + (n³ε/λ)^{1/3}, which matches the small-ball rate.

**Admissible window.** Rates hold for (log n)^C ≲ λ ≪ n³; the optimum n^{9/4} lies well inside. The VP's lower end n ≪ λ appears when posterior ℓ∞-boundedness is obtained from the crude bound ‖P_R δ‖∞ ≲ n²‖Dδ‖₁. My estimate of the actual pointwise posterior sd is ≍ λ^{−1/6}, small for any λ → ∞. Keep n ≪ λ as a safe technical condition if a proof needs it. It costs nothing at the optimum.

**Fast-rate class (s knots).** The theorem gives the same rate, ε² ≍ max(λ^{−1/3}, λ·s·n^{−3}), with optimum ≍ s^{1/4}n^{−3/4}. Heuristically, the true posterior bias for sparse truths is ≍ s·λ²n^{−6}, which would allow λ ≍ (n⁶/s)^{3/7} and rate ≍ s^{1/7}n^{−6/7}. That is unreachable by prior-mass techniques; it is a conjecture and upside only.

**Gamma cap and learned λ (Stage B preview).**
- *Hard cap.* λ | θ, y ~ Gamma(a₀ + m, b₀ + ‖Dθ‖₁) ≤_st Gamma(a₀ + m, b₀), so λ ≲ (a₀ + n)/b₀. Merely allowing λ ≍ n^{9/4} needs **b₀ ≲ n^{−5/4}**.
- *Virial identity (exact for fixed λ; follows from integration by parts in u, so it holds for the Lipschitz check loss).* E[λ‖Dθ‖₁ | y, λ] = m − Lₙ(λ), where Lₙ = E[u·∇_u(ωΣρ)]. Measured Lₙ ≈ +0.8·J_eff when bias is small, with J_eff ≈ 0.34·n·κ^{1/6}λ^{−1/3}. Lₙ turns negative when bias dominates. This explains the paper's observation that λ‖Dθ‖₁/m ≈ 1.0–1.1.
- *Fixed point.* Plugging into the conjugate update gives λb₀ ≈ a₀ + Lₙ(λ). For b₀ fixed this means λ ≈ (0.27·n·κ^{1/6}/b₀)^{3/4} ≍ n^{3/4}, so ε² ≍ n^{−1/4}.

  **Check against the paper:** Gamma(1, 1) at n = 500 predicts λ ≈ 53; Appendix A reports "between 50 and 75". With b₀ = n^{−β}: λ ≍ n^{3(1+β)/4} and ε² ≍ n^{−(1+β)/4} for β < 2. For **b₀ ≲ n^{−2}**, the fixed point needs Lₙ ≈ −a₀, i.e. bias ≈ spread. That suggests λ self-tunes to the oracle (n³/V\*)^{3/4} and ε² ≍ n^{−3/4}, adaptively in V\*. This is heuristic and worth a Stage-B theorem.

  The paper's b₀ ∈ {10⁻², 10⁻³, 5×10⁻⁴} is fixed in n. Asymptotically that is the slow regime. **Felipe should decide** whether Stage B targets b₀ = bₙ ↓ 0, or analyses the paper's prior and accepts the slower rate.

---

## 6. Draft statements, Stage A (statements only; difficulty in brackets)

**Assumptions.**
- (A0) Independent yᵢ on the grid xᵢ = i/n.
- (A±) as in §2.
- (T) θ\* ∈ Θ(V\*, B).
- (S) σ > 0 fixed.
- (Λ) (log n)^{C₀} ≤ λₙ ≤ n³/(log n)^{C₀}.
- (Optional) (Λ′) n ≤ λₙ.

**Theorem A (contraction in Δ²ₙ).** Under (A0), (A±), (T), (S) and (Λ), for every Mₙ → ∞:

E₀ Πₙ( Δ²ₙ(θ − θ\*) > Mₙ ε²ₙ | y ) → 0, with ε²ₙ = [ ω^{−5/6}λₙ^{−1/3} + λₙV\*/(ωn³) + n⁻¹ ]·(log n)^{c}.

- *Corollary A1 (best rate).* λₙ ≍ ω^{1/8}(n³/V\*)^{3/4} gives ε²ₙ ≍ ω^{−7/8}V\*^{1/4}n^{−3/4}(log n)^c.
- *Corollary A2 (Padilla tuning).* λₙσ ≍ n^{15/7} gives ε²ₙ ≍ n^{−5/7}; contrast this with the MAP's n^{−6/7}.
- *Corollary A3 (average squared error).* Add Lemma 10 (posterior ℓ∞-boundedness). Then the same rate holds for ‖θ − θ\*‖²ₙ, using Padilla Lemma 17, ‖δ‖² ≤ max(1, ‖δ‖∞)Δ²(δ). This is cheap at the optimum, where the sieve's ℓ∞ footprint is ≍ V\*.
- *Theorem A′ (fallback).* The same statement with ω^{−5/6}λ^{−1/3} replaced by λ^{−2/7}, via the crude TV-ball sieve. Its best rate is n^{−2/3} at λ ≍ n^{7/3}.
- *Remark (sharpness, conjectured).* For bias-free truths, Πₙ(Δ²ₙ < c·λ^{−1/3} | y) → 0. That is, the spread is a lower bound, as in Castillo et al. (2015) Theorem 7.

**Lemmas.**

| # | Statement | Difficulty |
|---|---|---|
| L1 | **Basis identity.** θ = Hα; the prior is flat on α_{1:3} and iid Laplace(2λ/n²) on α_{4:n}; ‖h_j‖_{2,n} ≤ 1. | Trivial (verified). |
| L2 | **Excess-risk sandwich under (A±).** c₀Δ²ₙ(δ) ≤ m(θ\* + δ) ≤ (f̄/2)‖δ‖²ₙ when ‖δ‖∞ ≤ L, and m ≤ ‖δ‖₁/n always; v(θ\* + δ) ≤ ‖δ‖²ₙ. | Easy (Padilla Lemma 13 plus the upper half of A±). |
| L3 | **Centred small-ball.** −log Π(‖P⊥Su‖ₙ ≤ ε) ≤ C(n^{5/2}/(λε))^{2/5} for (log n)/λ ≤ ε ≤ n^{5/2}/λ. | Medium. Gaussian case via Li–Linde/Sytaya-type spectral asymptotics; Laplace case via a small-deviation comparison for weighted sums. Exponent verified numerically. |
| L4 | **Shift.** Π(u\* + B) ≥ e^{−λ‖u\*‖₁}Π(B). | Trivial. |
| L5 | **Improper quadratic part.** The posterior is proper for n ≥ 4. Integrating the 3-dimensional flat component costs only O(log n) in the evidence bound and O(1/n) in the rate. | Low–medium. |
| L6 | **Evidence lower bound (misspecified, inid).** P₀( ∫ e^{−ωn(R̂ₙ(θ) − R̂ₙ(θ\*))}Π(dθ) ≥ e^{−Cnωε²} ) → 1. | Medium. Syring–Martin Lemma 1 plus L2–L5. |
| L7 | **Two-level sieve (Talagrand).** For 𝔅ₙ = θ\* + span(N) + S(A_ε + R₂B₂ + R₁B₁), with R₂ = (Cnωε²)^{1/2}/λ and R₁ = Cnωε²/λ: Π(𝔅ₙᶜ) ≤ e^{−C′nωε²}. | Medium. Talagrand's inequality for the product exponential measure, as used for Besov-Laplace priors by Agapiou–Dashti–Helin and Giordano; the exact form is to be checked. |
| L8 | **Uniform excess-loss on sieve shells.** With P₀-probability → 1, R̂ₙ(θ) − R̂ₙ(θ\*) ≥ ½c₀Δ²ₙ(θ − θ\*) for all θ ∈ 𝔅ₙ with Δ²ₙ ≥ Mε². This rests on a width bound w(𝔅ₙ ∩ {Δ² ≤ t²}) ≲ t·(J_eff log n)^{1/2} + t^{5/6}(n^{1/2}·n³R₁)^{1/6}. | Medium–high. Extends Padilla's Proposition 2 to the two-level set, including the Δ²-to-ℓ² conversion with ℓ∞ control. |
| L9 | **Far region by convexity.** Πₙ(𝔅ₙᶜ ∪ {Δ²ₙ > Mε²} | y) → 0 without MGF or moment bounds, using convexity of R̂ₙ, log-concavity of Πₙ, and L6 to L8. | **High: the main novelty and the main risk.** This is the step where Syring–Martin need a bounded-support prior or ω → 0, and where Kleijn–van der Vaart need tests. |
| L10 | **Posterior ℓ∞ control.** Πₙ(‖θ − θ\*‖∞ > C | y) → 0 (only for Corollary A3). | Medium. |
| B1–B3 | **Stage B preview.** (B1) σ-posterior concentration at σ₀ under the moment condition. (B2) The virial identity and the λ fixed point under Gamma(a₀, bₙ). (B3) The joint non-crossing version: the product posterior truncated to C has the same rate when min_i(θ\*_{i,j+1} − θ\*_{i,j}) ≳ ε-margin. | Medium, medium–high, and medium respectively. |

---

## 7. Risks and kill criteria

| Risk | Signal | Response / kill criterion |
|---|---|---|
| R1. The spread law fails for the ALD posterior (I verified it only with a Gaussian likelihood). | E-02: the slope of rough spread in log λ is outside [−0.42, −0.27] in the many-mode regime (J_eff ≳ 10), or depends on n. | **Kill** the n^{−3/4} target and re-derive the prior-mass calculus. Theorem A′ (n^{−2/3}) may survive. |
| R2. L9 (convexity far-region) cannot be done for heavy tails. | No route by the end of week 2. | Fall back to sub-exponential noise, where the MGF route of Syring–Martin Theorem 4.1 applies with a sieve. This loses only the moment-free claim. Not a kill. |
| R3. L3 (Laplace small-ball) is provable only up to worse polylogs or exponents. | — | Use the crude Theorem A′ (n^{−2/3}). Not a kill. |
| R4. The two-level sieve fails to give matching entropy. | The L7/L8 width bound exceeds nε². | Fall back to A′. |
| R5. E-02 is inconclusive because of pre-asymptotics or mixing. | At n ≤ 4000 near a = 9/4, the 3/n parametric term dominates and P-MALA may mix poorly at large λ. | Judge only rough-spread slopes, at a ≤ 2 or in the many-mode regime. Not a theory kill. |
| R6. Theory and practice diverge on the λ hyperprior. | The b₀-fixed prior of the paper gives ≈ n^{−1/4} asymptotically. | Needs Felipe's decision: Stage B with bₙ ≲ n^{−2}, or analyse the paper's prior and accept the slow rate. Engineering's check of existing λ values (requested) tests the fixed-point formula. |
| R7. Overclaiming. | — | No coverage, BvM or fast-rate claims (§3). |

**Global kill criterion for the n^{−3/4} programme:** R1 fires, or neither L7 nor any alternative sieve gives matching entropy within two weeks. In either case the deliverable becomes Theorem A′ (n^{−2/3}), which is still new according to T-01.

---

## Appendix A: verdicts on the advisor heuristics

1. **λσ ≍ n^{15/7}(log n)^{1/7} for Padilla on the raw scale: confirmed.** TV⁽³⁾ = n²‖D³θ‖₁ and λ_TV ≍ n^{1/7}(log n)^{1/7} together give n^{15/7}(log n)^{1/7} on ‖D³θ‖₁. Tibshirani's (n²/2)·n^{1/7} agrees up to the log.
2. **Small-ball cost {n^{5/2}/(λε)}^{2/5}, and n^{11/35} versus a budget of n^{1/7} at Padilla's tuning: confirmed.** The exponent was verified numerically: local slope → 0.404, with an exact collapse in x. Laplace equals Gaussian to within 1–3%. The constant is C ≈ 0.76 (Gaussian, deep regime).
3. **Balancing gives λ ≍ n^{9/4} and ε² ≍ n^{−3/4}: confirmed.** With the dependence made explicit: λ\* ≍ ω^{1/8}(n³/V\*)^{3/4} and ε\*² ≍ V\*^{1/4}n^{−3/4}. It is also the actual posterior bias/spread balance, not only a proof bound.
4. **Spread ∝ λ^{−1/3}; a crude sieve gives n^{−2/3} at λσ ≍ n^{7/3}; window n ≪ λ ≪ n³: confirmed, with one refinement.** The spread law is confirmed with the explicit κ^{−5/6} factor (Gaussian analogue exact; Laplace Gibbs slopes −0.335 to −0.347). The crude n^{−2/3} at n^{7/3} is reproduced via TV-ball entropy (λ^{−2/7}) against bias λn^{−3}. The upper window end n³ is confirmed. **Refinement:** the lower end n ≪ λ is not needed for the rate. It looks like an artefact of crude ℓ∞ control; keep it only as a technical condition.
5. **Gamma cap λ ≤_st Gamma(a₀ + n − 3, b₀): confirmed, and sharpened.** The cap is O(n/b₀). The actual fixed point (virial identity) is ≍ (n/b₀)^{3/4}, matching the paper's Gamma(1, 1) value. Optimal rates need b₀ ≲ n^{−2}.
6. **σ₀ needs a moment condition: confirmed.** Use sup_i E|εᵢ|^{1+η} < ∞ (Stage B only). Stage A needs no moments.

## Appendix B: numerical evidence (all in `scratch/`, uncommitted)

| Script and output | What it shows |
|---|---|
| `ff_basis_check.py` / `.out` | The falling-factorial identity and column norms |
| `spread_gaussian_analog.py` / `.out` | Exact Gaussian-analogue spread: λ^{−1/3}, κ^{−5/6}, flat in n |
| `small_ball.py`, `small_ball_deep.py` / `.out` | Small-ball exponent 2/5 and the collapse in x = n^{5/2}/(λε) |
| `small_ball_laplace_vs_gauss.out` | Laplace equals Gaussian small-ball probabilities |
| `laplace_gibbs_spread.py`, `laplace_gibbs_bigJ.py` / `.out` | Actual Laplace-prior posterior spread; the virial ratio |
| `laplace_gibbs_S.out`, `laplace_gibbs_PQ.out`, `compare_laplace_gauss.out` | A first pass that also covers small J_eff. Large-λ cells there are invalid because of a binding numerical cap; flagged by λ‖Dθ‖₁/m ≫ 1. |
| `map_bias.py`, `map_bias_run.py` / `map_bias.out` | Noiseless MAP bias for S and PQ, compared with the worst-case bound |

## Appendix C: E-02 coordination (Engineering)

**Sent 2026-11-22:**
- the spec: σ fixed at σ₀, λ fixed at n^a with a ∈ {1.5, 2, 15/7, 9/4, 7/3, 2.5}, n = 250–4000, truths S and PQ (VS optional), Gaussian and Cauchy noise, τ ∈ {0.5, 0.9};
- metrics M1–M4: Δ²ₙ and ‖·‖²ₙ posterior risk; bias, total and rough spread; the virial ratio; MAP error;
- predictions P1–P5, and an optional learned-λ arm;
- a follow-up asking for λ, σ and λ‖Dθ‖₁/m from the paper's existing runs, to test the fixed-point formula.

*Results pending. This section and §4–5 will be updated when they arrive.*
