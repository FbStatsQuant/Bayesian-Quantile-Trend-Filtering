# Paper corrections found by the Lean formalization

This file is kept by the Lean head, under the owner's policy of 2026-11-25. Each entry records a place where the paper's proof or statement had to change for the Lean version to compile: a hypothesis added or weakened, a constant or threshold changed, a statement fixed, a proof step that was wrong or had a gap, or a missing measurability or integrability condition.

Pure formalization artifacts are **not** corrections: coercions, 0-based `Fin` indexing, `ℝ≥0∞` encodings, and stating a bound as a lower bound on a probability instead of an upper bound on −log.

**Who proposes entries.** Provers propose candidates in `notes/logs/*_questions.md`. The head decides what goes in. Any statement change is checked by Theory, and frozen statements are re-audited by Astra.

**When a packet is sent.** A module counts as finalized and checked when all of the following hold:
- it has no `sorry`;
- `#print axioms` shows only `propext`, `Classical.choice` and `Quot.sound` on its main declarations;
- a fresh Sol review has passed, and the head has ruled on every finding;
- it is merged to main with a green build.

At that point the head sends that module's entries to Writing and Theory (CC HQ), with the merge commit hash. When Writing has changed the paper, an independent reviewer checks that the new text matches the Lean statement, and the result goes to HQ.

**Status values:**
- `open`: found, and the Lean piece is not finalized yet;
- `sent`: the packet has gone to Writing and Theory;
- `in paper`: Writing has changed the text;
- `verified`: the paper text has been checked against Lean.

---

## C-01: g_r > 0 is used without proof

- **Paper label:** appendix (`paper/sections/appendix_theory.tex`), the paragraph before Lemma `pf:lem:smooth` (definition of G_w, g_r and C_s). It is used in Lemmas `pf:lem:smooth` and `pf:lem:interp`.
- **Text before the fix:** "g_r = inf_{w≥r} λ_min(G_w) ∈ (0,1] (a constant depending only on r)". No argument was given that the infimum is positive.
- **Current paper text (906be2b):**
  > For $w\ge r$ let $G_w=\frac1w\sum_{k=0}^{w-1}\mathbf b(k/w)\mathbf b(k/w)^\top$, $\mathbf b(x)=(1,x,\dots,x^{r-1})^\top$, $g_r=\inf_{w\ge r}\lambda_{\min}(G_w)$, and $C_s=1+r/g_r$. The constant $g_r$ depends only on $r$ and lies in $(0,1]$. Indeed, $g_r\le(G_w)_{11}=1$. For $v\ne0$, $v^\top G_wv=w^{-1}\sum_kp(k/w)^2$ with $p=v^\top\mathbf b$ a nonzero polynomial of degree at most $r-1$, which cannot vanish at the $w\ge r$ points $k/w$, so every $G_w$ is positive definite; by the same argument, so is $H=\int_0^1\mathbf b(x)\mathbf b(x)^\top dx$. The entries of $G_w$ are left Riemann sums of the nondecreasing functions $x^{a}$, $0\le a\le 2r-2$, on $[0,1]$, so every entry of $H-G_w$ lies in $[0,1/w]$, the Frobenius norm of $H-G_w$ is at most $r/w$, and $\lambda_{\min}(G_w)\ge\lambda_{\min}(H)-r/w$. Hence $\lambda_{\min}(G_w)\ge\lambda_{\min}(H)/2$ for $w\ge2r/\lambda_{\min}(H)$, and the finitely many remaining $w$ give positive values.
- **Source of the fix:** Theory's T10 proof (`theory/T10_gr_positivity/`, commit 0c9f176). Writing inserted it at commit 906be2b.
- **Why it was needed:** a proof gap. The constant is used in C_s = 1 + r/g_r and C_0 = r/g_r.
- **Lean:** `BQTF.gr_pos (r) (hr : 1 ≤ r) : 0 < gr r ∧ gr r ≤ 1`, in `lean/BQTF/Gram.lean`. Here `gr r = ⨅ w ≥ r, quadMin r w`, and `quadMin` is the infimum of `gramQuad` over the ℓ² unit sphere, which is λ_min(G_w). The paper has r = k + 1 ≥ 2, so the Lean hypothesis r ≥ 1 is weaker.
- **Status:** **verified** (2026-11-25). No Writing packet was needed (HQ ruling). The Gram Sol review checked `gr_pos` and its definitions against the 906be2b text, and they match: same bounds, no extra hypotheses or constants. Gram finalized and merged at 5913b27.

