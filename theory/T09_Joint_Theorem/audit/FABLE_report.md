# T-09 audit: Theorem `thm:joint` (referee: Fable)

**Verdict: ACCEPT with minor wording fixes. The theorem is correct as stated and the proof is complete. 0 ERROR, 0 GAP, 6 IMPRECISION, 4 STYLE.**

Every step was re-derived by hand against `paper/sections/theory.tex`, `appendix_theory.tex` and `methodology.tex`. The exponents were also checked with exact fractions (one single-core run through `owls_run`). A scratch copy of `T09.tex` compiles with no errors and no overfull boxes; the only warnings are the expected undefined paper labels.

Files: S = `theory/T09_Joint_Theorem/STATEMENT.tex`, P = `theory/T09_Joint_Theorem/PROOF.tex`.

## Findings

### 1. IMPRECISION — S:28 (remark), "within half the distance between neighbouring true curves"
The proof does not use the distance between the true curves. It uses half of the guaranteed lower bound `g_0 = min{L, min_j (τ_{j+1}-τ_j)/f̄}` (P:62, P:64-66). The true gap can be much larger than `g_0` (it can exceed `L`), and using the true gap would make `n_0` depend on the law and break the uniformity claim. "It takes effect once" also reads as a necessary condition, whereas it is only the sufficient condition of the proof, and `n ≥ n_{0,l}` and `Jη_n ≤ 1/2` are needed as well.
**Fix:** "The proof applies once each individual posterior is concentrated, in the supremum norm, within half the separation $\min\{L,\min_j(\tau_{j+1}-\tau_j)/\bar f\}$ that Assumption B guarantees between neighbouring true curves, and the supremum-norm bound …".

### 2. IMPRECISION — P:83 (closing total-variation sentence)
The identity `TV(Π_C, Π^⊗) = Π^⊗(C^c | y)` is correct for the convention `sup_B |P(B) - Q(B)|` (attained at `B = C`). Under the `L_1` convention the value is `2Π^⊗(C^c | y)`. Three smaller points in the same sentence:
- "at most `Jη_n` on Ω" holds for `n ≥ n_0` and `σ_j = 1` only. For general scales it is `Σ_l η'_{n,l}`.
- "an event of probability of order `n^{-1/(2r)}`" is an upper bound, not an order.
- "total variation" collides with the paper's `TV(θ)`, the variation of the trend.

**Fix:** "… for $n\ge n_0$ the total variation distance $\sup_B|\Pi_{\mathcal C}(B\mid y)-\Pi^{\otimes}(B\mid y)|$ equals $\Pi^{\otimes}(\mathcal C^c\mid y)$, which is at most $J\eta_n$ on $\Omega$. Outside an event of probability at most $J(5/4+64/\underline f^2)n^{-1/(2r)}$, …". The claim "faster than any power of n" is correct: `η_n ≤ r!{n^{-f̲ n^{2/(2r+1)}/16} + e^{-n/8}}`.

### 3. IMPRECISION — S:25, "place mass tending to one on C"
The proof shows `Π^⊗(C | y) ≥ 1 - Jη_n` on the event Ω only, and `pr(Ω^c) ≤ J(5/4+64/f̲²)n^{-1/(2r)}`. As written the sentence reads as holding for every `y`.
**Fix:** "… place mass tending to one on $\mathcal C$, with probability tending to one, and then …".
Same line, optional: "No assumption is added to those of Theorem main" → "No assumption is added beyond those of Theorem main at each level".

### 4. IMPRECISION — S:11, "The denominator is positive for every y"
True only for `n > k+1` (Lemma `pf:lem:cond` is stated for `n > r`, and it cites `pf:lem:coord`, which needs `n > r`).
**Fix:** "For $n>k+1$ the denominator is positive for every $\by$, …".

### 5. IMPRECISION — S:22 and P:80 (general scales)
The argument is correct. Each level is rescaled by its own `σ_{0l}`, the ordering constraint and `g_0` stay on the original scale, and the proof correctly uses `σ_{0l}s'_{n,l} ≤ g_0/2` and level-dependent `η'_{n,l}`. Two things are left implicit:
- The object. `Π_j` is defined through `eq:post-fixed`, which is the `σ=1` posterior, so "the same holds for any fixed `σ_j = σ_{0j}`" never says what `Π_C` is.
  **Fix (S:22):** "The same holds for any fixed $\sigma_j=\sigma_{0j}>0$, with $\Pi_j$ in \eqref{eq:joint-fixed} replaced by the posterior at the scale $\sigma_{0j}$, and constants depending also on …".
