# Audit of Lemma S (`astra_sigma_concentration.md`): independent referee (Opus)

*2026-11-23, about 13:30 CT. The file was audited as it stands at HEAD 85599cc. Read-only review: no other files were changed and no compute jobs were run. The notation, L3, L5 and L6 were checked against `T05_Proofs/THEOREM_B_COMPLETE.md`, `L3_small_ball.md` and `L6_evidence_lower_bound.md`. The model was checked against `method/individual/Individual_Sampler_PMALA_Augmented.R`.*

## Verdicts

| Section | Verdict | One line |
|---|---|---|
| §1: (H) ⇔ σ/s_n → 1 | **ACCEPT WITH FIXES** (editorial) | Every step and constant re-derived and correct. The fixes make the coverage claim explicit. |
| §2: compact containment | **ACCEPT WITH FIXES** (editorial; one optional strengthening) | Every constant re-derived and correct. Two steps are implicit, and (A3) is stronger than the proof uses. |
| §3: transfer from U | **ACCEPT** | The disintegration and the measurability argument are correct, and there is no circularity. Finding 8 sharpens the open-input paragraph. |

**No mathematical error was found.** All the findings below are clarifications, scope statements, or ways to strengthen the result.

---

## Step-by-step verification (what was checked, and the result)

**§1.**
- **Propriety.** ∫ e^{−ρ_τ(z)/σ} dz = σ/τ + σ/(1−τ) = σ/(τ(1−τ)). The penalty density is at most the constant (λ/2)^m. So ∫ σ^{−n}(σ/τ(1−τ))^n dIG < ∞ ✓.
- **IG conditional.** The joint density ∝ σ^{−n−a−1}e^{−(b+Q)/σ}, so σ | θ, y ~ IG(n+a, b+Q) and G = (b+Q)/σ ~ Gamma(n+a, 1) ✓.
- **Chebyshev.** Suppose |G/n−1| > h and a/n < h/2. Then |G−(n+a)| > nh/2, so the probability is at most (n+a)/(n²h²/4) ✓. The law of G does not depend on θ, so integrating over Π^θ is exact ✓.
- **LLN.** E|avg W^K − E avg W^K| ≤ (nK²)^{1/2}/n = K/√n. Also W − W∧K = (W−K)₊ ≤ W·1{W>K}. Together these give a total of K/√n + 2u(K) ✓. And s_n ≤ K + u(K) ✓.
- **Equivalence of the moment conditions.** k|Z| ≤ W ≤ max(τ, 1−τ)|Z| ≤ |Z|, so E W1{W>K} ≤ E|Z|1{|Z|>K} and E|Z|1{|Z|>K} ≤ k^{−1}E W1{W>kK} ✓. The 1+γ moment bound suffices, since E W1{W>K} ≤ E W^{1+γ}/K^γ ✓.
- **Ratio.** σ/s_n = A/(G/n) ∈ [(1−h)/(1+h), (1+h)/(1−h)], so the error is at most 2h/(1−h) ✓.
- **Split for A.** |A−1| ≤ (|Q−Q_*|/n + |Q_*/n − s_n| + b/n)/d, with each term below dh/3 ✓. The event {|A−1| > h} depends on θ only, so its joint mass equals its Π^θ mass ✓.
- **Converse.** The product error is at most 2h + h² ✓. Then |Q−Q_*|/n ≤ |A−1|B + |s_n − Q_*/n| + b/n ✓.
- **Lipschitz bound.** |Q−Q_*|/n ≤ ‖δ‖_{1,n} ≤ √v + v (Cauchy–Schwarz on {|δ_i| ≤ 1}, direct summation on {|δ_i| > 1}) ✓.
- **Probability versus expectation.** For 0 ≤ X ≤ 1, EX ≤ t + P(X > t) and P(X > t) ≤ EX/t ✓.

