# Lemma L3: centred small-ball bound for the Laplace difference prior

**Status:** self-checked (2026-11-22). Second read done, with the fixes listed at the end; Astra's and the VP's L3 points from their final reviews of v3 are applied. The numerical check `checks/l3_singular_values.py` **passed** (Engineering, NOTS job 2857810, HEAD 97a04c2): see "Numerically checkable claims". Ready for the advisor check.
**Depends on:** standard facts only: the Gaussian scale-mixture representation of the Laplace law, Anderson's theorem, singular values of the cumulative-sum matrix, and Horn's (Ky Fan's) product inequality.
**Used by:** L6 (prior mass) and L4q (condition (C)).

## Setting

Notation as in L4q:
- Π = Π_λ = Laplace(λ)^{⊗m} on ℝᵐ, with m = n − 3;
- A = n^{−1/2}P⊥S, with S = C³[:, 4:n], where C is the n×n lower-triangular all-ones (cumulative-sum) matrix;
- B_ε = {u : ‖Au‖₂ ≤ ε} and φ(ε) = −log Π(B_ε).

## Statement

There is an absolute constant C such that, for all n ≥ 5 (so m ≥ 2), λ > 0, and ε > 0,

  φ(ε) ≤ 30 · x^{2/5} · (log m)^{1/5}  +  6,  where x := n^{5/2}/(λε).

The relevant range is x ≥ 1, i.e. ε ≤ n^{5/2}/λ, but the bound holds for all ε.

**In words.** φ(ε) ≲ (n^{5/2}/(λε))^{2/5} up to a (log n)^{1/5} factor. This is the exponent verified numerically in T-03 (the twice-integrated-walk law), with a polylog loss. That loss is absorbed by the (log n)^c in Theorem A.

## Proof

**Step 1 (scale mixture and Anderson).** A Laplace(λ) variable can be written u = √V·ξ, with ξ ~ N(0, 1) independent of V ~ Exp(rate λ²/2). So, conditional on V = (V₁, …, V_m), u is N(0, diag V).

B_ε is a centred symmetric convex set. **Anderson's theorem:** if Σ₁ ⪯ Σ₂ in the psd order, then N(0, Σ₁)(B) ≥ N(0, Σ₂)(B). On the event {maxⱼ Vⱼ ≤ v₀} we have diag V ⪯ v₀I, hence

  Π(B_ε) ≥ P(maxⱼ Vⱼ ≤ v₀) · γ_{v₀}(B_ε),  where γ_{v₀} := N(0, v₀ I_m).

**Step 2 (cost of the truncation).** P(maxⱼ Vⱼ ≤ v₀) = (1 − e^{−λ²v₀/2})^m. Choose v₀ := 2 log(m)/λ². Then this probability equals (1 − 1/m)^m ≥ 1/4 for m ≥ 2, so

  −log P(maxⱼ Vⱼ ≤ v₀) ≤ log 4 ≤ 2.

**Step 3 (reduction to a weighted χ² series).** Let σ₁ ≥ σ₂ ≥ … be the singular values of A. By rotation invariance of γ_{v₀},

  γ_{v₀}(B_ε) = P( Σ_r v₀σ_r² ξ_r² ≤ ε² ),  with ξ_r i.i.d. N(0, 1).

**Step 4 (singular-value bound: σ_r(A) ≤ 91.1·n^{5/2}r^{−3}).**
1. The cumulative-sum matrix C_N (N×N) satisfies σ_k(C_N) = 1/(2 sin((2k−1)π/(4N+2))). This is standard: C⁻ᵀC⁻¹ is tridiag(−1, 2, −1) with last diagonal entry 1.
2. Using sin x ≥ 2x/π on [0, π/2], σ_k(C_n) ≤ (2n+1)/(2(2k−1)) ≤ (2n+1)/(2k) ≤ 1.5n/k.
3. **Horn / Ky Fan:** σ_{i+j+l−2}(XYZ) ≤ σᵢ(X)σⱼ(Y)σₗ(Z). With i = j = l = k this gives σ_{3k−2}(C³) ≤ σ_k(C)³. Take k := ⌊(r+2)/3⌋, so that 3k − 2 ≤ r and k ≥ r/3. By monotonicity, σ_r(C³) ≤ σ_{3k−2}(C³) ≤ σ_k(C)³ ≤ (1.5n·3/r)³ = (4.5n/r)³.
4. S is a column-submatrix of C³, so σ_r(S) ≤ σ_r(C³) by Cauchy interlacing. P⊥ is a contraction.
5. Therefore σ_r(A) ≤ n^{−1/2}(4.5n/r)³ = 91.1·n^{5/2}r^{−3}.

**Step 5 (comparison).** Increasing any weight decreases the probability, by pointwise monotonicity (Anderson is not needed). Appending extra terms r > m with positive weights decreases it too. So with b := v₀(91.1)²n⁵,

  γ_{v₀}(B_ε) ≥ P( Σ_{r ≥ 1} b r^{−6} ξ_r² ≤ ε² ).

**Step 6 (elementary small-ball bound for Σ b r^{−6}ξ_r²).** Let K := ⌈(8b/(5ε²))^{1/5}⌉.
- **Tail.** Σ_{r>K} b r^{−6} ≤ b/(5K⁵) ≤ ε²/8. By Markov's inequality, P(Σ_{r>K} b r^{−6}ξ_r² > ε²/2) ≤ 1/4.
- **Head.** Since the coordinates are independent,

  P(Σ_{r≤K} b r^{−6}ξ_r² ≤ ε²/2) ≥ ∏_{r≤K} P(ξ_r² ≤ ε²r⁶/(2Kb)) = ∏_{r≤K} P(|ξ| ≤ t_r),  with t_r := εr³/√(2Kb).

  Use P(|ξ| ≤ t) ≥ 2φ(1)·min(t, 1) ≥ 0.48·min(t, 1). From K⁵ ≥ 8b/(5ε²) we get 2Kb ≤ (5/4)ε²K⁶, so t_r ≥ t₁ = ε/√(2Kb) ≥ 0.894·K^{−3}. Since t_r ≥ t₁r³ ≥ 0.894(r/K)³, keeping the full product (instead of bounding every factor by the worst one) gives

  log P(head) ≥ Σ_{r≤K} log(0.429·(r/K)³) = K log 0.429 + 3 log(K!/K^K) ≥ −0.85K − 3K = −3.85K,

  using K! ≥ (K/e)^K. **No log K factor appears.**
- **Combining.** The head and tail are independent, so

  −log γ_{v₀}(B_ε) ≤ log(4/3) + 3.85K,  with K ≤ 1 + (8b/(5ε²))^{1/5} = 1 + (1.6·91.1²·2 log m)^{1/5}·x^{2/5} ≤ 1 + 7.7(log m)^{1/5}x^{2/5}.

**Step 7 (assembly).** φ(ε) ≤ log 4 + log(4/3) + 3.85·(1 + 7.7(log m)^{1/5}x^{2/5}) ≤ 30·x^{2/5}(log m)^{1/5} + 6. (K ≥ 1 always, because of the ceiling.) ∎

## Remarks

- **Sharpness.** The exponent 2/5 is sharp (lower-bound direction): the T-03 numerics showed the local slope tending to 0.404. Only the factor (log m)^{1/5} is lost. It comes from truncating V at the 2 log m/λ² level. A Laplace-specific small-deviation argument could remove it, but that is not needed.
- **This resolves the T-04 caveat.** Weighted-i.i.d. small-deviation results did not apply because the singular basis destroys independence. Conditioning on V restores Gaussianity, and Anderson's theorem dominates the non-identical variances by v₀I. **No Laplace small-deviation theory is needed.**
- **Effect on L4q's condition (C).** Inserting L3, (C) holds once λε ≥ 51·n^{10/7}(log m)^{1/7} (L4q, R1). At the oracle tuning λε ≍ n^{25/12}, which is comfortably enough.

## Numerically checkable claims

`checks/l3_singular_values.py`:
1. the exact singular values of C_N;
2. DS = I;
3. σ_r(A) ≤ 91.1·n^{5/2}r^{−3}.

**Result (NOTS job 2857810, single thread):**
- the singular values of C_N match the closed form to ≤ 4.0e-15 (N = 5, 50, 400);
- ‖DS − I‖_max = 0 exactly (n = 50, 300, 1200);
- max_r σ_r(A)/(n^{5/2}r^{−3}) = 0.104, 0.121 and 0.124 at n = 50, 300 and 1200, against the bound 91.1. The bound is loose by a factor of about 730, and the ratio at r = 1 is 0.0040.

## Second read (2026-11-22): fixes

1. **Step 4.3:** the index should be ⌊(r+2)/3⌋, not ⌈(r+2)/3⌉. The ceiling can give 3k − 2 > r, which is the wrong direction for monotonicity. The final bound (4.5n/r)³ is unchanged.
2. **Statement:** n ≥ 5 is required, so that m ≥ 2. For m = 1, v₀ = 0 and Step 2 fails. Also, log(e + x) becomes log(e + x log m), because log K carries a (1/5)·log log m term. In the application x is polynomial in n, so this changes nothing.
3. **Constants made explicit** in Steps 6–7: t₁ ≥ 0.894K^{−3}, head cost K(0.85 + 3 log K), and K ≤ 1 + 7.7(log m)^{1/5}x^{2/5}. Step 5 needs only pointwise monotonicity.

All other steps were re-verified: the scale-mixture rate λ²/2, Anderson's direction, (1 − 1/m)^m ≥ 1/4, the singular values of C_N (tridiagonal (C⁻¹)ᵀC⁻¹ with last diagonal entry 1), sin x ≥ 2x/π on the relevant range, interlacing for column deletion, the tail integral 1/(5K⁵), and Markov's inequality.
4. **Head bound with the full product** (suggested independently by Astra and by the VP in their final reviews of v3). Keeping ∏(r/K)³ = (K!/K^K)³ ≥ e^{−3K} removes the log K factor. The bound becomes φ(ε) ≤ 30x^{2/5}(log m)^{1/5} + 6, with explicit constants and a loss of only (log m)^{1/5}. This supersedes fix 2's log(e + x log m).
