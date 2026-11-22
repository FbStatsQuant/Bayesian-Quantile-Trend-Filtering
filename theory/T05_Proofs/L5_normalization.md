# Lemma L5: normalization and propriety (the flat quadratic part)

**Status:** self-checked (2026-11-22); advisor-checked by Astra (ACCEPT, `reviews/ASTRA_L2_L4_L5.md`). **Depends on:** nothing. **Used by:** every lemma that writes Πₙ(B | y) as a ratio N(B)/N(ℝⁿ).

## Setting

- Coordinates: θ = Nc + Su, where c ∈ ℝ³ (N an orthonormal basis of the quadratics), u = Dθ ∈ ℝᵐ, and DS = I.
- The map (c, u) ↦ θ is a linear bijection of ℝ³ × ℝᵐ onto ℝⁿ with constant Jacobian. So Lebesgue measure dθ corresponds to a constant multiple of dc du, and the prior exp(−λ‖Dθ‖₁)dθ corresponds, up to a constant, to dc ⊗ Π_λ(du), where Π_λ = Laplace(λ)^{⊗m} is a probability measure.
- For measurable B ⊂ ℝⁿ, define

  N(B) := ∫∫ 1{Nc + Su ∈ B} exp{ −ω Σᵢ [ρ_τ(yᵢ − θᵢ) − ρ_τ(yᵢ − θ\*ᵢ)] } dc Π_λ(du).

## Statement

For every y ∈ ℝⁿ and every ω, λ > 0 (any n ≥ 4):
1. 0 < N(ℝⁿ) < ∞, so the Stage-A posterior Πₙ(B | y) = N(B)/N(ℝⁿ) is a proper probability measure.
2. Πₙ(· | y) does not depend on the choice of right-inverse S or of the basis N.
3. **Quadratic equivariance.** The law of θ − θ\* under Πₙ(· | y) is unchanged when θ\* and y are both shifted by the same quadratic. So no bound on the quadratic part of θ\* is needed, and ‖θ\*‖∞ ≤ B can be dropped from (A3).

## Proof

**(1)** Positivity is clear. For finiteness, with κ₀ := min(τ, 1−τ) > 0,

  ρ_τ(yᵢ − θᵢ) ≥ κ₀|yᵢ − θᵢ| ≥ κ₀|θᵢ| − κ₀|yᵢ|.

Also ρ_τ(yᵢ − θ\*ᵢ) ≤ |yᵢ| + |θ\*ᵢ|. So the integrand, written in θ, is at most e^{C(y, θ\*)} · e^{−ωκ₀‖θ‖₁} · e^{−λ‖Dθ‖₁} ≤ e^{C} e^{−ωκ₀‖θ‖₁}, which is Lebesgue-integrable on ℝⁿ. Changing variables to (c, u) only multiplies by a constant.

**(2)** The posterior is a ratio of two integrals of the same integrand. The integrand is defined intrinsically in θ: the prior exp(−λ‖Dθ‖₁)dθ does not depend on the parametrization. The constant Jacobians cancel in the ratio.

**(3)** If y′ = y + q and θ\*′ = θ\* + q with q quadratic, substitute θ′ = θ + q. Then Dθ′ = Dθ, and the loss differences are unchanged, so the integrand in (θ − θ\*) is unchanged. ∎

## Remark (correcting the earlier draft)

Propriety needs only coercivity of the check loss; it does not need n ≥ 4. The draft's "N(ℝⁿ) < ∞ for n ≥ 4" was stronger than necessary.

**What this lemma fixes.** The reviewers' objection that "Π(𝔅ᶜ) has no meaning" is handled as follows:
- every probability statement about the prior is made under Π_λ, which is proper;
- the flat c is integrated identically in the numerator and the denominator, as above.

## Response to the advisor check (Astra)

Accepted; no change needed. Astra adds two points, recorded here because the skeleton uses them:
- **Measurability.** For Borel events the integrand is nonnegative and measurable, and the prior is σ-finite. So N(B) is a measurable function of the data.
- **Finite prior mass of the sup-norm-restricted set** (SKELETON, Step 2). For each u, the constraint ‖θ − θ\*‖∞ ≤ Δ confines c to a translated Euclidean ball of radius √n·Δ, by orthogonal projection. No bound on the quadratic part of the truth enters.
