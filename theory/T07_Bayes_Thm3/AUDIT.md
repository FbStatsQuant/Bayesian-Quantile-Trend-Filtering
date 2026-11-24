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
