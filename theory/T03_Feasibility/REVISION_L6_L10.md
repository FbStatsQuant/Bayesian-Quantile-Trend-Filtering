# Revision of the Stage-A lemma chain after the external review (points 1–3)

*Theory Department, 2026-11-22. Statements only, no proofs. Responds to `reviews/review_astra_statement.md`, items 1–3. This file will be merged into STATEMENT v2 once the VP's review arrives.*

## What changed and why

- **Old L8 is withdrawn.** It claimed a uniform lower bound on the empirical excess check loss over the sieve shell. That is false: the shell contains an unstructured empirical-ℓ₂ ε-ball, and the check loss is ℓ₁-Lipschitz. An ε-move toward the observations gains order ε, which exceeds the claimed cost Mε² (the reviewer's counterexample). Atchadé's good-event / peeling structure does not rescue it, because his curvature event is also a uniform bound and works only on low-dimensional cones.
- **Repair: integrate, don't take the supremum.** The posterior numerator over a region is bounded *in expectation*, by Fubini plus a per-coordinate moment-generating-function bound. This is the Syring–Martin numerator argument. It needs no entropy, no tests and no sieve, but it needs **bounded coordinate displacements** and a **small learning rate** ω = 1/σ.
- **Consequence 1.** The Talagrand two-level sieve (old L7) is no longer needed for the main bound. It may still help inside L9′.
- **Consequence 2.** The whole difficulty moves to **L9′, posterior ℓ∞-localization**. This is the reviewer's "separate posterior tail bound for large coordinates".
- **Improper prior (review item 1, second paragraph).** All prior statements are now made under the **proper** product Laplace law on u = Dθ. The three flat quadratic coefficients are integrated with the same Lebesgue normalization in the numerator and the denominator.

## Coordinates and normalization

- **Parametrization.** Write θ = Nc + Su:
  - c ∈ ℝ³ is the quadratic part, carried by an orthonormal basis N of the quadratics;
  - u = Dθ ∈ ℝᵐ;
  - S is a fixed right-inverse of D on N^⊥.
- **Prior.** The prior is Lebesgue measure dc ⊗ Π_λ(du), where Π_λ = Laplace(λ)^{⊗m} is a probability measure.
- **Truth.** θ\* = Nc\* + Su\*, with u\* = Dθ\*.
- **Loss differences.** For B ⊂ ℝⁿ, define

  N(B) := ∫∫_{Nc+Su ∈ B} exp{ −ω Σᵢ [ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)] } dc Π_λ(du),

  so that Πₙ(B | y) = N(B)/N(ℝⁿ). The ratio is unaffected by the infinite total mass of dc. N(ℝⁿ) < ∞ almost surely, because the check loss grows linearly in c (posterior propriety, n ≥ 4).
- **Excess risk.** Write Xᵢ(θ) := ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ). Then |Xᵢ(θ)| ≤ |θᵢ − θ\*ᵢ| with no moments needed, and the population excess risk is M(θ) := Σᵢ E₀Xᵢ(θ).

## Revised assumptions affected

- **(A2) Two-sided margin.** As before. Following the reviewer, monotonicity extends the lower bound to the global linear-tail form Mᵢ(θ\*ᵢ + δ) ≥ c₀ min(|δ|, δ²). Lipschitzness extends the local quadratic upper bound globally, with a larger constant.
- **(A3) Truth class.** n²‖D³θ\*‖₁ ≤ V₀, with V₀ > 0 fixed. **The sup-norm bound B is dropped**, by quadratic equivariance.
- **(A4′) Tuning.** σ ≥ σ̄, where σ̄ = σ̄(f, f̄, L, Δ) is a constant; equivalently ω ≤ ω̄. Single oracle tuning λₙ = (n³/V₀)^{3/4}. **No "necessary" language.**

## Revised lemma chain

