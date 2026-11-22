# Lemma L4q: quadratic shift inequality for the Laplace prior on small balls

**Status: self-checked (2026-11-22).** An independent adversarial check (Fable) found "correct with fixable gaps", with no error in Steps 1–7. All its points are addressed in this revision; see "Changes after the referee check" at the end. Ready for the external advisor check.
**Depends on:** L4 (the ℓ₁ shift) and standard facts (Prékopa, Borell). L3 is used only to verify condition (C) in part of the window; at the oracle tuning an elementary bound may suffice (Remark R2).
**Used by:** L6 (the evidence lower bound) through Corollary L4q-M, which gives the bias term V²λ^{5/3}n^{−5} of Theorem A.

## Setting

- m = n − 3 ≥ 2, and Π := Π_λ = Laplace(λ)^{⊗m} on ℝᵐ, with density p(u) = ∏ⱼ (λ/2)e^{−λ|uⱼ|}.
- S = C³[:, 4:n] is the right-inverse of D = D⁽³⁾, with columns sⱼ(i) = (i−j−2)(i−j−1)/2 · 1{i ≥ j+3}. Here C is the n×n cumulative-sum matrix.
- P⊥ is the projector off the quadratics. A := n^{−1/2}P⊥S, so that ‖Au‖₂ = ‖P⊥Su‖ₙ. Its columns are aⱼ := Aeⱼ.
- B_ε := {u : ‖Au‖₂ ≤ ε} is convex and symmetric, and φ(r) := −log Π(B_r).
- δ_A := max_{1 ≤ j < m} ‖a_{j+1} − aⱼ‖₂.

**Scaling.** If u ~ Π_λ then λu ~ Π₁. Hence Π_λ(B_r) = Π₁(B_{λr}), so φ depends on (λ, r) only through ρ := λr. Write φ(r) = Φ(λr), with Φ nonincreasing.

## Statement

Assume **δ_A ≤ λε/2**. Define K := 4δ_A·Φ(λε/4)/(λε) and c_K := e^K/(1 − e^{−2}). Then for every h ∈ ℝᵐ:

  Π(h + B_ε) ≥ Π(B_ε) · exp( −λ Σⱼ min{ |hⱼ|, c_K λ hⱼ² } ),

and in particular Π(h + B_ε) ≥ Π(B_ε) · exp(−min{λ‖h‖₁, c_K λ²‖h‖₂²}). When K ≤ 1, c_K ≤ 3.144.

**When K ≤ 1.** K is a function of ρ = λε only, and it is decreasing, because Φ is nonincreasing. So it suffices to check K ≤ 1 at one threshold ρ₀; it then holds for all λε ≥ ρ₀. Two ways to check it:
- **(R1) via L3.** With Φ(ρ/4) ≤ C₃·(4n^{5/2}/ρ)^{2/5}·(log n)^{6/5} and δ_A ≤ n/√3, K ≤ 1 holds once ρ^{7/5} ≥ (4/√3)·4^{2/5}·C₃·n²(log n)^{6/5}, i.e. **λε ≳ n^{10/7}(log n)^{6/7}**. At the oracle, λε = (n^{5/2}/V)^{5/6}; this is fine for V ≲ n^{11/14}.
- **(R2) without L3** (to be confirmed with explicit constants). We have ‖Au‖₂ ≤ a_max‖u‖₁ with a_max := maxⱼ‖aⱼ‖ ≲ n², so B_r contains the ℓ₁ ball of radius r/a_max. The Gamma(m) distribution of λ‖u‖₁ then gives Φ(ρ) ≤ ρ/a_max + m·log(m·a_max/(eρ)) + O(log m). Hence K ≲ n²·log n/(λε), and K ≤ 1 once λε ≥ C·n²·log n. That covers the oracle λε ≍ n^{25/12} for bounded V, without L3.

## Proof

**Step 1 (symmetrization and AM–GM).** For measurable B, Π(h + B) = ∫_B p(w + h) dw. If B is symmetric, then because p is even, Π(−h + B) = Π(h + B). Hence

  Π(h + B) = ∫_B ½[p(w + h) + p(w − h)] dw.

