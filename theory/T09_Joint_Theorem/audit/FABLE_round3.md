# T-09 round 3: Theorem `thm:joint`, v3 (referee: Fable)

**Verdict: NOT CLEAN (1): 0 ERROR, 0 GAP, 1 IMPRECISION, 0 STYLE.**

The theorem is correct and the proof is complete. Every accepted round-2 finding is implemented correctly. I agree with the rejection of R2-A3. The one finding is an ambiguous antecedent in the last sentence after the proof, introduced by the round-2 rewrite of that sentence. It is a one-clause fix and changes no mathematics.

I re-derived the general-scale paragraph, the paragraph after the proof, the proof of Lemma `pf:lem:sup` and the statement by hand against `paper/sections/theory.tex`, `appendix_theory.tex` and `methodology.tex`. A scratch copy of `T09.tex` compiles to 5 pages with no errors and no overfull or underfull boxes. No computation was run. I did not read `audit/ASTRA_round3.md`.

Files: S = `theory/T09_Joint_Theorem/STATEMENT.tex`, P = `theory/T09_Joint_Theorem/PROOF.tex`.

## Finding

### 1. IMPRECISION — P:85, last sentence: "The bound tends to zero faster than any power of $n$."

The sentence before it now names two bounds: the probability of the exceptional event, at most $n^{-1/(2r)}\sum_l\{5/4+64/(\sigma_{0l}\fl)^2\}$, and the distance, at most $\sum_l\eta_{n,l}'$. It then ends with the unit-scale pair "$J(5/4+64/\fl^2)n^{-1/(2r)}$ and $J\eta_n$". "The bound" has no single antecedent. The claim is true for the distance bound and false for the probability bound, which is of order $n^{-1/(2r)}$ exactly. In v2 the sentence was "Both tend to zero…", and "both" were the two distance bounds; the round-2 edit (R2-A2 = R2-F1) added the probability and left the last sentence without a clear subject.

**Fix:** replace the last sentence with

"The distance bound $\sum_l\eta_{n,l}'$ tends to zero faster than any negative power of $n$; the probability of the exceptional event is of order $n^{-1/(2r)}$."

("Negative power" also removes the loose reading of "any power of $n$".)

## Accepted round-2 findings: implementation in v3

| Finding | In v3 | Correct |
|---|---|---|
| R2-A1 = R2-F2 (general-scale `M`, named thresholds) | P:82: `M = max_l M^{(l)}`; `M^{(l)}`, `C^{(l)}`, `n_0^{(l)}` are the constants of `thm:main` at the scale `σ_{0l}` in the original units; the factor `max{σ_{0l}, σ_{0l}²}` is stated; `n_0` is at least every `n_0^{(l)}` and every `n_2` of the rescaled problems | Yes. It matches `appendix_theory.tex:49` (`Δ_n²(σ_0 v) ≤ max{σ_0, σ_0²} Δ_n²(v)`). With `M ≥ M^{(j)}` the set `A` at P:73 is covered by `thm:main` at the scale `σ_{0j}` |
| R2-A2 = R2-F1 (exceptional probability at general scales) | P:85: probability at most `n^{-1/(2r)} Σ_l{5/4+64/(σ_{0l}f̲)²}`, distance at most `Σ_l η'_{n,l}`, then the unit-scale pair | Yes; both values are those of P:82. Residual wording in finding 1 |
| R2-F3 (simultaneous version) | P:85: "for `n ≥ n_0`, on Ω and for any Borel sets `A_1,…,A_J`", then `A_j` specialised | Yes. Union bound plus Lemma `pf:lem:cond` and `Π^⊗(C | y) ≥ 1/2`. The constant `2Σ_l C^{(l)} + J(5/4+64/f̲²)` is right, and it is correctly limited to unit scales |
| R2-F4 (order of sentences, Lemma `pf:lem:sup`) | P:54: bound on `K_n`, then the inclusion and `pf:prop:local`(b), then the two limits, then the probability | Yes. "Hence" now follows the step it uses |
| R2-F5 (general-scale sentence in the theorem) | S:22: "where `Π_j` in (eq:joint-fixed) is the posterior at the scale `σ_{0j}`, with constants depending also on `σ_{01},…,σ_{0J}`" | Yes |
| R2-F6 (overfull lines) | P:74–79: `aligned` display | Yes. No overfull box in the paper geometry (12pt, 1in margins) |
| R2-F optional ("this joint posterior") | S:5: "the joint posterior defined below" | Yes |

## The rejection R2-A3 (`k ≥ 1` in the propriety sentence): agree