| Lemma | Statement (revised) | Status / difficulty |
|---|---|---|
| L1 Basis | Unchanged (θ = Hα, falling factorial). | Trivial. |
| L2 Excess-risk sandwich | Under (A2), for all δ: c₀Δ²ₙ(δ) ≤ n⁻¹M(θ\* + δ) ≤ C₁ min(‖δ‖₁/n, ‖δ‖²ₙ) and n⁻¹Σᵢ Var Xᵢ ≤ ‖δ‖²ₙ. | Easy. |
| L3 Small ball (proper prior) | −log Π_λ(u : ‖P⊥S u‖ₙ ≤ ε) ≤ C (n^{5/2}/(λε))^{2/5} for (log n)/λ ≤ ε ≤ n^{5/2}/λ. | Medium. **Open in the Laplace case** (rotation destroys independence, T-04). The Gaussian half is classical. Verified numerically. |
| L4 Shift | Π_λ(u\* + B) ≥ e^{−λ‖u\*‖₁}Π_λ(B) for all B. | Trivial. |
| L6′ Evidence lower bound | With P₀-probability → 1: N(ℝⁿ) ≥ ε³ · exp{ −C(λ‖u\*‖₁ + (n^{5/2}/(λε))^{2/5} + nωε²) }. Proof route: restrict to c ∈ c\* + εB₃ (Lebesgue volume ∝ ε³) and u ∈ u\* + small ball; then Chebyshev, with L2 to L4 for prior mass. | Medium. |
| **L8′ Integrated numerator on a bounded region** (replaces L8) | Fix Δ > 0. Let G_Δ := {θ : ‖θ − θ\*‖∞ ≤ Δ}. There is ω̄ = ω̄(f, f̄, L, Δ) > 0 such that for ω ≤ ω̄ and all M: E₀ N(G_Δ ∩ {Δ²ₙ(θ − θ\*) > Mε²}) ≤ C_Δ · exp(−c ω M n ε²). The polynomial factor C_Δ comes from the bounded c-volume of G_Δ. | **Medium. Route:** Fubini, then ∏ᵢ E e^{−ωXᵢ} ≤ exp{−ω(1 − Cω e^{ωΔ}Δ)Σᵢ Mᵢ} for \|δᵢ\| ≤ Δ (bounded-differences moment-generating-function bound plus L2). There is no supremum, no entropy and no sieve. |
| **L9′ Posterior ℓ∞-localization** (the crux) | Πₙ(‖θ − θ\*‖∞ > Δ | y) → 0 in P₀-probability, for some fixed Δ, under (A1), (A2), (A3) and (A4′), **without moment conditions**. | **High. Now the single critical lemma.** It cannot come from prior mass (prior draws have sup-norm ≍ n^{5/2}/λ ≍ n^{1/4}). It must use the likelihood. Candidate tools: (i) log-concavity of Πₙ through Prékopa–Leindler, combining the mass near θ\* from L6′ with L8′ to exclude far mass along segments; (ii) peeling over sup-norm shells; (iii) coordinatewise conditional posteriors of θᵢ, whose bounded-influence check-loss factor limits pull from outliers. Fallback: sub-exponential noise, where the moment-generating-function bound extends to unbounded coordinates. |
| L5 (merged) | The improper quadratic part is handled by the normalization above (no separate lemma). | Done by construction. |
| Old L7 (Talagrand sieve) | **Removed from the main chain.** It is kept only as a possible tool for L9′(ii). It is re-stated, if needed, for the proper Π_λ centred at u\*, via L4: Π_λ((u\* + Ã)ᶜ) ≤ e^{λ‖u\*‖₁}Π_λ(Ãᶜ). | — |
| Old L10 (ℓ∞ control) | **Absorbed into L9′.** On G_Δ, ‖δ‖²ₙ ≤ max(1, Δ)Δ²ₙ(δ), so the **average-squared-error corollary follows at no extra cost** once L9′ holds. | — |

## How the theorem then follows (logic only)

1. Split {Δ²ₙ > Mε²} ⊂ (G_Δ ∩ {Δ²ₙ > Mε²}) ∪ G_Δᶜ.
2. The first part has expected numerator ≤ e^{−cωMnε²} (L8′), against a denominator ≥ e^{−C′nε²} (L6′, which uses L3 and L4 at λₙ = (n³/V₀)^{3/4}). For M large the first part is negligible.
3. The second part is negligible by L9′.

The resulting rate is the prior-mass rate: ε² ≍ max{λ^{−1/3}, λV₀n^{−3}} up to constants depending on ω. At the oracle tuning this is ε² ≍ V₀^{1/4}n^{−3/4}.

## Remaining open items

- **L9′.** The crux, and the main risk.
- **L3, Laplace case.** Open.
- **The constant ω̄.** It restricts σ to be large enough. The reviewer endorses a "bounded-coordinate likelihood-ratio argument at sufficiently small ω" as a first step. Whether ω̄ can be removed is a later question.
- **Uniformity over the law class 𝒫ₙ** (the reviewer's suggested theorem). L6′ and L8′ depend only on the margin constants and V₀, so uniformity looks natural; L9′ must also be uniform.
