# Lemma L2: excess-risk sandwich for the check loss

**Status:** self-checked (2026-11-22); advisor-checked by Astra (ACCEPT WITH FIXES, `reviews/ASTRA_L2_L4_L5.md`). Both fixes are applied below; see "Response to the advisor check". **Depends on:** (A2) only. **Used by:** L6, L8′/L8-b, L9.

## Setting

Fix a coordinate i. Let Zᵢ := yᵢ − θ\*ᵢ, with right-continuous distribution function Fᵢ. Since θ\*ᵢ is a τ-quantile (generalized inverse), Fᵢ(0−) ≤ τ ≤ Fᵢ(0). For δ ∈ ℝ define the loss difference

  Xᵢ(δ) := ρ_τ(Zᵢ − δ) − ρ_τ(Zᵢ),  and  mᵢ(δ) := E Xᵢ(δ).

**(A2) Two-sided margin.** There are constants L, f, f̄ > 0 such that, for all |δ| ≤ L,

  f|δ| ≤ |Fᵢ(δ) − Fᵢ(0)| ≤ f̄|δ|.

**Continuity at the target.** Letting δ ↑ 0 in the upper half of (A2) gives Fᵢ(0−) = Fᵢ(0). Hence **Fᵢ(0) = τ**, and Fᵢ is continuous at 0. This is the only place where an exact quantile identity enters, and it uses the *upper* half of (A2).

## Statement

For all δ ∈ ℝ:
1. **Bounded increments.** |Xᵢ(δ)| ≤ max(τ, 1−τ)|δ| ≤ |δ|, almost surely. No moments are needed.
2. **Lower margin.** mᵢ(δ) ≥ c₀ min(|δ|, δ²), with c₀ := min(f/2, fL/4).
3. **Global upper bound.** mᵢ(δ) ≤ min(|δ|, C₁δ²), with C₁ := max(f̄/2, 1/L).
4. **Variance.** Var Xᵢ(δ) ≤ E Xᵢ(δ)² ≤ δ².

**Summed form.** For θ = θ\* + δ, let M(θ) := Σᵢ mᵢ(δᵢ). Then

  c₀ n Δ²ₙ(δ) ≤ M(θ) ≤ n·min{ ‖δ‖₁/n, C₁‖δ‖ₙ² },  and  Σᵢ Var Xᵢ ≤ n‖δ‖ₙ².

The linear branch has constant 1, not C₁. A common constant outside the minimum would have to be max(1, C₁): for the uniform law on [−4, 4] at its median, L = 4 and f = f̄ = 1/8 give C₁ = 1/4, while m(t)/t → 1/2.

## Proof

**Exact form of the increment.** Take δ > 0; the case δ < 0 is symmetric for the increment, with τ ↔ 1−τ. A case check (z ≤ 0, 0 < z < δ, z ≥ δ) gives

  ρ_τ(z − δ) − ρ_τ(z) = (1−τ)δ − clip(z, 0, δ).

So Xᵢ ∈ [−τδ, (1−τ)δ], which proves (1). Part (4) follows from (1).

**Integral representation.** By Fubini, mᵢ(δ) = (1−τ)δ − E clip(Zᵢ, 0, δ). Since E clip(Zᵢ, 0, δ) = ∫₀^δ P(Zᵢ > s) ds,

  mᵢ(δ) = ∫₀^δ (Fᵢ(s) − τ) ds  (δ > 0),   mᵢ(−a) = ∫₀^a (τ − Fᵢ(−s)) ds  (a > 0).

The negative-side form follows in the same way from E clip(−Zᵢ, 0, a) = ∫₀^a Fᵢ(−s−) ds. The left limit does not matter inside the integral.

This is Belloni & Chernozhukov (2011, eq. B.3), used as Lemma 13 of Madrid Padilla & Chatterjee. Since Fᵢ(0) = τ (continuity, above), both integrands are nonnegative and nondecreasing in s.

**(2) Lower margin.** This follows the proof of P&C Lemma 13.
- If |δ| ≤ L: by (A2) and Fᵢ(0) = τ, both integrands are ≥ f s, so mᵢ ≥ ∫₀^{|δ|} f s ds = fδ²/2 ≥ (f/2) min(|δ|, δ²).
- If δ > L: by monotonicity, mᵢ ≥ ∫_{L/2}^{δ} (Fᵢ(L/2) − τ) ds ≥ (δ − L/2)(fL/2) ≥ fLδ/4.
- If δ = −a with a > L: mᵢ(−a) ≥ ∫_{L/2}^{a} (τ − Fᵢ(−L/2)) ds ≥ (a − L/2)(fL/2) ≥ fLa/4.

Both sides give ≥ (fL/4) min(|δ|, δ²). No symmetry of the law is needed.

**(3) Upper bound.** Since |Fᵢ(s) − τ| ≤ 1, mᵢ ≤ |δ| always.
- If |δ| ≤ L: mᵢ ≤ ∫₀^{|δ|} f̄ s ds = f̄δ²/2.
- If |δ| > L: mᵢ ≤ |δ| ≤ δ²/L.

Hence mᵢ ≤ max(f̄/2, 1/L)·δ² for every δ. ∎

## Remarks

- **Where the upper half of (A2) is used.** In two places: (i) through C₁, which L6 needs so that an empirical-ℓ₂ ball lies inside an excess-risk neighbourhood; and (ii) to get continuity of Fᵢ at 0, hence Fᵢ(0) = τ, which the margin (2) needs. Without (ii) the lower half alone allows a jump at 0, e.g. Fᵢ(−t) = τ − t² with Fᵢ(0) > τ. That gives mᵢ(−t) = t³/3, and (2) fails. (Counterexample due to Astra.)
- **Numerically checkable.** The identity mᵢ(δ) = ∫₀^δ (F(s) − τ) ds, and the bounds (2) and (3), for any simulated noise law. These are trivial checks.

## Response to the advisor check (Astra, `reviews/ASTRA_L2_L4_L5.md`)

1. **Constant in the summed upper bound: accepted.** The summed form now reads M/n ≤ min{‖δ‖₁/n, C₁‖δ‖²ₙ}. The same erratum is applied to the L2 row of `../T03_Feasibility/STATEMENT_DRAFT.md`. L6 uses only the quadratic branch, so it is unchanged.
2. **Continuity at the target: accepted.** The Setting now uses the generalized-inverse convention Fᵢ(0−) ≤ τ ≤ Fᵢ(0), and derives Fᵢ(0) = τ from the upper half of (A2). The negative-side margin is proved in signed form with τ − Fᵢ(−L/2). The remark on where (A2) is used is corrected, with Astra's counterexample. No new assumption is needed.
