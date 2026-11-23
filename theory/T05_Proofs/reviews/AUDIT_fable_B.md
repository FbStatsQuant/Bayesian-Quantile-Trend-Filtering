# End-to-end audit of Theorem B (light-tail oracle contraction in Δ²ₙ)

*Fable (VP / mathematical reviewer), 2026-11-22. Audited at commit `5304e9d`; all line numbers refer to the files at that commit. Read-only audit; this report is the only file written. I did not read `AUDIT_astra_B.md`, so the two audits are independent.*

## Overall verdict: **COMPLETE WITH FIXES**

The proof of Theorem B is correct and complete as a chain. I re-derived every step of L2, L3, L4, L4q, L4q-M, L5, L6, Propositions 1–2 and the assembly, and checked every join for radius, normalization, λ range, thresholds and constants. **I found no mathematical gap and no join where a hypothesis fails or a constant changes silently.**

The fixes are outside the proof itself:
- one scope claim that is supported by a wrong example (finding 1, major for the Scope and Positioning paragraphs, no effect on the theorem);
- statement precision and bookkeeping that a referee needs in order to verify the result (findings 2–7, all minor).

## What was checked, and how

- **By hand:** every inequality and constant in the nine files of the chain, both signs of δ, both λ tunings, both routes (L4q-M primary, L4 fallback).
- **Numerically** (single thread, `owls_run -j 1`, scratchpad only; scripts and output in `/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/e287d343-97b3-4c2c-9338-f52306b314d0/scratchpad/chk/`):
  - H(δ) ≥ min(‖δ‖₂², ‖δ‖₂) on 20 000 random vectors: smallest ratio 1.000.
  - L4q-M kernel at n = 60, 200, 600 and w from 3 to m/2, every j including the boundary: quadratic reproduction to 1e-12; w·‖K⁽ʲ⁾‖∞ ≤ 8.9; √w·‖K⁽ʲ⁾‖₂ ≤ 3.0; ‖G_w⁻¹‖ ≤ 368; residual supported on rows min Wⱼ … max Wⱼ + 2; ‖S(eⱼ − K⁽ʲ⁾)‖ₙ ≤ 0.010·w^{5/2}/√n. DS = I exactly.
  - Proposition 1: inf_d −log U(d)/min(d², d) > 0 for five (ω, τ, b₊) triples, with the stated limits at 0 and ∞.
  - R1 threshold: K(ρ₀) ≤ 0.634 at ρ₀ = 51·n^{10/7}(log m)^{1/7} for n = 5 … 10⁸.
  - Prior budget: φ-bound(ε/2)/(nε²) → 39.6 at both oracles for V = 0.1, 1, 10 (finding 2).
  - The uniform example and a staircase law (finding 1).
- **Not re-run:** `checks/global_threshold.py` (the mixture σ_crit figures; already reproduced twice) and the L4q Monte Carlo (N1, N2). Neither is used by the proof.

## Verdict per lemma

| Piece | Verdict | Note |
|---|---|---|
| L2 excess risk | **Correct** | B uses only parts (1), (3), (4) and the identity. Part (2) is used only in Proposition 2. |
| L3 small ball | **Correct** | All constants reproduce: 91.125, 7.68, 5.52 ≤ 6, 29.6 ≤ 30. |
| L4 ℓ₁ shift | **Correct** | |
| L4q quadratic shift | **Correct** | Steps 1–7 re-derived; c_K = e^K/(1 − e^{−2}) ≤ 3.144 for K ≤ 1. δ_A ≤ n/√3 holds (column differences are (i−j−2)₊). |
| L4q-M mollification | **Correct** | (1)–(3) hold with C ≤ 9 numerically. For w = 3 the kernel is the identity, so u_h = u\*. |
| L5 normalization | **Correct** | |
| L6 evidence | **Correct** | Needs only the upper half of (A2); see finding 4. |
| Proposition 1 | **Correct** | Uses the L8′(a) identity, which needs no margin assumption; see finding 4. |
| Proposition 2 | **Correct** | Needs the full (A2), as stated. |
| Assembly (steps 1–4) | **Correct** | |
| L8′, L10-I (secondary) | **Correct and consistent with STATEMENT v3.1**, up to finding 6 | |

## Verdict per join

