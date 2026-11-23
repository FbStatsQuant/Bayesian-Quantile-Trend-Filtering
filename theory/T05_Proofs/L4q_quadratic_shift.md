# Lemma L4q: quadratic shift inequality for the Laplace prior on small balls

**Status: advisor-checked (2026-11-22).** Astra (`reviews/ASTRA_L4q.md`): the lemma is ACCEPTED. L4q-M is ACCEPTED WITH FIXES, all applied below. The L3-free verification of (C) is ACCEPTED. Earlier, a Fable adversarial check found "correct with fixable gaps" (see "Changes after the referee check"). See "Response to the advisor check" at the end.
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

Define the function **K(ρ) := 4δ_A·Φ(ρ/4)/ρ**. Assume **δ_A ≤ λε/2**, and set K := K(λε) and c_K := e^K/(1 − e^{−2}). Then for every h ∈ ℝᵐ:

  Π(h + B_ε) ≥ Π(B_ε) · exp( −λ Σⱼ min{ |hⱼ|, c_K λ hⱼ² } ),

and in particular Π(h + B_ε) ≥ Π(B_ε) · exp(−min{λ‖h‖₁, c_K λ²‖h‖₂²}). When K ≤ 1, c_K ≤ 3.144.

**Half-radius form (the form cited by L6).** If δ_A ≤ λε/4, then for every h,

  Π(h + B_{ε/2}) ≥ Π(B_{ε/2}) · exp(−c_{K′} λ²‖h‖₂²),  with K′ := K(λε/2) = 8δ_A·Φ(λε/8)/(λε) and c_{K′} = e^{K′}/(1 − e^{−2}).

This is the lemma applied at radius ε/2; no monotonicity argument is involved. **Condition (C) at half radius** means K′ ≤ 1. It must be checked directly: since K(·) is nonincreasing, K′ ≥ K, so K ≤ 1 does not imply K′ ≤ 1.

