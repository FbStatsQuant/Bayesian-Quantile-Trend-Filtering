# Lemma L6: evidence (denominator) lower bound under misspecification

**Status:** draft, self-checked except the prior-mass inputs, which are taken from L3, L4 and L4q (2026-11-22).
**Depends on:** L2 (for C₁), L5 (normalization), L3 (small ball), and L4 or L4q (shift) with Corollary L4q-M (mollification).
**Used by:** the assembly of Theorem A (SKELETON).

## Setting

Notation as in L5. θ\* = Nc\* + Su\*, with u\* = Dθ\*. Write ℛ(θ) := Σᵢ Xᵢ(θᵢ − θ\*ᵢ) for the empirical excess check loss (L2), so that N(ℝⁿ) = ∫ e^{−ωℛ(θ)} ν(dθ), with ν := dc ⊗ Π_λ.

Fix ε ∈ (0, 1) and a vector u_h ∈ ℝᵐ (the mollified truth of Corollary L4q-M, or simply u_h = u\*) such that

  ‖P⊥S(u_h − u\*)‖ₙ ≤ ε/2.

Define the set

  G := { (c, u) : u ∈ u_h + B_{ε/2},  ‖N(c − c\*) + P_N S(u − u\*)‖ₙ ≤ ε/2 },

where B_r = {u : ‖P⊥Su‖ₙ ≤ r} as in L4q, and P_N is the projector onto the quadratics.

## Statement

For any ω > 0 (no restriction on σ) and any law satisfying (A1) and (A2),

  P₀( N(ℝⁿ) ≥ ν(G)·exp{ −ω(1.44 C₁ + 1) nε² } ) ≥ 1 − 1.44/(nε²).

Here C₁ = max(f̄/2, 1/L) is the constant of L2. The prior mass of G satisfies

  ν(G) = V₃(ε√n/2)³ · Π_λ(u_h + B_{ε/2}),

with V₃ the volume of the unit ball in ℝ³. In turn:
- with L4 and u_h = u\*: Π_λ(u_h + B_{ε/2}) ≥ exp{ −λ‖Dθ\*‖₁ − φ(ε/2) } (fallback);
- with the half-radius form of L4q and u_h mollified (L4q-M): Π_λ(u_h + B_{ε/2}) ≥ exp{ −c_{K′} λ²‖u_h‖₂² − φ(ε/2) }, with K′ = K(λε/2), assuming δ_A ≤ λε/4 (primary).

**Consequence (rates).** With the bounds of L3 and Corollary L4q-M, −log ν(G) ≲ C′nε² provided ε² ≳ λ^{−1/3} + min{λVn^{−3}, V²λ^{5/3}n^{−5}}, up to the 3·log(1/(ε√n)) term. That term is negligible against nε².

## Proof

**Step 1 (G is ε-close and has finite mass).** For (c, u) ∈ G, write δ := θ − θ\*. Then

  δ = [N(c − c\*) + P_N S(u − u\*)] + P⊥S(u − u\*),

and the two brackets are orthogonal. The second has ‖·‖ₙ ≤ ‖P⊥S(u − u_h)‖ₙ + ‖P⊥S(u_h − u\*)‖ₙ ≤ ε/2 + ε/2 = ε. So ‖δ‖ₙ² ≤ ε²/4 + ε² ≤ 1.25ε², i.e. ‖δ‖ₙ ≤ 1.2ε.

For fixed u, the c-section of G is a Euclidean ball in ℝ³ of radius ε√n/2, because ‖Nc‖ₙ = ‖c‖₂/√n. Its volume V₃(ε√n/2)³ does not depend on u. Fubini then gives the formula for ν(G).

**Step 2 (Jensen).** Let ν_G := ν(· ∩ G)/ν(G), a probability measure. By Jensen's inequality applied to the exponential,

  log N(ℝⁿ) ≥ log ∫_G e^{−ωℛ} dν = log ν(G) + log ∫ e^{−ωℛ} dν_G ≥ log ν(G) − ω ∫ ℛ dν_G.

**Step 3 (mean and variance of the averaged excess loss).** Let T := ∫ ℛ dν_G. By Fubini, and L2 with ‖δ‖ₙ² ≤ 1.25ε² on G:

  E₀T = ∫ M dν_G ≤ C₁ n · 1.25ε² ≤ 1.44 C₁ nε².

By Jensen, (∫(ℛ − M) dν_G)² ≤ ∫(ℛ − M)² dν_G, so

  Var₀ T ≤ ∫ Var₀ ℛ(θ) ν_G(dθ) ≤ ∫ n‖δ‖ₙ² ν_G(dθ) ≤ 1.44 nε².

This uses L2 (4) and independence across i (A1). No moments of y are used, since every Xᵢ is bounded by |δᵢ|.

**Step 4 (Chebyshev).** P₀(T > 1.44C₁nε² + nε²) ≤ 1.44nε²/(nε²)² = 1.44/(nε²). On the complementary event, Step 2 gives

  N(ℝⁿ) ≥ ν(G) exp{ −ω(1.44 C₁ + 1) nε² }. ∎

## Remarks

- **Where ω and the prior enter.** No condition on ω is needed: the learning rate only scales the exponent. The prior enters only through ν(G), which is where L3, L4 and L4q are used.
- **Uniformity.** The probability bound and the constants depend only on (C₁, n, ε). So the lemma is uniform over the law class 𝒫ₙ, and over λ (λ enters only through ν(G)).
- **Comparison with Syring & Martin's Lemma 1.** This Jensen route is a little simpler than their Chebyshev-on-cross-sections route, and gives the same order.
