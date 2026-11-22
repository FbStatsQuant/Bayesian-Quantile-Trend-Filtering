# Lemma L4: ℓ₁ shift inequality for the Laplace prior

**Status:** self-checked (2026-11-22); advisor-checked by Astra (ACCEPT, `reviews/ASTRA_L2_L4_L5.md`). **Depends on:** nothing. **Used by:** L6 (the fallback rate), and the proof of L4q (Step 5).

## Statement

Let Π := Laplace(λ)^{⊗d} on ℝᵈ, with density p(u) = ∏ⱼ (λ/2)e^{−λ|uⱼ|}. For every measurable C ⊂ ℝᵈ and every x ∈ ℝᵈ,

  Π(x + C) ≥ e^{−λ‖x‖₁} Π(C).

## Proof

First, Π(x + C) = ∫ 1{v ∈ x + C} p(v) dv = ∫_C p(w + x) dw.

By the triangle inequality, |wⱼ + xⱼ| ≤ |wⱼ| + |xⱼ|, so p(w + x) ≥ e^{−λ‖x‖₁} p(w). Integrating over C gives the claim. ∎

## Remarks

- **Relation to the literature.** Agapiou, Dashti & Helin (2021), Prop. 2.11 (p = 1), is the version for centred norm balls, at unit scale. Our prior has scale 1/λ, so rescale the variable (λu has unit scale). The extension to every measurable set C is the two-line argument above. ADH is cited for context only; it is not needed.
- **Use in L6.** It is applied with x = u\* = Dθ\* and C a centred small ball. That gives the shift cost λ‖Dθ\*‖₁ ≤ λVn^{−2} (A3 is a budget), and hence the fallback bias term λVn^{−3} (per observation, after dividing by n).
- **Sharpness.** It is sharp for "spiky" shifts (|xⱼ| ≫ 1/λ) and loose for small, spread-out shifts. For those, L4q gives the quadratic cost.

## Response to the advisor check (Astra)

Accepted, with no change to the proof. The ADH citation is now described as the centred-norm-ball version at unit scale (we rescale). The shift cost is now written as an inequality, ≤ λVn^{−2}. Astra confirms the lemma covers both downstream uses: the fallback prior mass in L6, and the translated lower-dimensional section in L4q, Step 5.
