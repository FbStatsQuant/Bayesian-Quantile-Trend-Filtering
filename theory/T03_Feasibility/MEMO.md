# T-03 Week-1 feasibility memo: posterior contraction for BQTF

*Theory Department. **FINAL**, 2026-11-22. Draft v1 was revised after both advisor reviews and the E-02 results (E-04 passed). The final statement is `STATEMENT_DRAFT.md` v3.*

**Scope.** Feasibility calculations, heuristics and statements only. No proofs.

**Sources.** Numerical checks are in `scratch/`, with scripts and `.out` files listed in Appendix B. The E-02 results from Engineering are in, and count as evidence after E-04 (§8.1a′–§8.1e). The provenance of every number is in §8.1c.

**Conventions.**
- D := D⁽³⁾, unscaled (rows −1, 3, −3, 1), with m = n − 3.
- TV⁽³⁾(θ) = n²‖Dθ‖₁, Padilla's convention with r = 3.
- ‖v‖²ₙ = n⁻¹Σvᵢ² and Δ²ₙ(v) = n⁻¹Σ min(|vᵢ|, vᵢ²).
- **Stage A** is σ fixed (ω := 1/σ) and λ = λₙ deterministic. The posterior is

  Πₙ(dθ | y) ∝ exp{−ω Σᵢ ρ_τ(yᵢ − θᵢ)} · exp{−λ‖Dθ‖₁} dθ.

- κ := ω·f(θ*), the local curvature per observation of the working log-likelihood.
- "≍" hides constants and polylog factors.

---

## ADDENDUM v3.1 (2026-11-22, after the final reviews; supersedes the summary below where they differ)

