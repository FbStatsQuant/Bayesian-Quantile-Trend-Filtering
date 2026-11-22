# Lemma L4: ℓ₁ shift inequality for the Laplace prior

**Status:** self-checked (2026-11-22). **Depends on:** nothing. **Used by:** L6 (the fallback rate), and the proof of L4q (Step 5).

## Statement

Let Π := Laplace(λ)^{⊗d} on ℝᵈ, with density p(u) = ∏ⱼ (λ/2)e^{−λ|uⱼ|}. For every measurable C ⊂ ℝᵈ and every x ∈ ℝᵈ,

  Π(x + C) ≥ e^{−λ‖x‖₁} Π(C).

## Proof

First, Π(x + C) = ∫ 1{v ∈ x + C} p(v) dv = ∫_C p(w + x) dw.

By the triangle inequality, |wⱼ + xⱼ| ≤ |wⱼ| + |xⱼ|, so p(w + x) ≥ e^{−λ‖x‖₁} p(w). Integrating over C gives the claim. ∎

## Remarks

- This is Agapiou, Dashti & Helin (2021), Prop. 2.11, with p = 1 and unit scalings.
- **Use in L6.** It is applied with x = u\* = Dθ\* and C a centred small ball. That gives the shift cost λ‖Dθ\*‖₁ = λVn^{−2}, and hence the fallback bias term λVn^{−3} (per observation, after dividing by n).
- **Sharpness.** It is sharp for "spiky" shifts (|xⱼ| ≫ 1/λ) and loose for small, spread-out shifts. For those, L4q gives the quadratic cost.