**§2, data roughness.**
- (Dy)_j = −y_j + 3y_{j+1} − 3y_{j+2} + y_{j+3}. The coefficient on y_j has magnitude one. So, conditionally on the other observations, T_j = |Z_j − t| with t independent of Z_j by (A1) ✓.
- ρ_τ(x) ≤ |x| ✓.
- Write ρ_τ(z−t) − ρ_τ(z) = ∫₀ᵗ(1{z<v} − τ)dv. Taking expectations with Fubini on the finite interval gives the oriented ∫₀ᵗ(F(v−) − τ)dv, which is at least 0. This holds because θ\* is the generalized-inverse quantile: F < τ on (−∞, 0) and F ≥ τ on [0, ∞) ✓.
- **Omitted terms.** The three omitted terms are W_{n−2}, W_{n−1}, W_n, and they cost at most 3K/n + u(K) ✓.
- **Bound on T_j.** T_j ≤ V/n² + 8 max|Z_i|. For K > 2V, the event T_j > K forces 8 max > K/2, so max > K/16 and T_j ≤ 16 max ✓. Each i is counted at most four times. So n^{−1}Σ E T_j1{T_j>K} ≤ 64·n^{−1}Σ E|Z_i|1{|Z_i|>K/16} → 0 ✓.
- **m-dependence.** T_j and T_{j′} are independent when |j−j′| ≥ 4. There are at most 7 overlapping partners per j, and each |Cov| ≤ K² (in fact ≤ K²/4). So the variance over n² is at most 7mK²/n² ≤ 7K²/n ✓.
- **ℓ₁ operator norm.** ‖D‖_{1→1} is the maximum column sum, 1+3+3+1 = 8 ✓. The chain nd/2 − 8Q/k ≥ nd/2 − 8qn/k = nd/4 at q = kd/32 ✓.

**§2, evidence.**
- **L3 at radius one.** With ε = 1 and x = n^{5/2}/λ, L3 holds for all n ≥ 5, λ > 0 and ε > 0, with no further conditions ✓. Its exponent is 30nλ^{−2/5}(log m)^{1/5} + 6. This is at most n once λ ≥ (30(1+o(1)))^{5/2}(log n)^{1/2}, which is implied by λ/log n → ∞ ✓.
- **Entries of S.** (C³)_{ij} = (i−j+1)(i−j+2)/2 ≤ n(n+1)/2 ≤ n². So ‖Su\*‖_∞ ≤ n²‖u\*‖₁ ≤ V and ‖P⊥θ\*‖_n = ‖P⊥Su\*‖_n ≤ V ✓.
- **c-ball.** P_N(θ−θ\*) = N(c − Nᵀ(θ\* − Su)), so the polynomial error has Euclidean norm at most 1 on the ball ✓. Then ‖θ−θ\*‖_n ≤ 1/√n + 1 + V ≤ 2 + V ✓.
- **Bound on Q.** Q/n ≤ Q_*/n + ‖δ‖_{1,n} ≤ Q_*/n + ‖δ‖_n ≤ B + 3 + V ✓.
- **Scales in [1, 2].** On s ∈ [1, 2], s^{−n}e^{−Q/s} ≥ 2^{−n}e^{−n(B+3+V)}. IG(0.1, 0.1)([1, 2]) is a positive constant ✓. Hence C = 1 + log 2 + B + 3 + V + o(1) ✓.

**§2, tails.**
- **Flat bound.** Q ≥ k‖y−θ‖₁ ≥ k‖y−θ‖₂ ≥ k‖Nᵀ(y−θ)‖₂ = k‖c − Nᵀ(y−Su)‖₂. So ∫e^{−Q/(2s)}dc ≤ 8π(2s/k)³ = C_k s³ ✓.
- **Upper tail.** C_k ∫_{s>H₀} s^{3−n} dIG ≤ C_k H₀^{3−n} (n > 3). Dividing by e^{−Cn} leaves at most C_k H₀³e^{−n} when log H₀ > C+1 ✓.
- **Lower tail, Q ≥ qn.** The contribution is at most C_k sup_{s<l} s³·exp{n[−log s − q/(2s)]} ✓.
- **Lower tail, Q < qn.** Under Laplace(λ), |u_j| ~ Exp(λ) and E e^{(λ/2)|u_j|} = 2. So P_λ(‖u‖₁ ≥ nd/4) ≤ 2^{m}e^{−λnd/8} with m = n−3 ✓.
- **IG negative moment.** E σ^{3−n} = E X^{n−3} with X = 1/σ ~ Gamma(a, rate b). This equals Γ(a+n−3)/(Γ(a)b^{n−3}) ✓. The ratio is a product of n−3 factors a+j ≤ n+a ✓. So the log cost is (n−3)[log(n+a) + log(1/b) + log 2] = O(n log n). It is dominated by λnd/8, since λ/log n → ∞ ✓.
- **Final assembly.** The bound is 1 off the two events, plus deterministic bounds on them. Uniformity holds because every probability bound is uniform ✓.

**§3.**
- **Conditional law.** Given σ = s, the joint density restricted to θ is ∝ e^{−Q/s}e^{−λ‖Dθ‖₁}, because the penalty does not involve σ. So it equals the fixed-scale posterior Π_s for every s > 0, and Π_s is proper by the flat bound ✓.
- **Disintegration.** Π^θ(E|y) = ∫Π_s(E|y)Π(ds|y) ≤ sup_I Π_s(E|y) + Π(σ∉I|y) ✓.
- **Measurability.** For s ≤ H₀, e^{−Q/s} ≤ e^{−Q/H₀}, and ∫e^{−Q/H₀}dν ≤ C_k(2H₀)³/8 < ∞. Dominated convergence gives continuity of the numerator and the denominator in s ∈ I, and the denominator is positive. So the supremum equals a supremum over a countable dense set. Each Π_s(E_y|y) is Borel in y by Tonelli, because E_y = {|Q(θ) − Q(θ\*)| > nt} is jointly Borel in (θ, y) ✓.
- **Circularity.** §2 uses only the unconditional LLN of §1, not (H). U is labeled as assumed ✓.

