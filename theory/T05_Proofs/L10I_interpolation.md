# Lemma L10-I: discrete interpolation inequality (sup-norm from ℓ₂ and TV⁽³⁾)

**Status:** advisor-checked (2026-11-22), Astra (`reviews/ASTRA_L10I.md`): L10-I ACCEPT WITH FIXES, all applied; Huber corollary ACCEPT. The Christoffel supremum is now proved analytically to be exactly 9 (Astra's formula). The numerical check `checks/l10i_christoffel.py` passed and is now a cross-check only.
**Depends on:** nothing.
**Used by:** L10, Stage 2 of the VP's two-stage route; and, **prospectively**, the flagged squared-loss corollary of Theorem B, for which a Stage-1-type posterior TV bound is a hypothesis (audit, Astra #6).

## Statement

For n ≥ 4 and δ ∈ ℝⁿ, let a := ‖δ‖ₙ and T := TV⁽³⁾(δ) = n²‖D⁽³⁾δ‖₁. Then

  ‖δ‖∞ ≤ 2√C·a + K₁·a^{4/5}T^{1/5},  with K₁ := max{ [6C(2√C)^{1/2}]^{2/5}, (18√C)^{1/5} }.

Here C := sup_{w≥3} C_eq(w) is the discrete Christoffel constant for quadratics, defined below. **C = 9 exactly**, so 2√C = 6 and K₁ = (54√6)^{2/5} = 7.0565… < 7.06.

- **No projection is needed.** The quadratic component is covered by the a-term, through a window of full width.
- **Scale invariance.** A bump of height H and width r (grid units r ≤ n) has a ≍ H(r/n)^{1/2} and T ≍ Hn²/r². So a^{4/5}T^{1/5} ≍ H. The inequality is sharp up to constants, from a single spike (r = 1) to smooth bumps.
- **Relation to P&C.** P&C's Lemma 19 is off by n^{r−1} as printed (MEMO). This lemma replaces it in our chain.

**Corollary (Huber form, used in L10).** Suppose Δ²ₙ(δ) ≤ η and TV⁽³⁾(δ) ≤ T₀, with 16Cη < 1 and (2K₁)^{5/3}η^{2/3}T₀^{1/3} < 1. Then ‖δ‖∞ ≤ 1 and

  ‖δ‖∞ ≤ 2√C·η^{1/2} + K₁·η^{2/5}T₀^{1/5}.

In particular, for 0 < Δ ≤ 1, ‖δ‖∞ ≤ Δ/2 as soon as **η ≤ Δ²/(64C) and η²T₀ ≤ (Δ/(4K₁))⁵** (Astra). This is the shorthand η ≲ min(Δ², Δ^{5/2}T₀^{−1/2}) with a sufficiently small universal constant, and it also covers T₀ = 0.

## Proof

**Christoffel constant.** For a window W of w ≥ 3 consecutive indices, put x_k := (k − min W)/(w−1), b(x) := (1, x, x²)ᵀ and G_w := w⁻¹Σ_{k∈W} b(x_k)b(x_k)ᵀ. Set C_eq(w) := max_{k∈W} b(x_k)ᵀG_w⁻¹b(x_k).
- *Norm equivalence.* By Cauchy–Schwarz in the G_w inner product, every quadratic q satisfies max_{k∈W} q(k)² ≤ C_eq(w)·w⁻¹Σ_{k∈W} q(k)².
- *Exact value (Astra).* Centre the nodes, t = j − (w−1)/2 for 0 ≤ j < w, and let E be the uniform average over them. The polynomials 1, t and t² − μ are orthogonal, with μ = Et² = (w²−1)/12 and v = E(t² − μ)² = (w²−1)(w²−4)/180. In this basis the Christoffel function is

  F(t²) = 1 + t²/μ + (t² − μ)²/v.

  It is convex in t², so its maximum over the nodes is the larger of its values at t² = 0 and at t² = β := (w−1)²/4.
  - F(0) = 1 + 5(w²−1)/(4(w²−4)) ≤ 3 for w ≥ 3.
  - F(β) = 1 + 3(w−1)/(w+1) + 5(w−1)(w−2)/((w+1)(w+2)). This equals 3 at w = 3 and increases to 9.

  The value F(β) is attained at a window endpoint, so C_eq(w) = F(β) for every w ≥ 3, even or odd. Hence **C = sup_w C_eq(w) = 9**, approached but not attained.

**Discrete Taylor expansion.** Let W = {k₀, …, k₀ + w − 1}. Newton's forward formula gives, for k ∈ W,

  δ_k = Σ_{p=0}^{2} C(k − k₀, p)·(Δ^pδ)_{k₀} + Σ_{j=k₀}^{k−3} C(k − j − 1, 2)·(Δ³δ)_j =: q(k) + r(k),

with the empty-sum convention when k − 3 < k₀. Every stencil {j, …, j+3} with j ≤ k − 3 lies inside W, so the indices j range over k₀ ≤ j ≤ k₀ + w − 4; the range is empty for w = 3. The identity follows by recurrence: r vanishes at the first three nodes, and Δ³r_j = Δ³δ_j for every stencil inside the window.

Here q is a quadratic in k. Since |C(k − j − 1, 2)| ≤ w²/2 and the Δ³δ are, up to sign, the entries of D⁽³⁾δ,

  |r(k)| ≤ (w²/2)·Σ_{j∈W}|(Dδ)_j| ≤ ρ_w := w²T/(2n²).

**Local mass.** Let s := ‖δ‖∞ = |δᵢ|, and let W ∋ i be a window of width w ∈ [3, n], shifted inside {1, …, n} if necessary. Suppose ρ_w ≤ s/(4√C). Then:
- |q(i)| ≥ s − ρ_w, so w⁻¹Σ_W q² ≥ (s − ρ_w)²/C;
- by Minkowski on W, (Σ_W δ²)^{1/2} ≥ (Σ_W q²)^{1/2} − (Σ_W r²)^{1/2} ≥ √w·[(s − ρ_w)/√C − ρ_w] ≥ √w·s/(2√C).

Hence

  n a² ≥ Σ_W δ² ≥ w s²/(4C).   (★)

**Trivial cases.** If s = 0 there is nothing to prove. If T = 0, the remainder vanishes on the full window, so s ≤ √C·a.

**Choice of w (s, T > 0).** Put w\* := n·(s/(2√C·T))^{1/2}, so that ρ_{w\*} = s/(4√C). Every w ≤ w\* satisfies the condition above.
- **Case A (w\* ≥ n).** Take w = n. (★) gives a² ≥ s²/(4C), i.e. s ≤ 2√C·a.
- **Case B (3 ≤ w\* < n).** Take w = ⌊w\*⌋ ≥ (2/3)w\*. (★) gives

  a² ≥ (1/(6C))·s²·(s/(2√C·T))^{1/2},  i.e.  s ≤ [6C(2√C)^{1/2}]^{2/5}·a^{4/5}T^{1/5}.

- **Case C (w\* < 3).** Then s < 18√C·T/n². Also n a² ≥ s², since the single coordinate i already gives this. Therefore

  a^{4/5}T^{1/5} ≥ (s/√n)^{4/5}·(s n²/(18√C))^{1/5} = s·(18√C)^{−1/5}.

In all cases s ≤ 2√C·a + K₁a^{4/5}T^{1/5}. ∎

**Proof of the corollary.**
- *If s ≤ 1:* every |δᵢ| ≤ 1, so a² = Δ²ₙ(δ) ≤ η, and the lemma gives the bound.
- *If s > 1:* δᵢ² ≤ s·min(δᵢ², |δᵢ|) for every i, so a² ≤ sη. Then the lemma gives s ≤ 2√C(sη)^{1/2} + K₁(sη)^{2/5}T₀^{1/5}. One of the two terms is ≥ s/2:
  - the first gives s ≤ 16Cη < 1;
  - the second gives s^{3/5} ≤ 2K₁η^{2/5}T₀^{1/5}, i.e. s ≤ (2K₁)^{5/3}η^{2/3}T₀^{1/3} < 1.

  Both contradict s > 1. ∎

## How L10 uses this

The interpolation step is deterministic. **What it cannot do on its own is establish entry into a small Huber ball** (Astra's circularity objection).
- L10 must supply, in posterior probability, both Δ²ₙ ≤ η and TV⁽³⁾ ≤ T₀ with η ≪ T₀^{−1/2}.
- With the prior-typical T₀ ≍ n³/λ (VP, Stage 1), this needs η ≪ (λ/n³)^{1/2}. At λ ≍ n^{5/2} that is η ≪ n^{−1/4}.
- Stage 1 of the VP's route claims η ≍ λ^{−2/7}, which beats (λ/n³)^{1/2} exactly when λ > n^{21/11}. That is the origin of a₀.
- **Stage 2 closes, given Stage 1 (Astra #5).** Suppose Stage 1 supplies, with posterior probability → 1, the joint event {Δ²ₙ ≤ η, TV⁽³⁾ ≤ T₀} with η ≲ λ^{−2/7} and T₀ ≲ n³/λ. Then η → 0 and η²T₀ ≲ n³λ^{−11/7} → 0 **whenever λ/n^{21/11} → ∞**. So the explicit bootstrap applies, and

  ‖δ‖∞ ≲ λ^{−1/7} + (n³λ^{−11/7})^{1/5} = o(1).

  A fixed multiple above the threshold is not enough. λ ≥ n^{21/11+ε} for fixed ε > 0 suffices, including the project's lower endpoint λ = n². **L10 therefore reduces to Stage 1.**

## Numerical check (`checks/l10i_christoffel.py`, owls_run -j 1)

- **Christoffel constant (cross-check of the exact formula):** C_eq(w) = 3, 3.8, 4.43, 4.93, 5.33, 5.67, 5.95, 6.18 for w = 3, …, 10, and 8.9964 at w = 10⁴. These agree with F(β).
- **Inequality:** tested on 1200 vectors (n = 20, 200, 2000: Gaussian noise, single spikes, local quadratic bumps, sparse-kink cubic sums). The maximum of ‖δ‖∞/bound is 0.362. (One all-zero vector gave 0/0 and was ignored.)

## Response to the advisor check (Astra, `reviews/ASTRA_L10I.md`)

1. **Christoffel supremum: fixed.** The finite numerical value is replaced by Astra's exact formula, which gives C = 9 (attained at window endpoints in the limit). K₁ = (54√6)^{2/5} < 7.06.
2. **Newton indexing:** made literal (k₀ ≤ j ≤ k₀ + w − 4), with the recurrence justification.
3. **Trivial cases** s = 0 and T = 0 are now handled before dividing by T.
4. **Fixed-radius corollary:** explicit constants (η ≤ Δ²/(64C), η²T₀ ≤ (Δ/(4K₁))⁵), which also cover T₀ = 0.
5. **Stage 2:** stated with the diverging-ratio condition λ/n^{21/11} → ∞, conditional on Stage 1's joint event.