- **Statement.** `STATEMENT_DRAFT.md` is now v3.1. Its changes:
  - Theorem A requires **strict slack**, ω ≤ (1−η)ω̄. The equality case is false (Astra's counterexample).
  - The window is n² ≤ λ ≤ n³/(V^{3/2}(log n)^{C₀}), with C₀ > 3c/5.
  - The theorem is stated in both losses.
  - L10 is planned via the VP's two-stage route.
  - The mixture row is corrected: it is not covered globally.
- **Positioning (HQ decision).** The light-tail **Theorem B** is proved first.
  - B assumes the global MGF condition (EM). Sufficient conditions are Astra's two-sided envelope, or a ψ₁ bound plus a σ threshold.
  - B is in Δ²ₙ only. If Fᵢ is differentiable at the quantile, B implies a strict **point-density** threshold F′(q) ≥ ωτ(1−τ) + 2b, so Gaussian noise at σ₀ is still excluded; it also implies tail necessity. B's scale condition is stated via the point density and does not require A's secant condition for a fixed margin class. For differentiable laws, however, it implies A4 for some small margin interval, so B genuinely covers laws that A excludes only when Fᵢ is not differentiable at the quantile (dyadic staircase example). Corrected after the end-to-end audit: the earlier uniform-error example fails A4 only at L = 4.
  - **If the moment-free Theorem A is proved**, A is the main theorem and B is the warm-up proposition.
  - **If not**, B is the main theorem, and moment-free contraction is stated as a conjecture supported by the t₂ and Cauchy simulations.
- **Sandwich check** (Engineering, the VP's test). At Gaussian noise, τ = ½, σ = σ₀, the replicate variance of the posterior mean divided by the spread is 1.49 in the null-space directions (≈ π/2) and 1.08 in the rough part. The σ̄ restriction is therefore a limitation of the proof route, not an empirical inflation of the rate.
- **Outlook (referee points, no action now).**
  - A lower bound in one case (quadratic truth) is the best single addition.
  - The oracle λ depends on V.

- **Reading note for the body (§0–§8).** These sections are the dated T-03 record. Where they write σ ≥ σ̄ (non-strict), read ω ≤ (1−η)ω̄ (v3.1). Where they call a lemma "drafted", "to be written" or "pending", the current status is in FINAL SUMMARY item 4 and in `../T05_Proofs/SKELETON.md`.

## FINAL SUMMARY (read this first; it supersedes §0–§7 where they differ)

**1. The theorem.** `STATEMENT_DRAFT.md` v3 was the final T-03 statement; it is now **superseded by v3.1** (addendum above). Under (A1)–(A4), at fixed σ and λ:

  ε²(λ) = (log n)^c κ^{−5/6}[λ^{−1/3} + min{κ^{−1/6}λVn^{−3}, V²λ^{5/3}n^{−5}}].

- **Primary rate:** n^{−5/6}, the linear-smoother rate, at λ ≍ n^{5/2}/V.
- **Fallback rate:** n^{−3/4} at λ ≍ (n³/V)^{3/4}.
- **Two versions:** Theorem A requires **strict slack**, ω ≤ (1−η)ω̄ with ω̄ = f/(τ(1−τ)) (v3.1; the v3 equality case σ ≥ σ̄ is false), and is the milestone. Theorem A⁺ holds for every σ and is the one that covers the paper's practice. The light-tail **Theorem B** is now proved (addendum).
- **Not claimed:** credible-set coverage, BvM, fast rates, or a lower bound (the lower bound appears as a conjecture).

**2. Numerical evidence** (company sampler, E-04 passed; §8.1a′–§8.1e):

| Claim | Result |
|---|---|
| Spread law | ALD posterior: slope −0.37 / −0.34, against a predicted −1/3; along λ = c·n^a, within 0.016 of −a/3 |
| Linear-smoother mechanism | Laplace ÷ Gaussian twin = 1.00 ± 0.02 (kinked truth); Laplace ÷ spline bias² = 0.996–1.013 |
| **Bias law** | Calibrated kinked bias² slopes match the VP law 5a/3 − 5 and **exclude the ℓ₁ law at every a** |
| Learned-λ fixed point | Confirmed (slope 2.257 against 9/4); it is not a bias-law test (§8.1d) |

**3. Exact results** (no sampler needed):
- the small-ball exponent 2/5;
- the Gaussian-analogue spread law;
- the sharp σ̄ and the gap ratios R = σ̄/σ₀: π/2 for Gaussian noise at τ = ½, up to 4.5 at τ = 0.95;
- the correction of Padilla–Chatterjee Lemma 19 (off by n^{r−1}).

**4. The proof campaign (T-05); status as of the 2026-11-22 checkpoint.**
- **Advisor-checked:** L2, L3 (small ball, (log m)^{1/5} only), L4, L4q, L4q-M, L5, L6, L8′ (bounded numerator, strict slack), L10-I (interpolation, i.e. L10 Stage 2).
- **Theorem B (light tails): proof complete, advisor-checked** (`../T05_Proofs/B_light_tail.md`; audit package `../T05_Proofs/THEOREM_B_COMPLETE.md`).
- **Open:** L10 Stage 1 (sup-norm localization; parked at the checkpoint, `../T05_Proofs/parked/L10_stage1_NOTES.md`), and L8-b (realized numerator; any σ).

**5. Gate item (what Felipe's decision turns on).**
- L4q needs Π_λ(h + B) ≥ e^{−Cλ²‖h‖²}Π_λ(B) for small-ball sets B.
- It is now proved and advisor-checked (Astra: ACCEPT): symmetrization reduces it to the marginal density of uⱼ at 0 under Π_λ restricted to B, and neighbour-coordinate compensation bounds that density by c_K·λ ≤ 3.15λ.

**6. Stage-B/C notes.**
- The learned scale σ needs a first-moment condition.
- The learned λ needs b₀,ₙ ≲ n^{−2} (or n^{−7/3} heuristically for λ ≍ n^{5/2}). Kinked truths then self-tune to λ ≍ n^{9/4}, which gives n^{−3/4} under learned λ.

---

## 0. Bottom line

> **Revision note (after the reviews).** Items 1–3 below are superseded by §8.
> - **Primary target:** n^{−5/6} at λ ≍ n^{5/2}/V, the VP's min form. It is conditional on a new quadratic shift lemma (L4q), and is backed by exact-Gibbs evidence that the Laplace posterior mean equals the spline smoother.
> - **Fallback:** n^{−3/4} at λ ≍ (n³/V)^{3/4}.
> - **Likelihood side:** L8 is withdrawn and replaced. L9 is split, and L10 is now essential.
> - **σ:** no σ restriction in the statement.
>
> The current statement is `STATEMENT_DRAFT.md` v2.

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

## 3a. Frequentist-to-Bayesian translation (primary blueprints: Padilla & Chatterjee, Tibshirani 2014)

Felipe's steering: Padilla & Chatterjee (P&C) and Tibshirani (2014) are the primary blueprints; Atchadé (2017) and Bach & Klein (2022) are supporting templates. The two tables below map every frequentist step to our lemma (§6) and state what changes. "Verbatim" means the statement and proof should carry over with notation changes only.

**Padilla & Chatterjee (risk bounds for quantile trend filtering, r = 3):**

| P&C step | Our lemma | What carries over | What changes |
|---|---|---|---|
| Assumption A (linear CDF growth at θ\*) | (A2), lower half | Verbatim: identification and margin. | Add the **upper** half. The posterior needs prior mass of excess-risk neighbourhoods, which a minimizer never needs. |
| Lemma 13: M(θ\* + δ) ≥ c₀Δ²(δ); Remark 11 (no moments) | L2 | Verbatim lower bound. Bounded loss differences, so no moments. | Add M ≤ (f̄/2)‖δ‖² and the variance bound v ≤ ‖δ‖²ₙ, used by the Chebyshev step of the evidence bound. |
| Lemma 9, basic inequality M̂(θ̂) ≤ 0 | L6 (evidence lower bound) | — | **No analogue.** The posterior does not minimize M̂. It is replaced by D_n ≥ e^{−Cnε²}, which needs prior mass (L3, L4, L5). This step is purely Bayesian. |
| Lemmas 10–11 (symmetrization; Ledoux–Talagrand contraction for the 1-Lipschitz loss), Markov | L8 (uniform excess-loss event) | Same tools: P(sup over shell of (M − M̂) > ½c₀t²) ≤ C·RW(shell)/t². | The supremum is over the **sieve shell** 𝔅ₙ ∩ {Δ² ≈ t²}, not the TV ball K_V. The event must hold uniformly over a region carrying posterior mass, not just at one estimator. Markov still suffices, since we need probability → 0, not exponential. |
| Prop. 1 / Thm 7, convexity line-segment trick (the point θ̃ on [θ\*, θ̂] with M(θ̃) = t²) | L9 (far region) | Convexity of M̂ along segments from θ\* transfers a lower bound on the shell {Δ² = t²} to every θ beyond it. The sieve 𝔅ₙ is convex and contains θ\*, so it is star-shaped and segments stay inside. | We need M̂(θ) ≳ t² for **all** θ in the far region, not only at θ̂, plus control of 𝔅ₙᶜ (prior mass, ADH). That is where log-concavity and Atchadé's peeling enter. |
| Lemma 16 (R⊥ = polynomials of degree < r), Lemmas 18, 20, 21 (null-space part ‖P_{R⊥}δ‖∞ ≲ n^{−1/2}·(…)) | L5 and the null-space part of L8 | **Verbatim.** Our flat quadratic part *is* P&C's R⊥ (dimension 3 for r = 3). Their T₁ term bounds its contribution to the width. | The prior is flat on R⊥, so the evidence bound must integrate this 3-dimensional part (Bach & Klein's proper-ization). |
| Lemma 17, ‖δ‖² ≤ max(‖δ‖∞, 1)Δ²(δ); Lemmas 19, 22 (‖P_Rδ‖∞ ≲ ‖D⁽ʳ⁾δ‖₁; Δ²(P_Rδ) ≲ t²) | Δ²-to-ℓ² conversion inside L8; Corollary A3 | Verbatim for the ℓ₁ part of the sieve, S(R₁B₁), which is a TV ball of radius n²R₁. | **The ℓ₂ part of the sieve, S(R₂B₂), has no ‖D³δ‖₁ control, so Lemma 19 does not apply.** Its ℓ∞ footprint is ≍ R₂n^{5/2} ≍ n^{3/8} at the optimal tuning. ℓ∞ control on Δ²-bounded elements of this ellipsoid needs a new argument. ⚠ This is the likely weak point of L8 as drafted. |
| Prop. 2, the width of {TV⁽³⁾(δ) ≤ 2V, Δ²(δ) ≤ t²} via Guntuboyina et al. (2020) Lemma B.1 | L8 width bound, ℓ₁ part | Verbatim with V′ = n³R₁ ≍ n³ε²/λ. That gives the exponent ε² ≳ λ^{−2/5} (non-binding). | The ellipsoid part needs a separate Gaussian-width bound, about t·√(J_eff log n), via the Demmler–Reinsch spectrum (Bach & Klein / Xiao). |
| Thm 3 (PQTF slow rate): Prop. 3 restricted set A, built from the score uᵢ = τ − 1{yᵢ ≤ θ\*ᵢ} (Lemmas 23–25) | Atchadé's score event E_{n,0} inside L8/L9; the sieve replaces A | The bounded score u, with sup over ‖D⁽ʳ⁾x‖₁ ≤ 1 of u′x (Lemma 24), gives the score event without moments. | P&C localize via the penalty (optimality of θ̂). We localize via the **prior** (the ADH two-level sieve). The roles of λ differ: penalty ≍ n^{15/7} there, prior rate ≍ n^{9/4} here. |
| Thm 4 (fast rate; Ortelli–van de Geer effective sparsity) | — | Not transferable. | The Laplace posterior has a truth-independent spread floor λ^{−1/3} (§4). Fast rates are a remark only (§5). |
| §5, multiple quantiles under an ordering constraint | B3 (joint, Stage-B preview) | The structure: a product of check losses on an ordered cone. | The truncated product posterior needs prior mass of the truncated set. That is fine when the true quantiles are separated by more than ε. |

**Tibshirani (2014, trend filtering):**

| Tibshirani step | Our use | What changes |
|---|---|---|
| Lemma 2, lasso form θ = Hα (falling factorial) | L1, verbatim (verified numerically). Our prior is iid Laplace(2λ/n²) on α_{4:n}. | Nothing. The basis is the prior's natural coordinate system: ADH applies in α. |
| Penalty scaling (n^k/k!)λ_TF, λ_TF ≍ n^{1/(2k+3)} ⇒ n^{15/7} on ‖D³θ‖₁ | The MAP correspondence (MAP penalty = λσ); Corollary A2 | The posterior-optimal λ is n^{9/4}, not n^{15/7}. |
| §5.1 minimax rate n^{−(2k+2)/(2k+3)} = n^{−6/7} over F₂(C); linear smoothers suboptimal | Benchmark for Theorem A | Our posterior rate n^{−3/4} is above minimax: the full posterior pays a factor n^{3/28}. |
| Embedding (33): Besov B^{k+1}₁,₁ ⊂ F_k(C) | Links our class (A3) to the B₁₁ scale, where Laplace-type priors are known to be optimal when scaled (Agapiou–Wang, ADH) | Supports the plausibility of L3 and L7; it is not used in a proof step. |
| Thm 1 / Lemma 3 (trend filtering ≈ locally adaptive regression splines via lasso stability, ‖G − H‖∞) | Not needed, since our prior is defined through H | Possibly useful for the fast-rate remark (spline approximation with few knots). |
| (5), df = E[#knots] + k + 1 | Interpretation: the posterior's effective dimension J_eff ≍ nλ^{−1/3} is the Bayesian analogue of df | Heuristic only. |

**Supporting templates.**
- **Atchadé (2017)** supplies the overall pathwise architecture: the score, curvature and lower-bound events plus peeling. It puts P&C's L8 ingredients and our L6 into one deterministic-on-event argument.
- **Bach & Klein (2022)** supplies the Gaussian prior-mass mechanics for difference priors with an improper polynomial part (L3 Gaussian half, L5), and a hyperprior-balance condition for Stage C.

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

  *Remark (fixed b₀, documented for contrast).* The paper's b₀ ∈ {10⁻², 10⁻³, 5×10⁻⁴} is fixed in n. Then λ ≍ n^{3/4} and ε² ≍ n^{−1/4}, which is the slow regime.

**Stage-C plan: n-dependent b₀ = b₀,ₙ (Felipe's direction, 2026-11-22).**

- **Required order.** b₀,ₙ ≲ c·V\*·n^{−2}. At the oracle λ\* ≍ (n³/V\*)^{3/4}, the effective dimension is J_eff(λ\*) ≍ n^{1/4}V\*^{1/4}. The fixed point λb₀ ≈ a₀ + Lₙ ≍ J_eff then puts λ at or beyond λ\* iff b₀ ≲ J_eff(λ\*)/λ\* ≍ V\*n^{−2}. V\* is unknown, so the recommendation is **b₀,ₙ = s_y·n^{−2}/log n**, or n^{−5/2}. Here s_y is a data scale such as sd(y) or σ̂, needed because b₀ carries the units of ‖Dθ‖₁, i.e. data units. This choice also satisfies the hard-cap requirement b₀ ≲ n^{−5/4}.
- **Pairing with the Stage-A window.** Stage A holds for (log n)^{C₀} ≤ λ ≤ n³/(log n)^{C₀}. The Stage-C theorem would show that the λ-posterior puts mass → 1 on a band [λ\*/Cₙ, Cₙλ\*] ⊂ window, then apply Theorem A **uniformly over λ in that band**. So Theorem A should be stated uniformly in λ over compact-in-log ranges; this is easy to arrange.

  Prediction for Engineering's learned-λ check with b₀ = n^{−2} (κ = 4):
  - quadratic truth (V\* = 0, no bias): λ ≈ (0.27·κ^{1/6})^{3/4}n^{9/4} ≈ 0.45·n^{9/4};
  - sin and PQ: λ ≈ min{that, bias-balance value}.
- **Side effects.**
  1. **Propriety.** b₀ > 0 is required. With b₀ = 0 the λ-marginal prior on u = Dθ is ∝ ‖u‖₁^{−(a₀+m)}, which is not integrable at u = 0 in ℝᵐ. So the posterior is improper, and b₀,ₙ must stay strictly positive.
  2. **a₀.** Keep a₀ fixed with 0 < a₀ ≲ J_eff(λ\*) ≍ n^{1/4}; a₀ = 1 is fine. Large a₀ shifts the fixed point upward.
  3. **Implied prior on smoothness.** The marginal prior on ‖Dθ‖₁ is b₀·Beta′(m, a₀), with typical size ≍ m·b₀/a₀ ≍ n^{−1} for b₀ = n^{−2}. That is rougher than the truth (V\*n^{−2}) and smoother than the posterior draws (m/λ\* ≍ n^{−5/4}), so it is not dominant. The prior mean of λ is a₀/b₀ ≍ n².
  4. **Mixing.** λ is identified only through the slowly varying Lₙ(λ) ∝ λ^{−1/3}. Removing the b₀ restoring term makes the log-λ posterior flatter, so expect *slower* λ mixing than the paper's already low ESS (log λ ESS ≈ 9 per 20k sweeps), plus a long burn-in from λ⁽⁰⁾ = m up to n^{9/4}. Mitigations: keep the interweaving step, and initialize λ at the n^{9/4} scale.
  5. **Units and scaling.** b₀,ₙ ∝ s_y·n^{−2} makes the recommendation invariant to rescaling y. The paper standardizes y in the applications, so s_y = 1 there.
- **Recommended paper setting** (if adopted at the end-of-week gate): λ ~ Gamma(1, n^{−2}·s_y). At n = 500 that is b₀ ≈ 4×10⁻⁶, against the current 10⁻³.

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
| L3 | **Centred small-ball.** −log Π(‖P⊥Su‖ₙ ≤ ε) ≤ C(n^{5/2}/(λε))^{2/5} for (log n)/λ ≤ ε ≤ n^{5/2}/λ. | Medium. The Gaussian, continuous version is classical: twice-integrated Brownian motion has L² small-ball exponent ε^{−2/5} (Chen & Li; exact asymptotics in Fill & Torcaso 2004 via Sytaja's theorem, arXiv:math/0309391). Still needed: (i) the discretization to the grid, (ii) the step from Gaussian to Laplace increments (a small-deviation comparison for weighted sums). Both are checked numerically: exponent → 0.404, and Laplace equals Gaussian within 1–3%. This is the main remaining prior-side gap, since ADH only lower-bound small balls via their Theorem 2.13. |
| L4 | **Shift.** Π(u\* + B) ≥ e^{−λ‖u\*‖₁}Π(B). | Trivial. |
| L5 | **Improper quadratic part.** The posterior is proper for n ≥ 4. Integrating the 3-dimensional flat component costs only O(log n) in the evidence bound and O(1/n) in the rate. | Low–medium. |
| L6 | **Evidence lower bound (misspecified, inid).** P₀( ∫ e^{−ωn(R̂ₙ(θ) − R̂ₙ(θ\*))}Π(dθ) ≥ e^{−Cnωε²} ) → 1. | Medium. Syring–Martin Lemma 1 plus L2–L5. |
| L7 | **Two-level sieve (Talagrand).** For 𝔅ₙ = θ\* + span(N) + S(A_ε + R₂B₂ + R₁B₁), with R₂ = (Cnωε²)^{1/2}/λ and R₁ = Cnωε²/λ: Π(𝔅ₙᶜ) ≤ e^{−C′nωε²}. | **Medium-low, largely transferable.** In falling-factorial coordinates our prior is a (finite-dimensional, scaled) p = 1 exponential measure. Agapiou, Dashti & Helin (2021), Proposition 2.15, give exactly μ(A + r^{1/2}B_Q + rB_Z) ≥ 1 − e^{−r/K}/μ(A) (Talagrand's two-level inequality). Their Theorem 3.1 turns "concentration function ≤ nε²" into the sieve and prior-mass conditions; their Theorem 2.13 is the shifted small-ball bound (our L4). |
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
| R8. The L3 Laplace step resists off-the-shelf results (raised by T-04). | The summation operator's singular basis destroys the independence of the Laplace coordinates, so weighted-iid small-deviation theorems do not apply. | Route via the Laplace-as-Gaussian-scale-mixture comparison, or a direct grid argument. The fallback is A′. |

**Proof architecture after T-04.**
- Likelihood side: Atchadé's (2017) pathwise good-event / peeling structure, with Knight's identity for the check loss.
- Prior side: ADH's p = 1 concentration, plus Bach & Klein's proper-ization of the polynomial part and their Demmler–Reinsch spectral bounds.

See `theory/T04_Template_Sweep/SHORTLIST.md`.

**Global kill criterion for the n^{−3/4} programme:** R1 fires, or neither L7 nor any alternative sieve gives matching entropy within two weeks. In either case the deliverable becomes Theorem A′ (n^{−2/3}), which is still new according to T-01.

---

**Effect of the reference library (`literature/READING_LIST.md`) on the plan.** The prior side of Theorem A is largely the p = 1 case of the Agapiou–Dashti–Helin framework, transplanted to falling-factorial coordinates:
- concentration function = shift cost (L4) + small-ball (L3);
- sieve = Proposition 2.15 (L7);
- prior-mass and sieve conditions = their Theorem 3.1.

The remaining small-ball step L3 has a classical Gaussian, continuous counterpart (Fill & Torcaso; Chen & Li).

The genuinely new work is therefore concentrated on the **likelihood side**: the misspecified check loss (L6, L8) and the moment-free far-region argument (L9). Ghosal & van der Vaart (2007) is the template for the independent, non-identical structure. Castillo et al. (2015, Theorem 7) is the template for the conjectured sharpness remark.

## 8. Revision after review (supersedes §0 items 1–3, the bias column of §5, and §6)

Both reviews are in `reviews/`. The CEO's combined list of required changes and decisions has items A1–A4, B5–B6 and C7–C9. The current statement is `STATEMENT_DRAFT.md` v2.

### 8.1 The bias law: the VP's n^{−5/6} claim (C7)

**(a) Repeat of the VP's check, at larger n.** The setup is exact Park–Casella Gibbs with a Laplace prior, a Gaussian likelihood (κ = 16) and noiseless data. The truth is the kinked piecewise quadratic PQ (V = 26). All solves are done in long double, which reaches λ ≈ 10⁹ (`scratch/vp_bias_check*.out`, `spline_bias_scaling.out`).

| n | a = 2.00 | a = 2.25 | a = 2.50 | a = 2.67 |
|---|---|---|---|---|
| 300 | 1.004 | 1.002 | 1.001 | 1.000 |
| 600 | 1.005 | 1.001 | 1.000 | 1.000 |
| 1200 | 1.000 | 1.004 | n/a | n/a |
| 2400 | 1.005 | 0.995 | n/a | n/a |

*Entries: Laplace posterior-mean bias² ÷ smoothing-spline bias² (a Gaussian prior with the same variance), at λ = n^a. "n/a" means numerically infeasible even in long double.*

- **The VP's mechanism is supported.** This table came from Theory's own MCMC, now retired. The same conclusion is now established on the company sampler by the E-02 Gaussian-twin arm (§8.1a′, E-04 passed). For kinks below the threshold J ≲ n²λ^{−2/3}, the Laplace posterior mean *is* the linear (spline) smoother. The actual bias² is 2–3 orders of magnitude below the draft's ℓ₁-shift bound in every cell.
- **The asymptotic slope at a ≥ 5/2 is not observable at n ≤ 5000.** Along λ = n^a, the spline bias² has local slopes:
  - at a = 2: −2.6, −2.2, −1.2, −1.4, −1.8 over n = 600 to 19200, approaching the VP's −5/3;
  - at a = 2.5: about −0.4, between the draft's −0.5 and the VP's −0.83;
  - at a = 2.67: about −0.05.

  The kernel width w/n ≈ (λ²/κ)^{1/6}/n is still about 15% of the domain at a = 2.5, n = 4800, so the bias is near its saturation value. The VP's asymptotic law (the classical linear-smoother bias of a θ″-kink, J²(w/n)⁵ with w ≍ (λ²/κ)^{1/6}) applies only once w/n ≪ the knot spacing, i.e. n ≳ 10⁵ at a = 5/2.
- **Consequence for E-02, with a correction.** The saturation caveat applies to the *raw* scale λ = n^a. On Engineering's **calibrated grid** (λσ₀ = 2000·(n/500)^a, κ = 4), the kernel width at a = 5/2 and n = 32k is w/n ≈ 0.02, which is the asymptotic regime. So the calibrated PQ arm (a ∈ {9/4, 2.4, 5/2, 2.6, 8/3}) can discriminate after all. The tests are the slope of centre bias² in n (5a/3 − 5 vs a − 3), the risk-minimizing a, and the Gaussian-twin ratios. On the raw grid, the a = 5/2 and 8/3 runs may not separate n^{−5/6} from the draft's law cleanly. At practical n the risk is still lowest near a = 2–9/4 (risk proxy at n = 4800: 1.4e−4 at a = 2, 1.2e−4 at a = 9/4, 6.8e−4 at a = 5/2). **This is a finite-n statement and does not contradict n^{−5/6}.**

**(b) Is an ADH-type quadratic shift inequality available?** **Not off the shelf.** ADH's Proposition 2.11 gives the shift loss exponential in the Z-norm (ℓ₁ for p = 1), and they note that for p ≠ 2 the loss is not in the Hilbert norm Q. A new lemma L4q is needed. A plausible route:
1. Symmetrize over ±h. Using AM–GM, ½[Π(h+B) + Π(−h+B)] ≥ Π(B)·E_{Π\|B} exp{−λΣⱼ(\|hⱼ\| − \|uⱼ\|)₊}.
2. Under the (log-concave) conditional marginals, E(\|h\| − \|u\|)₊ ≈ λh²/2 for \|h\| ≪ 1/λ.
3. That gives a cost of ≈ λ²‖h‖₂²/2, provided the conditioning on the small-ball set B does not inflate the near-zero density of individual uⱼ (B constrains only about J_eff of the m directions).

> **L4q in one line (the point Felipe's gate turns on).**
> - **What it needs:** for symmetric convex small-ball sets B and shifts h with ‖h‖∞ ≤ 1/λ, Π_λ(h + B) ≥ exp(−Cλ²‖h‖₂²)·Π_λ(B).
> - **Why it is plausible:**
>   1. On average a Laplace shift costs only quadratically: KL(Laplace(h, λ) ‖ Laplace(0, λ)) = λ\|h\| + e^{−λ\|h\|} − 1 ≈ λ²h²/2 for \|h\| ≪ 1/λ.
>   2. Symmetrizing over ±h (AM–GM) reduces the lemma to bounding the near-zero density of individual uⱼ under Π_λ conditioned on B, and B constrains only about J_eff ≪ m directions.
>   3. Empirically, the Laplace posterior mean equals the Gaussian-twin (spline) posterior mean to within 0.5% (§8.1a).

**(c) Decision.** I **adopt the VP's min form** as the target statement:
- the **primary rate** is n^{−5/6} at λ ≍ n^{5/2}/V, conditional on L4q;
- the **fallback** is the draft's n^{−3/4}, via L4 alone, using the same likelihood-side lemmas.

Both are in STATEMENT v2. The evidence for the primary version is (a) above together with classical spline-smoother bias theory; the evidence that it remains open is L4q itself.

**Revised rate table** (fixed σ, V ≍ 1, λ = n^a):

| a | ε² (primary, min form) | ε² (fallback, ℓ₁ shift) |
|---|---|---|
| 2 | n^{−2/3} | n^{−2/3} |
| 15/7 | n^{−5/7} | n^{−5/7} |
| 9/4 | n^{−3/4} | **n^{−3/4}** (best fallback) |
| **5/2** | **n^{−5/6}** (best) | n^{−1/2} |
| 8/3 | n^{−5/9} | n^{−1/3} |
| 3 | inconsistent | inconsistent |

**What E-02 will show for the bias law** (agreed with Engineering; CC HQ). A paired **Gaussian-twin** arm: the same exact Gibbs sampler with the scale latents frozen at tⱼ ≡ 2/λ². Settings: sin and PQ, κ = 16, a ∈ {2, 9/4, 5/2, 8/3}, n up to 32k. It reports Laplace÷twin ratios for bias², rough spread and Δ² risk.
- **Prediction:** all ratios ≈ 1 (within about 5%). That establishes the linear-smoother mechanism, from which n^{−5/6} follows by classical theory, without needing the asymptotic slope.
- **Falsifier:** a bias ratio that grows with λ points to the ℓ₁ law, i.e. the fallback.
- **Secondary test:** the slope of the learned-λ λ̄ in n (2.5 vs 2.25) and the PQ/sin ratio (≈ 6 vs 3.8).

### 8.1b σ: Theorem A is the milestone, Theorem A⁺ covers the paper's practice

The Fubini (integrated-likelihood-ratio) route works **exactly** for σ ≥ σ̄ := τ(1−τ)/f.
- **Derivation.** The check-loss increment is X = (1−τ)δ − clip(Z, 0, δ), with E e^{−ωX} = e^{−ω(1−τ)δ}[1 + ∫₀^δ ωe^{ωs}(1 − F(s)) ds]. Expanding at δ = 0 gives a coefficient of ½(ω²τ(1−τ) − ωf)δ², so the threshold is ω̄ = f/(τ(1−τ)).
- **Sharpness.** It is sharp: numerically, ω̄(Δ) equals the local value for every Δ tested (`scratch/omega_bar_exact.out`).
- **Gap to the paper's regime.** The paper uses σ = σ₀ = E ρ_τ(ε − q_τ). The gap ratio R = σ̄/σ₀ = τ(1−τ)/(f(q)σ₀) is:

| Noise | τ = 0.50 | τ = 0.75 | τ = 0.90 | τ = 0.95 |
|---|---|---|---|---|
| Gaussian | **1.571** (π/2) | 1.857 | 2.922 | **4.466** |
| Laplace (correctly specified ALD) | 1.000 | | | |
| t₃ | 1.234 | | | |
| t₂ | 1.000 | | | |
| Uniform | 2.000 | | | |
| 0.9 N(0, 0.1²) + 0.1 N(0, 3²) | **0.446** | | | |

**Framing.**
- Extreme quantiles are a headline use case of the paper, and the gap is largest there (R ≈ 4.5 at τ = 0.95 under Gaussian noise).
- **Theorem A⁺ (every fixed σ) is therefore the theorem that covers the paper's practice.** Its plan is the realized-numerator analysis in STATEMENT v2.1: a Knight score term with entropy on a coarse net, valid for any ω once M is large; the fine part integrated against the prior; and the remainder chained across scales.
- **Theorem A (σ ≥ σ̄) is the first milestone.** It covers the paper's σ₀ only when R ≤ 1, i.e. for noise sharply peaked at the quantile.

### 8.1c Provenance of the numerical evidence (HQ rule, 2026-11-22)

**Rule.** Every E-02 number was **provisional** until Engineering's sampler check **E-04** marked the Gibbs sampler "fit". **Update: E-04 passed** (`Engineering/E04_Sampler_Check/REPORT.md`). E-02 numbers now count as evidence, with two qualifiers: (i) runs before the clamp-free fix used latent safety clamps, measured at ≤ 2% on Δ², centre and λ‖Dθ‖₁/m and −1 to −1.8% on rough spread, which is immaterial for slopes; (ii) the learned-λ sin cells at b₀ ∈ {n⁻², n^{−5/2}}, n = 8k (ESS ≈ 8 per 10k) stay flagged as provisional-quality. Theory's own MCMC code is held to the same standard. The table below gives the source of each piece of evidence and its status.

| Evidence | Source and method | Sampler? | Status |
|---|---|---|---|
| Falling-factorial identity, column norms | `ff_basis_check.py`; linear algebra | none | exact |
| Spread law, Gaussian analogue (λ^{−1/3}, κ^{−5/6}) | `spread_gaussian_analog.py`; closed-form posterior covariance spectrum | none | exact, up to the eigenvalue approximation |
| Small-ball exponent 2/5 and the collapse in n^{5/2}/(λε) | `small_ball*.py`; Gaussian saddle point with exact spectrum | none | exact asymptotics; deterministic numerics |
| Laplace vs Gaussian small-ball probabilities | `small_ball.py` part B; plain i.i.d. Monte Carlo | **no MCMC** (direct sampling) | reliable |
| Exact σ̄ and the gap ratios R | `omega_bar_exact.py`; quadrature of the exact MGF | none | exact |
| P&C Lemma 19 counterexample | `padilla_lemma19_check.py`; linear algebra | none | exact |
| Noiseless MAP bias (k = 2 trend filtering) | `map_bias.py`; ADMM with KKT residual reported | optimizer | reliable where KKT < 1e−5 |
| Spline (Gaussian-twin) bias along λ = n^a | `spline_bias_scaling.py`; long-double banded solve | none | exact, where Cholesky succeeds |
| Laplace-prior posterior spread (Gaussian likelihood; slopes −0.335 to −0.347) | `laplace_gibbs_spread.py`, `laplace_gibbs_bigJ.py`; **Theory's own Park–Casella Gibbs**, banded Cholesky | **own MCMC** | **provisional**, pending the grid validation below. Large-λ cells with a binding cap are already excluded. |
| Laplace posterior-mean bias = spline bias (ratios 0.995–1.005) | `vp_bias_check.py`; **Theory's own Park–Casella Gibbs**, long-double Cholesky, Rao-Blackwellised mean | **own MCMC** | **superseded**: not used as evidence; replaced by the company-sampler table §8.1a″ (0.996–1.013) |
| Virial ratio λ‖Dθ‖₁/m and the λ fixed-point formula | own Gibbs (above), plus the paper's reported λ for Gamma(1, 1) | own MCMC, plus the paper | **superseded** by E-02 (company sampler; §8.1d), plus the paper's independent value |
| ALD spread law (T3lam: slopes −0.37/−0.34, C = 0.28–0.35) | **E-02**, Engineering's exact Gibbs (z-augmentation, scale mixture, banded-QR perturb-and-solve) | **E-02 sampler** | **evidence (E-04 passed); was provisional until E-04 passes** |
| Learned-λ smoke test (λ ≈ 60 for b₀ = 1) | E-02 sampler; the paper's own report (50–75) | E-02 and paper | the paper's figure is independent; the E-02 figure is evidence (E-04 passed) |

**Validation of Theory's own Gibbs sampler.** `scratch/gibbs_validation_grid.py` compares it against **exact 3-D numerical integration** at n = 6. The flat quadratic coefficients are integrated analytically, and the posterior mean and variance of each θᵢ are compared, with batch-means z-scores. **First result** (`gibbs_validation_grid.out`; seed 42; 195k draws; λ = 6, κ = 16).
- **Variances agree** to within 0.5–5% (ratios 1.005–1.048).
- **The means disagree significantly.** Batch-means z-scores are −4.1, 4.5, 5.7, −2.1, −9.7 and 9.6, an absolute difference of about 0.002–0.006 against posterior standard deviations of about 0.17–0.24.

**Status: Theory's Gibbs is NOT yet validated.** The discrepancy is small in absolute terms (≤ 3% of a posterior sd), but significant. There are three candidate causes: underestimated Monte Carlo standard errors (slow mixing of the scale latents), grid error, or a sampler defect.

A follow-up (`gibbs_validation_grid2.py`) separates them, using a Gaussian-twin control with a closed-form posterior, a second seed with a 400k chain and ESS-based standard errors, and a finer grid. `owls_run` refused for budget, so it has been sent to Engineering to run on NOTS with E-04.

**Follow-up result** (`gibbs_validation_grid2.py`, run by Engineering on NOTS, job 2857080, commit 8ba6ed2).
- **(a) The Gaussian-twin control passes:** |z| ≤ 1.8 and variance ratios 0.99–1.01. So the Gibbs machinery and the banded Gaussian draw are correct.
- **(c) The exact reference is not converged.** Refining the grid (du 0.01 → 0.005, window 1.2 → 0.9) moves the "exact" means by 0.005–0.014. That is the same size as the Laplace discrepancies, and the smaller window truncates support.
- **(b) The pieces line up against the coarser, wider grid.** The Laplace minus fine-grid differences (−0.009, 0.011, 0.012, −0.006, −0.020, 0.012) are almost exactly cancelled by the grid change. Gibbs minus the coarse, wider grid is 0.001–0.006, matching run 1.
- **Verdict: inconclusive, a reference error rather than a sampler error.** There is no evidence of a defect. Since the sampler is retired (HQ decision) and E-02's Gaussian-twin arm now carries the evidence, it is not pursued further. A converged reference would need a rotated-coordinate grid at the 1/λ scale, the approach of Engineering's E-04 part A3.

**The two own-MCMC rows in the table above are not used as evidence.** The bias-equivalence claim (Laplace mean = spline) then rests on E-02's Gaussian-twin arm, itself subject to E-04, and on the VP's independent n = 300 check. Note that a mean bias of ≤ 3% of a posterior sd could not overturn a ratio of 1.000 ± 0.005 on *bias²* of order 10⁻³–10⁻⁶.

**HQ decision (2026-11-22).** The company uses **one MCMC sampler for theory numerics: Engineering's**, once E-04 marks it fit.
- **Theory's own Gibbs is retired.** It will not be used for evidence unless the diagnosis shows it is correct *and* it is needed for something Engineering's sampler cannot do.
- **The bias-equivalence check is being rerun** on Engineering's sampler, through Engineering on NOTS, within the E-02 ceiling: the noiseless PQ table of §8.1a plus the paired Gaussian-twin arm.
- **Update:** E-04 has passed, and the E-02 Gaussian-twin arm (§8.1a′) now provides this support on the company sampler: kinked-truth Laplace ÷ twin = 1.00 ± 0.02. **The numerical support for the n^{−5/6} mechanism is therefore evidence.** The rate itself remains conditional on L4q. The noiseless rerun of §8.1a is now optional.

**Conclusions that rest only on exact or deterministic computations.** The small-ball exponent, the Gaussian-analogue spread law, σ̄ and R, the Lemma 19 correction, and the spline-bias scaling. These stand regardless of the sampler checks.

### 8.1a″ Bias-equivalence table on the company sampler (E-04 passed)

*Source: Engineering, `Engineering/E02_Rate_Sims/bias_equiv.R`. Setup: Gaussian likelihood with κ = 16, noiseless y = θ\* (PQ), frozen-λ Laplace posterior, Rao-Blackwellised mean. This replaces the own-MCMC table of §8.1a.*

Each entry is the Laplace posterior-mean bias² divided by the spline bias²:

| a \ n | 300 | 600 | 1200 | 2400 |
|---|---|---|---|---|
| 2 | 1.013 | 1.011 | 1.008 | 1.004 |
| 9/4 | 1.003 | 1.000 | 1.001 | 0.9997 |
| 5/2 | 1.000 | 0.9996 | 0.9968 | 0.9960 |
| 8/3 | 0.9999 | 1.000 | 0.9998 | 0.9997 |

- **All 16 cells lie in 0.996–1.013**, covering w/n from 0.047 to 0.33, with λ‖Dθ‖₁/m = 0.993–1.007.
- The small excess at a = 2 is Monte Carlo noise relative to a tiny bias² (10⁻⁶ to 10⁻⁴).
- Together with the noisy-data Gaussian-twin ratios of §8.1a′, this **establishes the linear-smoother mechanism for kinked truths on the company sampler**.

### 8.1a′ Gaussian-twin ratios at E-02 scale (evidence: E-04 passed; produced with the safety clamps, effect ≤ 2%)

*Source: Engineering's sampler, phase "twin". Setup: N(0, 0.25²), τ = 0.5, σ = σ₀, λ = n^a, n ∈ {1k, 4k, 16k}, 10 paired seeds. Each entry is the Laplace ÷ Gaussian-twin ratio, with paired-bootstrap 95% CIs.*

**Kinked truth (PQT, V = 26): the ratio is ≈ 1 everywhere.**
- Bias² ratio, at n = 1k / 4k / 16k:

  | a | n = 1k | n = 4k | n = 16k |
  |---|---|---|---|
  | 2 | 0.995 | 1.003 | 0.990 |
  | 9/4 | 1.003 | 0.998 | 0.981 [0.965, 0.997] |
  | 5/2 | 0.999 | 0.995 | 0.999 |
  | 8/3 | 1.001 | 0.999 | 0.998 |

- Total Δ² and MSE ratios: 0.992–1.003.
- Rough-spread ratio: 0.999–1.046.
- λ‖Dθ‖₁/m: 0.997–1.006.
- This holds across kernel widths w/n from 0.025 to 0.29. It is exactly the VP's mechanism: for kinks, the Laplace posterior behaves like its Gaussian twin, whose posterior mean is the linear smoother. That is the numerical basis for the primary rate n^{−5/6}, and it now comes from the company sampler rather than Theory's retired one, still pending E-04.

**Smooth truth (sin, V = 157): ≈ 1 except in the bias-dominated corner.**
- In the many-mode regime the ratio is ≈ 1: at a = 2, bias² 0.99–1.01; at a = 9/4, bias² 0.82 → 0.98 → 1.00 as n grows.
- Where λ‖Dθ‖₁/m ≫ 1 (a ≥ 5/2, saturated, w/n ≥ 0.13), the Laplace posterior has **15–52% less bias²** than its twin, at the price of 1.15–2.5× the rough spread. This is ℓ₁ adaptivity.
- This is consistent with Theorem A, which is an *upper* bound with a min over the quadratic and ℓ₁ shift costs: Laplace never does worse than the twin on bias.

**The slope test** (the calibrated kinked arm, a ∈ {9/4, 2.4, 7/3, 5/2, 2.6, 8/3}, n to 32k) is still running.

### 8.1e Calibrated kinked-truth slopes: the bias law is decided (E-04 passed)

*Source: Engineering. Setup: pq truth, λσ₀ = 2000·(n/500)^a, N(0, 0.5²) so κ = 4, τ = 0.5, 20 reps per cell, n = 250…32k. Slopes are fitted over n ≥ 2k, with paired-bootstrap 95% CIs. Every cell is in the asymptotic regime: n·λ^{−1/3} ≥ 19 and w/n ≤ 0.04.*

**Bias law.** The slope of the spline bias² in n equals the posterior bias² slope, by the equivalence tables (§8.1a′, §8.1a″):

| a | 9/4 | 2.4 | 5/2 | 2.6 | 8/3 |
|---|---|---|---|---|---|
| observed | **−1.247** | **−1.007** | **−0.851** | **−0.704** | **−0.602** |
| VP law (5a/3 − 5) | −1.250 | −1.000 | −0.833 | −0.667 | −0.556 |
| ℓ₁ law (a − 3) | −0.750 | −0.600 | −0.500 | −0.400 | −0.333 |

**The VP law is confirmed and the ℓ₁ law is excluded at every a.** There is a slight excess at the largest a, as w/n grows.

**Spread along λ = c·n^a (P1).** The rough-spread slopes are −0.734, −0.785, −0.762, −0.819, −0.854 and −0.876, within 0.016 of −a/3 at every a.

**MAP versus posterior.** At 15/7 the MAP beats the posterior: −0.90 against −0.69, while P4 predicted −0.857 against −0.714.

**What is not identifiable.** The risk-minimizing a cannot be identified in this window. Bias stays 2–4 orders of magnitude below variance up to n = 32k, so a = 3 has the lowest risk empirically. The n^{−5/6} optimum at a = 5/2 instead follows from the confirmed bias law together with P1. A direct risk-minimizer test would need a larger-V or lower-noise kinked truth; it is optional.

**Net (numerical side of C7).** All three pieces point the same way:
- the mechanism: Gaussian-twin ratio ≈ 1, and bias equivalence ≈ 1;
- the bias slope, which matches the VP law and excludes the ℓ₁ law;
- the spread law along λ = c·n^a.

**The primary rate n^{−5/6} at λ ≍ n^{5/2}/V is numerically supported.** Theoretically it rests on L4q, now drafted in `theory/T05_Proofs/L4q_quadratic_shift.md`: it is proved conditional on L3 and on λε ≳ n^{10/7}, and is under independent check.

### 8.1d Learned λ: the fixed-point formula holds, but it is not a bias-law test

*Source: E-02 lamlearn, lamlearn2 and lamlearn3 (Engineering's sampler). Evidence since E-04 passed, except the flagged low-ESS sin cells at n = 8k.*

**The fixed-point formula** λ ≈ (0.27·n·κ^{1/6}/b₀)^{3/4} **is confirmed quantitatively by the E-02 numbers below (E-04 passed).** The independent confirmation is the paper's own Gamma(1, 1) value.
- **Quadratic truth, κ = 4, b₀ = n⁻²:**
  - predicted λ ≈ 5.3×10⁵, 1.2×10⁷ and 2.7×10⁸ at n = 500, 2k and 8k; observed medians 4.35×10⁵, 1.16×10⁷ and 2.45×10⁸ (ratios 0.82, 0.97, 0.90);
  - slope 2.257 [2.233, 2.278] against a predicted 9/4;
  - the same λ̄ (within 2%) from λ₀ = m and from λ₀ = 0.3·n^{9/4}, with ESS(log λ) 536–1310;
  - λ‖Dθ‖₁/m = 0.998–1.000, against a predicted ≈ 0.995+.
- **sin and PQ at b₀ = 1 and 10⁻³:** slope 0.745–0.754, with λ̄ ≈ 60 and 1.0×10⁴ at n = 500, as predicted. The paper's own Gamma(1, 1) value (50–75) is independent confirmation.

**The learned-λ λ̄ does not discriminate the bias law** (this corrects §5 and my earlier heuristic). The Gamma conditional sees λE‖Dθ‖₁ = m − L, i.e. the ℓ₁ norm of the draws, not bias².
- **Kinked truth.** A kink coefficient |u\*ⱼ| ≈ J/n² is far above the prior scale 1/λ (≈ 10⁻⁷ against 10⁻⁹ at n = 8k), so the draws carry it at full ℓ₁ cost. Then λ̄ ∝ (n³/V)^{3/4} whatever the bias law. Observed at b₀ = n^{−5/2}: PQ slope 2.13 [2.03, 2.27], and the PQ/sin ratio falls to 3.7 [3.1, 4.4] at n = 8k, against an ℓ₁ prediction of 3.8.
- **Smooth truth.** The entries |u\*ⱼ| ≈ V/n³ are dense and ≪ 1/λ, so they cost only quadratically (E\|u\* + v\| − E\|v\| ≈ λu\*²/2) and the self-tuned λ grows faster. Observed sin slope 2.49 [2.45, 2.54]; its n = 8k cells mix poorly.
- **The bias law** is decided only by the Gaussian-twin ratios and the calibrated PQ centre-bias slopes (§8.1a).

**Stage-C consequence.** With learned λ and b₀,ₙ ↓ 0, *kinked* truths self-tune to λ ≍ (n³/V)^{3/4} ≈ n^{9/4}. At that λ the rate is spread-limited at n^{−3/4}, **even if the oracle rate is n^{−5/6}**. Smooth truths self-tune higher and can do better. A Stage-C theorem should therefore target n^{−3/4} uniformly over the BV class, with n^{−5/6} at the oracle tuning only. This is a natural split between "learned" and "oracle" statements.

### 8.2 Other required changes, and where each is made

| Item | Change | Where |
|---|---|---|
| A1 | L8 withdrawn. Two replacement routes: L8-a (Fubini-integrated numerator on a sup-norm-bounded set; small-ω milestone) and L8-b (in-probability uniform bounds over nested structured sieves, chained across scales below ε, inside an Atchadé-type peeling over shells; any σ). L7's fine-scale set A_ε becomes a multiscale small-ball set. **Atchadé fits as the outer peeling structure of L8-b, not as a replacement for the chaining.** | STATEMENT v2; `REVISION_L6_L10.md` |
| A2 | Proper Π_λ on u = Dθ, centred at u\* via L4. The flat c is integrated identically in N(B) and N(ℝⁿ). "Π(𝔅ᶜ)" now refers to Π_λ only. | STATEMENT v2 |
| A3 | L9 split into L9-a ({Δ² > K}: convexity and log-concavity, moment-free), the shells Mε² < Δ² ≤ K (L8), and L9-c (sieve complement, with an explicit integrated-numerator bound). | STATEMENT v2 |
| A4 | Dropped ‖θ\*‖∞ ≤ B, the "necessary" language and the lower-bound claims (now a conjecture). Knots: one remark. Corollary A2 uses P&C's exact tuning, λσ = c n^{15/7}(log n)^{1/7}. L2 is stated globally. κ = f/σ is explicit. "+n⁻¹" dropped. A polylog factor inside ε² with a fixed large M (no Mₙ). | STATEMENT v2 |
| B5 | **No σ restriction** in Theorem A, as decided. Small ω appears only as the L8-a milestone. The VP's π/2 computation confirms that the MGF route would exclude the paper's own σ₀ regime. | STATEMENT v2 |
| B6 | Primary: oracle tuning, uniform over 𝒫ₙ. Target: also uniform over the λ-window, as Stage B needs. | STATEMENT v2 |
| C8 | **P&C Lemma 19 is off by n^{r−1}, verified** (`scratch/padilla_lemma19_check.out`). max\|pinv(D³)\| ≈ 0.017n². For a single kink, ‖P_R δ‖∞ = 0.0155 at every n, while the printed bound C·TV/n² → 0. The correct bound is ‖P_R δ‖∞ ≲ TV⁽³⁾(δ). This is harmless for P&C (V = O(1)) but not for us.<br>**L10 is now essential.** Its route is the interpolation bound ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}TV^{1/5}: the exponent 4/5 is forced by scaling; the discrete version is to be proved.<br>**a₀:** with the two-level sieve's ℓ₁ radius n³ε²/λ and ε² ≈ λ^{−1/3}, sup-norm control holds when λ ≳ n^{3/2} (a₀ = 3/2, as the VP suggests). With the draws' full TV ≍ n³/λ it needs λ ≳ n^{9/5} (conservative a₀). Both lie below both optima.<br>**A′ (TV-ball sieve) is no longer the fallback.** With the corrected Lemma 19 it is not lower-risk. The fallback is now A-fb (ℓ₁ shift). | STATEMENT v2 |
| C9 | **b₀ under the surviving law.** For λ\* ≍ n^{5/2}/V, the fixed point λb₀ ≈ a₀ + Lₙ(λ) needs b₀ ≲ J_eff(λ\*)/λ\* ≍ V^{4/3}n^{−7/3}, matching the VP's n^{−7/3}. The necessary Gamma-cap scale becomes b₀ ≲ n/λ\* ≍ V·n^{−3/2}; the external advisor's n^{−5/4} was for λ ≍ n^{9/4}.<br>**Engineering's b₀ ~ n⁻² check** should show λ ≈ 0.45·n^{9/4} (b₀-limited), which is consistent with both laws. Reaching n^{5/2} needs b₀ ≲ n^{−7/3}.<br>Kept as a **Stage-B candidate.** The self-tuning heuristic (b₀ → 0 ⇒ λ settles at the bias ≈ spread balance) now points at n^{5/2}/V; still unproved. | §5 (Stage-C plan) is superseded on the exponent |

### 8.3 Responses to reviewers

**External advisor**

| # | Point | Response |
|---|---|---|
| 1 | L8 fails: the ε-ball fits the residual signs | **Accepted**; the counterexample is correct. Replaced by L8-a and L8-b (§8.2, A1). An explicit integrated-numerator bound outside the sieve is now L9-c. |
| 1 | L7 uses an infinite measure | **Accepted.** Proper Π_λ, centring at u\*, and identical integration of c (A2). |
| 1 | L3 needs an actual Laplace bound | **Accepted.** Still open; listed as doubt 4. The Gaussian half is classical. |
| 1 | A′ inherits the outside-sieve problem | **Accepted.** A′ is demoted (C8). |
| 2 | Upper margin; excess risk as the expectation of the loss difference; global forms | **Accepted.** (A2) is labelled sufficient; L2 is stated globally. |
| 2 | Drop the sup-norm bound in (A3); (A4) is not necessary | **Accepted.** |
| 2 | Shift-term tightness unknown; no power of σ; Corollary A2 needs the published tuning | **Accepted.** κ is carried explicitly, with no claimed σ-power beyond κ. Corollary A2 is restated. The shift term is now the min form, so tightness is moot for the primary version. |
| 3.1 | ALD runs test the spread | Agreed. Pending E-02. |
| 3.2 | Bounded-coordinate likelihood-ratio argument at small ω, plus a separate tail bound | **Adopted as the L8-a milestone and L10.** Per the CEO's decision (B5), not in the final statement. |
| 3.3 | No "pays n^{3/28}" without a lower bound | **Accepted.** It is now a conjecture. Under the min form the gap to the mode would be n^{1/42}. |
| 3.4 | Omit the knot-count rate | **Accepted.** One remark. |
| 3.5 | b₀ ≲ n^{−5/4} necessary; the n⁻² calibration is unproved | **Accepted.** Recomputed for λ\* ≍ n^{5/2}/V: the necessary scale is b₀ ≲ n^{−3/2}, the heuristic n^{−7/3}. Stage-B candidate. |
| 3.6 | Fixed radius; uniformity over the law class; oracle tuning first | **Accepted** as the primary version (B6). |
| Suggested theorem | sup over 𝒫ₙ at λₙ = (n³/V₀)^{3/4} | Adopted in spirit, with the oracle λₙ updated to n^{5/2}/V under the min form. The fallback keeps (n³/V)^{3/4}. |

**VP**

| § | Point | Response |
|---|---|---|
| 1 | The bias term is an L4 artefact; n^{−5/6} at n^{5/2} | **Largely accepted.** The mechanism is confirmed numerically (Laplace posterior mean = spline, ratios 0.995–1.005, n ≤ 2400). The asymptotic slope at a = 5/2 is not reachable at n ≲ 10⁵. L4q is new and unproved, hence the primary and fallback structure (§8.1). |
| 1 | "The posterior is slower" is a lower-bound claim | **Accepted.** Reworded; now a conjecture. |
| 1 | The s^{1/7}n^{−6/7} sparse upside is a property of the mode | **Accepted.** Removed. |
| 2 | Drop B; label (A2) as proof-driven; global L2; carry κ; drop +n⁻¹ | **Accepted**, all. |
| 3 | P&C Lemma 19 is off by n^{r−1}; A′ is not lower risk | **Verified and accepted** (C8). |
| 4 | L8 false; L9 reaches only a constant K; split it | **Accepted** (A1, A3). |
| 4 | Do not accept σ ≥ σ̄ (π/2) | **Accepted** (B5). Verified: f/(τ(1−τ)) = 1.596/s, against ω = 1/σ₀ = 2.507/s for Gaussian noise at τ = ½. |
| 4 | L10 essential; interpolation ‖·‖ₙ^{4/5}TV^{1/5} | **Accepted.** Route adopted; a₀ = 3/2 (two-level sieve) or 9/5 (conservative). |
| 4 | L5 is not the issue, normalization is; L4 needs a quadratic version | **Accepted.** L5 merged into the normalization; L4q added. |
| 5.1 | Read slopes only where nλ^{−1/3} ≳ 10 | Agreed; also passed to Engineering. |
| 5.2 | Sub-exponential noise is not a sufficient fallback | **Accepted.** That fallback is removed. |
| 5.3 | Positioning: "the posterior attains the linear-smoother rate" | **Adopted** for Corollary A1, conditional on L4q. |
| 5.5 | b₀ ≍ n^{−7/3} | **Consistent with** the fixed-point formula (heuristic; the fixed-point formula itself is confirmed by E-02, §8.1d). Stage-B candidate (C9). |
| 5.6 | Uniform over λ-window; fix c; polylog or Mₙ, not both; raise the lower window | **Accepted** (B6, A4, C8). |
| 6 | Suggested Theorem A | **Adopted** as the target statement in STATEMENT v2, with κ made explicit and the primary/fallback split. |

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