| # | Join | Checked | Verdict |
|---|---|---|---|
| J1 | (EM) → step 1 (Tonelli, independence) | Same Xᵢ, same ω, all δ ∈ ℝ; integrand nonnegative; the event E is a deterministic Borel set in θ. | OK |
| J2 | L8′(a) → Proposition 1 | Survival form of the MGF; both signs; envelope prefactors. | OK (citation, finding 4) |
| J3 | L2(2) + L2 identity → Proposition 2 | c₀ from the full (A2); ω ≤ c/2 used in both moment cases. | OK |
| J4 | L5 coordinates → step 2 (flat part) | N orthonormal, c₀(u) translation, Π_λ mass 1. C₃(bω) uses bω/2, matching the half exponent kept in step 1. | OK |
| J5 | L2 → L6 | C₁ on all of ℝ (quadratic branch), variance ≤ Σδᵢ²; ‖δ‖ₙ² ≤ 1.25ε² on G, relaxed to 1.44 in both places. | OK |
| J6 | L3 → L6 at half radius | x = 2n^{5/2}/(λε); φ(ε/2) ≤ 39.6·(n^{5/2}/(λε))^{2/5}(log m)^{1/5} + 6; this is ≤ const·nε² iff ε² ≳ λ^{−1/3}(log m)^{1/6}. Hence c ≥ 1/6. | OK |
| J7 | L3 → L4q (R1) at half radius | K′ = K(λε/2) = 8δ_AΦ(λε/8)/(λε); threshold λε ≥ 102·n^{10/7}(log m)^{1/7}; K is nonincreasing, so one threshold check suffices. | OK |
| J8 | L4 → L4q step 5; L4 → L6 (fallback) | Dimension m − 1 shift by −t·e_{j±1}; fallback centre u_h = u\*, cost λ‖u\*‖₁ ≤ λVn^{−2}. | OK |
| J9 | L4q-M → L4q (half radius) → L6 (primary) | L6's hypothesis ‖P⊥S(u_h − u\*)‖ₙ ≤ ε/2 from (2) with w = c₁n(ε/V)^{2/5}; 3 ≤ w ≤ m/2; δ_A ≤ λε/4; K′ ≤ 1. At the primary oracle λε ≍ n^{25/12}V^{−5/6}(log n)^{c/2}, so all hold for n ≥ n₀(V, constants). | OK |
| J10 | L6 → steps 3–4 | Same ε in E and in G; ν(G) = V₃(ε√n/2)³·Π_λ(u_h + B_{ε/2}); Πₙ(E \| y) ≤ N(E)·1_Ω/L + 1_{Ωᶜ}. | OK |
| J11 | Constants → M | Exponent −[bM/2 − (1.44C₁ + 1) − C_pr/ω]·ωnε². C_pr is fixed before M; no circularity. | OK (finding 2) |
| J12 | Normalizations | H = nΔ²ₙ; B_ε in ‖·‖ₙ through A = n^{−1/2}P⊥S; L3's x; L4q-M's (w/n)⁵. No n⁻¹Σ versus Σ slip, no ε versus ε² slip. | OK |

## Statement check (item 1)

- **B_light_tail.md, STATEMENT_DRAFT.md and SKELETON.md agree** on the hypothesis, the law class with a common b, the two tunings, both rates, the loss, and the threshold M > (2/b)(1.44C₁ + 1 + C_pr/ω).
- **Log power.** B proves the result for every c ≥ 1/6 (line 102). STATEMENT line 128 states c = 1/6. These are consistent; c = 1/6 is the sharpest the chain gives, and it comes entirely from L3.
- **What the assembly proves, exactly.** For fixed (ω, b, τ, L, f̄, V), fixed comparison constants a₁ ≤ λₙ/λ_oracle ≤ a₂, any fixed C > 0 in εₙ², and n ≥ n₀(V, a₁, a₂, C): the bound of step 4, uniformly over 𝒫ₙᴮ. The statement matches this, with the precision gaps of finding 2.

## Hidden assumptions (item 4)

