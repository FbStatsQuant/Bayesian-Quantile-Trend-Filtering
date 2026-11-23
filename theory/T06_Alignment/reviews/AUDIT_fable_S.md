# Cross-family audit of Lemma S (Astra) — Fable

*Fable, research sub-agent for Theory, 2026-11-23. Target: `../astra_sigma_concentration.md` (§§1–3 and the Theory response table). Pure mathematics, checked by hand; no compute was run. I formed the view in Part A before opening `AUDIT_opus_S.md`; Part C compares the two.*

## Verdicts

| Section | Verdict |
|---|---|
| §1 Conditional scale consistency, (H) ⇔ σ/s_n → 1 | **ACCEPT** |
| §2 Compact containment of σ in [l, H₀], no trend localization | **ACCEPT WITH FIXES** (editorial: constants and one implicit step; no mathematical error) |
| §3 Transfer from a fixed-scale theorem | **ACCEPT** |
| Theory response table (9 rulings) | **ACCEPT**; every ruling re-derived and agreed (Part B) |
| §2 uniformly over λ ≥ Λ₋, and under λ-mixing, as used in V2T Step 2 | **HOLDS** (finding 9) |

No step fails. No circularity: §2 uses no property of the trend posterior, §3 passes from §2 and a fixed-scale hypothesis to (H), and §1 passes from (H) to scale consistency.

---

## Part A. Findings

### §1

**1. CONFIRMED — the conditional law and the Chebyshev step are correct.**
- The σ-dependent factors of the joint posterior are σ^{−n}e^{−Q(θ)/σ}·σ^{−a−1}e^{−b/σ}, so σ | θ, y ~ IG(n + a, b + Q(θ)) and G = (b + Q)/σ ~ Gamma(n + a, 1). This uses only that the θ-prior is σ-free (and, if λ is random, that its prior is σ-free).
- G has mean and variance n + a. G/n − 1 = (G − (n + a))/n + a/n, so for a/n < h/2: Π(|G/n − 1| > h | θ, y) ≤ (n + a)/(nh/2)² = 4(n + a)/(n²h²). As stated.
- A − 1 = b/(ns_n) + (Q − Q\*)/(ns_n) + (Q\*/n − s_n)/s_n. Each numerator ≤ dh/3 and s_n ≥ d give |A − 1| ≤ h.
- On the good events, σ/s_n = A/(G/n) ∈ [(1−h)/(1+h), (1+h)/(1−h)], and both ends are within 2h/(1 − h) of 1.

**2. CONFIRMED — the law of large numbers under row-average UI is correct.**
- Clipped part: Var(W∧K) ≤ K²/4, so E|n⁻¹Σ(Wᵢ∧K − E(Wᵢ∧K))| ≤ K/(2√n) ≤ K/√n.
- Unclipped remainder: E|n⁻¹Σ((Wᵢ − K)₊ − E(Wᵢ − K)₊)| ≤ 2n⁻¹ΣE(Wᵢ − K)₊ ≤ 2u(K).
- So E|Q\*/n − s_n| ≤ K/√n + 2u(K), uniformly over the class. No second moment is used.
- Side claims: k|z| ≤ ρ_τ(z) ≤ |z| with k = min(τ, 1 − τ); s_n ≤ K + u(K); a common 1 + γ moment gives u(K) ≤ sup E W^{1+γ}/K^γ. All correct.

**3. CONFIRMED — propriety and the converse.**
- ∫e^{−ρ_τ(z)/σ}dz = σ/τ + σ/(1 − τ) = σ/(τ(1 − τ)), so ∫σ^{−n}e^{−Q/σ}dθ = (τ(1 − τ))^{−n}, free of σ; the penalty factor is ≤ 1. The joint posterior is proper.
- Converse: A = (σ/s_n)(G/n), and (Q − Q\*)/n = s_n(A − 1) − b/n − (Q\*/n − s_n), with s_n ≤ B. So (H) is equivalent to scale consistency.
- |Q − Q\*|/n ≤ ‖δ‖₁,ₙ ≤ √v + v with v = Δ²ₙ(δ): correct (Cauchy–Schwarz on {|δᵢ| ≤ 1}, |δᵢ| = min(δᵢ², |δᵢ|) elsewhere).

**4. CONFIRMED (scope, not an error) — §1 never uses λ.** The statement says "fixed deterministic λ", but the proof uses the roughness prior only through σ-freeness and propriety. So §1 holds verbatim for any σ-free prior on (θ, λ), including the truncated-Gamma mixture of V2T. V2T's conclusion 3 relies on exactly this; it is valid.

