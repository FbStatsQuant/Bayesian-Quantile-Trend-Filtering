# T-02 Feasibility read: Syring & Martin (2023) for the BQTF posterior

*Theory Department, 2026-11-22. Source: `Papers/Syring_Martin 2023.pdf` (arXiv v6), read in full myself: §2–4, §5.1, 5.4, 5.6, App. A–C (Lemmas 1–2; proofs of Props 1, 5, 8). Feasibility only. No proofs, sketches or plans.*

**The bridge.** At fixed σ our ALD posterior **is** their Gibbs posterior: exp{−σ⁻¹Σᵢρ_τ(yᵢ−θᵢ)}·π(θ) = e^{−ω n Rₙ(θ)}π(θ), with ω = 1/σ and Rₙ the empirical check risk. Their expected excess risk is m(θ,θ*) = n⁻¹ΣᵢMᵢ(θᵢ). This is Padilla's M/n, which Padilla's Lemma 13 bounds below by c₀Δ²ₙ(θ−θ*). Two parts of our model fall outside this bridge: the learned σ and the improper, unbounded prior.

## 1. Mapping, condition by condition

Each condition is classed as **holds** (as is), **adapt** (could plausibly be adapted), or **blocks**.

| Their condition | Where | Our setting | Status |
|---|---|---|---|
| iid data Uᵢ ~ P | Thms 3.2–3.5, 4.1 | Independent but not identically distributed, fixed grid, one observation per θᵢ | **Adapt.** They handle inid fixed design xᵢ = i/n themselves (Prop 5, §5.4). Lemma 1 (Chebyshev) and the Fubini/independence step for the numerator do not use identical distribution. |
| Parameter dimension | general; Prop 8 uses a random series with J ~ π | θ ∈ ℝⁿ, dimension = sample size; m and v are coordinate averages | **Holds** in form; the divergence may depend on n (§3.1). |
| **Condition 1** (global MGF bound) | Thms 3.2–3.5 | Check loss | **Blocks.** The authors state it fails for the check loss: the Bernstein exponent degrades where \|θᵢ−θᵢ*\| is large (§3.2.1, §4.1). |
| **Condition 2** (MGF bound on a sieve Θₙ = {‖θ‖∞ ≤ Δₙ}) | Thm 4.1, Prop 8 | The excess check loss is 1-Lipschitz per coordinate, so it is bounded on Θₙ. Their computation gives m ≳ Δₙ⁻²‖θ−θ*‖², so Kₙ ∝ Δₙ⁻² if ωₙΔₙ = O(1). | **Holds on a sieve.** Their margin m ≳ Δₙ⁻²‖·‖² is a sieve version of Padilla's Huber margin (Lemmas 13, 17). Δ²ₙ is the natural divergence for us. |
| Divergence / loss | L²(P) (Prop 8); empirical L² (Prop 5) | Padilla's Δ²ₙ (Huber), equivalent to the excess risk | **Adapt.** Theorem 3.2 and its relatives allow any d satisfying the MGF condition. |
| Moments | Prop 1: one finite moment of Y; Prop 8: none (Koltchinskii form of the loss) | Padilla's Assumption A: no moments | **Holds.** The excess loss ℓ_θ − ℓ_θ* needs no moments (Padilla's Remark 11 makes the same point). |
| Density condition | Assump. 8(3): conditional density continuous, ≥ β on (θ*(x)±δ) | Assumption A: linear CDF growth, uniform in i | **Holds/adapt.** Assumption A is slightly weaker, but it is exactly what the m-lower bound uses (eq. (66) in their proof of Prop 8). |
| **Learning rate** | Thm 3.2: fixed ω < ω̄; Thm 3.4: deterministic ωₙ; Thm 3.5: data-driven ω̂ₙ ∈ (ωₙ/2, ωₙ), the same for all θ; Prop 8: ωₙ = cΔₙ⁻² → 0 | σ ~ IG and integrated out. The σ⁻ⁿ factor gives the θ-marginal ∝ (b_σ + nRₙ(θ))^{−(n+a_σ)}, i.e. exp{−(n+a_σ) log(b_σ+nRₙ(θ))}. Locally this behaves like ω̂ ≈ 1/Rₙ(θ) ≈ 1/σ₀, with σ₀ = mean check loss, the same σ₀ as in Sriram et al. (2013, §6). | **Blocks as is.** The effective ω is (i) O(1), not vanishing, and not guaranteed below their distribution-dependent ω̄; (ii) θ-dependent, through a log-transformed risk rather than a plug-in. Even at fixed σ, Thm 3.2 needs 1/σ < ω̄. Adaptation is plausible but non-trivial. |
| **Prior mass** (12)/(14)/(21): log Π{m ∨ v ≤ εʳ} ≳ −C n ω εʳ | all theorems | Small-ball mass of {n⁻¹‖θ−θ*‖² ≲ ε²} under the λ-marginal prior ∝ (b₀+‖D⁽³⁾θ‖₁)^{−(a₀+m)}. Only the marginal prior enters, so the Gamma hyperprior is allowed in principle. | **Adapt, but uncomputed.** Nobody has computed this (T-01, gaps 2–3), and it decides the rate. |
| Π a probability measure | Lemma 1 (Π(Gₙ)) | Flat (improper) on the null space of D (quadratics) | **Blocks as is.** A 3-dimensional nuisance part, so plausibly adaptable. |
| Sieve remainder (22): PⁿΠₙ(Θₙᶜ) → 0 | Thm 4.1 | They meet it by giving the prior support inside Θₙ (Prop 8), or by Lemma 2 (convexity, via Hjort–Pollard), which is finite-dimensional. Our prior has full support on ℝⁿ. | **Blocks as is.** Neither of their routes applies. |
| Joint non-crossing | not covered | ∝ 1_C(Θ)·∏ⱼ e^{−ωⱼnRₙ,ⱼ(θⱼ)}πⱼ(θⱼ): formally one Gibbs posterior on ℝⁿᴶ with summed losses, prior restricted to C, and a separate ω per level | **Adapt**, later. One learning rate per level, plus the truncation's effect on prior mass. |