Nothing is used that is not available. Specifically:
- **Measurability:** covered by L5 (Astra's remark, lines 43–44).
- **Uniformity in i and n:** (EM) and the upper half of (A2) are uniform by the definition of the class; the prior side does not depend on the law.
- **Independence:** used in step 1 and in L6 step 3; both cite (A1).
- **Common b:** stated (line 97).
- **Existence of the centre:** u_h is constructed explicitly and is deterministic; ν(G) > 0.
- **Uniqueness of θ\*:** not assumed, and not needed. It follows anyway: by Jensen, (EM) gives mᵢ(δ) ≥ b·min(δ², |δ|), so 0 is the unique minimiser of the expected check loss. The same line gives the lower margin with c₀ = b, and Fᵢ(δ) − τ ≥ bδ on (0, 1].
- **Not stated but harmless:** n ≥ 5 (L3), εₙ < 1 (L6), n ≥ n₀ (finding 2).

## Findings

### 1. The uniform example does not separate B from A. CONFIRMED. Major for the scope claim; no effect on the theorem.

**Where:** `B_light_tail.md` lines 22, 150, 167; `STATEMENT_DRAFT.md` lines 134 and 136.

**Problem.** The text says B applies to uniform errors on [−1, 1] at τ = ½, ω = 1, "while A4's σ̄ = 2 > σ", and concludes that B covers cases A does not. The value σ̄ = 2 comes from choosing L = 4 in (A2). But (A2) only asks that *some* (L, f, f̄) work. With L = 1 the same law has f = f̄ = ½, so ω̄ = 2 and (A4) holds at ω = 1 with η = ½ (L8′(b) gives B(ω, Δ) = 0.30 at Δ = 0.2). **Theorem A, if proved, covers this law.**

**The general fact.** If Fᵢ is differentiable at the quantile, (EM) gives F′(q) ≥ ωτ(1−τ) + 2b, and the secant constant on [−L, L] tends to F′(q) as L → 0. So for every such law (EM) implies (A2) and (A4) for a small enough L and some η > 0. No law with a density at the quantile can separate B from A.

**Is the claim itself true?** Yes, but only for laws that are not differentiable at the quantile. A separating example: Z = ±2^{−k−1} with probability 2^{−k−2} each (k ≥ 0), τ = ½.
- (A2) holds two-sided on every interval with secant constants f = ½ and f̄ = 1, so ω̄ = 2 for every L, and (A4) fails for every ω ≥ 2.
- inf_δ m(δ)/δ² = 1/3, so the local (EM) threshold is ω < 8/3, with b = 1/3 − ω/8.
- I checked the exact MGF numerically on δ ∈ [10⁻⁵, 30]: inf −log E e^{−ωX(δ)}/(ω·min(δ², |δ|)) = 0.0833, 0.0583, 0.0208 at ω = 2, 2.2, 2.5, and negative at ω = 2.7. The infimum is at the smallest dyadic point, matching 1/3 − ω/8. *(This replacement example is PLAUSIBLE: numerical on that range, plus self-similarity for δ → 0.)*

**Fix.**
- Delete the uniform example as evidence of separation. Keep the true sentence "(EM) does not imply (A4) for a prescribed (L, f)".
- Replace "B covers some cases A does not" by: "For laws differentiable at the quantile, (EM) implies (A2) and (A4) for some (L, f, f̄, η), so B's class is contained in A's. B can cover laws A does not only when Fᵢ is not differentiable at the quantile (for example the dyadic staircase law above, for 2 ≤ ω < 8/3), or when no common L serves the whole class."
- Revise the Positioning paragraph accordingly: this "distinct conclusion" is much thinner than stated.

### 2. C_pr is not defined, and its stated dependence on V is wrong. CONFIRMED. Minor.

**Where:** `B_light_tail.md` lines 107 and 130; `STATEMENT_DRAFT.md` line 128.

**Problem.** The threshold for M contains C_pr, described only as "depends on V and the comparison constants". A referee cannot check M. Inserting the lemmas gives an explicit value, and it does not depend on V.

With a₁·λ_oracle ≤ λₙ ≤ a₂·λ_oracle and εₙ² = C(log n)^c × (oracle rate):
- **Spread (both routes):** φ(ε/2)/(nε²) ≤ 39.6·a₁^{−2/5}·C^{−6/5}·(log m)^{1/5}(log n)^{−6c/5} + 6/(nε²).
- **Shift, primary:** ≤ C′·c_{K′}·a₂²·C^{−6/5}·(log n)^{−6c/5} → 0, with C′ from L4q-M.
- **Shift, fallback:** ≤ a₂·C^{−1}·(log n)^{−c} → 0.

So for c = 1/6 any **C_pr > 39.6·a₁^{−2/5}·C^{−6/5}** works for n ≥ n₀; for c > 1/6 any C_pr > 0 works. V enters only through n₀. (Numerical confirmation: ratio → 39.6 at C = a₁ = 1, for V = 0.1, 1, 10.)

**Fix.** State this value in the theorem. Also state that C > 0 is arbitrary and that the conclusion holds for n ≥ n₀(V, a₁, a₂, C), where n₀ collects n ≥ 5, ε < 1, K′ ≤ 1, δ_A ≤ λε/4 and 3 ≤ w ≤ m/2.

### 3. Stale status lines in B_light_tail.md contradict SKELETON and STATEMENT. CONFIRMED. Minor.

**Where:** `B_light_tail.md` line 3 ("fully checked once L3 passes … Fable, running"), lines 152–158 ("L6: draft, self-checked"; "L3: … self-checked once its fixes are committed"; "the remaining risk is … in L6"). `SKELETON.md` line 84 and `STATEMENT_DRAFT.md` line 128 say "PROOF COMPLETE, advisor-checked".

**Fix.** Update lines 3 and 152–158. In line 10, "Depends on" should also list L8′(a) (Proposition 1) and L8′(c) (the scale implication), not only the optional use in Proposition 2. This file was not touched by the later bookkeeping commit `250761e`.

### 4. Two joins are valid only after reading past the cited statement. CONFIRMED. Minor.

- **L6 hypothesis.** `L6_evidence_lower_bound.md` line 23 assumes "(A1) and (A2)". Theorem B's class has only the upper half of (A2). The proof of L6 uses only the upper half (through C₁ and Fᵢ(0) = τ), as the response at line 79 notes, but the statement was not changed. *Fix:* state L6 under "(A1) and the upper half of (A2)", and add Theorem B to "Used by" (line 5).
- **L8′(a) in Proposition 1.** `B_light_tail.md` lines 39–41 cite L8′(a) for the survival-form identity. `L8p_bounded_numerator.md` lines 10–12 put (A2) and Fᵢ(0) = τ in the Setting, while Proposition 1 assumes neither. The identity (L8′ line 53) holds for any law. *Fix:* say in L8′ that part (a) needs no margin assumption, and cite the survival form by line.

### 5. The flagged squared-loss corollary: the exponent looks like 9/5, not 3/2. PLAUSIBLE. Minor (the corollary is flagged, not claimed).

**Where:** `B_light_tail.md` lines 144–147; `STATEMENT_DRAFT.md` line 130.

**Problem.** The sketch uses Δ²ₙ ≲ η := Mε² and TV⁽³⁾(δ) ≲ T₀ := n³/λ. The corollary of L10-I needs η²T₀ → 0. With ε² ≍ λ^{−1/3} this is n³λ^{−5/3} → 0, i.e. λ/n^{9/5} → ∞. At λ = n^{3/2} the product is n^{1/2}. The value 3/2 would need a posterior TV bound of order n^{5/2}/λ, which the Fubini step does not give.

**Effect.** None on what B could claim: both oracle tunings (n^{5/2} and n^{9/4}) are above n^{9/5}. *Fix:* write "for λ/n^{9/5} → ∞" or drop the range until the corollary is written.

### 6. STATEMENT and SKELETON quote the interpolation in an older form. CONFIRMED. Minor (secondary item).

**Where:** `STATEMENT_DRAFT.md` line 164; `SKELETON.md` line 57.

**Problem.** Both write ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}·TV⁽³⁾(δ)^{1/5}. L10-I (lines 11–15) proves the unprojected inequality ‖δ‖∞ ≤ 6‖δ‖ₙ + 7.06‖δ‖ₙ^{4/5}TV⁽³⁾(δ)^{1/5}, with the extra ‖δ‖ₙ term. The consequences drawn (threshold 21/11, Stage 2) are the same. *Fix:* quote L10-I's form. Also `SKELETON.md` line 35 omits the (log m)^{1/5} of L3; step 1 is shared with Theorem B.