### §2

**5. CONFIRMED — the data-roughness event.**
- *Conditional argument.* (Dy)ⱼ = ±(yⱼ − 3y_{j+1} + 3y_{j+2} − y_{j+3}), so Tⱼ = |Zⱼ − t| with t := 3y_{j+1} − 3y_{j+2} + y_{j+3} − θ\*ⱼ, a function of (Z_{j+1}, Z_{j+2}, Z_{j+3}) only, hence independent of Zⱼ by (A1). The unit endpoint coefficient is what makes this work.
- *E|Zⱼ − t| ≥ Eρ_τ(Zⱼ − t) ≥ EWⱼ.* The first step is |z| ≥ ρ_τ(z). The second: Eρ_τ(Zⱼ − t) − Eρ_τ(Zⱼ) = ∫₀ᵗ(Fⱼ(v) − τ)dv ≥ 0 for both signs of t, because θ\*ⱼ is a τ-quantile (generalized inverse): Fⱼ(0) ≥ τ and Fⱼ(0−) ≤ τ. **No margin condition and no continuity are needed**, so atoms are allowed. E|Zⱼ| < ∞ follows from the UI condition (each EWᵢ ≤ nB).
- *Mean.* n⁻¹Σ_{j≤n−3}ETⱼ ≥ s_n − n⁻¹Σ_{i>n−3}EWᵢ ≥ d − 3K/n − u(K).
- *UI of Tⱼ.* Tⱼ ≤ |(Dθ\*)ⱼ| + 8max_{j≤i≤j+3}|Zᵢ| ≤ V/n² + 8max|Zᵢ|. For K > 2V, {Tⱼ > K} ⊂ {max|Zᵢ| > K/16} and Tⱼ ≤ 16max|Zᵢ| there. Since max|Zᵢ|·1{max > K/16} ≤ Σᵢ|Zᵢ|1{|Zᵢ| > K/16}, and each i lies in at most four stencils, n⁻¹ΣⱼE[Tⱼ1{Tⱼ > K}] ≤ (64/k)·u(kK/16) → 0.
- *m-dependence.* Tⱼ depends on Zⱼ, …, Z_{j+3}, so Tⱼ and T_{j′} are independent for |j − j′| ≥ 4. Each j has at most 7 dependent partners (itself included), each covariance of clipped terms is ≤ K²/4, so Var(n⁻¹Σ(Tⱼ∧K)) ≤ 7K²/(4n) ≤ 7K²/n. As stated.
- *Deterministic step.* ‖Dθ‖₁ ≥ ‖Dy‖₁ − ‖D(y − θ)‖₁ ≥ ‖Dy‖₁ − 8‖y − θ‖₁, because the absolute column sums of D⁽³⁾ are ≤ 1 + 3 + 3 + 1 = 8. With Q ≥ k‖y − θ‖₁ and q = kd/32: Q(θ) < qn gives 8‖y − θ‖₁ < nd/4, hence ‖Dθ‖₁ > nd/4 on {‖Dy‖₁ ≥ nd/2}. Correct, with the right constant.

**6. CONFIRMED — the coarse evidence bound and its set.**
- *Set.* 𝒢 := {u : ‖P⊥Su‖ₙ ≤ 1} × {c : ‖c − Nᵀ(θ\* − Su)‖₂ ≤ 1} × {s ∈ [1, 2]}.
- *On 𝒢.* P_N(θ − θ\*) = N(c − Nᵀ(θ\* − Su)), of ‖·‖ₙ-norm ≤ 1/√n; P⊥(θ − θ\*) = P⊥Su − P⊥Su\*, of ‖·‖ₙ-norm ≤ 1 + V, since ‖Su\*‖ₙ ≤ maxⱼ‖sⱼ‖ₙ·‖u\*‖₁ ≤ (n²/2)(V/n²). So ‖θ − θ\*‖ₙ ≤ 2 + V, and Q/n ≤ Q\*/n + ‖δ‖₁,ₙ ≤ B + 3 + V on {Q\*/n ≤ B + 1}.
- *Integrand.* For s ∈ [1, 2] and Q ≥ 0: s^{−n}e^{−Q/s} ≥ 2^{−n}e^{−Q}.
- *Mass.* V₃ (unit ball in ℝ³) × Π_λ(‖P⊥Su‖ₙ ≤ 1) × IG([1, 2]). L3 at radius one gives −log Π_λ ≤ 30·n·(log(m)/λ²)^{1/5} + 6 ≤ n once λ ≥ 30^{5/2}(1 + o(1))√(log m) ≈ 4930√(log m). This is implied by λ/log n → ∞.
- *Result.* Evidence ≥ V₃·IG([1, 2])·exp{−n(1 + log 2 + B + 3 + V)}, i.e. e^{−Cn} with any C > B + V + 4 + log 2, for n ≥ n₀.
- The evidence and all numerators use the same uncentred integrand s^{−n}e^{−Q/s} against dc ⊗ Π_λ ⊗ IG, so the ratio is the posterior probability. Correct.

