# Stage-A theorem: draft statement for advisor review

*BQTF Theory Department, 2026-11-22. Statement only, with no proofs. Supporting calculations: `MEMO.md` §4–5 and `scratch/`.*

## Setting

- **Data.** Observations y₁, …, yₙ on the grid xᵢ = i/n. Fix a quantile level τ ∈ (0, 1). The target θ\* = (θ\*₁, …, θ\*ₙ) is the vector of true τ-quantiles, θ\*ᵢ = Fᵢ⁻¹(τ), where Fᵢ is the distribution function of yᵢ.
- **Posterior (Stage A).** σ > 0 is fixed and λ = λₙ is deterministic:

  Πₙ(dθ | y) ∝ exp{ −σ⁻¹ Σᵢ ρ_τ(yᵢ − θᵢ) − λₙ ‖D θ‖₁ } dθ on ℝⁿ.

  Here D = D⁽³⁾ ∈ ℝ^{(n−3)×n} is the third-difference operator (k = 2), and ρ_τ is the check loss. This is the paper's posterior with σ and λ held fixed, and with the latent z integrated out.
- **Equivalent basis form** (Tibshirani 2014, Lemma 2). θ = Hα with falling-factorial columns ‖h_j‖_{2,n} ≤ 1. The prior is flat on α₁, α₂, α₃ and iid Laplace(rate 2λₙ/n²) on α₄, …, αₙ.
- **Loss.** Padilla's Huber-type loss, Δ²ₙ(v) = n⁻¹ Σᵢ min{|vᵢ|, vᵢ²}.
- **Notation.** TV⁽³⁾(θ) := n²‖Dθ‖₁; ω := 1/σ. All probabilities and expectations are under the true law P₀; the ALD is a working likelihood only.

## Assumptions

| Label | Assumption | Why it is reasonable or checkable |
|---|---|---|
| **(A1) Design** | y₁, …, yₙ are independent, not necessarily identically distributed, on the equispaced grid. | This is the paper's setting. Padilla & Chatterjee use the same. |
| **(A2) Two-sided local margin** | There are constants L, f, f̄ > 0 such that for all n, all i and all \|δ\| ≤ L: f\|δ\| ≤ \|Fᵢ(θ\*ᵢ + δ) − Fᵢ(θ\*ᵢ)\| ≤ f̄\|δ\|. | The lower half is exactly Padilla's Assumption A: the quantile is identified and has a curvature margin. The upper half holds for any density bounded near the quantile. It is checkable for every noise law in our simulations: Gaussian, Beta, mixed normal, t and Cauchy. **No moment conditions are imposed.** |
| **(A3) Truth class** | TV⁽³⁾(θ\*) ≤ V\* and ‖θ\*‖∞ ≤ B, with V\* and B constants. Some θ\* may have discontinuities in θ″. | This is the bounded-variation class of Padilla's slow rate (r = 3) and of Tibshirani's F₂(C). It is the canonical class for trend filtering with k = 2. |
| **(A4) Tuning** | σ > 0 is a fixed constant. λₙ is deterministic with (log n)^{C₀} ≤ λₙ ≤ n³/(log n)^{C₀}. | λ ≪ n³ is necessary, since otherwise the bias is O(1). λ → ∞ is necessary, since otherwise the spread is O(1). The rate-optimal choice lies well inside the window. |

## Theorem A (posterior contraction in Δ²ₙ, σ and λ fixed)

Assume (A1)–(A4). There is a constant c ≥ 0 such that, for every sequence Mₙ → ∞,

  **E₀ Πₙ( Δ²ₙ(θ − θ\*) > Mₙ εₙ² | y ) → 0,** where **εₙ² = (log n)^c · [ λₙ^{−1/3} + λₙ V\* n^{−3} + n⁻¹ ].**

The constants depend on (τ, σ, L, f, f̄, B, V\*). The rate is uniform over the class in (A3).

**Corollary A1 (best rate).** With λₙ ≍ σ^{−1/8}(n³/V\*)^{3/4}, i.e. λₙ ≍ n^{9/4}:

  εₙ² ≍ V\*^{1/4} n^{−3/4} (log n)^c.

**Corollary A2 (frequentist tuning).** With λₙσ ≍ n^{15/7}, the MAP-optimal tuning of Tibshirani and of Padilla & Chatterjee:

  εₙ² ≍ n^{−5/7} (log n)^c.

The posterior mode attains n^{−6/7} at this tuning, so the full posterior is slower.

**Corollary A3 (average squared error, optional).** If, in addition, Πₙ(‖θ − θ\*‖∞ > C | y) → 0 (Lemma L10), then the same rate holds for n⁻¹‖θ − θ\*‖₂².

**Theorem A′ (fallback, lower risk).** The same conclusion holds with λₙ^{−1/3} replaced by λₙ^{−2/7}. Its best rate is n^{−2/3}, at λₙ ≍ n^{7/3}.

**Interpretation of the two rate terms.**
- λ^{−1/3} is the posterior **spread**. It does not depend on θ\*: the Laplace prior leaves about n·λ^{−1/3} rough directions unshrunk. This is checked numerically. With a Gaussian likelihood and the exact Laplace prior, the slope is −0.335 to −0.347 against the predicted −1/3, and the spread does not depend on n.
- λV\*n^{−3} is the **bias**, the shift cost of the truth. This is where the structure of θ\* enters.

## Lemmas Theorem A relies on