## 2. Verdict

**Useful for some pieces, not as the backbone.** Its skeleton (numerator bounded through the MGF, denominator through prior mass, sieve split) is the right shape for a fixed-σ Gibbs-posterior argument. But none of its theorems covers our model as is, because three of the model's defining features fall outside every theorem: the learned σ, the improper and unbounded ℓ₁-difference prior, and a learning rate that does not vanish.

Pieces I would reuse:
1. Lemma 1, the in-probability lower bound on the denominator. It is assumption-light and survives inid data.
2. The sieve split and the Kₙ bookkeeping of Condition 2 and Thm 4.1, together with the bounded-difference MGF bound (their (16), from Lafferty et al.) for the 1-Lipschitz check loss.
3. The excess-risk calculation for the check loss (eq. (66) and the I₁/I₂ split in their proof of Prop 8). It yields a Huber-type margin that matches Padilla's Lemma 13.
4. The inid fixed-design bookkeeping of Prop 5.
5. The ω-monotonicity device in the proof of Thm 3.5 (splitting on the sign of Rₙ(θ)−Rₙ(θ*)), as a template for a random learning rate.

Not reusable: the Prop 8 prior (sieve-restricted random series), the vanishing ωₙ = cΔₙ⁻², and Lemma 2 (fixed dimension).

## 3. Suggested rate (a guess, not a claim)

If the blockers were resolved and our prior's small-ball mass behaves like a well-scaled Laplace-type prior on the BV⁽³⁾ class, the machinery would *suggest* contraction in Padilla's Δ²ₙ at about Padilla's slow rate: n^{−6/7} for Δ²ₙ, i.e. ε ≈ n^{−3/7}, up to log factors. That matches the minimax rate for k = 2.

Run unchanged, the machinery carries the sieve loss of Prop 8: a Δₙ² factor, and ω ↓ 0, which conflicts with a learned σ. The Laplace-prior evidence from T-01 (Castillo et al.; the Song & Cheng remark) means the true answer could be slower. I do not expect the fast rate (s+1)/n·log from this machinery.

## 4. Main obstacles, ranked

1. **Learned σ.** The σ⁻ⁿ factor turns the posterior into a log-risk quasi-posterior, (b_σ+nRₙ(θ))^{−(n+a_σ)}, with a θ-dependent effective ω ≈ 1/σ₀ = O(1). Their theory needs a small, θ-free ω, or a vanishing one.
2. **Prior small-ball mass** for Laplace on D⁽³⁾θ with λ ~ Gamma, around BV or piecewise-quadratic truths. It is uncomputed, it sets the rate, and there is negative evidence for Laplace priors.
3. **Large deviations of the check loss.** Bernstein fails globally. Their remedies are support restricted to a sieve and ω → 0, and our unbounded prior with non-vanishing ω admits neither. Condition (22) would need a new argument in n dimensions.
4. **Improper flat prior on the null space.** Lemma 1 needs a probability measure.
5. **Joint non-crossing extension.** Multiple learning rates and a prior restricted to C; secondary.
6. **Fixed design and Assumption A versus a density condition.** Minor; their Prop 5 already handles inid data.