**7. CONFIRMED — the tails, including the split at Q = qn and the IG negative moment.**
- *Flat bound.* Q ≥ k‖y − θ‖₁ ≥ k‖y − θ‖₂ ≥ k‖c − Nᵀ(y − Su)‖₂, so ∫e^{−Q/(2s)}dc ≤ 8π(2s/k)³ = C_k s³ with C_k = 64π/k³, for every (s, u, y).
- *Upper tail.* e^{−Q/s} ≤ e^{−Q/(2s)} (Q ≥ 0) and Π_λ, IG have unit mass: numerator ≤ C_k·sup_{s>H₀}s^{3−n} = C_k H₀^{3−n} (n > 3). Divided by e^{−Cn}: C_k H₀³e^{−n(log H₀ − C)} → 0.
- *Lower tail, Q ≥ qn.* e^{−Q/s} ≤ e^{−qn/(2s)}e^{−Q/(2s)}, so numerator ≤ C_k·sup_{s<l}s³·exp{n(−log s − q/(2s))}. The function g(s) := −log s − q/(2s) increases on (0, q/2] and g(0+) = −∞, so for l ≤ q/2 the supremum is g(l), and g(l) < −C − 1 for l small. With l < 1 the factor s³ ≤ 1. Correct.
- *Q < qn, all scales.* On the roughness event, {Q < qn} ⊂ {‖u‖₁ ≥ nd/4}. λ‖u‖₁ ~ Gamma(m, 1) and E e^{Γ/2} = 2^m give Π_λ(‖u‖₁ ≥ nd/4) ≤ 2^{n−3}e^{−λnd/8}. The c-integral is ≤ C_k s³ and ∫s^{3−n}dIG(s) = E[(1/s)^{n−3}] = b^{3−n}Γ(n + a − 3)/Γ(a), since 1/s ~ Gamma(a, rate b). The Gamma ratio is ∏_{i=0}^{n−4}(a + i) ≤ (n + a)^{n−3}. Total log cost: n log 2 + n log(n + a) + n log(1/b) + Cn − λnd/8 → −∞ iff λ/log n → ∞. Correct.
- *Coverage.* {s ∉ [l, H₀]} ⊂ {s > H₀} ∪ {s < l, Q ≥ qn} ∪ {Q < qn}. Complete.

**8. CONFIRMED (editorial fixes for the clean write-up).**
- (a) The statement of §2 should list the hypotheses it uses: (A1), s_n ≥ d, row-average UI, (A3) or a bounded truth, λ/log n → ∞, n ≥ 5 (L3). It uses **no** margin assumption (A2). This is worth saying, because the containment then holds for laws with atoms at the quantile.
- (b) "≥ e^{−n} eventually" should carry its threshold, e.g. 30(log m)^{1/5}λ^{−2/5} + 6/n ≤ 1.
- (c) The lower-tail choice should read: l < min(1, d, q/2) and −log l − q/(2l) < −C − 1. The condition l ≤ q/2 is not an extra hypothesis: if l > q/2 the supremum is log(2/q) − 1, which can never be < −C − 1 here (it would need q > 2e^{C}, while q ≤ d/64 and C > B ≥ d). So Astra's "sufficiently small l" is correct as written; the explicit form is clearer. Agrees with ruling #3 of the response table.
- (d) The interval [l, H₀] is very wide. H₀ ≥ e^{C+1} with C > B + V + 4.69, so H₀ > 296 for any B, V, while the designs have s_n ≤ 0.29. And g(l) < −C − 1 with l < 1 forces l < q/(2(C + 1)). Hence **H₀/l > 2(C + 1)e^{C+1}/q > 3300/q ≈ 10⁵/(kd)**. This is harmless for the lemma but matters downstream (finding 11).

