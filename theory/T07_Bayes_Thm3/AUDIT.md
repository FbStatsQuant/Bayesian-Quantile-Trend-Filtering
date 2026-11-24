# T-07 audit log

This file has two parts:
- Part I (now): the Theory head's verification of internal Astra findings, logged as they arrive.
- Part II (later): the formal Astra audit of the final proof, with the prover's responses and the Theory head's rulings.

Rule (Felipe, 2026-11-24): the Theory head verifies each Astra claim personally until the claims prove consistently correct. After that, spot-checks are allowed, and the switch is recorded here with its date and reason.

## Part I: internal delegate findings

### Astra-1, hard steps (`astra/ASTRA1_hard_steps.md`), 2026-11-24

Notation: p = 2r−1, s = n^{−p/(2r)}(log n)^{1/(2r)}, H = ns.

| # | Claim | Theory head's check | Ruling |
|---|---|---|---|
| A1-1 | Bias/shift step: bandwidth w = ⌈λ^{1/r}⌉. The squared approximation error and the quadratic shift charge per observation are both ≲ V²c^{p/r}n^{−p/(2r)} = o(s), for every fixed c > 0, with the L4q half-radius conditions met | Redone. (i) λ^{p/r}n^{−p} = c^{p/r}n^{p²/(2r)−p} = c^{p/r}n^{−p/(2r)}. (ii) λ²‖u_h‖²/n ≤ c²V²n^{p}n^{−2r+2}/(nw) = c^{2−1/r}V²n^{−p/(2r)}. (iii) The ratio to s is (log n)^{−1/(2r)} → 0. So the bias is o(s) **only by the log factor**; this is noted for the prover. (iv) δ_A ≤ n^{r−2} ≪ λε holds trivially. (v) The small-ball term (2/c)^{2/p}ε^{−2/p}(log n)^{1/p} equals (2/c)^{2/p}·H exactly, so the log power 1/(2r) is what balances the small-ball term | HOLDS |
| A1-2 | Any fixed c > 0 works, with no window. Fine-part MGF ratio 2ω‖t‖∞/λ ≍ (ω/c)M^{−p/2}n^{−p/(4r)}(log n)^{1/(4r)} → 0. Log-MGF ≲ (ω/c)²H/M^{p}. Truth term ≲ ωVM^{−p/2}√H = o(H) | Redone with J ≍ MH and ‖t‖∞ ≲ (n/J)^{p/2}√(log n). The identity H^{p+1} = n log n, since p+1 = 2r, gives all three orders. c enters only constants, and a large M absorbs them | HOLDS |
| A1-3 | r = 2 localization closes with W′: b² ≍ (T/c)^{2/5}n^{−3/5}(log n)^{4/5}, T₀ = (T/c)√n, b²T₀ ≍ n^{−1/10}(log n)^{4/5} → 0. In general, (b²)^{k}T₀ has n-exponent 1/2 − k(2k+1)/(2k+3) < 0 for k ≥ 1 | Redone. T₀ = Tn^r/λ = (T/c)n^{1/2}. The exponent at k=1 is 1/2 − 3/5 = −1/10. H = (n log n)^{1/4} = o(nb²) = o(n^{2/5}) | HOLDS |
| A1-4 | Roadmap Step 4 overstates C2. The right form is a high-probability numerator bound on the score event; then E Π ≤ P(bad) + E[Π·1_good], using Π ≤ 1 | Correct and standard. It gives the in-mean statement directly | HOLDS (roadmap wording to be fixed in the proof, not in the statement) |

### Astra-2, check of T07a and the breakdown (`astra/ASTRA2_statement_check.md`), 2026-11-24

