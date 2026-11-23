# Lemma L10-I: discrete interpolation inequality (sup-norm from ℓ₂ and TV⁽³⁾)

**Status:** self-checked (2026-11-22). The proof is deterministic and elementary. Numerical check `checks/l10i_christoffel.py` passed (owls_run, 1 core): see the end.
**Depends on:** nothing.
**Used by:** L10 (both stages of the VP's two-stage route), and the squared-loss corollary of Theorem B.

## Statement

For n ≥ 4 and δ ∈ ℝⁿ, let a := ‖δ‖ₙ and T := TV⁽³⁾(δ) = n²‖D⁽³⁾δ‖₁. Then

  ‖δ‖∞ ≤ 2√C·a + K₁·a^{4/5}T^{1/5},  with K₁ := max{ [6C(2√C)^{1/2}]^{2/5}, (18√C)^{1/5} }.

Here C := sup_{w≥3} C_eq(w) < ∞ is the discrete Christoffel constant for quadratics, defined below. Numerically, C ≤ 9, which gives 2√C ≤ 6 and K₁ ≤ 7.06.

- **No projection is needed.** The quadratic component is covered by the a-term, through a window of full width.
- **Scale invariance.** A bump of height H and width r (grid units r ≤ n) has a ≍ H(r/n)^{1/2} and T ≍ Hn²/r². So a^{4/5}T^{1/5} ≍ H. The inequality is sharp up to constants, from a single spike (r = 1) to smooth bumps.
- **Relation to P&C.** P&C's Lemma 19 is off by n^{r−1} as printed (MEMO). This lemma replaces it in our chain.

**Corollary (Huber form, used in L10).** Suppose Δ²ₙ(δ) ≤ η and TV⁽³⁾(δ) ≤ T₀, with 16Cη < 1 and (2K₁)^{5/3}η^{2/3}T₀^{1/3} < 1. Then ‖δ‖∞ ≤ 1 and

  ‖δ‖∞ ≤ 2√C·η^{1/2} + K₁·η^{2/5}T₀^{1/5}.

In particular, ‖δ‖∞ ≤ Δ (Δ ≤ 1) as soon as **η ≲ min(Δ², Δ^{5/2}T₀^{−1/2})**.

## Proof

**Christoffel constant.** For a window W of w ≥ 3 consecutive indices, put x_k := (k − min W)/(w−1), b(x) := (1, x, x²)ᵀ and G_w := w⁻¹Σ_{k∈W} b(x_k)b(x_k)ᵀ. Set C_eq(w) := max_{k∈W} b(x_k)ᵀG_w⁻¹b(x_k).
- *Norm equivalence.* By Cauchy–Schwarz in the G_w inner product, every quadratic q satisfies max_{k∈W} q(k)² ≤ C_eq(w)·w⁻¹Σ_{k∈W} q(k)².
- *Finiteness of C.* G_w is invertible for w ≥ 3 and converges to the positive definite moment matrix of the uniform law on [0, 1]. So C = sup_w C_eq(w) < ∞.
- *Numerical value.* C_eq(3) = 3. C_eq increases monotonically, to 8.9964 at w = 10⁴. The limit is the continuous Christoffel value (p+1)² = 9.

**Discrete Taylor expansion.** Let W = {k₀, …, k₀ + w − 1}. Newton's forward formula gives, for k ∈ W,

  δ_k = Σ_{p=0}^{2} C(k − k₀, p)·(Δ^pδ)_{k₀} + Σ_{j=k₀}^{k−3} C(k − j − 1, 2)·(Δ³δ)_j =: q(k) + r(k).

Here q is a quadratic in k. Since |C(k − j − 1, 2)| ≤ w²/2 and the Δ³δ are, up to sign, the entries of D⁽³⁾δ,

  |r(k)| ≤ (w²/2)·Σ_{j∈W}|(Dδ)_j| ≤ ρ_w := w²T/(2n²).

**Local mass.** Let s := ‖δ‖∞ = |δᵢ|, and let W ∋ i be a window of width w ∈ [3, n], shifted inside {1, …, n} if necessary. Suppose ρ_w ≤ s/(4√C). Then:
- |q(i)| ≥ s − ρ_w, so w⁻¹Σ_W q² ≥ (s − ρ_w)²/C;
- by Minkowski on W, (Σ_W δ²)^{1/2} ≥ (Σ_W q²)^{1/2} − (Σ_W r²)^{1/2} ≥ √w·[(s − ρ_w)/√C − ρ_w] ≥ √w·s/(2√C).

Hence

  n a² ≥ Σ_W δ² ≥ w s²/(4C).   (★)

**Choice of w.** Put w\* := n·(s/(2√C·T))^{1/2}, so that ρ_{w\*} = s/(4√C). Every w ≤ w\* satisfies the condition above.
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

## Numerical check (`checks/l10i_christoffel.py`, owls_run -j 1)

- **Christoffel constant:** C_eq(w) = 3, 3.8, 4.43, 4.93, 5.33, 5.67, 5.95, 6.18 for w = 3, …, 10, and 8.9964 at w = 10⁴. So sup C = 8.9964 < 9, which gives K₁ = 7.06.
- **Inequality:** tested on 1200 vectors (n = 20, 200, 2000: Gaussian noise, single spikes, local quadratic bumps, sparse-kink cubic sums). The maximum of ‖δ‖∞/bound is 0.362. (One all-zero vector gave 0/0 and was ignored.)