By AM–GM (½(a + b) ≥ √(ab)) and the identity |x + y| + |x − y| = 2 max(|x|, |y|),

  ½[p(w+h) + p(w−h)] ≥ p(w) · exp(−λ Σⱼ (|hⱼ| − |wⱼ|)₊).

**Step 2 (Jensen).** Write E_B for expectation under Π restricted to B and normalized. Then

  Π(h + B) ≥ Π(B) · exp(−λ Σⱼ E_B(|hⱼ| − |wⱼ|)₊).

**Step 3 (marginal densities at 0).** Let fⱼ be the density of wⱼ under Π(· | B_ε).
- Π restricted to the convex set B_ε is log-concave. Its marginals are log-concave (Prékopa) and even, so fⱼ is maximal at 0.
- Hence E_B(|hⱼ| − |wⱼ|)₊ = ∫₀^{|hⱼ|} P_B(|wⱼ| < s) ds ≤ min{ |hⱼ|, hⱼ² fⱼ(0) }.
- **It remains to show fⱼ(0) ≤ c_K λ.**

**Step 4 (the section function).** Fix j. Write v ∈ ℝ^{m−1} for the other coordinates, Π₋ⱼ for their product law, and A₋ⱼ for A with column j removed. Define

  B_t := {v : ‖A₋ⱼv + t aⱼ‖ ≤ ε},  g(t) := Π₋ⱼ(B_t).

Then fⱼ(t) = g(t)(λ/2)e^{−λ|t|}/Π(B_ε), and Π(B_ε) = ∫ g(t)(λ/2)e^{−λ|t|} dt. The function g is even and log-concave (Prékopa), so it is maximal at 0.

**Step 5 (compensation by a neighbour).** Let z := e_{j+1}, or e_{j−1} if j = m, viewed in the v-coordinates. Then A₋ⱼz = a_{j±1}. Set δ := ‖aⱼ − a_{j±1}‖ ≤ δ_A and 𝒦(r) := {v : ‖A₋ⱼv‖ ≤ r}.
- If v′ ∈ 𝒦(ε − |t|δ), then v := v′ − tz satisfies A₋ⱼv + t aⱼ = A₋ⱼv′ + t(aⱼ − a_{j±1}), which has norm ≤ ε. Hence B_t ⊇ −tz + 𝒦(ε − |t|δ).
- By L4 (shift −tz, with ‖tz‖₁ = |t|): **g(t) ≥ e^{−λ|t|}·Π₋ⱼ(𝒦(ε − |t|δ))**.

**Step 6 (radius loss, by Borell).** The set 𝒦(1) is convex, and r₁𝒦(1) + r₂𝒦(1) = (r₁ + r₂)𝒦(1). So ℓ(r) := log Π₋ⱼ(𝒦(r)) is concave and nondecreasing.
- For 0 ≤ a ≤ ε/2, put x := ε − a. Then ℓ(ε) − ℓ(x) ≤ a·ℓ′₊(x) ≤ a·ℓ′₋(x) ≤ a·(ℓ(x) − ℓ(x/2))/(x/2) ≤ 4a·φ₋ⱼ(ε/4)/ε, where φ₋ⱼ(r) := −ℓ(r).
- **Comparison.** Π(B_r) = ∫ g_r(t)(λ/2)e^{−λ|t|} dt ≤ g_r(0) = Π₋ⱼ(𝒦(r)). So φ₋ⱼ ≤ φ.
- Take a = |t|δ with |t| ≤ 1/λ. Then a ≤ δ_A/λ ≤ ε/2 by assumption, and

  g(t) ≥ g(0) · exp(−λ|t| − 4|t|δ_A φ(ε/4)/ε) ≥ g(0) · e^{−λ|t| − K}.

**Step 7 (conclusion).**

  Π(B_ε) ≥ ∫_{|t| ≤ 1/λ} g(0) e^{−K} e^{−2λ|t|} (λ/2) dt = g(0) e^{−K}(1 − e^{−2})/2.

Hence fⱼ(0) ≤ λe^K/(1 − e^{−2}) = c_K λ. ∎

## Corollary L4q-M (mollified truth: the source of the bias term)

**Statement.** Let u\* := Dθ\*, with ‖u\*‖₁ = V/n². For 3 ≤ w ≤ m/2 there is a vector u_h with:
1. ‖u_h‖₂ ≤ C·V/(n²√w);
2. ‖S(u\* − u_h)‖ₙ² ≤ C·V²(w/n)⁵.