---

## Findings

**1. CONFIRMED (§1, coverage wording).** "This covers … the heteroscedastic paper designs" checks only the integrability half of the assumptions. The separate assumption s_n ≥ d is never verified for the designs. I checked the three generators in `simulate_data`:
- **Normal:** sd (1+x²)/4 ∈ [¼, ½];
- **Beta(1, 11−10x):** shape β ∈ [1, 11], support [0, 1];
- **Mixed:** weights x and 1−x on N(∓0.2, ½).

All three have uniformly bounded moments, so u(K) → 0. Each also has E ρ_τ(Z_i) bounded below uniformly in x for interior τ, so s_n ≥ d. In each case Eρ_τ(Z) is continuous and positive in the design parameter on a compact set. So the claim is true, but half of it is not argued.
*Fix:* add one sentence: "For the three paper designs, s_n ≥ d holds because the per-row law ranges over a compact family (sd ∈ [¼, ½]; β ∈ [1, 11]; mixture weight ∈ [0, 1]) on which Eρ_τ(Z) is continuous and positive." Also replace "centered component locations" with "component locations relative to the τ-quantile". The current wording is ambiguous between mean-centring and quantile-centring.

**2. CONFIRMED (§2, an optional strengthening: (A3) can be dropped).** The proof uses (A3) in only two places, and both need much less:
- the UI bound T_j ≤ |(Dθ\*)_j| + 8 max|Z_i|;
- the evidence step, through ‖P⊥θ\*‖_n ≤ V.

A uniform sup-norm bound ‖θ\*‖_∞ ≤ R suffices for both: |(Dθ\*)_j| ≤ 8R, and ‖P⊥θ\*‖_n ≤ ‖θ\*‖_n ≤ R. The rest of §2 is unchanged with V replaced by 8R, and with K > 16R in the UI step. The extension matters because the **PC baseline violates (A3)** at fixed V. Each jump contributes 8×(jump) to ‖Dθ\*‖₁, which is order 1, not order n^{−2}. Yet PC is bounded. So with this change, compact containment holds for all three baselines and all three noises. The lower bound E T_j ≥ E W_j never uses smoothness.
*Fix:* restate the §2 hypothesis as "sup_P ‖θ\*‖_∞ ≤ R (implied by (A3) together with a bounded quadratic part)". If (A3) is kept for uniformity with Theorem B, add a remark that only boundedness is used. Then edit the last sentence of the file ("Section 2 uses both the truth restriction …") to match.

**3. CONFIRMED (§2, lower tail; an implicit step).** "This contribution is at most C_k e^{−(C+1)n}" silently drops the factor s³ from s^{3−n} = s³·s^{−n}. That is valid only because l < 1, which is assumed but not invoked. Also, sup_{s<l}[−log s − q/(2s)] is attained at s = l only when l ≤ q/2, since g(s) = −log s − q/(2s) increases on (0, q/2).
*Fix:* write the bound as "≤ C_k l³ exp{n·g(l)} with l ≤ min(1, d, q/2) and g(l) < −C−1". This also gives an explicit admissible l.

**4. CONFIRMED (§2, order of constants; bookkeeping).** The proof is non-circular, but the order in which constants are fixed is left implicit, and l and H₀ depend on C. The order is:
1. (k, d, B, V) come from the class;
2. q = kd/32;
3. C = 4 + log 2 + B + V + (any slack), which depends on IG(a, b)([1, 2]) only through o(1);
4. then H₀ = e^{C+1} ∨ B, and l comes from Finding 3.

*Fix:* add one line listing this order, so a reader can see that l and H₀ are "fixed" in the sense of the statement.

**5. CONFIRMED (§2, citation detail).** The file quotes L3 with (log n)^{1/5}. L3 states (log m)^{1/5}, with m = n−3. The bound is still valid, because log m ≤ log n and φ is bounded from above. L3 also requires n ≥ 5.
*Fix:* write "(log m)^{1/5} ≤ (log n)^{1/5}, n ≥ 5".

