# Lemma L2: excess-risk sandwich for the check loss

**Status:** self-checked (2026-11-22). **Depends on:** (A2) only. **Used by:** L6, L8′/L8-b, L9.

## Setting

Fix a coordinate i. Let Zᵢ := yᵢ − θ\*ᵢ, with distribution function Fᵢ, so that Fᵢ(0) = τ. For δ ∈ ℝ define the loss difference

  Xᵢ(δ) := ρ_τ(Zᵢ − δ) − ρ_τ(Zᵢ),  and  mᵢ(δ) := E Xᵢ(δ).

**(A2) Two-sided margin.** There are constants L, f, f̄ > 0 such that, for all |δ| ≤ L,

  f|δ| ≤ |Fᵢ(δ) − Fᵢ(0)| ≤ f̄|δ|.

## Statement

For all δ ∈ ℝ:
1. **Bounded increments.** |Xᵢ(δ)| ≤ max(τ, 1−τ)|δ| ≤ |δ|, almost surely. No moments are needed.
2. **Lower margin.** mᵢ(δ) ≥ c₀ min(|δ|, δ²), with c₀ := min(f/2, fL/4).
3. **Global upper bound.** mᵢ(δ) ≤ min(|δ|, C₁δ²), with C₁ := max(f̄/2, 1/L).
4. **Variance.** Var Xᵢ(δ) ≤ E Xᵢ(δ)² ≤ δ².

**Summed form.** For θ = θ\* + δ, let M(θ) := Σᵢ mᵢ(δᵢ). Then

  c₀ n Δ²ₙ(δ) ≤ M(θ) ≤ C₁ n ‖δ‖ₙ²,  and  Σᵢ Var Xᵢ ≤ n‖δ‖ₙ².

## Proof

**Exact form of the increment.** Take δ > 0; the case δ < 0 is symmetric, with τ ↔ 1−τ. A case check (z ≤ 0, 0 < z < δ, z ≥ δ) gives

  ρ_τ(z − δ) − ρ_τ(z) = (1−τ)δ − clip(z, 0, δ).

So Xᵢ ∈ [−τδ, (1−τ)δ], which proves (1). Part (4) follows from (1).

**Integral representation.** By Fubini, mᵢ(δ) = (1−τ)δ − E clip(Zᵢ, 0, δ). Since E clip(Zᵢ, 0, δ) = ∫₀^δ P(Zᵢ > s) ds,

  mᵢ(δ) = ∫₀^δ (Fᵢ(s) − τ) ds.

This is Belloni & Chernozhukov (2011, eq. B.3), used as Lemma 13 of Madrid Padilla & Chatterjee. The integrand is nonnegative and nondecreasing, since Fᵢ is monotone.

**(2) Lower margin.** This follows the proof of P&C Lemma 13.
- If |δ| ≤ L: by (A2), mᵢ ≥ ∫₀^{|δ|} f s ds = fδ²/2 ≥ (f/2) min(|δ|, δ²).
- If |δ| > L: by monotonicity, mᵢ ≥ ∫_{L/2}^{|δ|} (Fᵢ(L/2) − τ) ds ≥ (|δ| − L/2)(fL/2) ≥ fL|δ|/4 ≥ (fL/4) min(|δ|, δ²).

**(3) Upper bound.** Since |Fᵢ(s) − τ| ≤ 1, mᵢ ≤ |δ| always.
- If |δ| ≤ L: mᵢ ≤ ∫₀^{|δ|} f̄ s ds = f̄δ²/2.
- If |δ| > L: mᵢ ≤ |δ| ≤ δ²/L.

Hence mᵢ ≤ max(f̄/2, 1/L)·δ² for every δ. ∎

## Remarks

- **Where the upper half of (A2) is used.** It enters only through C₁, which L6 needs so that an empirical-ℓ₂ ball lies inside an excess-risk neighbourhood. It is not needed for the margin (2).
- **Numerically checkable.** The identity mᵢ(δ) = ∫₀^δ (F(s) − τ) ds, and the bounds (2) and (3), for any simulated noise law. These are trivial checks.