## C-02: measurability of the posterior mass is not stated

- **Paper label:** appendix, `\subsection{Proof of Theorem~\ref{thm:main}}` (the display bounding E Π_λ(Δ²_n > Mε_n² | y)). The same issue affects the statement of `thm:main`, which takes E_{θ*} of Π_λ(· | y).
- **Current paper text:** "E Π_λ(Δ_n² > Mε_n² | y) ≤ P(Ω_Eᶜ) + … + E[Π_λ(K_nᶜ | y) 1_{Ω_E∩Ω_G}] + Σ_k E[Π_λ(E_{a_k} | y) 1_{Ω_E∩Ω_ζ}]". The expectation of y ↦ Π_λ(B | y) is taken, but nowhere is it said that this map is measurable.
- **Correct version:** add one sentence before the display: "For every Borel B the map y ↦ Π_λ(B | y) is Borel measurable: the unnormalized weight exp{−Σρ_τ(y_i−θ_i)/σ − λ‖Dθ‖₁} is jointly measurable in (y, θ), so its integrals over B and over ℝⁿ are measurable in y by Tonelli, and so is their ratio."
- **Why it was needed:** a missing measurability condition. Without it the expectation is not defined; formally, a lower integral would be bounded. This is the paper-side counterpart of difference D3 in docs/statements.md.
- **Lean:** the measurability conjunct of `BQTF.MainConclusion`, proved in `BQTF.main_theorem` via the private `measurable_posterior_apply`, in `lean/BQTF/Main.lean`.
- **Status:** **open**. Main is merged, but it is not finalized and checked: it still depends on sorried modules. The packet goes out once Main's axiom check shows only the 3 standard axioms.

## C-03: the finiteness step in Lemma coord(b) says the c-integral is "free of u"