**9. CONFIRMED — §2 holds uniformly over λ ≥ Λ₋ and for the λ-mixed prior of V2T, with Λ₋/log n → ∞.**
- §2 bounds the evidence from below and three numerators from above, **separately**. Each bound is an integral against the u-prior, hence linear in that prior. A bound valid for every Π_ℓ with ℓ ≥ Λ₋ therefore holds for Π̄ = ∫p_n(dℓ)Π_ℓ, for any p_n on [Λ₋, ∞). (A supremum over ℓ of posterior *ratios* would not transfer to the mixture; the separate form is what makes it work.)
- λ enters at two places only, both monotone in the right direction, and exactly so, not just through the bounds:
  - Π_ℓ(‖P⊥Su‖ₙ ≤ 1) = Π₁(B_ℓ) is nondecreasing in ℓ (scaling, L4q "Setting"), so Π̄(‖P⊥Su‖ₙ ≤ 1) ≥ Π_{Λ₋}(‖P⊥Su‖ₙ ≤ 1) ≥ e^{−n};
  - Π_ℓ(‖u‖₁ ≥ nd/4) = P(Gamma(m, 1) ≥ ℓnd/4) is nonincreasing in ℓ, so Π̄(‖u‖₁ ≥ nd/4) ≤ 2^{n−3}e^{−Λ₋nd/8}.
- The flat bound, the upper tail and the {Q ≥ qn} piece use only that the u-prior has mass 1. The two data events are λ-free.
- The factor λ^m in the paper's joint posterior is exactly the normalization of Π_λ, so the mixture dc ⊗ Π_ℓ ⊗ p_n ⊗ IG is the right object (as V2T states).
- There is **no upper restriction on λ** in §2: both monotonicities improve as ℓ grows. So V2T Step 2 is valid as written, for constant b₀ and for scaled b₀.

### §3

**10. CONFIRMED — the transfer is correct and non-circular.**
- Disintegration: given σ = s, the θ-law is Π_s because the θ-prior is σ-free; Π^θ(E | y) = ∫Π_s(E | y)Π(ds | y) ≤ sup_{s∈I}Π_s(E | y) + Π(σ ∉ I | y).
- Measurability: for fixed y the set E_y = {|Q − Q\*| > nt} does not depend on s; numerator and denominator are continuous in s ∈ I by dominated convergence with dominator e^{−Q/H₀} (valid since Q ≥ 0 and s ≤ H₀), integrable by the flat bound. A countable dense set of scales suffices.
- U must hold on the **whole** interval of §2, as Astra says. The CONJECTURE paragraph is now discharged by C1 (response table #8), which is uniform on compact σ-intervals and needs no (EM).

**11. PLAUSIBLE (improvement, not an error) — a second disintegration removes the wide interval from the rate constant.**
- In Theorem C\* the threshold for M is ω₁(f/8 − η)M > ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂²/M⁵ with ω₂/ω₁ = H₀/l. With the [l, H₀] of §2 this ratio exceeds 10⁵/(kd) (finding 8d), so M is finite but very large (at least of order 10⁵·(1.44C₁ + 1)/(kd·f)).
- Once Lemma S is proved (σ/s_n → 1 in posterior probability), disintegrate a second time over the deterministic interval I′ := [(1 − η′)s_n, (1 + η′)s_n] ⊂ [(1 − η′)d, (1 + η′)B]: Π(E | y) ≤ sup_{s∈I′}Π_s(E | y) + Π(σ ∉ I′ | y). The second term → 0 by Lemma S. The first is C1 + C2 on I′, where ω₂/ω₁ = (1 + η′)/(1 − η′).
- This is not circular: the first pass (wide I) is complete before the second starts. It needs the C1/C2 bounds to be explicit and monotone in (ω₁, ω₂) so that an n-dependent interval inside a fixed compact is allowed; they are (C1 "Uniformity in ω"; `FABLE_lemmaF_C2.md` §3.5). I did not write the second pass out in full; hence PLAUSIBLE.
- Effect: the rate constant of C\* and V0T\* depends on σ₀ only through one endpoint ratio close to 1. No exponent changes.

**12. PLAUSIBLE (generalization) — order k.** §§1 and 3 are order-free. §2 at D = D⁽ᵏ⁺¹⁾: 8 → 2^{k+1}, q = k_τd/2^{k+3}, stencil dependence range k + 1, ℝ³ → ℝ^{k+1}, and the same condition λ/log n → ∞. Details in `../FABLE_B_general_k.md` §8.

---

## Part B. The Theory response table

I re-derived each ruling.

| # | Ruling | My check | Agree? |
|---|---|---|---|
| 1 | s_n ≥ d for the paper designs | `../../T05_Proofs/checks/gap_ratio_check.out` has 33 rows; the smallest and largest sigma0 are 0.00463 and 0.28954. I read the output only; I did not rerun it or check the script. | Yes (evidence as stated) |
| 2 | (A3) can be replaced by a bounded truth in §2 | ‖P⊥θ\*‖ₙ ≤ ‖θ\*‖ₙ ≤ ‖θ\*‖∞; Tⱼ ≤ 8‖θ\*‖∞ + 8max\|Zᵢ\|; the UI argument runs for K > 16‖θ\*‖∞. | Yes |
| 3 | l < 1 and l ≤ q/2 | Finding 8(c): l < 1 is used for s³ ≤ 1; l ≤ q/2 is implied by the supremum condition. | Yes |
| 4 | Order of constants | (k, d, B, V) → q = kd/32; (B, V) → C; C → H₀ = e^{C+1} ∨ B (and > 1); (q, C, d) → l. C does not depend on q. | Yes |
| 5 | (log m)^{1/5}, n ≥ 5 | L3's statement. | Yes |
| 6 | The penalty must not involve σ | The paper's posterior is σ^{−n}e^{−Q/σ}·λ^m e^{−λ‖Dθ‖₁}·Gamma(λ)·IG(σ) (methodology section, as recorded in Theory's notes). §1's Gamma conditional and §3's disintegration both need it. | Yes |
| 7 | Not uniform as σ₀ → 0 or ∞ | d and B enter q, C, H₀, l. | Yes |
| 8 | U cannot come from Theorem B | (EM) at ω = 1/l would be needed on the whole interval; C1 supplies U without it. | Yes |
| 9 | §2 uses only λ/log n → ∞ | Findings 6 and 7: the L3 step needs λ ≳ √(log m), the roughness step needs λ ≫ log n. | Yes |