- The constants.
  **Fix (P:80, append):** "This gives the bound with $C=2\max_lC_l+\sum_l\{5/4+64/(\sigma_{0l}\underline f)^2\}$, and with $n_0$ chosen so that $n_0$ exceeds the thresholds of the rescaled problems, $\max_l\sigma_{0l}s'_{n,l}\le g_0/2$ and $\sum_l\eta'_{n,l}\le1/2$ for $n\ge n_0$."

### 6. IMPRECISION — the rest of the paper contradicts the new theorem once it is inserted
Outside the two audited files, but it has to change with them.
- `paper/sections/discussion.tex:8`: "A natural next step is a contraction result for the joint posterior of several quantile levels under the ordering constraint, which would extend Theorem main to the non-crossing sampler." This becomes false. Replace it with the open cases the remark names: random `λ_j, σ_j`, the regime where the constraint binds, and a grid of levels that grows with `n`.
- `paper/sections/theory.tex:13` (roadmap of the section) does not list the new subsection `sec:joint-result`.
- `introduction.tex:23` ("Third, we establish posterior contraction …") and `:25`, `discussion.tex:6`, and the abstract mention one theorem only.

### 7. STYLE — notation clashes with the appendix the proof is inserted into
- `C_l` at `l = 1` (P:58, P:60) is `C_1`, which `appendix_theory.tex:87` already defines as `max{f̄/2, 1/L}` and uses in `pf:lem:check`(d) and `pf:lem:evid`. **Fix:** write `M^{(l)}, C^{(l)}, n_0^{(l)}, n_2^{(l)}`.
- `J` is the number of spline knots throughout the appendix (`pf:lem:F`, `pf:lem:sb`, `pf:lem:width`, `pf:lem:score`, `pf:prop:shell`, and "J as in Proposition shell" in the proof of the main theorem). `J` for the number of levels is fixed by Section 2, so **fix** by adding at P:5: "In this subsection $J$ is the number of levels, not the number of knots."

### 8. STYLE — the theorem is stated level by level; the simultaneous version costs nothing
For a result on the joint posterior a referee will expect all levels at once. The same proof gives it: on Ω,
`Π_C(∪_j {θ_j ∈ A_j} | y) ≤ 2 Σ_j Π_j(A_j | y)`, so
`E Π_C(max_j Δ_n²(θ_j - θ*_j) > M ε_n² | y) ≤ {J(5/4+64/f̲²) + 2 Σ_j C_j} n^{-1/(2r)}`.
**Fix:** state the display with `max_{1≤j≤J} Δ_n²(θ_j - θ*_j)` and `C = 2Σ_l C_l + J(5/4+64/f̲²)`, or add one sentence after the theorem. Optional in the same spirit: the fact of finding 2 in expectation, `E sup_B|Π_C(B | y) - Π^⊗(B | y)| ≤ C n^{-1/(2r)}`, is the real content of the theorem and could be its second display.

### 9. STYLE — P:54, Lemma `pf:lem:sup` cites the proof of Proposition `pf:prop:local`(a), not its statement
Valid, and the parenthesis says so, but the step is one line and can stand alone. **Fix:** "For $\delta\in K_n$, Lemma interp with $\|\delta\|_n\le\rho_n$ and $\TV^{(r)}(\delta)\le T_n$ gives $\|\delta\|_\infty\le s_n$ (for all $n>r$); and $\rho_n^{2r-2}T_n=(4/c)\,n^{-(4r^2-8r+1)/(2(2r+1))}(\log n)^{r-1}\to0$ since $r\ge2$."

### 10. STYLE — small wording
- P:68: the union bound silently uses `{‖θ_l - θ*_l‖_∞ > g_0/2} ⊂ {‖θ_l - θ*_l‖_∞ > s_{n,l}}`. Add "since $s_{n,l}\le g_0/2$".
- P:78: "M depends on neither J nor the spacing" → "M is the largest of the J single-level constants and does not depend on the spacing".
- S:11 and S:20: `E_{θ*}` is kept, but no single `θ*` exists in this subsection (only `θ*_j`). The definition in words covers it, so this is cosmetic.

