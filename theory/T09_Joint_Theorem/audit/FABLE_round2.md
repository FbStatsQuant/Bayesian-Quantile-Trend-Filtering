# T-09 round 2: Theorem `thm:joint`, v2 (referee: Fable)

**Verdict: NOT CLEAN, 6 findings: 0 ERROR, 0 GAP, 3 IMPRECISION, 3 STYLE.**

The theorem is correct and the proof is complete. Every accepted round-1 finding is implemented, and each fix is mathematically right. All six remaining findings are wording in sentences that v2 added; none changes the statement or any constant at unit scales.

I re-derived every step of v2 by hand against `paper/sections/theory.tex`, `appendix_theory.tex` and `methodology.tex`. A scratch copy of `T09.tex` compiles to 5 pages with no errors. No computation was run.

Files: S = `theory/T09_Joint_Theorem/STATEMENT.tex`, P = `theory/T09_Joint_Theorem/PROOF.tex`.

## Findings

### 1. IMPRECISION — P:83, total-variation sentence at general scales
The sentence gives the exceptional probability `J(5/4+64/f̲²)n^{-1/(2r)}` at unit scales, then says "for general scales the bound is `Σ_l η'_{n,l}`" without restating the probability. Read literally, the unit-scale probability carries over. For `σ_{0l} < 1` the proof gives the larger value `Σ_l{5/4+64/(σ_{0l}f̲)²}n^{-1/(2r)}` (P:80). This is the same omission as round-1 A1, moved from the bound to the event.

**Fix:** replace "; for general scales the bound is $\sum_l\eta_{n,l}'$. Both tend to zero…" with
". For general scales, with the $n_0$ of the last paragraph of the proof, the event has probability at most $\sum_l\{5/4+64/(\sigma_{0l}\fl)^2\}n^{-1/(2r)}$ and the bound is $\sum_l\eta_{n,l}'$. Both bounds tend to zero faster than any power of $n$."

### 2. IMPRECISION — P:80, general-scale constants: `M` is missing
The new sentence writes out `C` and `n_0` and says `C^{(l)}` is "now the constant of Theorem main at the scale `σ_{0l}`". It does not say the same for `M^{(l)}`. `M` changes too: the reduction multiplies it by `max{σ_{0l}, σ_{0l}²}` (`appendix_theory.tex:49`). Also "the thresholds of the rescaled problems" does not say which thresholds; both `n_0^{(l)}` and `n_2^{(l)}` are needed.

**Fix:** "This gives the bound with $M=\max_lM^{(l)}$ and $C=2\max_lC^{(l)}+\sum_l\{5/4+64/(\sigma_{0l}\fl)^2\}$, where $M^{(l)}$, $C^{(l)}$ and $n_0^{(l)}$ are now the constants of Theorem~\ref{thm:main} at the scale $\sigma_{0l}$, and with $n_0\ge\max_ln_0^{(l)}$, at least the thresholds $n_2$ of the rescaled problems, and such that …".

### 3. IMPRECISION — P:83, simultaneous version: `A_j` undefined, `n ≥ n_0` missing
The proof defines one set `A` for a fixed `j` (P:73). `A_j` is never defined. The inequality "on Ω" also needs `n ≥ n_0`, because `Π^⊗(C | y) ≥ 1/2` on Ω holds only then.

**Fix:** "First, for $n\ge n_0$, on $\Omega$ and for any Borel sets $A_1,\dots,A_J\subset\R^n$, $\Pi_{\mathcal C}(\cup_j\{\theta_j\in A_j\}\mid y)\le2\sum_j\Pi_j(A_j\mid y)$. With $A_j=\{\theta:\Delta_n^2(\theta-\thetas_j)>M\en^2\}$, the bound of Theorem~\ref{thm:joint} holds simultaneously …".

The constant `2Σ_l C^{(l)} + J(5/4+64/f̲²)` is correct.

### 4. STYLE — P:54, order of sentences in the proof of Lemma `pf:lem:sup`
"Hence {‖θ−θ*‖_∞ > s_n} ⊂ {θ−θ* ∉ K_n}" follows from the first sentence (the bound on `K_n`). It now sits after the sentence proving `s_n → 0`, so "Hence" points at the wrong step.

**Fix:** move the "Hence … on Ω_E ∩ Ω_G." sentence to directly after the first sentence, and put the two limits `s_n → 0` and `η_n → 0` together after it.

### 5. STYLE — S:22, "with Π_j in (eq:joint-fixed) the posterior at the scale σ_{0j} and constants depending also on …"
The two "with" complements are not parallel, and the sentence reads as elliptical.

**Fix:** "The same holds for any fixed $\sigma_j=\sigma_{0j}>0$, where $\Pi_j$ in \eqref{eq:joint-fixed} is the posterior at the scale $\sigma_{0j}$, with constants depending also on $\sigma_{01},\dots,\sigma_{0J}$."