**When K ≤ 1.** K is a function of ρ = λε only, and it is decreasing, because Φ is nonincreasing. So it suffices to check K ≤ 1 at one threshold ρ₀; it then holds for all λε ≥ ρ₀. Two ways to check it:
- **(R1) via L3.** L3 gives Φ(ρ/4) ≤ 30·(4n^{5/2}/ρ)^{2/5}(log m)^{1/5} + 6, and δ_A ≤ n/√3. So K(ρ) ≤ (4n/(√3ρ))·[52.3·n(log m)^{1/5}ρ^{−2/5} + 6], and K(ρ) ≤ 1 once **ρ ≥ 51·n^{10/7}(log m)^{1/7}**. At half radius this becomes λε ≥ 102·n^{10/7}(log m)^{1/7}. At the log-free oracle radius, λε = (n^{5/2}/V)^{5/6}, this needs V ≲ n^{11/14}(log n)^{−6/35}. With a log-inflated radius, insert that radius directly.
- **(R2) without L3 (Astra's elementary bound; ACCEPTED).**
  - *Argument.* a_max ≤ n², so on the event {maxⱼ|λuⱼ| ≤ 1/n} we have ‖Aλu‖₂ ≤ n². That event has probability (1 − e^{−1/n})^m ≥ (2n)^{−m}. Hence Φ(ρ/4) ≤ m log(2n) for every ρ ≥ 4n².
  - *Bound on K.* With δ_A ≤ n, K(ρ) ≤ 4n² log(2n)/ρ. So **λε ≥ 8n² log(2n) gives K′ = K(λε/2) ≤ 1**, even at half radius.
  - *Scope.* This supplies (C) only. L6 still needs L3 for the centred mass φ(ε/2). At the oracle the check is asymptotic: it needs n^{1/12} ≳ 8V^{5/6}log(2n).
  - *Superseded version (kept for the record): the Gamma(m) bound.*
  - *Column norms.* ‖aⱼ‖₂ ≤ n^{−1/2}‖sⱼ‖₂, and ‖sⱼ‖₂² = Σ_{k ≤ n−j−2} (k(k+1)/2)² ≤ n⁵/20. So a_max ≤ ā := n²/√20; numerically the ratio is 0.90, 0.975 and 0.995 at n = 50, 200, 1000.
  - *Containment.* Since ‖Au‖₂ ≤ ā‖u‖₁, B_r contains the ℓ₁ ball of radius r/ā.
  - *Gamma bound.* Under Π₁, ‖u‖₁ ~ Gamma(m, 1), and P(Gamma(m) ≤ s) ≥ e^{−s}s^m/m!. With Stirling, log m! ≤ m log m − m + ½log(2πm) + 1/(12m), this gives

    Φ(ρ) ≤ ρ/ā + m·log(m ā/(eρ)) + ½log(2πm) + 1  (all ρ > 0).

  - *Bound on K.* Hence

    K ≤ δ_A/ā + (4δ_A/ρ)·[ m log(4mā/(eρ)) + ½log(2πm) + 1 ] ≤ √20/(√3 n) + (4n/(√3 ρ))·[ m log(4mā/(eρ)) + ½log(2πm) + 1 ],

    using δ_A ≤ n/√3. So K ≤ 1 once λε ≥ (4/√3)(1 + o(1))·n²·log(n³/(λε)). At the oracle λε ≍ n^{25/12}V^{−5/6}, this is n^{1/12} ≳ 2.1·V^{5/6}·log n.
  - *Caveat: this is asymptotic only.* With the worst-case δ_A ≤ n/√3 it needs astronomically large n. With the empirical δ_A ≈ 0.0258n (a factor ≈ 22 smaller) it holds from n ≈ 10⁶ for V = 1. **For finite-n statements, use (R1) via L3.**

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

**Statement.** Let u\* := Dθ\*, with ‖u\*‖₁ ≤ V/n² (A3). For 3 ≤ w ≤ m/2 there is a vector u_h with:
1. ‖u_h‖₂ ≤ C·V/(n²√w);
2. ‖S(u\* − u_h)‖ₙ² ≤ C·V²(w/n)⁵;
3. ‖u_h‖∞ ≤ C·V/(n²w).

The constant C is absolute. Set θ_h := S u_h + (θ\* − S u\*), using the same null-space remainder for both vectors. Then θ_h − θ\* = S(u_h − u\*), with no projection.

**Proof.**
- **Kernels (explicit; Astra).** For each j let Wⱼ be a window of w consecutive indices containing j, shifted inward near the boundary.
  - Use window coordinates x_k := (k − min Wⱼ)/(w − 1), b(x) := (1, x, x²)ᵀ and G_w := w⁻¹Σ_{k∈Wⱼ} b(x_k)b(x_k)ᵀ.
  - Set K⁽ʲ⁾(k) := w⁻¹·b(xⱼ)ᵀG_w⁻¹b(x_k) on Wⱼ, and 0 elsewhere.
  - These weights reproduce evaluation at xⱼ for every quadratic, including at an endpoint. Hence Σ_k K⁽ʲ⁾(k)(k − j)^p = 1{p = 0} for p = 0, 1, 2.
  - G_w is invertible for w ≥ 3 and converges to the positive definite moment matrix of the uniform law on [0, 1]. So sup_{w≥3}‖G_w⁻¹‖ < ∞ and |K⁽ʲ⁾(k)| ≤ C/w.
  - *Alternative (VP):* extend θ\* beyond each end by its end quadratic (u\* by zeros) and use the interior kernel throughout.
- **Define** u_h := Σⱼ u\*ⱼ K⁽ʲ⁾.
- **The column differences are localized.** For rows i ≥ max Wⱼ + 3, the map k ↦ s_k(i) = (i−k−2)(i−k−1)/2 is a quadratic polynomial in k, so Σ_k K⁽ʲ⁾(k)s_k(i) = sⱼ(i) exactly. For rows i < min Wⱼ every s_k(i) is 0. So S(eⱼ − K⁽ʲ⁾) is supported on ≤ w + 3 rows, with entries O(w²). Hence ‖S(eⱼ − K⁽ʲ⁾)‖ₙ ≤ C·w^{5/2}/√n.
- **Minkowski over the atoms of u\*** gives:
  - (2): ‖S(u\* − u_h)‖ₙ ≤ ‖u\*‖₁·C w^{5/2}/√n;
  - (1): ‖u_h‖₂ ≤ ‖u\*‖₁·maxⱼ‖K⁽ʲ⁾‖₂ ≤ ‖u\*‖₁·C/√w;
  - (3): ‖u_h‖∞ ≤ ‖u\*‖₁·maxⱼ‖K⁽ʲ⁾‖∞ ≤ ‖u\*‖₁·C/w. ∎

**Note.** The kernel must be **signed**. With a nonnegative kernel the second moment is nonzero, the error becomes V²(w/n)⁴, and the exponent changes.

**Consequence (bias term).**
- Choose w ≍ n(ε/V)^{2/5}, so that (2) gives approximation error ≤ ε/2. This needs V·n^{−5/2} ≲ ε ≲ V; for ε ≳ V take u_h = 0.
- Apply the half-radius form, i.e. with δ_A ≤ λε/4 and K′ = K(λε/2). Since u_h + B_{ε/2} ⊂ u\* + B_ε by (2), this gives

  −log Π(u_h + B_{ε/2}) ≤ φ(ε/2) + c_{K′} λ²‖u_h‖₂² ≤ φ(ε/2) + C·c_{K′}·λ² V^{12/5} n^{−5} ε^{−2/5}.

- Requiring the shift charge to be ≤ nε² gives **ε² ≥ (C·c_{K′})^{5/6}·V²λ^{5/3}n^{−5}**. With the evidence budget nκε², this becomes κ^{−5/6}(C·c_{K′})^{5/6}V²λ^{5/3}n^{−5}.
- **Uniform claims need K′ bounded.** Keep the factor c_{K′}^{5/6} until a fresh threshold check at half radius shows K′ ≤ 1: R1 (λε ≥ 102·n^{10/7}(log m)^{1/7}) or R2 (λε ≥ 8n² log(2n)). At the fixed-V oracle, λε ≍ n^{25/12} satisfies both for large n, so c_{K′} ≤ 3.144.
- **Where (C) fails** (low end of the window, e.g. λ = n^{3/2} with fixed V, κ, where λε ≈ n^{5/4} is below R1): use L4 instead. Its cost λVn^{−3} ≲ λ^{−1/3} fits the spread budget there (Astra).
- **Shift size at the oracle.** By (3), λ‖u_h‖∞ ≲ √n/w = o(1) at the oracle width w ≍ n^{5/6}V^{−1/3}. So even the older cap ‖h‖∞ ≤ 1/λ holds eventually, although the proof does not need it.

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
4. Remark R2: (C) holds without L3 for λε ≳ n² log n; explicit constants added (asymptotic only; finite n uses R1).
5. Remark on V growth.
6. Sharper form: Σⱼ min{|hⱼ|, c_K λhⱼ²}.
7. The δ_A computation is corrected: the entries are exactly (i−j−2)₊.
8. The constant in (R1) is corrected.
9. Notation: the set 𝒦 is renamed to avoid a clash with the constant K, and m ≥ 2 is stated.
10. Boundary columns: nothing special is needed.

## Response to the advisor check (Astra, `reviews/ASTRA_L4q.md`)

1. **Set, radius, quantifiers: accepted.** K(ρ) is now a named function. The half-radius form is stated right after the lemma, with δ_A ≤ λε/4 and K′ = K(λε/2), so L6 cites it directly. The STATEMENT L4q row and SKELETON Step 1 now name c_{K′}.
2. **Shift proof: accepted;** no change.
3. **Boundary construction: accepted, with the explicit kernel added.** A3 is written as ‖u\*‖₁ ≤ V/n². The same null-space remainder θ\* − Su\* is used for both vectors, so θ_h − θ\* = S(u_h − u\*) with no projection.
4. **‖u_h‖∞ ≤ CV/(n²w): added** as claim (3), together with the oracle check λ‖u_h‖∞ = o(1). The width prescriptions are unified: the STATEMENT table now cites w ≍ n(ε/V)^{2/5}.
5. **Bias charge: accepted.** The factor c_{K′}^{5/6} is kept explicit. "Same order as K" is replaced by a fresh threshold check at half radius (monotonicity goes the wrong way). L4 is used where (C) fails. The growing-V remark is corrected, using the new L3 constants: V ≲ n^{11/14}(log n)^{−6/35}.
6. **Elementary verification: adopted** as R2, replacing my Gamma bound, with its scope stated: it supplies (C) only, and L6 still needs L3.
