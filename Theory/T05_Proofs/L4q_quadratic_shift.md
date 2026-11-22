# Lemma L4q: quadratic shift inequality for the Laplace prior on small balls

**Status:** draft, self-check in progress (2026-11-22); L3 is now drafted (L3_small_ball.md). **Depends on:** L3 (an upper bound on the small-ball exponent) and L4 (the ℓ₁ shift). It also uses one standard fact, Borell's log-concavity of r ↦ μ(rK). **Used by:** L6 (the evidence lower bound) through the mollified shift (Corollary L4q-M), which gives the bias term V²λ^{5/3}n^{−5} of Theorem A.

## Setting

- m = n − 3, and Π := Π_λ = Laplace(λ)^{⊗m} on ℝᵐ, with density p(u) = ∏ⱼ (λ/2)e^{−λ|uⱼ|}.
- S is the right-inverse of D = D⁽³⁾ with columns sⱼ(i) = (i−j−2)(i−j−1)/2 · 1{i ≥ j+3}, the falling-factorial columns rescaled so that DS = I.
- P⊥ is the orthogonal projector onto the complement of the quadratics in ℝⁿ.
- A := n^{−1/2}P⊥S : ℝᵐ → ℝⁿ, so that ‖Au‖₂ = ‖P⊥Su‖ₙ. Its columns are aⱼ := Aeⱼ.
- For ε > 0, B_ε := {u ∈ ℝᵐ : ‖Au‖₂ ≤ ε}. It is convex and symmetric.
- φ(r) := −log Π(B_r), the centred small-ball exponent.
- δ_A := max_{1 ≤ j < m} ‖a_{j+1} − aⱼ‖₂.

## Statement

Let ε > 0 satisfy

  **(C)**  K := 4·δ_A·φ(ε/4) / (λε) ≤ 1,  and  δ_A ≤ λε/2.

Then for **every** h ∈ ℝᵐ,

  Π(h + B_ε) ≥ Π(B_ε) · exp( −c_K λ² ‖h‖₂² ),  with c_K := e^K/(1 − e^{−2}) ≤ 3.15.

Combined with L4, this gives Π(h + B_ε) ≥ Π(B_ε)·exp(−min{λ‖h‖₁, c_K λ²‖h‖₂²}).

**When (C) holds.**
1. **The constant δ_A.** δ_A ≤ n/√3. Indeed, s_{j+1} − sⱼ has entries of absolute value ≤ (i−j) for i > j, so ‖s_{j+1} − sⱼ‖₂² ≤ Σ_{k ≤ n} k² ≤ n³/3. P⊥ is a contraction, and the factor n^{−1/2} gives the bound.
2. **The small-ball exponent.** With L3, φ(r) ≤ C₃(n^{5/2}/(λr))^{2/5}, so (C) holds once (λε)^{7/5} ≥ (16/√3)·4^{2/5}·C₃·n².
3. **On the Stage-A grid.** With ε² ≍ λ^{−1/3}: **(C) holds for λ ≥ C·n^{12/7}**. That includes the oracle λ ≍ n^{5/2}/V, where λε ≍ n^{25/12} ≫ n^{10/7}.

## Proof

**Step 1 (symmetrization and AM–GM).** For any measurable B, Π(h + B) = ∫_B p(w + h) dw. If B is symmetric, then since p is even, Π(−h + B) = Π(−(h + B)) = Π(h + B). Hence

  Π(h + B) = ∫_B ½[p(w + h) + p(w − h)] dw.

By AM–GM, ½(a + b) ≥ √(ab). Applying this to the two products, and using |x + y| + |x − y| = 2 max(|x|, |y|),

  ½[p(w+h) + p(w−h)] ≥ ∏ⱼ (λ/2) e^{−λ max(|wⱼ|, |hⱼ|)} = p(w) · exp( −λ Σⱼ (|hⱼ| − |wⱼ|)₊ ).

**Step 2 (Jensen).** Write E_B for expectation under Π restricted to B and normalized. Then

  Π(h + B) ≥ Π(B) · E_B exp(−λΣⱼ(|hⱼ| − |wⱼ|)₊) ≥ Π(B) · exp( −λ Σⱼ E_B(|hⱼ| − |wⱼ|)₊ ).

**Step 3 (reduction to marginal densities at 0).** Let fⱼ be the density of wⱼ under Π(· | B), with B = B_ε.
- The restriction of the log-concave measure Π to the convex set B is log-concave. Its one-dimensional marginals are log-concave (Prékopa), and they are even because B is symmetric and p is even.
- So fⱼ is maximal at 0, and P_B(|wⱼ| < s) ≤ 2s fⱼ(0).
- Hence E_B(|hⱼ| − |wⱼ|)₊ = ∫₀^{|hⱼ|} P_B(|wⱼ| < s) ds ≤ hⱼ² fⱼ(0).
- Therefore Π(h + B) ≥ Π(B) exp(−λ Σⱼ fⱼ(0) hⱼ²). **It remains to show that fⱼ(0) ≤ c_K λ for every j.**

**Step 4 (the section function).** Fix j. Write v ∈ ℝ^{m−1} for the other coordinates, Π₋ⱼ for the product Laplace law on them, and A₋ⱼ for A with column j removed. For t ∈ ℝ, define the section B_t := {v : ‖A₋ⱼv + t aⱼ‖ ≤ ε} and g(t) := Π₋ⱼ(B_t). Then

  fⱼ(t) = g(t)·(λ/2)e^{−λ|t|}/Π(B),  and  Π(B) = ∫ g(t)(λ/2)e^{−λ|t|} dt.

The function g is log-concave (Prékopa) and even, so it is maximal at t = 0.