Set θ_h := S u_h + (the quadratic part of θ\*). Then ‖θ_h − θ\*‖ₙ = ‖S(u_h − u\*)‖ₙ.

**Proof.**
- **Kernels.** For each j let K⁽ʲ⁾ be a signed weight vector supported on a window Wⱼ of w consecutive indices containing j, shifted inward near the boundary, such that Σ_k K⁽ʲ⁾(k)(k − j)^p = 1{p = 0} for p = 0, 1, 2, and |K⁽ʲ⁾(k)| ≤ C/w. Local-quadratic equivalent kernels work.
- **Define** u_h := Σⱼ u\*ⱼ K⁽ʲ⁾.
- **The column differences are localized.** For rows i ≥ max Wⱼ + 3, the map k ↦ s_k(i) = (i−k−2)(i−k−1)/2 is a quadratic polynomial in k, so Σ_k K⁽ʲ⁾(k)s_k(i) = sⱼ(i) exactly. For rows i < min Wⱼ every s_k(i) is 0. So S(eⱼ − K⁽ʲ⁾) is supported on ≤ w + 3 rows, with entries O(w²). Hence ‖S(eⱼ − K⁽ʲ⁾)‖ₙ ≤ C·w^{5/2}/√n.
- **Minkowski over the atoms of u\*** gives (2): ‖S(u\* − u_h)‖ₙ ≤ ‖u\*‖₁·C w^{5/2}/√n. It also gives (1): ‖u_h‖₂ ≤ ‖u\*‖₁·maxⱼ‖K⁽ʲ⁾‖₂ ≤ ‖u\*‖₁·C/√w. ∎

**Note.** The kernel must be **signed**. With a nonnegative kernel the second moment is nonzero, the error becomes V²(w/n)⁴, and the exponent changes.

**Consequence (bias term).**
- Choose w ≍ n(ε/V)^{2/5}, so that (2) gives approximation error ≤ ε/2. This needs V·n^{−5/2} ≲ ε ≲ V; for ε ≳ V take u_h = 0.
- Apply the lemma at radius ε/2, i.e. with δ_A ≤ λε/4 and K′ := 8δ_A·Φ(λε/8)/(λε), which has the same order as K. This gives

  −log Π(u\* + B_ε) ≤ φ(ε/2) + c_{K′} λ²‖u_h‖₂² ≤ φ(ε/2) + C λ² V^{12/5} n^{−5} ε^{−2/5}.

- Requiring the right-hand side to be ≤ C′nε² gives **ε² ≳ V²λ^{5/3}n^{−5}**.

## Numerical checks

- **Referee's plain Monte Carlo** (n = 8–30, λ = 1):
  - **(N1)** maxⱼ fⱼ(0)/λ ∈ [0.52, 0.67] whenever δ_A ≤ λε/2, far below the bound 1.157e^K;
  - **(N2)** −log[Π(h + B)/Π(B)] ≤ Σⱼ fⱼ(0)hⱼ² ≤ c_K‖h‖₂² in all 112 cases;
  - **δ_A/n → 0.0258**, so the bound n/√3 = 0.577n is loose by a factor of about 22.
- **Still to do** at Stage-A scale: (N1) and (N2) with signed order-3 mollified-kink shifts. Engineering can do this if wanted.

## Changes after the referee check (Fable, 2026-11-22)

1. Monotonicity of K in ρ = λε (L3 is needed at one radius only).
2. The lemma is stated for general K. It needs only δ_A ≤ λε/2, which absorbs the radius-ε/2 issue in the corollary.
3. The corollary is proved by quadratic reproduction outside the window, with a signed kernel. Claim 1 uses Minkowski, and the range of w is stated.
4. Remark R2: (C) holds without L3 for λε ≳ n² log n (constants to be confirmed).
5. Remark on V growth.
6. Sharper form: Σⱼ min{|hⱼ|, c_K λhⱼ²}.
7. The δ_A computation is corrected: the entries are exactly (i−j−2)₊.
8. The constant in (R1) is corrected.
9. Notation: the set 𝒦 is renamed to avoid a clash with the constant K, and m ≥ 2 is stated.
10. Boundary columns: nothing special is needed.