---

## Part C. Comparison with the Opus audit

*(Written after Part A; I read `AUDIT_opus_S.md` only then.)*

**Agreement.** Every step Opus re-derived, I re-derived independently with the same result: the IG conditional and Chebyshev constant; the LLN bound K/√n + 2u(K); the roughness chain with 8 and q = kd/32; the m-dependence count 7; the evidence constant C = 4 + log 2 + B + V + slack; the flat bound C_k = 64π/k³; the three tails; the disintegration and measurability. **No disagreement on any mathematical point.** Opus's nine findings all stand (Part B).

**Verdict difference, cosmetic.** Opus gives §1 "ACCEPT WITH FIXES (editorial)" for the coverage wording about the paper designs (its finding 1). I give §1 ACCEPT because the lemma and its proof need no change; the wording fix belongs to the remark about the designs. Both readings agree that the mathematics of §1 is correct.

**Two small refinements of Opus's findings.**
- *Opus #3 (l ≤ q/2).* Correct, and in fact not an additional hypothesis: the condition sup_{s<l}g < −C − 1 already forces l < q/(2(C + 1)) (finding 8c above). Astra's text was therefore complete, if terse.
- *Opus #8 ("a pointwise-in-s theorem upgrades to U for free whenever its denominator event is s-free").* True for the numerator bound in expectation (the two-endpoint inequality), and it is what C1 and C2 do. It should be read with the proviso that the **numerator** control must also come from s-free events or from expectations at the two endpoints; that holds in C1 (Ω_G is ω-free) and in C2 (endpoint Markov events).

**What this audit adds.**
- Finding 4: §1 does not use λ at all, so it covers λ-mixing.
- Finding 5, second bullet: §2 uses no margin assumption; atoms at the quantile are allowed.
- Finding 9: §2 for the λ-mixed prior on [Λ₋, ∞), with the reason (separate, prior-linear bounds; exact monotonicity in ℓ; no upper restriction on λ). Opus audited before V2T existed and its scope line says "no mixing over a learned λ"; that restriction can now be lifted for §§1–2.
- Finding 8(d) and 11: the width of [l, H₀] (ratio > 10⁵/(kd)) and the second-disintegration remedy for the rate constant.
- Finding 12: the order-k form.

---

## Part D. Not done

- No numerics. Nothing in Lemma S needs any, apart from ruling #1 (I read the existing output file only).
- I did not re-audit L3; §2 uses its statement at radius one.
- Finding 11's second pass is not written out line by line.
- I did not check the sampler code for the σ-free penalty; I relied on the methodology formula recorded in Theory's notes and on Opus's code check (its finding 6).