**Step 5 (compensating the coordinate by its neighbour).** Let z := e_{j+1}, viewed as a vector in the v-coordinates; for j = m use e_{j−1}. Then A₋ⱼz = a_{j+1}. Set δ := ‖aⱼ − a_{j+1}‖ ≤ δ_A and, for r > 0, K₋ⱼ(r) := {v : ‖A₋ⱼv‖ ≤ r}.
- If ‖A₋ⱼv′‖ ≤ ε − |t|δ, then v := v′ − tz satisfies A₋ⱼv + t aⱼ = A₋ⱼv′ + t(aⱼ − a_{j+1}), whose norm is ≤ ε. Hence **B_t ⊇ −tz + K₋ⱼ(ε − |t|δ)**.
- By L4 applied to Π₋ⱼ (shift −tz, with ‖tz‖₁ = |t|): g(t) ≥ e^{−λ|t|} Π₋ⱼ(K₋ⱼ(ε − |t|δ)).

**Step 6 (radius loss, by Borell).** The set K := K₋ⱼ(1) is convex. Since r₁K + r₂K = (r₁ + r₂)K, log-concavity of Π₋ⱼ gives that ℓ(r) := log Π₋ⱼ(rK) is concave and nondecreasing on (0, ∞).
- For 0 ≤ a ≤ ε/2, put x := ε − a ≥ ε/2. Concavity gives ℓ(ε) − ℓ(x) ≤ a·ℓ′₋(x) ≤ a·(ℓ(x) − ℓ(x/2))/(x/2) ≤ 2a·φ₋ⱼ(x/2)/x ≤ 4a·φ₋ⱼ(ε/4)/ε, where φ₋ⱼ(r) := −log Π₋ⱼ(K₋ⱼ(r)).
- **Comparison φ₋ⱼ ≤ φ.** Π(B_r) = ∫ g_r(t)(λ/2)e^{−λ|t|} dt ≤ g_r(0), because g_r is even, log-concave and hence maximal at 0. Since g_r(0) = Π₋ⱼ(K₋ⱼ(r)), we get φ₋ⱼ(r) ≤ φ(r).
- With a = |t|δ, and |t| ≤ 1/λ (so that a ≤ δ_A/λ ≤ ε/2, by the second part of (C)):

  g(t) ≥ g(0) · exp( −λ|t| − 4|t|δ φ(ε/4)/ε ) ≥ g(0) · e^{−λ|t| − K}.

**Step 7 (conclusion).**

  Π(B) ≥ ∫_{|t| ≤ 1/λ} g(0) e^{−K} e^{−λ|t|} (λ/2) e^{−λ|t|} dt = g(0) e^{−K} (1 − e^{−2})/2.

Hence fⱼ(0) = (λ/2) g(0)/Π(B) ≤ λ e^K/(1 − e^{−2}) = c_K λ. Substituting into Step 3 proves the lemma. ∎

## Corollary L4q-M (mollified truth: the source of the bias term)

**Claim.** Let θ\* satisfy TV⁽³⁾(θ\*) = n²‖Dθ\*‖₁ ≤ V. Let K_w be a kernel of width w (in grid units) with moments 1, 0, 0, so that it reproduces quadratics, with ‖K_w‖₂ ≲ w^{−1/2}. Set u_h := K_w ⋆ Dθ\*, with boundary handling. Then:
1. ‖u_h‖₂ ≲ ‖Dθ\*‖₁/√w ≤ V/(n²√w), by Young's inequality.
2. The corresponding trend θ_h satisfies ‖P⊥(θ_h − θ\*)‖ₙ² ≲ V²(w/n)⁵, by local Taylor expansion with the quadratic-reproducing kernel.

**Consequence.** Choose w so that the approximation error is ≤ ε/2. Combining L4q at radius ε/2 with the triangle inequality,

  −log Π(u\* + B_ε) ≤ φ(ε/2) + C λ² V^{12/5} n^{−5} ε^{−2/5}.

Setting this ≤ C′nε² gives ε² ≳ V² λ^{5/3} n^{−5}. This is the VP's bias term.

**Status of the corollary:** draft. The kernel construction and the boundary handling are standard but still need to be written out (to be done in L4q-M).

## Self-check notes

- **(i) Symmetry.** Step 1 uses only that B is symmetric. B_ε is symmetric.
- **(ii) Log-concavity.** Prékopa is used for both g and fⱼ. Π restricted to B has a log-concave density p·1_B; marginals and sections of log-concave functions are log-concave.
- **(iii) No ℓ∞ restriction on h.** The bound holds for every h. For spiky h (with |hⱼ| ≫ 1/λ) it is worse than L4, which is why the min form is used.
- **(iv) Where L3 enters.** L3 is used only as an *upper* bound on φ at ε/4, inside condition (C). Any polynomial upper bound with enough slack would do. At the oracle, (C) needs φ(ε/4) ≲ n^{13/12}, whereas L3 gives ≍ n^{1/6}.
- **(v) Constants.** c_K ≤ e/(1 − e^{−2}) ≈ 3.144 when K ≤ 1.

**To do before marking "self-checked":**
- confirm that the boundary columns (j near m, where ‖aⱼ‖ → 0) need nothing special;
- write out the kernel construction of Corollary L4q-M;
- run the numerical checks below.

## Numerically checkable claims (for Engineering)

- **(N1)** Under Π restricted to B_ε, the marginal density of uⱼ at 0 is ≤ c_K λ. Estimate by MCMC on the truncated product Laplace, e.g. hit-and-run, at moderate n with ε at the Stage-A scale. The prediction is fⱼ(0) ≈ λ/2 up to a factor ≤ 2.
- **(N2)** Π(h + B_ε)/Π(B_ε) = E_{Π|B}[p(w + h)/p(w)] ≥ exp(−3.15λ²‖h‖₂²). Test with mollified-kink shifts h.