| Lemma | Statement | Difficulty |
|---|---|---|
| L1 Basis | θ = Hα. The prior is flat on α₁, α₂, α₃ and iid Laplace(2λ/n²) on the rest. ‖h_j‖_{2,n} ≤ 1. | Trivial; verified numerically. |
| L2 Excess risk | Under (A2), c₀Δ²ₙ(δ) ≤ n⁻¹M(θ\* + δ) ≤ (f̄/2)‖δ‖²ₙ when ‖δ‖∞ ≤ L. Also n⁻¹Σᵢ Var(ℓ_{θ\*+δ} − ℓ_{θ\*}) ≤ ‖δ‖²ₙ, where ℓ is the check loss. | Easy (Padilla Lemma 13). |
| L3 Small ball | Write θ = (quadratic part) + Su, with u ~ Laplace(λ)^{⊗(n−3)} and P⊥ the projection that removes the quadratic part. Then −log Π(‖P⊥Su‖ₙ ≤ ε) ≤ C (n^{5/2}/(λε))^{2/5} for (log n)/λ ≤ ε ≤ n^{5/2}/λ. | Medium. The Gaussian continuous analogue is classical (twice-integrated Brownian motion, exponent ε^{−2/5}; Chen & Li, Fill & Torcaso 2004). The grid and Laplace versions are verified numerically. |
| L4 Shift | Π(u\* + B) ≥ e^{−λ‖u\*‖₁}Π(B) for any set B. | Trivial. |
| L5 Improper part | The posterior is proper for n ≥ 4. The flat quadratic part costs O(log n) in the evidence bound. | Low–medium. |
| L6 Evidence lower bound (misspecified) | P₀( ∫ exp{−ω Σᵢ [ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)]} Π(dθ) ≥ e^{−C n εₙ²} ) → 1. | Medium. Syring–Martin Lemma 1 plus L2–L5. |
| L7 Sieve | Let A_ε = {u : ‖P⊥Su‖ₙ ≤ ε} (the small-ball set of L3), and let B₂ and B₁ be the unit ℓ₂ and ℓ₁ balls in ℝⁿ⁻³. Define the two-level set 𝔅ₙ = θ\* + {quadratics} + S(A_ε + R₂B₂ + R₁B₁), with R₂ ≍ (nεₙ²)^{1/2}/λ and R₁ ≍ nεₙ²/λ. Then Π(𝔅ₙᶜ) ≤ e^{−C′nεₙ²}. | Medium-low. This is Agapiou, Dashti & Helin (2021), Proposition 2.15 (Talagrand's two-level inequality, p = 1), applied in falling-factorial coordinates. Their Theorem 3.1 converts it into the sieve and prior-mass conditions. |
| L8 Uniform excess loss | With P₀-probability → 1, uniformly over θ ∈ 𝔅ₙ with Δ²ₙ(θ − θ\*) ≥ Mεₙ²: n⁻¹Σᵢ[ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)] ≥ ½c₀Δ²ₙ(θ − θ\*). This replaces Hellinger tests; its proof uses symmetrization, contraction and localized widths, as in Padilla's Theorem 7 and Proposition 2. | Medium–high. |
| L9 Far region | Πₙ(𝔅ₙᶜ ∪ {Δ²ₙ > Mεₙ²} | y) → 0 without MGF or moment bounds. It uses convexity of the empirical check risk and log-concavity of Πₙ. | **High. The key new step.** |
| L10 ℓ∞ control | Πₙ(‖θ − θ\*‖∞ > C | y) → 0. Needed only for Corollary A3. | Medium. |

Theorem A′ replaces L7 and L8 with a single TV-ball sieve, {TV⁽³⁾(θ − θ\*) ≲ n³/λ}, and Padilla's Proposition 2 width bound.

## Main open doubts (feedback especially welcome)

1. **The ALD spread law is not yet verified.** The λ^{−1/3} spread is confirmed only with a Gaussian likelihood. Engineering's E-02 runs, testing the actual ALD posterior, are due this week. If the spread slope differs, the n^{−3/4} statement falls back to Theorem A′.
2. **Lemma L9 (far region without moments).** This step is the main risk, and possibly the main contribution. It is not yet clear whether it needs σ large, i.e. the learning rate ω = 1/σ small, as the Gibbs-posterior MGF route does. If it does, (A4) gains the condition "σ ≥ σ̄(f, f̄, τ)". If heavy tails cannot be handled, the fallback adds a sub-exponential noise assumption.
3. **Sharpness and positioning.** We believe n^{−3/4} is the true posterior rate for this prior. We do not intend to prove a lower bound in Stage A, so it would appear as a remark. Is it acceptable to headline a theorem whose rate is *below* minimax (n^{−6/7})? The honest framing would be "the full posterior pays n^{3/28} relative to the mode".
4. **Fast-rate class not covered.** For piecewise quadratics with s knots, the theorem gives only s^{1/4}n^{−3/4}. Should it be stated at all?
5. **Relation to the paper's actual prior.** Stage A fixes σ and λ. With the paper's Gamma(1, b₀) prior and b₀ fixed, our heuristics give λ ≍ n^{3/4} and a rate of only about n^{−1/4}. Reaching the Stage-A rate adaptively appears to need b₀ ≲ n^{−2}. This affects how Stage B is framed.
6. **Smaller points.**
   - Should V\* be allowed to grow with n?
   - Should we state a pointwise or a uniform version?
   - The polylog power c is unknown.
   - The lower window could perhaps be raised to n ≤ λₙ if needed. That costs nothing at the optimum.