## Checked OK

- **Joint posterior (S:7-11).** Integrating `Z` out of `eq:joint_target` and conditioning on `(λ, σ)` gives `1_C(Θ) Π_j exp{-σ_j^{-1} Σ_i ρ_{τ_j}(y_i - θ_{ij}) - λ_j‖Dθ_j‖_1}`. This is `eq:joint-fixed` at `σ_j = 1`, the product of the single-level posteriors conditioned on `C`.
- **Lemma `pf:lem:cond`.** Positive density everywhere from `pf:lem:coord`(b), used within `n > r`. `C` is closed and contains a nonempty open set. The inequality is immediate.
- **Lemma `pf:lem:gap` and the "no added assumption" claim.** Assumption B at `τ_j` gives continuity at `θ*_{ij}`, hence `F(θ*_{ij}) = τ_j`. `F(θ*_{i,j+1}) ≥ τ_{j+1}` by the definition of a quantile. So `d > 0`, and `d ≤ L` implies `τ_{j+1} - τ_j ≤ f̄ d`. Only B at the lower level and the same `L` are used, so the separation follows from Assumption B exactly as stated in `theory.tex`. The claim at S:25 is correct.
- **Lemma `pf:lem:sup`.**
  - `sup_{K_n}‖δ‖_∞ ≤ s_n` follows from `pf:lem:interp`.
  - Exponent of `ρ_n^{2r-2}T_n` is `-(4r²-8r+1)/(2(2r+1))`.
  - `pf:prop:local`(b) is used for `n ≥ n_2` on `Ω_E ∩ Ω_G`.
  - `pr(Ω_E^c) ≤ (5/4)n^{-1/(2r)}` for `n ≥ n_1`.
  - `nρ_n² = n^{2/(2r+1)} log n ≥ n^{1/(2r)}` for `n ≥ 3`.
  - `s_n` depends on `(c, r)` only and `η_n` on `(f̲, r)` only.
- **Proof of the theorem.** Choice of `n_0`; `C^c ⊂ ∪_l {‖θ_l - θ*_l‖_∞ > g_0/2}`; `Π^⊗(C | y) ≥ 1/2` on Ω; transfer with factor 2; `M ≥ M_j`; the final constant `C = 2 max_l C_l + J(5/4+64/f̲²)`. The posteriors share the same `y`, but only a union bound over the `Ω_l` is used, so their dependence does not matter.
- **Constants and uniformity.** `M`, `C`, `n_0` depend only on `c_1,…,c_J, k, L, f̲, f̄, V̄, J` and the smallest spacing. The single-level constants do not depend on `τ`: in the appendix `τ` enters only through `τ(1-τ) ≤ 1/4`, `|ζ_i| ≤ 1`, and the qualitative finiteness in `pf:lem:coord`(b). The spacing enters `n_0` only. The uniformity claim is justified.
- **General scales.** The rescaled assumptions `(L/σ_0, σ_0 f̲, σ_0 f̄, V̄/σ_0)`, `c → σ_0 c`, and the quantile `θ*_l/σ_{0l}` of `y/σ_{0l}` are right. `pr(Ω_l^c) ≤ {5/4 + 64/(σ_{0l} f̲)²} n^{-1/(2r)}`.
- **Remark, `n^{-13/70}`.** For `k = 2` (`r = 3`): `ρ_n = n^{-5/14}(log n)^{1/2}` and `(ρ_n^4 T_n)^{1/5} = (4/c)^{1/5} n^{-13/70}(log n)^{2/5}`, so `s_n` is of order `n^{-13/70}(log n)^{2/5}`. For scale, with the constant set to 1 this is below 0.1 only for `n` near `1.3e8`, so "decreases slowly" and "does not describe that regime" are fair.
- **Remark, other claims.** Fixed `λ_j, σ_j` and fixed levels are correctly listed as not covered by the statement.
- **Parallelism with `thm:main`.** Same hypotheses format, rate, probability order, uniformity sentence and `σ_0` sentence. All cited labels exist in the paper, and all macros used are defined in `theory.tex` and `appendix_theory.tex`. The description of each cited result in `T09.tex` matches the paper.