Otherwise L8′ and L10-I match STATEMENT v3.1: the MGF identity (STATEMENT line 43), B ≥ η/2 under ω ≤ (1−η)ω̄, the strict slack, C = 9, and the Stage 2 condition λ/n^{21/11} → ∞. One small imprecision: Δ₀ also depends on L ("the largest Δ ≤ L"), while STATEMENT lines 53 and 160 write Δ₀(η, ω̄, τ).

### 7. Symbol clashes inside B_light_tail.md that slow verification. CONFIRMED. Minor.

- **b:** the (EM) constant (line 15) and the envelope rate "b := b₊" (line 43), two lines after the claim "bω = a".
- **c₀:** the margin constant of L2 (line 67) and the centre c₀(u) of the flat integral (line 121).
- **c:** the log power (line 102), the ψ₁ constant (line 65) and the quadratic coordinates (line 121).

*Fix:* rename the envelope rate (β₊), the flat centre (c̄(u)) and the ψ₁ constant.

## Summary

- **Verdict: COMPLETE WITH FIXES.** The mathematics of Theorem B is correct end to end; no lemma and no join fails.
- **One major item, outside the proof:** the uniform example does not show that B covers cases A does not (take L = 1). The claim survives only for laws not differentiable at the quantile; a dyadic staircase law works numerically.
- **Six minor items:** explicit C_pr (it is 39.6·a₁^{−2/5}C^{−6/5}, free of V), stale statuses in B_light_tail.md, two hypothesis and citation mismatches (L6, L8′(a)), the 9/5 exponent in the flagged squared-loss sketch, the older interpolation form in STATEMENT and SKELETON, and symbol clashes.
