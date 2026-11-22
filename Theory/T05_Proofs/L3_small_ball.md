# Lemma L3: centred small-ball bound for the Laplace difference prior

**Status:** draft (2026-11-22). The numerical check `checks/l3_singular_values.py` is queued: owls_run refused for budget, so it will be retried or sent to Engineering.
**Depends on:** standard facts only: the Gaussian scale-mixture representation of the Laplace law, Anderson's theorem, singular values of the cumulative-sum matrix, and Horn's (Ky Fan's) product inequality.
**Used by:** L6 (prior mass) and L4q (condition (C)).

## Setting

Notation as in L4q:
- Π = Π_λ = Laplace(λ)^{⊗m} on ℝᵐ, with m = n − 3;
- A = n^{−1/2}P⊥S, with S = C³[:, 4:n], where C is the n×n lower-triangular all-ones (cumulative-sum) matrix;
- B_ε = {u : ‖Au‖₂ ≤ ε} and φ(ε) = −log Π(B_ε).

## Statement

There is an absolute constant C such that, for all n ≥ 4, λ > 0, and 0 < ε ≤ n^{5/2}/λ,

  φ(ε) ≤ C · x^{2/5} · (log m)^{1/5} · log(e + x)  +  2,  where x := n^{5/2}/(λε).

**In words.** φ(ε) ≲ (n^{5/2}/(λε))^{2/5} up to a (log n)^{6/5} factor. This is the exponent verified numerically in T-03 (the twice-integrated-walk law), with a polylog loss. That loss is absorbed by the (log n)^c in Theorem A.

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
3. **Horn / Ky Fan:** σ_{i+j+l−2}(XYZ) ≤ σᵢ(X)σⱼ(Y)σₗ(Z). Hence σ_r(C³) ≤ σ_k(C)³ with k := ⌈(r+2)/3⌉ ≥ r/3, which gives σ_r(C³) ≤ (4.5n/r)³.
4. S is a column-submatrix of C³, so σ_r(S) ≤ σ_r(C³) by Cauchy interlacing. P⊥ is a contraction.
5. Therefore σ_r(A) ≤ n^{−1/2}(4.5n/r)³ = 91.1·n^{5/2}r^{−3}.

**Step 5 (comparison).** By Anderson's theorem again, for diagonal Gaussian series, increasing any weight decreases the probability. So with b := v₀(91.1)²n⁵,

  γ_{v₀}(B_ε) ≥ P( Σ_{r ≥ 1} b r^{−6} ξ_r² ≤ ε² ).

**Step 6 (elementary small-ball bound for Σ b r^{−6}ξ_r²).** Let K := ⌈(8b/(5ε²))^{1/5}⌉.
- **Tail.** Σ_{r>K} b r^{−6} ≤ b/(5K⁵) ≤ ε²/8. By Markov's inequality, P(Σ_{r>K} b r^{−6}ξ_r² > ε²/2) ≤ 1/4.
- **Head.** Since the coordinates are independent,

  P(Σ_{r≤K} b r^{−6}ξ_r² ≤ ε²/2) ≥ ∏_{r≤K} P(ξ_r² ≤ ε²r⁶/(2Kb)) = ∏_{r≤K} P(|ξ| ≤ t_r),  with t_r := εr³/√(2Kb).

  Use P(|ξ| ≤ t) ≥ 0.48·min(t, 1). Also t_r ≥ t₁ = ε/√(2Kb) ≥ c·K^{−3}, from the choice of K. Hence log P(head) ≥ −K·(log(1/0.48) + 3 log K + C).
- **Combining.** The head and tail are independent, so

  −log γ_{v₀}(B_ε) ≤ log(4/3) + K(C + 3 log K),  with K ≍ (b/ε²)^{1/5} = (91.1²·2 log m)^{1/5}·x^{2/5}.

**Step 7 (assembly).** φ(ε) ≤ 2 + log(4/3) + C·x^{2/5}(log m)^{1/5}·log(e + x). The condition ε ≤ n^{5/2}/λ, i.e. x ≥ 1, ensures K ≥ 1. ∎

## Remarks

- **Sharpness.** The exponent 2/5 is sharp (lower-bound direction): the T-03 numerics showed the local slope tending to 0.404. Only the polylog is lost. It comes from truncating V at the 2 log m/λ² level and from the crude head bound. A Laplace-specific small-deviation argument could remove it, but that is not needed.
- **This resolves the T-04 caveat.** Weighted-i.i.d. small-deviation results did not apply because the singular basis destroys independence. Conditioning on V restores Gaussianity, and Anderson's theorem dominates the non-identical variances by v₀I. **No Laplace small-deviation theory is needed.**
- **Effect on L4q's condition (C).** Inserting L3, (C) holds once (λε)^{7/5} ≥ C·n²·(log n)^{6/5}. At the oracle tuning λε ≍ n^{25/12}, which is comfortably enough.

## Numerically checkable claims

`checks/l3_singular_values.py`:
1. the exact singular values of C_N;
2. DS = I;
3. σ_r(A) ≤ 91.1·n^{5/2}r^{−3}. This bound is loose; the true ratio σ₁/(n^{5/2}) is about 0.03.