- **Paper label:** appendix, proof of Lemma `pf:lem:coord`(b), the finiteness of N(ℝⁿ).
- **Current paper text:** "For finiteness: ρ_τ(x) ≥ min{τ,1−τ}|x| and ‖y−Nc−Su‖₁ ≥ ‖c−Nᵀ(y−Su)‖₂, so the c-integral is finite and free of u."
- **Correct version:** "…so the c-integral is at most ∫exp{−a‖c − Nᵀ(y−Su)‖₂}dc = ∫exp{−a‖c‖₂}dc < ∞, with a = min{τ,1−τ}, a bound that does not depend on u; integrating it against the probability measure Q_λ gives N(ℝⁿ) < ∞. Positivity of the integrand gives N(ℝⁿ) > 0."
- **Why it was needed:** a wrong proof step, in its wording. The c-integral itself depends on u (Sol reviewer's example: n = 2, r = 1, y = θ* = 0, τ = 1/2, N = (1,1)ᵀ/√2, S = (0,1)ᵀ gives √2(|u|+2)e^{−|u|/2}). Only its upper bound is u-free, and that is what the argument uses.
- **Lean:** `BQTF.posterior_eq_ratio` (the clause 0 < Nmass univ < ∞), in `lean/BQTF/Coord.lean`.
- **Status:** **sent** (2026-11-25) to Writing and Theory, CC HQ. Coord finalized and checked at merge 5913b27 (`posterior_eq_ratio`: standard axioms only). Found in the Coord review.

## C-04: Lemma interp uses Lemma coord at window size w = r, where Lemma coord assumes n > r

- **Paper label:** appendix, proof of Lemma `pf:lem:interp`.
- **Current paper text:** "On a window W ∋ i₀ of w ≥ r consecutive indices, Lemma coord applied to δ_W gives δ_W = p + S_w u_W …". But Lemma `pf:lem:coord` begins "Let n > r", and the choice w = ⌈n x*⌉ can equal r.
- **Correct version:** add "(if w = r, δ_W is itself the evaluation of a polynomial of degree ≤ r−1, by interpolation at r points, so take p = δ_W and ϱ_w = 0)", or require w > r and adjust the case split.
- **Why it was needed:** a proof gap at a boundary case. The bound survives unchanged.
- **Lean:** `BQTF.interp`, in `lean/BQTF/Interp.lean` (Neon-A, not proved yet). The Lean proof must handle w = r.
- **Status:** **open, confirmed by Lean.** It was found by the Coord reviewer while reading the paper. Neon-A's Interp proof (9627577) confirmed it on 2026-11-25. `window_poly_approx` handles w = r separately: there, `polySpace r r = ⊤` because the dimensions match, so δ_W is itself a polynomial and the error is 0. The packet goes out when Interp is finalized and checked.

## C-05: in the reduction to σ = 1, the TV bound refers to the original target

- **Paper label:** appendix, §`pf:sec:reduction` ("Reduction to σ = 1").
- **Current paper text:** "The data y/σ₀ satisfy A and B with (L/σ₀, σ₀f̲, σ₀f̄), and V* ≤ V̄/σ₀." Here V* = TV^{(r)}(θ*) is defined for the original target (appendix opening paragraph).
- **Correct version:** "…satisfy A and B with (L/σ₀, σ₀f̲, σ₀f̄) at the target θ*/σ₀, whose total variation is TV^{(r)}(θ*/σ₀) = V*/σ₀ ≤ V̄/σ₀."
- **Why it was needed:** a wrong statement in a proof step. As written, the inequality fails for σ₀ > 1 when V* = V̄ > 0. The argument needs the bound for the rescaled target.
- **Lean:** `BQTF.main_theorem_scale`, in `lean/BQTF/Reduction.lean`, with the data rescaling in `lean/BQTF/Scale/Data.lean`.
- **Status:** **open**. Found in the Reduction review on 2026-11-25. Reduction is merged but depends on `main_theorem`; the packet goes out when the axiom check is clean.

## C-06: the variance step in Lemma conc uses a two-sided change bound that only holds one-sided

- **Paper label:** appendix, proof of Lemma `pf:lem:conc` (variance bound for the supremum G_K, appendix line ≈235).
- **Current paper text:** the proof bounds the change in G_K when Z_i is replaced by an independent copy by |δ̂_i|, with δ̂ a maximizer, and concludes "Var ≤ ‖δ̂‖²" by Efron–Stein.
- **Correct version:** with δ̂ = δ̂(y) the maximizer at the original data, only the positive part satisfies (G_K(y) − G_K(y⁽ⁱ⁾))₊ ≤ |δ̂_i(y)|; the negative part would need the maximizer at y⁽ⁱ⁾. Use the one-sided Efron–Stein inequality Var f(Y) ≤ Σ_i E[(f(Y) − f(Y⁽ⁱ⁾))₊²] (Boucheron–Lugosi–Massart, Thm 3.1 and its corollary). It gives Var G_K ≤ E Σ_i δ̂_i(Y)² ≤ sup_{δ∈K} ‖δ‖₂². The stated bound is unchanged.
- **Why it was needed:** a wrong proof step. The two-sided change bound is not justified as written.
- **Lean:** `BQTF.concentration`, in `lean/BQTF/Concentration.lean` (Neon-B), using `BQTF.Prob.efronStein_oneSided` in `lean/BQTF/Prob/EfronStein.lean` (Opus-W1).
- **Status:** **open**. Found by Sol-W1 (Shells work, `notes/logs/solW1_questions.md`) on 2026-11-25 and accepted by the head. The packet goes out when Concentration is finalized and checked.

## C-07: Lemma check(e) proves the second-moment bound only for positive shifts

- **Paper label:** appendix, proof of Lemma `pf:lem:check`(e).
- **Current paper text:** "(e) $R_i(t)^2=\int_0^t2(t-s)\ind(0\le Z_i<s)ds$ gives $\E R_i^2\le\fu\int_0^t2(t-s)s\,ds=\fu t^3/3$." Unlike (d), there is no "similarly for t<0". For t < 0 the displayed representation is false: its right side is ≤ 0, but R_i(t)² > 0 when t < Z_i < 0. The result t³/3 is also negative.
- **Correct version:** "(e) For $t>0$, $R_i(t)^2=\int_0^t2(t-s)\ind(0\le Z_i<s)ds$ gives $\E R_i^2\le\fu\int_0^t2(t-s)s\,ds=\fu t^3/3$; for $t<0$, $R_i(t)^2=\int_t^0 2(s-t)\ind(s<Z_i<0)ds$ and $\tau-F_i(s)\le\fu|s|$ give the same bound $\fu|t|^3/3$."
- **Why it was needed:** a proof gap. The negative case was missing, and the printed formula is wrong for t < 0. The constants are unchanged.
- **Lean:** `BQTF.remK_moments`, in `lean/BQTF/CheckLoss.lean`. The negative-shift case uses the weight 2(s−t) on (t,0).
- **Status:** **sent** (2026-11-25) to Writing and Theory, CC HQ. CheckLoss was finalized and checked at merge 5f8ba95. Found in the CheckLoss review.
