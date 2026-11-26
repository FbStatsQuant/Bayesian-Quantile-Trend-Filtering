# T-09 audit record

Theory Department, 2026-11-25. Theorem `thm:joint`: the joint non-crossing posterior contracts at every level at the rate of Theorem `thm:main`. The statement is an upper bound only.

## Head's line-by-line check of the prover's draft (before the audits)

I checked every step against `paper/sections/theory.tex` and `paper/sections/appendix_theory.tex`. Every step holds. I changed five points of wording and citation myself; the prover's original draft is in `audit/round0/`, and the audited v1 is in `audit/round1/`.

| # | Where | Change | Why |
|---|---|---|---|
| H1 | PROOF.tex, throughout | `\by` → `y` | The appendix writes plain `y`; the main-text statement keeps `\by`. |
| H2 | PROOF.tex, Lemma `pf:lem:sup` | "the first display … the second display" → "applies Lemma `pf:lem:interp` on K_n … its display" | In the appendix the sup-norm bound is inline text, not a display. There is one display. |
| H3 | PROOF.tex, Lemma `pf:lem:sup` | Added nρ_n² = n^{2/(2r+1)} log n ≥ n^{1/(2r)}, because 2/(2r+1) ≥ 1/(2r) | The exponent comparison was used but not stated. |
| H4 | PROOF.tex, closing sentence | "exponentially small" → "at most Jη_n, which tends to zero faster than any power of n" | Jη_n is of order e^{−c n^{2/(2r+1)} log n}, which is stretched-exponential, not exponential. |
| H5 | STATEMENT.tex, scope remark | "for k = 2" → "for the default k = 2" | The paper uses k = 2 throughout, so this says why that order is quoted. |

Points checked and found correct:
- **Separation (Lemma `pf:lem:gap`).** It uses only Assumption B at level τ_j (as stated, with δ supported on one coordinate) and the definition of a quantile.
- **Union bound.** C^c is covered by the union of the sets where some ‖θ_l − θ*_l‖_∞ exceeds g_0/2. No independence between levels is used; all levels share the same y.
- **Constants.** n_2 depends on (c, r, L, f̲, f̄, V̄), n_0 adds J and g_0, and C does not depend on the spacing.
- **σ_j rescaling.** It matches the appendix's "Reduction to σ = 1".
- **Total variation.** The distance between P(·|C) and P is P(C^c).
- **Remark's order.** n^{−13/70} at k = 2 follows from the display in the proof of `pf:prop:local`(a), with r = 3.

## Independent audits

Two fresh reviewers each received the statement, the proof and the paper's appendix, but not my conclusion:
- Fable 5.2 (CP, high): `audit/FABLE_report.md`
- Astra (gpt-6.2-astra, high): `audit/ASTRA_report.md`