**6. CONFIRMED (scope: the model as implemented).** The Gamma pivot of §1 (shape n+a, rate b+Q) and the identity Π(θ | σ=s, y) = Π_s in §3 both rely on the penalty e^{−λ‖Dθ‖₁} not involving σ. I checked that this is the paper's default (`prior_scale <- "none"`, line 79 of the individual sampler). Under the Park–Casella option `prior_scale = "sigma"` (prior ∝ (λ/σ)^m e^{−(λ/σ)‖Dθ‖₁}), the conditional becomes IG(n+m+a, b+Q+λ‖Dθ‖₁). Then §1's target s_n is wrong, and §3's Π_s is a different posterior. The augmented sampler's σ | θ, z ~ IG(a + 3n/2, …) integrates over z back to the lemma's IG(n+a, b+Q), so the two agree.
*Fix:* add one sentence to §1: "The penalty is σ-free (the paper's prior; `prior_scale = "none"`). The σ-scaled variant changes the pivot and is not covered."

**7. PLAUSIBLE (§1, why "at each fixed level").** For heteroscedastic Gaussian noise, d and B scale with the overall noise level σ₀. Nothing in §1 is uniform as σ₀ → 0 or σ₀ → ∞, because d → 0 kills Chebyshev's split at dh/3. This is probably what "at each fixed level" means, but it is not said.
*Fix:* replace "at each fixed level" with "for each fixed noise level σ₀; constants depend on σ₀ through (d, B), and nothing is uniform as σ₀ → 0".

**8. CONFIRMED (§3 and the CONJECTURE paragraph; it sharpens the open input).** On the EM route, Hypothesis U on the whole of I = [l, H₀] reduces exactly to (EM) at the single largest precision ω₂ = 1/l. There are three reasons:
- **(EM) is monotone in ω.** By Jensen (x ↦ x^{ω′/ω} is concave), E e^{−ω′X} ≤ (E e^{−ωX})^{ω′/ω} ≤ e^{−bω′min(δ², |δ|)} for ω′ ≤ ω. So (EM) at ω₂ gives (EM) at every ω ∈ I with the same b.
- **The supremum over s costs nothing.** For ω ∈ [ω₁, ω₂], e^{−ωℛ} ≤ e^{−ω₁ℛ} + e^{−ω₂ℛ} pointwise. So E sup_ω N_ω(E) ≤ E N_{ω₁}(E) + E N_{ω₂}(E).
- **The L6 event does not depend on ω.** It is {∫ℛ dν_G ≤ (1.44C₁+1)nε²}. So one event serves every ω, with denominator at least ν(G)e^{−ω₂(1.44C₁+1)nε²}.

Theorem B's Step 4 then goes through with sup over s inside the expectation. The only change is that M must satisfy bω₁M/2 > ω₂(1.44C₁+1) + C_pr.

The consequence confirms, and makes precise, the file's own diagnosis. In the differentiable case, (EM) at ω₂ = 1/l forces F′(q) ≥ τ(1−τ)/l + 2b. Here l is tiny, below q/(2(C+1)), so this fails for every paper design. So the EM route **cannot** supply U on the coarse interval. The open input is therefore genuinely a non-EM, local-margin fixed-scale theorem (an L8′-type route), or a narrower containment interval.
*Fix:* add this reduction to the CONJECTURE paragraph. It turns "remains to be established" into a precise statement of what is missing and why Theorem B cannot fill it. It also shows that a pointwise-in-s theorem upgrades to U for free whenever its denominator event is s-free. This is worth stating, because §3's "a bound of this form" otherwise looks as if it requires a separate uniformity argument.

**9. CONFIRMED (§2, statement header; minor).** The section title says "at oracle tuning", but the proof uses only λ_n/log n → ∞. Two steps use it: L3 at radius one needs λ ≳ √log n, and the IG-moment step needs λ ≫ log n. The second is genuinely needed on this route. The IG(a, b) negative moment of order n−3 is about (n/b)^n, an n log n cost that the roughness penalty λnd/8 must beat.
*Fix:* retitle the section "at growing deterministic tuning (λ/log n → ∞)". Add one sentence saying that the log n threshold comes from the IG prior's negative moment and is not a slack in the argument.

---

## Hidden assumptions and circularity: summary

- **No circularity.**
  - §2 uses the unconditional LLN, the roughness bound, L3 and the IG moment. It does not use (H) or any trend localization.
  - §3 uses U (labeled as assumed) together with §2.
  - §1 uses (H).
- **Assumptions used but not displayed:**
  - the penalty is σ-free (Finding 6);
  - l < 1 and l ≤ q/2 in the lower tail (Finding 3);
  - n ≥ 5 for L3 (Finding 5);
  - s_n ≥ d for the paper designs, which is true but unargued (Finding 1).
- **Scope correctly stated in the file:** λ is deterministic (no mixing over a learned λ), and U is open.