| # | Astra-2 severity | Theory head's check | Ruling and action |
|---|---|---|---|
| 1 | ERROR: an atom at the quantile is compatible with Assumption A and breaks score centring and Lemma 13 | Example checked: A holds with L=1 and slope 1/4; F(0)=3/4≠1/2; left excess t³/6 = o(t²) | HOLDS. The main theorem is safe, because B gives continuity at θ*, hence F(θ*)=τ. The corollary now assumes A+B, and a sentence explaining why was added |
| 2 | ERROR: Padilla's Lemma 24 is false (Δ vs ℓ₂ comparison) | Read Lemma 24's proof. Δ(x) ≥ c‖x‖₂ fails once entries are ≫1, since Δ² ~ ‖x‖₁. The r=2 example gives ‖x‖₂ ≍ n^{3/2} and Δ ≍ n. This agrees with the project's earlier "Lemma 19 off by n^{r−1}" | HOLDS. It is a gap in Padilla's Proposition 3, so the mode corollary rests on the published theorem. Internal note added to T07a; flagged to HQ. The prover is told not to use Lemmas 19/24 |
| 3 | OK: conversions, normalization, propriety, MAP identity | — | Accepted |
| 4 | IMPRECISION: bookkeeping in the breakdown | Spot-checked Lemma 25 (Δ²/n in the statement vs Δ²/√n in the proof (36)) | HOLDS. Breakdown §8 added |
| 5 | OK: any fixed c > 0 consistent | Agrees with my check of A1-2 | Accepted |
| 6 | IMPRECISION: A+B are CDF-increment conditions, not density bounds | Correct (chord conditions) | HOLDS. The assumptions paragraph in T07a was reworded |
| 7 | ERROR: unconditional expected numerator (roadmap Step 4) | Same as A1-4. Also, at fixed θ, E e^{−M̂/σ₀} < 1 needs σ₀ > τ(1−τ)/f (second-order expansion; the reviewer found the same independently) | HOLDS. Roadmap Step 4 rewritten as an event-wise bound and the 1/σ₀ restored in N(B). The proof must use the realized-numerator route (audited for σ below τ(1−τ)/f) |
| 8 | IMPRECISION: centre of IG(n+a, S+b) | Mean (S+b)/(n+a−1), coefficient of variation (α−2)^{−1/2} | HOLDS. Remark 2 reworded |
| 9 | ERROR: Remark 2 claim fails for Cauchy (σ̄ₙ = ∞) | Correct: A+B allow Cauchy | HOLDS. Remark 2 now states finite mean, row-UI and σ̄ₙ bounded away from 0 (all true for the paper's three noises) |
| 10 | OK: spread/bias heuristics | — | Accepted |
| 11 | ERROR: sharpness overclaimed beyond r=3 and the proved tunings; LB at Padilla's λ carries (log n)^{−1/21} | Correct: LB is r=3 only, λ ≲ n^{5/2}, radius c₀λ^{−1/3} | HOLDS. Outcome line and Remark 4(v) qualified |
| 12 | IMPRECISION: C1 at Padilla's λ is n^{−30/49}(log n)^{40/49} with W′ | λ^{−2/7}(log n)^{6/7} at λ = n^{15/7}(log n)^{1/7} gives n^{−30/49}(log n)^{40/49} | HOLDS. Updated |
| 13 | IMPRECISION: Tibshirani §5.1 gives a linear lower bound only | Correct | HOLDS. Reworded to "matches the lower bound for linear estimators" |
| 14 | IMPRECISION: Castillo Thm 7 is a sequence-model analogue | Correct | HOLDS. Reworded |

**Astra track record so far.** All 18 claims checked (Astra-1: 4, Astra-2: 14) hold on my own verification. Full verification continues for the proof-draft feedback. The switch to spot-checks will be decided after that round.

### Reviewer (Agent 2, `T07b_review.md`), key claims checked, 2026-11-24

| Claim | Check | Ruling |
|---|---|---|
| A, B and V* = O(1) hold in all 99 truth × noise × τ cells; weak constants only (f down to 0.031 at τ = 0.99; V*(VS) ≈ 7280) | Spot-checked: V*(PC, Gaussian) = 36 (three f″ jumps of 12); Gaussian quantile curve s(u)z_τ is quadratic, so it adds 0; S limit 16π² for sin(2πu) | HOLDS |
| E e^{−M̂ᵢ/σ₀} < 1 only if σ₀ > τ(1−τ)/fᵢ; fails at σ₀ = σ̄ₙ in most cells | Second-order expansion agrees | HOLDS as a fact. It constrains only expectation-based proofs; the proof must use the realized-numerator route (see Astra-2 #7) |
| SEVERE MISALIGNMENT: learned λ (Gamma) and the joint non-crossing sampler are not covered | Correct. This is the agreed scope (Felipe: deterministic λ, single level, σ fixed) | HOLDS as a scope statement; reported to HQ |
| Misspecification paragraph | Checked the KL claim: KL(p₀ ‖ ALD_θ) = const + E ρ_τ(y−θ)/σ, minimized at the τ-quantile | HOLDS. Adopted into T07a Remark 3 (the clause "densities bounded away from 0 and ∞" was dropped as imprecise) |
| Koenker (2005) Cond. A1 precedent for B | The reviewer quoted it from memory | NOT VERIFIED. Must be checked against the book before any citation |

### Theory head's own check of the proof draft `T07c_proof.tex` (prover's first draft), 2026-11-24

I read every lemma and redid the arithmetic. No errors were found. The items checked:

| Item | What I redid | Ruling |
|---|---|---|
| Lemma 4 (small ball, no log) | Laplace = √V·g mixture; Eckart–Young with rank(P_J − P) = J′ ≤ J; Σ_{q>J}μ_q ≤ b₀J^{−(2r−1)}; μ_q ≤ 2·3^{2r−1}b₀q^{−2r} = 8·6^{2r−1}c_F²n^{2r−1}/λ²·q^{−2r}; tail ≤ ϱ²/8 then Markov; head t_q ≥ (2/√(2r−1))(q/K)^r; P(\|γ\|≤t) ≥ 0.48 min(t,1); K!/K^K ≥ e^{−K}; final C_sb | HOLDS |
| Lemma 5 (quadratic shift) | AM–GM step and max(\|w\|,\|h\|) identity; Prékopa marginals; neighbour shift v = −te_{j′}+v′; concavity of Λ via K(s) = sK(1); chord-slope bound for a ≤ ϱ/2; f_j(0) ≤ λ(1+K/2)/(1−e^{−2}) | HOLDS |
| Lemma 6 + Prop 1 (smoothed truth, prior mass) | Polynomial-reproducing kernel, \|K\| ≤ r/(g_r w); d_j supported on w−1 rows; δ_A ≤ n^{r−2}; condition 4 ≤ c n^{3/2}ε_n; K → 0 so c_K ≤ 2; ε_n^{−2/(2r−1)} = nε_n²; C_pr | HOLDS |
| Lemma 7 (denominator) | Jensen; mean via global upper margin C₁ = max{f̄/2, 1/L}; Var(ℓ̄) ≤ (5/4)nε²; Chebyshev | HOLDS |
| Lemmas 8–10 (width, interpolation, concentration) | Sub-Gaussian max with h ≤ 2n/J gives 2^r c_F; window bound and the three cases of w; symmetrization (vdV–W 2.3.6) and contraction (L–T 4.12) constants 2 and 2 match the published statements as I know them; Efron–Stein bounded change \|δ̂_i\| | HOLDS (exact citation wording still to be checked by the formal auditor) |
| Prop 2 (localization) | ρ_n^{2r−2}T_n exponent −(4r²−8r+1)/(2(2r+1)), −1/10 at r=2; J_n ≍ n^{2/(2r+1)}, so E sup ≍ n^{2/(2r+1)}√log n = o(nρ_n²); Chebyshev 64/(f²nρ²); rays; Gamma(m,1) tail exp{−(1−log 2)n + (3/2)(α+1)}; ratio to denominator | HOLDS |
| Lemma 11 (score events) | Var(ψᵀQψ) ≤ ‖Q‖_F²/4; coarse Chebyshev 4/(9(J+r)); Hoeffding 1/(2n); ℓ₂ part: ‖WWᵀ‖_F ≤ ‖W‖_op‖W‖_F, c_op²/c_F² = 3r, h/m ≤ 2/J | HOLDS |
| Prop 3 (shells) | Cauchy–Schwarz split; coarse term ≤ (f/8)a nε²; Laplace MGF; 8ω²‖t‖²/λ² = 2C_fine ω²/(c²M^{2r−1})·nε² using n = (nε²)^{2r}; truth term √log n · (nε²)^{1/2} = o(nε²); exponents combine to −(ωf/8)a nε² + (1 + C_fine ω²/(c²M^{2r−1}))nε² | HOLDS |
| Assembly | Volume ratio (8a)^{r/2}; M = M₁ + M₂ gives bracket ≤ (ωf/16)M; dyadic sum ≤ 2 for r ≥ 2; 4/9 + 8r/3 ≤ 3r; C = 2 + 768r/(f²M); M formula matches Theorem 2 | HOLDS |
| Lemmas 12–13, Prop 4 (lower bound, general r) | Log-concave variance bound p(0) ≤ 1/√(2v); block functionals (z−1)^rσ_ℓ^{r+1} = (z^ℓ−1)^rσ_ℓ, disjoint supports, ‖g_b‖² = ℓ·C(2r,r); p₀ bound; union bound (4p₀)^{B/2}; range x₀ ≤ x ≤ C_ℓn^{r−1/2}; Hoeffding-lemma numerator; Anderson; c₀ choice | HOLDS |

Naturality: the log-free Theorem 2 (radius M n^{−(2r−1)/(2r)}, bound C n^{−1/(2r)}) together with Prop 4 is the cleaner statement. Recommendation to HQ: after the formal audit, make it the headline and keep the log version as a remark. Not changed yet.

Not checked by me in this pass: Lemmas 1–3 proofs line by line (statements checked; Lemma 3 numerics reported by the prover). These go to Astra-1 and the formal audit.

## Padilla items: status in our proof

Felipe's ruling (2026-11-24): Padilla is a template, not a law. Any borrowed item is re-checked; known or suspected wrong items are never cited.

| Padilla item | What it says | Our status |
|---|---|---|
| Assumption A | lower CDF chord growth | Used as is, plus our Assumption B (upper chord growth, which also forces F(θ*) = τ) |
| Lemma 10 | symmetrization | Used, but cited to the source (van der Vaart–Wellner 1996, Lemma 2.3.6) |
| Lemma 11 | contraction | Used, but cited to the source (Ledoux–Talagrand 1991, Thm 4.12) |
| Lemma 13 | lower margin | Corrected: our Lemma 2(d) under A + B; his version breaks with an atom at the quantile (Astra-2 #1) |
| Lemma 16 | ker D^{(r)} = polynomials | Used as is (elementary; re-proved in Lemma 1) |
| Prop 3, Lemmas 17–25 | localization, incl. Δ vs ℓ₂ comparison | Avoided. Lemma 24/19 is false for entries ≫ 1 (Astra-2 #2). Our localization (Lemmas 8–10, Prop 2) is self-contained and compares Δ and ℓ₂ only where ‖δ‖_∞ ≤ 1 |
| Theorem 3 | mode rate | Not used by the main theorem. Mode corollary: to be re-proved self-contained under A + B (Felipe, 2026-11-24) |

**Pending style instruction (HQ, 2026-11-24).** If Felipe picks the log-free theorem plus lower bound as the headline, both theorem blocks are written like Padilla's: "there exist constants M, C depending only on …". The explicit formulas for M, C and c₀ move into the proof or a remark. This goes into the prover's fix-round brief.

### Astra-1, feedback on the proof draft (`astra/ASTRA1_proof_feedback.md`), 2026-11-24

The file was restored by me from Astra-1's thread, because its `owls_run tee` heredoc wrote an empty file.

| # | Astra-1 severity | Theory head's check | Ruling and action |
|---|---|---|---|
| 1 | GAP: Prop 1 bandwidth divides by V̄ = 0 | True: w = ⌊n(ε/(2C_sV̄))^{2/(2r−1)}⌋ is undefined at V̄ = 0. With u° = 0, the approximation and shift terms vanish and Lemma 4 gives the first summand of C_pr | HOLDS (boundary case). Prover adds the branch |
| 2 | ERROR (wording): Remark "same order" | These are upper bounds; for a polynomial truth they are 0 | HOLDS. Reword as "at most of order" |
| 3 | ERROR (wording): Remark r=2, "any polynomial loss breaks it" | Redone: a loss n^γ gives ρ^{5/4} ≍ n^{γ−3/8}, so ρ² ≍ n^{−3/5+8γ/5} and ρ²T ≍ n^{−1/10+8γ/5} → 0 iff γ < 1/16 | HOLDS. Reword: a loss of n^{1/16} or more would break it |
| 4 | IMPRECISION: Lemma 5 at a = 0 or δ_A = 0 | True. The fix (integrate over \|t\| ≤ 1/λ, which is inside the old range because λϱ/(2δ_A) ≥ 1) gives the same constant | HOLDS. Prover applies the fix |
| 5 | IMPRECISION: ordered pairs in the quadratic-form variance | True; the formula is right, the sentence is not | HOLDS. Reword |
| 6 | IMPRECISION: "realized numerator" | Prop 3 bounds E[N(E_a)1_Ω]; the point of Remark 6 (the score is never averaged) is unaffected | HOLDS. Reword Remark 6 and the status table |

**Track record and switch to spot-checks.** All 24 Astra claims checked so far (Astra-1: 4 + 6 + 12 OK computations, which I had redone myself in my own pass; Astra-2: 14) held up. From now on, for IMPRECISION or OK items, I spot-check instead of redoing every one. ERROR and GAP items, and every finding of the formal audit, still get my full check. Reason: 24/24 correct, and the remaining risk is concentrated in ERROR/GAP claims.

### Mode corollary plan (`T07d_mode_plan.md`), 2026-11-24

The gate passed: about 1.5 pages, no new tool. Padilla's Theorem 3, Prop 3 and Lemmas 17–25 are not used. I checked the plan:
- Basic inequality: L̂(sδ̂) + λ_TV·TV(sδ̂) ≤ 2λ_TV·V* along the ray (by convexity).
- Norm face: (3f/8)nρ² > 2λ_TV·V̄ iff C_ρ > 16cV̄/(3f).
- TV face: λ_TV·(T − 2V̄) = (f/4)nρ² > G.
- The width gives J ≍ n^{1/(2r+1)}(log n)^{1/(2r+1)}, the same order as nρ², so a large C_ρ absorbs it.

Rulings:
- r ≥ 2 only, the same as the main theorem; r = 1 goes in as a remark sketch. Accepted.
- Log power (log n)^{1/(2r+1)}, the same as Padilla's. Accepted.
- Any c > 0; no threshold c_{1,ε} is needed. Accepted.

### Mode proof (T07c §10, Proposition prop:mode), Theory head's check, 2026-11-24

| Step | Check | Ruling |
|---|---|---|
| Basic inequality along the ray | Convexity of Q_n; TV(θ*+sδ̂) ≥ TV(sδ̂) − V* | HOLDS |
| Sup-norm on K_m | Interpolation lemma with T_m constant, β_n → 0, r ≥ 2 | HOLDS |
| Width and event | (T√log(2n)/β)^{1/r} = 2^{1/(2r)}T^{1/r}C_m^{−(2r+1)/(2r)}·nβ²; T_m² ≤ 8V̄² + f²C_m²/(8c²), covered by the max of the last two entries of C_m; E G ≤ 4(1+2^r c_F)√c_w·nβ² = (f/16)nβ²; Chebyshev 256/(f²nβ²) | HOLDS |
| Ray, norm face | 3f/8 > 2cV̄/C_m ≥ … ≤ f/3, using C_m ≥ 6cV̄/f | HOLDS |
| Ray, TV face | λ_TV(T_m − 2V̄) = (f/4)nβ² > G | HOLDS |

Verdict: the mode result is proved for r ≥ 2, any c > 0 and n ≥ n_ε, at Padilla's rate n^{−2r/(2r+1)}(log n)^{1/(2r+1)}, without Padilla's Thm 3, Prop 3 or Lemmas 17–25. Statement to be restated in this proved form (r ≥ 2, any c > 0, n ≥ n_ε); this was put to HQ. r = 1 stays a SKETCH remark.