Both audited the same version (v1 = the prover's draft plus H1–H5). I verified each finding myself.

### Astra, round 1

Verdict: the theorem is correct and the proof complete. Findings:

| # | Tag | Finding | Ruling |
|---|---|---|---|
| A1 | ERROR (closing sentence) | After the general-scale paragraph, the TV bound Jη_n is stated without qualification. At unequal scales the proof gives Σ_l η'_{n,l}, and for σ_{0l} < 1 the first term decays more slowly. Also "of order" should be "at most of order". | **Accepted.** It holds: η'_{n,l} has f̲ replaced by σ_{0l}f̲. Fix: give Jη_n at σ_j = 1 and Σ_l η'_{n,l} in general, and say "at most of order". |
| A2 | IMPRECISION | The opening "under the same assumptions" is vague, and it could be read as covering learned hyperparameters. | **Partly accepted.** Reworded to "under the assumptions of Theorem main, imposed at every level". The deterministic-λ point is rejected: the section preamble in theory.tex already says that all results in the section take λ deterministic and σ fixed, and the scope remark repeats it. |
| A3 | IMPRECISION | "M depends on neither J nor the spacing" is misleading, because M = max_l M_l runs over c_1, …, c_J. | **Accepted.** Reworded: M is the largest single-level constant, it has no extra factor of J, and the spacing enters only n_0. |
| A4 | IMPRECISION | (a) The text should state k ≥ 1 and n > k+1 where it says Π_C is proper. (b) It should define the σ_j-posterior. | **Rejected at first, then reversed to accepted (see F4, F5).** Original reasoning: (a) The order k ≥ 1 is fixed in the setting at theory.tex:17. For n ≤ k+1 each Π_j is undefined, so the claim is conditional on Π_j existing, exactly as for eq:post-fixed ("It is proper", no n range in the main text). Lemma pf:lem:cond states n > r in the appendix. (b) thm:main itself handles general σ by the sentence "The same holds for any fixed σ = σ_0", with eq:post-fixed written at σ = 1. HQ required the new statement to mirror thm:main exactly. |
| A5 | IMPRECISION | The separation lemma divides by f̄ without assuming f̄ > 0, and it cites Lemma check(b), which assumes A as well as B. | **Accepted.** f̄ > 0 is added to the lemma's hypothesis (A forces f̄ ≥ f̲ > 0 in the theorem). F(θ*_{ij}) = τ_j is derived directly from F(q−) ≤ τ ≤ F(q) and continuity, without the citation. |
| A6 | STYLE | In the remark, "the ordering constraint can bind" is ambiguous, since equality has probability zero. The half-gap condition belongs to the proof, not the theorem. Penalties should be "deterministic". | **Partly accepted.** Changed to "conditioning on C can change the posterior materially", and the half-gap sentence is now attributed to the proof. "Deterministic" is rejected because the remark already says λ_j and σ_j are fixed and that learning them is not covered. |

### Fable, round 1

Verdict: ACCEPT with minor wording fixes: 0 ERROR, 0 GAP, 6 IMPRECISION, 4 STYLE.

| # | Tag | Finding | Ruling |
|---|---|---|---|
| F1 | IMPRECISION | The remark says "half the distance between neighbouring true curves". The proof uses half of the guaranteed g_0; the true gap would make n_0 depend on the law. Also, "takes effect once" reads as a necessary condition. | **Accepted** (merged with A6). The remark now says: "Its proof requires … within half the separation min{L, min_j(τ_{j+1}−τ_j)/f̄} guaranteed above". |
| F2 | IMPRECISION | In the closing TV sentence: the identity holds for the sup_B convention (twice that for L1); the bound needs n ≥ n_0 and σ = 1; "of order" should be "at most"; and "total variation" clashes with TV(θ). | **Accepted** (merged with A1). The distance is now written out as sup_B\|·\| to avoid the clash, and the sentence states n ≥ n_0, unit versus general scales, and "at most J(5/4+64/f̲²)n^{−1/(2r)}". |
| F3 | IMPRECISION | "Place mass tending to one on C" holds only on Ω. | **Accepted**: added "with probability tending to one". Also "no assumption is added beyond those of Theorem main at each level". |
| F4 | IMPRECISION | The denominator is positive only for n > k+1. | **Accepted**, and A4(a) is reversed. Both auditors raised it independently, and "For n > k+1" costs three words, so I prefer precision over strict parallel with eq:post-fixed. |
| F5 | IMPRECISION | Π_C at general scales is never defined, and C and n_0 for general scales are not written out. | **Accepted**, and A4(b) is reversed for the same reason. The theorem now says "with Π_j in (eq:joint-fixed) the posterior at the scale σ_{0j}", and the proof writes out C and n_0 for general scales. |
| F6 | IMPRECISION | Once the theorem is inserted, other parts of the paper become stale: discussion.tex:8 ("A natural next step is a contraction result for the joint posterior…") becomes false; the roadmap at theory.tex:13, introduction.tex:23/25 and the abstract mention one theorem only. | **Accepted, handed to HQ/Writing.** These are edits to paper/, which Theory does not make. |
| F7 | STYLE | C_l at l = 1 collides with the appendix's C_1 = max{f̄/2, 1/L}, and J means the number of knots throughout the appendix. | **Accepted.** Per-level constants are now M^{(l)}, C^{(l)}, n_0^{(l)}, n_2^{(l)}, and one sentence says J is the number of levels in this subsection. |
| F8 | STYLE | The simultaneous version over all levels (max_j Δ²_n) costs nothing. | **Partly accepted.** It is added as a sentence after the proof, with C = 2Σ_l C^{(l)} + J(5/4+64/f̲²) at unit scales. The theorem stays per level as HQ specified; promoting the simultaneous version is offered to HQ. |
| F9 | STYLE | Lemma sup cites the proof, not the statement, of Proposition local(a). | **Accepted.** The one-line derivation from Lemma interp now stands alone and points to Proposition local(a) only for the exponent. |
| F10 | STYLE | (a) "since s_{n,l} ≤ g_0/2" is implicit; (b) the M wording; (c) E_{θ*} with J truths. | (a), (b) **Accepted.** (c) **Rejected**: it keeps the paper's symbol, and the sentence before the theorem defines it in words. |

### Changes from the Astra findings (rulings above, revised where noted)

A1 and A3 are applied. In A2 the reworded opening is applied. A4 is reversed to **accepted** (see F4, F5). A5 is applied: f̄ ∈ (0, ∞) is added to the lemma, and F(θ*) = τ is now derived without citing Lemma check(b). A6 is applied with F1.

Result: v2 (statement and proof). It compiles to 5 pp; the only warnings are the expected paper labels and two overfull boxes under 9pt in the standalone 12pt wrapper.

## Round 2: re-check of v2 by fresh agents

Two new agents re-checked v2: Fable 5.2 (CP, high), report `audit/FABLE_round2.md`, and Astra (gpt-6.2-astra, high), report `audit/ASTRA_round2.md`.

Both found the theorem correct, the proof complete, and every accepted round-1 fix implemented correctly. Both agree with all three rejections (A2 and A6 "deterministic", F10(c)). The new findings are wording in sentences that v2 had added. I verified each one.

| # | Finding | Ruling |
|---|---|---|
| R2-A1 = R2-F2 | At general scales, M is left implicit. The single-level theorem at scale σ_0 multiplies its M by max{σ_0, σ_0²}. The thresholds "of the rescaled problems" should name n_0^{(l)} and n_2. | **Accepted.** M = max_l M^{(l)}, with M^{(l)}, C^{(l)} and n_0^{(l)} taken at the scale σ_{0l} in the original units. The factor is stated, and n_0 ≥ every n_0^{(l)} and every n_2. |
| R2-A2 = R2-F1 | The closing sentence gives the general-scale distance bound but keeps the unit-scale exceptional probability. That probability is too small when σ_{0l} < 1. | **Accepted.** The sentence now states the probability at most n^{−1/(2r)} Σ_l{5/4 + 64/(σ_{0l}f̲)²} together with the bound Σ_l η'_{n,l}, and gives the unit-scale specialisation. |
| R2-A3 | Add "k ≥ 1" to the propriety sentence. | **Rejected.** The section fixes "an order k ≥ 1" in its setting paragraph (theory.tex:17), so the theorem inherits it. "For n > k+1" is the part that carries information. |
| R2-F3 | In the simultaneous version, A_j is undefined, and "on Ω" needs n ≥ n_0. | **Accepted.** The sentence now reads "for n ≥ n_0, on Ω and for any Borel A_1, …, A_J", then specialises A_j. |
| R2-F4 | In Lemma sup's proof, the inclusion sentence should follow the first sentence directly. | **Accepted.** The sentences are reordered. |
| R2-F5 | "with Π_j … and constants depending" is elliptical. | **Accepted.** It now reads "where Π_j in (…) is the posterior at the scale σ_{0j}, with constants depending also on …". |
| R2-F6 | Two overfull lines in the paper geometry. | **Accepted.** The transfer display is broken with `aligned`, and v3 compiles with no overfull box. |
| R2-F (optional) | "this joint posterior" has no antecedent. | **Accepted.** It now reads "the joint posterior defined below". |

Result: v3. It compiles to 5 pp with no errors and no overfull boxes; the only warnings are the expected undefined paper labels.

## Round 3: final confirmation of v3 by fresh agents

Two new agents checked v3: Fable 5.2 (CP, high), report `audit/FABLE_round3.md`, and Astra (gpt-6.2-astra, high), report `audit/ASTRA_round3.md`. Both confirm that every accepted round-2 fix is implemented correctly, and both agree with the rejection of R2-A3.

- **Astra: CLEAN, 0 findings.**
- **Fable: 1 IMPRECISION, 0 ERROR, 0 GAP.** The last sentence said "the bound tends to zero faster than any power of n" after naming two bounds. That holds for the distance bound Σ_l η'_{n,l} but not for the exceptional probability, which is at most of order n^{−1/(2r)}. **Accepted.** The sentence now applies Fable's text, with "at most of order" in place of "of order", because only an upper bound is proved (as in A1).

The fix is Fable's own text verbatim, apart from that one word change, in one sentence of a remark after the proof. It changes no mathematics, so I verified it myself and did not run a fourth round.

**Final state.** v4 is clean in both audits. It compiles to 5 pp with no errors and no overfull boxes.

## Open items handed to HQ / Writing (not Theory's to edit)

- **F6.** Once thm:joint is inserted, `paper/sections/discussion.tex:8` ("A natural next step is a contraction result for the joint posterior …") becomes false. The roadmap at theory.tex:13, introduction.tex:23/25, discussion.tex:6 and the abstract mention one theorem only.
- The appendix subsection "Reduction to σ = 1" has no `\label`. The proof cites it by name; a label would allow a `\ref`.
- **Option (F8).** The simultaneous bound over all levels, for max_j Δ²_n, costs nothing and is proved in the closing paragraph. It could become the theorem's display if Felipe prefers.

## Post-audit fix (2026-11-26, Sol-P2 via the Lean head)

`PROOF.tex` line 60 used C = 2 max_l C^{(l)} + J(5/4 + 64/f̲²). For the per-level statement here that is valid. The paper's Theorem 2 (W-05, 5d5eb81) is the max_j form, and the closing paragraph of this proof gives 2 Σ_l C^{(l)} for it. The paper appendix and Lean J7 already use the sum. The source now uses C = 2 Σ_l C^{(l)} + J(5/4 + 64/f̲²), which serves both forms because Σ ≥ max.
- The transfer display still ends with "≤ C".
- No other change.
- The fix is a one-symbol edit, so I verified it myself and ran no new audit.