### 6. STYLE — P:75–76 and P:83, two overfull lines that will appear in the paper
The wrapper uses the paper's geometry (12pt, 1in margins; `paper/main.tex:1,5`), so these are not artefacts of the wrapper. The transfer display is 2.5pt too wide, and the closing paragraph has a line 8.2pt too wide.

**Fix:** break the transfer display after the first `\le` (use `aligned`). The closing paragraph will re-break after the edits of findings 1 and 3; if it does not, display the inequality.

## Accepted round-1 findings: implementation

| Finding | In v2 | Correct |
|---|---|---|
| A1 / F2 (TV sentence) | P:83: distance written as `sup_B`, `n ≥ n_0`, unit versus general scales, "at most" | Yes; residual in finding 1 |
| A2, accepted part (opening) | S:5 | Yes |
| A3 / F10(b) (`M` wording) | P:78 | Yes |
| A4(a) / F4 (`n > k+1`) | S:11 | Yes |
| A4(b) / F5 (general-scale object and constants) | S:22, P:80 | Yes; residual in findings 2 and 5 |
| A5 (`f̄ > 0`, no citation of `pf:lem:check`(b)) | P:23, P:31 | Yes. `F(θ*−) ≤ τ ≤ F(θ*)` plus continuity gives `F(θ*) = τ` under B alone |
| A6 / F1 (remark) | S:28 | Yes |
| F3 ("with probability tending to one") | S:25 | Yes |
| F7 (notation) | P:9, P:58–76 | Yes. No `C_l`, `M_l`, `n_{0,l}` or `n_{2,l}` remains |
| F8 (simultaneous version) | P:83 | Yes; residual in finding 3 |
| F9 (Lemma `pf:lem:sup` proof) | P:54 | Yes; residual in finding 4 |
| F10(a) ("since s_{n,l} ≤ g_0/2") | P:68 | Yes |
| F6 (rest of the paper) | Not in these files | Still open: `paper/sections/discussion.tex:8` still says "A natural next step is a contraction result for the joint posterior…" |

## Rejected parts

- **A2, deterministic-penalty wording: agree with the rejection.** `theory.tex:13` and `:24` state that all results of the section take λ deterministic and σ fixed, S:11 calls `Π_C` "the conditional posterior of Θ given the penalties and the scales", and the remark repeats it. One optional tweak at S:5: "this joint posterior" has no antecedent, because the previous sentence names the sampler, not a posterior. "…at every level of the joint posterior defined below" removes the only reading under which Astra's concern applies.
- **A6, "deterministic": agree.** The paper itself writes "held fixed" (`theory.tex:13`) and "the fixed λ and σ of the theorem" for the same objects, and the remark contrasts "fixed" with "learns them".
- **F10(c), `E_{θ*}`: agree.** S:11 defines the symbol in words, and a new symbol would break the parallel with `thm:main`.

## Checked OK

- **Statement against `thm:main`.** Same order of hypotheses, same penalty display, same rate and probability order, same uniformity and general-scale sentences. The dependence list adds only `J` and the smallest spacing. It reads naturally.
- **Lemma `pf:lem:cond`.** Positive density from `pf:lem:coord`(b); `C` contains a nonempty open set.
- **Lemma `pf:lem:gap`.** Uses B at the lower level only. `d > 0`, and `d ≤ L` gives `τ_{j+1} − τ_j ≤ f̄ d`.
- **Lemma `pf:lem:sup`.**
  - `‖δ‖_∞ ≤ s_n` on `K_n` follows from `pf:lem:interp` by monotonicity in both arguments.
  - The exponent `−(4r²−8r+1)/(2(2r+1))` is right.
  - `nρ_n² = n^{2/(2r+1)} log n ≥ n^{1/(2r)}` for `n ≥ 3`.
  - `s_n` depends on `(c, r)` only and `η_n` on `(f̲, r)` only.
- **Proof of the theorem.** Choice of `n_0`; `C^c ⊂ ∪_l{‖θ_l − θ*_l‖_∞ > s_{n,l}}`; factor 2; `C = 2 max_l C^{(l)} + J(5/4+64/f̲²)`. Neither `M` nor `C` depends on the spacing, because the single-level constants do not depend on τ.
- **General scales.** `c_l → σ_{0l}c_l`, `(L/σ_{0l}, σ_{0l}f̲, σ_{0l}f̄)`, `V̄/σ_{0l}`; the radius `σ_{0l}s'_{n,l}` is on the original scale; `pr(Ω_l^c) ≤ {5/4+64/(σ_{0l}f̲)²}n^{-1/(2r)}`; `η'_{n,l}` is `η_n` with `f̲` replaced by `σ_{0l}f̲`. The stated `C` and the conditions on `n_0` are right.
- **Closing paragraph.** `sup_B|Π_C(B) − Π^⊗(B)| = Π^⊗(C^c)` (attained at `B = C`). `Jη_n` and `Σ_l η'_{n,l}` decay faster than any power of `n`.
- **Remark.** `n^{-13/70}(log n)^{2/5}` at `k = 2`. The half-separation sentence now matches `g_0/2` in the proof.
- **Labels.** Every cited label exists in `paper/`. None of the seven new labels is already used there.