`theory.tex:17` fixes "an order `k ≥ 1`" for the whole section, and the new subsection sits inside that section. The sentence at S:11 is also true without it: positivity of the denominator needs only `n > k+1` (Lemma `pf:lem:coord`(b) and Lemma `pf:lem:cond` assume `n > r` and nothing about `r ≥ 2`). Adding `k ≥ 1` there would suggest that propriety depends on it, which it does not. `k ≥ 1` is needed only for the supremum-norm step (`ρ_n^{2r-2}T_n → 0`), and the proof says so at P:54.

## Checked OK

- **General-scale paragraph (P:82).**
  - Rescaling: the law of `θ_l/σ_{0l}` under `Π_l` is the unit-scale posterior for `y/σ_{0l}` with `c_l → σ_{0l}c_l`, because the prior `eq:prior_theta` is not scaled by σ. The rescaled data satisfy A and B with `(L/σ_{0l}, σ_{0l}f̲, σ_{0l}f̄)`, and `V* ≤ V̄/σ_{0l}`.
  - Lemma `pf:lem:sup` for the rescaled problem: `s'_{n,l}` uses `T_n = 4√n/(σ_{0l}c_l)`; `η'_{n,l} = r!{e^{-σ_{0l}f̲nρ_n²/16} + e^{-n/8}}`; `pr(Ω_l^c) ≤ {5/4+64/(σ_{0l}f̲)²}n^{-1/(2r)}`. The radius `σ_{0l}s'_{n,l}` is in the original units.
  - `g_0` stays in the original units, so the condition `max_l σ_{0l}s'_{n,l} ≤ g_0/2` is the right one. Lemmas `pf:lem:cond` and `pf:lem:gap` do not involve the scales.
  - `C = 2 max_l C^{(l)} + Σ_l{5/4+64/(σ_{0l}f̲)²}` follows from the transfer step with `pr(Ω^c) ≤ Σ_l pr(Ω_l^c)`.
- **Paragraph after the proof (P:85).** `sup_B|Π_C(B) − Π^⊗(B)| = Π^⊗(C^c)`, attained at `B = C^c`. On Ω and for `n ≥ n_0` this is at most `Σ_l η'_{n,l}`. At unit scales the two quantities reduce to `J(5/4+64/f̲²)n^{-1/(2r)}` and `Jη_n`. `Σ_l η'_{n,l}` is of order `n^{-a n^{2/(2r+1)}}` and so decays faster than any negative power of `n`.
- **Lemma `pf:lem:sup` (P:40–55).**
  - `‖δ‖_∞ ≤ s_n` on `K_n`: Lemma `pf:lem:interp` is nondecreasing in both arguments.
  - Exponent: `−(2r−1)(r−1)/(2r+1) + 1/2 = −(4r²−8r+1)/(2(2r+1))`, positive decay for `r ≥ 2`. At `r = 3` the radius is of order `n^{-13/70}(log n)^{2/5}`, and `ρ_n = n^{-5/14}(log n)^{1/2}` is smaller.
  - `nρ_n² = n^{2/(2r+1)} log n ≥ n^{1/(2r)} = nε_n²` for `n ≥ 3`, so `pr{(Ω_E ∩ Ω_G)^c} ≤ (5/4+64/f̲²)n^{-1/(2r)}`.
  - `s_n` depends on `(c, r)` only and `η_n` on `(f̲, r)` only; both statements need `n ≥ n_2`, as stated.
- **Statement (S:3–29).**
  - `C` in `eq:joint_order` has weak inequalities, so the half-gap step (`≥ 0`) gives `Θ ∈ C`.
  - `eq:joint-fixed` is the conditional of Θ under `eq:joint_target` given the penalties and scales, at unit scales: the indicator depends on Θ only and the latent `z_j` integrate out level by level.
  - Hypotheses, penalty display, rate, probability order, uniformity sentence and general-scale sentence parallel `thm:main`. The dependence list adds `J` and the smallest spacing only.
  - Remark: half the separation `g_0`; `n^{-13/70}` at `k = 2`.
- **Proof of the theorem at unit scales (P:57–80).** Choice of `n_0`; `C^c ⊂ ∪_l{‖θ_l − θ*_l‖_∞ > s_{n,l}}`; factor 2 from Lemma `pf:lem:cond`; the `aligned` display reproduces the v2 chain exactly.

## Outside these files

Round-1 F6 is with HQ/Writing and is not part of this check: the rest of `paper/` still has to be updated when the theorem is inserted.
