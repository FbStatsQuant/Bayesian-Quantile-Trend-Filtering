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


**Theory-confirmed fixes go into the paper early** (owner directive, via HQ, 2026-11-25). Once Theory has made a fix final, Writing puts it into the paper right away, without waiting for the Lean module to be finalized.
- The head passes Theory's fix packet to the prover who owns the affected module, so the Lean proof follows the corrected argument.
- When Writing reports the paper commit, the head marks the entry `in paper (<hash>)`.
- When the module is finalized, the head runs only the fidelity check against that paper text. Writing makes no second edit for that entry.

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
- **Status:** **in paper (998a9ce)**; **verified** (2026-11-26, Lean head). Opens the proof of Theorem 1. Written at σ = 1, the appendix convention, so the /σ is dropped. Theory's added clause, "denominator positive and finite by Lemma pf:lem:coord(b)", is correct, since (b) states 0 < N(ℝⁿ) < ∞. Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ. Main was finalized and checked at merge 4498143: `main_theorem` and `main_theorem_scale` use only propext, Classical.choice and Quot.sound. Found in the Main review.

## C-03: the finiteness step in Lemma coord(b) says the c-integral is "free of u"

- **Paper label:** appendix, proof of Lemma `pf:lem:coord`(b), the finiteness of N(ℝⁿ).
- **Current paper text:** "For finiteness: ρ_τ(x) ≥ min{τ,1−τ}|x| and ‖y−Nc−Su‖₁ ≥ ‖c−Nᵀ(y−Su)‖₂, so the c-integral is finite and free of u."
- **Correct version:** "…so the c-integral is at most ∫exp{−a‖c − Nᵀ(y−Su)‖₂}dc = ∫exp{−a‖c‖₂}dc < ∞, with a = min{τ,1−τ}, a bound that does not depend on u; integrating it against the probability measure Q_λ gives N(ℝⁿ) < ∞. Positivity of the integrand gives N(ℝⁿ) > 0."
- **Why it was needed:** a wrong proof step, in its wording. The c-integral itself depends on u (Sol reviewer's example: n = 2, r = 1, y = θ* = 0, τ = 1/2, N = (1,1)ᵀ/√2, S = (0,1)ᵀ gives √2(|u|+2)e^{−|u|/2}). Only its upper bound is u-free, and that is what the argument uses.
- **Lean:** `BQTF.posterior_eq_ratio` (the clause 0 < Nmass univ < ∞), in `lean/BQTF/Coord.lean`.
- **Status:** **in paper (3f5dff1)**; **verified** (2026-11-26, lean/notes/reviews/Fidelity_C03_C07_2026-11-25.md). Theory CONFIRMED (wording only). Earlier: **sent** (2026-11-25) to Writing and Theory, CC HQ. Coord finalized and checked at merge 5913b27 (`posterior_eq_ratio`: standard axioms only). Found in the Coord review.

## C-04: Lemma interp uses Lemma coord at window size w = r, where Lemma coord assumes n > r

- **Paper label:** appendix, proof of Lemma `pf:lem:interp`.
- **Current paper text:** "On a window W ∋ i₀ of w ≥ r consecutive indices, Lemma coord applied to δ_W gives δ_W = p + S_w u_W …". But Lemma `pf:lem:coord` begins "Let n > r", and the choice w = ⌈n x*⌉ can equal r.
- **Correct version:** add "(if w = r, δ_W is itself the evaluation of a polynomial of degree ≤ r−1, by interpolation at r points, so take p = δ_W and ϱ_w = 0)", or require w > r and adjust the case split.
- **Why it was needed:** a proof gap at a boundary case. The bound survives unchanged.
- **Lean:** `BQTF.interp`, in `lean/BQTF/Interp.lean` (Neon-A). It handles w = r separately.
- **Status:** **in paper (c5db4c2)**; **verified** (2026-11-26, Lean head: the w = r clause matches `BQTF.interp`'s polynomial case; Theory CONFIRMED, Vandermonde. Writing adapted "take ϱ_w = 0" to "‖δ_W − p‖_∞ = 0 ≤ ϱ_w", which keeps ϱ_w's defining formula for its reuse in the next sentence; accepted by the Lean head, since T = TV^{(r)}(δ) ≥ 0 gives ϱ_w ≥ 0 and every later use of ϱ_w is an upper bound). Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ. Interp was finalized and checked at merge 058c2ab (`interp`: standard axioms only; SmoothInterp review confirmed C-04). Earlier: open, confirmed by Lean. It was found by the Coord reviewer while reading the paper. Neon-A's Interp proof (9627577) confirmed it on 2026-11-25. `window_poly_approx` handles w = r separately: there, `polySpace r r = ⊤` because the dimensions match, so δ_W is itself a polynomial and the error is 0.

## C-05: in the reduction to σ = 1, the TV bound refers to the original target

- **Paper label:** appendix, §`pf:sec:reduction` ("Reduction to σ = 1").
- **Current paper text:** "The data y/σ₀ satisfy A and B with (L/σ₀, σ₀f̲, σ₀f̄), and V* ≤ V̄/σ₀." Here V* = TV^{(r)}(θ*) is defined for the original target (appendix opening paragraph).
- **Correct version:** "…satisfy A and B with (L/σ₀, σ₀f̲, σ₀f̄) at the target θ*/σ₀, whose total variation is TV^{(r)}(θ*/σ₀) = V*/σ₀ ≤ V̄/σ₀."
- **Why it was needed:** a wrong statement in a proof step. As written, the inequality fails for σ₀ > 1 when V* = V̄ > 0. The argument needs the bound for the rescaled target.
- **Lean:** `BQTF.main_theorem_scale`, in `lean/BQTF/Reduction.lean`, with the data rescaling in `lean/BQTF/Scale/Data.lean`.
- **Status:** **in paper (e0de68f)**; **verified** (2026-11-26, Lean head). Verbatim. Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ. Reduction was finalized and checked at merge 4498143 (`main_theorem_scale`: standard axioms only). Found in the Reduction review on 2026-11-25.

## C-06: the variance step in Lemma conc uses a two-sided change bound that only holds one-sided

- **Paper label:** appendix, proof of Lemma `pf:lem:conc` (variance bound for the supremum G_K, appendix line ≈235).
- **Current paper text:** the proof bounds the change in G_K when Z_i is replaced by an independent copy by |δ̂_i|, with δ̂ a maximizer, and concludes "Var ≤ ‖δ̂‖²" by Efron–Stein.
- **Correct version:** with δ̂ = δ̂(y) the maximizer at the original data, only the positive part satisfies (G_K(y) − G_K(y⁽ⁱ⁾))₊ ≤ |δ̂_i(y)|; the negative part would need the maximizer at y⁽ⁱ⁾. Use the one-sided Efron–Stein inequality Var f(Y) ≤ Σ_i E[(f(Y) − f(Y⁽ⁱ⁾))₊²] (Boucheron–Lugosi–Massart, Thm 3.1 and its corollary). It gives Var G_K ≤ E Σ_i δ̂_i(Y)² ≤ sup_{δ∈K} ‖δ‖₂². The stated bound is unchanged.
- **Why it was needed:** a wrong proof step. The two-sided change bound is not justified as written.
- **Lean:** `BQTF.concentration`, in `lean/BQTF/Concentration.lean` (Neon-B), using `BQTF.Prob.efronStein_oneSided` in `lean/BQTF/Prob/EfronStein.lean` (Opus-W1).
- **Status:** **in paper (58c9a02)**, applied early under the early-fix rule (Theory CONFIRMED; EfronStein merged at aaaedb4; packet passed to Neon-B). **verified** (2026-11-26): Concentration was finalized at merge 058c2ab, and its Sol review (lean/notes/reviews/Concentration_2026-11-25.md, § C-06) checked the 58c9a02 text against the Lean proof. Found by Sol-W1 (Shells work, `notes/logs/solW1_questions.md`) on 2026-11-25 and accepted by the head.
- **Theory verdict (2026-11-25):** **CONFIRMED.** The fix packet went to Writing and to Lean the same day.
  - The paper's step is unjustified as written in both directions.
  - "Var ≤ ‖δ̂‖²" also has a random right-hand side; the right-hand side should be sup_K‖δ‖².
  - The one-sided fix is correct, and the constant stays 1. For each (y, Z′), a maximizer works for all i at once, so no measurable selection is needed. G_K is bounded, so Efron–Stein applies.
  - The fix restores the argument Theory audited (theory/T07_Bayes_Thm3/T07c_proof.tex:496, commit fae4124, AUDIT.md alongside); the condensed proof dropped the "₊".
  - Only the proof sentence at appendix_theory.tex:235 changes. The statement of Lemma conc, its user Prop. local (line 260), the Var(L̄) step in Lemma denom (line 198) and THEOREM_INDEX.md are all unchanged.
  - **Replacement sentence (Theory):** "For the variance, let $G_K^{(i)}$ be the value of $G_K$ when $Z_i$ is replaced by an independent copy, and let $\hat\delta\in K$ attain the supremum defining $G_K$. Since $\ell_i(\hat\delta_i)$ takes values in an interval of length $|\hat\delta_i|$ (Lemma~\ref{pf:lem:check}(a)), $(G_K-G_K^{(i)})_+\le|\hat\delta_i|$, and the Efron--Stein inequality in its one-sided form \citep[Theorem~3.1]{boucheron2013concentration} gives $\mathrm{Var}(G_K)\le\sum_i\E(G_K-G_K^{(i)})_+^2\le\sup_K\|\delta\|_2^2$."

## C-07: Lemma check(e) proves the second-moment bound only for positive shifts

- **Paper label:** appendix, proof of Lemma `pf:lem:check`(e).
- **Current paper text:** "(e) $R_i(t)^2=\int_0^t2(t-s)\ind(0\le Z_i<s)ds$ gives $\E R_i^2\le\fu\int_0^t2(t-s)s\,ds=\fu t^3/3$." Unlike (d), there is no "similarly for t<0". For t < 0 the displayed representation is false: its right side is ≤ 0, but R_i(t)² > 0 when t < Z_i < 0. The result t³/3 is also negative.
- **Correct version:** "(e) For $t>0$, $R_i(t)^2=\int_0^t2(t-s)\ind(0\le Z_i<s)ds$ gives $\E R_i^2\le\fu\int_0^t2(t-s)s\,ds=\fu t^3/3$; for $t<0$, $R_i(t)^2=\int_t^0 2(s-t)\ind(s<Z_i<0)ds$ and $\tau-F_i(s)\le\fu|s|$ give the same bound $\fu|t|^3/3$."
- **Why it was needed:** a proof gap. The negative case was missing, and the printed formula is wrong for t < 0. The constants are unchanged.
- **Lean:** `BQTF.remK_moments`, in `lean/BQTF/CheckLoss.lean`. The negative-shift case uses the weight 2(s−t) on (t,0).
- **Status:** **in paper (30625fd)**; **verified** (2026-11-26, lean/notes/reviews/Fidelity_C03_C07_2026-11-25.md). Theory CONFIRMED (math and text). Earlier: **sent** (2026-11-25) to Writing and Theory, CC HQ. CheckLoss was finalized and checked at merge 5f8ba95. Found in the CheckLoss review.

## C-08: the Laplace mgf in the Shells score bound is used without its domain

- **Paper label:** appendix, the proof of the shell bound (Lemma `pf:lem:shells`). It is the "Score, on Ω_ζ" paragraph, at appendix_theory.tex line ≈314.
- **Current paper text:** "By (pf:eq:vol) and $\int e^{sx}(\lambda/2)e^{-\lambda|x|}dx=(1-s^2/\lambda^2)^{-1}$, $I_1\le\dots\prod_j(1-4t_j^2/\lambda^2)^{-1}$." The condition |s| < λ is never stated. The integral is +∞ for |s| ≥ λ. The next paragraph gives the fact that makes the formula applicable, 4‖t‖∞²/λ² ≤ 1/2 for n ≥ n₃, but only after the formula has been used.
- **Correct version:** "…and $\int e^{sx}(\lambda/2)e^{-\lambda|x|}dx=(1-s^2/\lambda^2)^{-1}$ for $|s|<\lambda$ (applicable with $s=2t_j$ since $4\|t\|_\infty^2/\lambda^2\le\frac12$ for $n\ge n_3$, shown below), …"
- **Why it was needed:** a missing condition in a displayed identity, and a proof-order gap. The bound is unchanged.
- **Lean:** `BQTF.shells`, in `lean/BQTF/Shells.lean` (Sol-W1). It establishes |2t_j| < λ before using the mgf formula, using `lean/BQTF/Asym/Laplace.lean`.
- **Status:** **in paper (f4e6c9b)**; **verified** (2026-11-26, Lean head). Verbatim. Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ. Shells was finalized and checked at merge 4498143 (`shells`: standard axioms only). The Denominator review confirmed the Lean side: |2t_j| < λ at Shells.lean:183, before the mgf at :188. Found in the Shells review on 2026-11-25.

## C-09: Lemma sb's eigenvalue bound leaves q = 1 and the trace bound unjustified

- **Paper label:** appendix, proof of Lemma `pf:lem:sb`, "Eigenvalues" paragraph (appendix_theory.tex line ≈144).
- **Current paper text:** "…$\le b_0J^{-(2r-1)}$ with $b_0=\dots$; also $\sum_q\mu_q\le b_0$. Taking $J=\lfloor q/2\rfloor$ and using monotonicity, $\mu_q\le b\,q^{-2r}$ with $b=8\cdot6^{2r-1}c_F^2n^{2r-1}/\lambda^2$." There are two gaps. First, the trace bound $\sum_q\mu_q\le b_0$ is asserted without a reason. Second, at q = 1 the choice J = ⌊q/2⌋ = 0 lies outside the range of Lemma F, which needs J ≥ 1, so the tail bound cannot be used there. That case needs the trace bound, and the text does not say so.
- **Correct version:** "…; also, since $\|\Pp s_j\|_2\le\|s_j\|_2\le\sqrt n\,n^{r-1}/(r-1)!\le c_F(2n)^{r-1/2}$, $\sum_q\mu_q=\|G\|_F^2=n^{-1}\sum_jV_j\|\Pp s_j\|_2^2\le b_0$ on $\mathcal V$ (using $m\le n$), so $\mu_1\le b_0\le b$. For $q\ge2$ take $J=\lfloor q/2\rfloor$, so $J\ge q/3$ and $q-J\ge q/2$; then $(q-J)\mu_q\le\sum_{i>J}\mu_i\le b_0J^{-(2r-1)}$, giving $\mu_q\le b\,q^{-2r}$ with $b=2\cdot3^{2r-1}b_0=8\cdot6^{2r-1}c_F^2n^{2r-1}/\lambda^2$."
- **Why it was needed:** a proof gap at a boundary case, plus an unjustified step. The statement, hypotheses and constant b are unchanged; Lean uses b verbatim.
- **Lean:** `BQTF.small_ball`, in `lean/BQTF/SmallBall.lean` (Neon-A): the trace bound is at SmallBall.lean ≈274, and q = 1 is a separate branch.
- **Status:** **in paper (0aa30fc)**; **verified** (2026-11-26, Lean head: verbatim. Theory CONFIRMED and re-derived b = 2·3^{2r−1}b₀. Theory's optional q > m clause is covered in Lean by the types: `small_ball` ranges over q : Fin (n − r) and the tail needs J ≤ m). Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ. SmallBall was finalized and checked at merge 058c2ab (`small_ball`: standard axioms only). The SmallBall review found it (F2), and the EckartYoung review raised the q = 1 case first.

## C-10: the quad-shift lemma omits ϱ > 0 and takes a log before restricting |t|

- **Paper label:** appendix, the quadratic-shift lemma and its proof (appendix_theory.tex lines ≈151–160).
- **Current paper text:**
  - (a) "Let $m\ge2$, $A$ any real matrix with columns $a_1,\dots,a_m$, $B_\varrho$ and $\varphi$ as above for this $A$ …", then "$K=\frac{4\delta_A\varphi(\varrho/4)}{\lambda\varrho}$" (line 153). Nothing in the statement requires ϱ > 0 or λ > 0. With ϱ = 0, K is 0/0, and the zero-radius ball can have prior mass 0.
  - (b) "$\Lambda(s)=\log Q_{-j}\{\|A_{-j}v\|_2\le s\}$. Shifting $v$ by $-te_{j'}$ gives $g(t)\ge e^{-\lambda|t|}e^{\Lambda(\varrho-|t|\delta_A)}$" (line 160). The restriction "For $|t|\le1/\lambda$" comes only later. For large |t| the reduced radius is negative and Λ is log 0. Example: λ = 1, ϱ = 2, A = [0, 1], t = 3.
- **Correct version:**
  - (a) Open the lemma with "Let $m\ge2$, $\lambda>0$ and $\varrho>0$. Let $A$ be any real matrix with columns $a_1,\dots,a_m$, and define $B_\varrho$ and $\varphi$ as above for this $A$. Set $\delta_A=\max_{j<m}\|a_{j+1}-a_j\|_2$."
  - (b) Replace the first use by "For $s>0$, write $\Lambda(s)=\log Q_{-j}\{\|A_{-j}v\|_2\le s\}$. For $|t|\le1/\lambda$ we have $\varrho-|t|\delta_A\ge\varrho/2>0$, and shifting $v$ by $-te_{j'}$ gives $g(t)\ge e^{-\lambda|t|+\Lambda(\varrho-|t|\delta_A)}$." The later concavity claims apply on $(0,\infty)$.
- **Why it was needed:**
  - (a) is a missing hypothesis that the formula needs in order to be defined. The paper's only application uses ϱ = ε_n/2 > 0 (line 187), so no downstream result changes.
  - (b) is a proof-order gap. Every use in the integral is already in the band, so the bound is unchanged.
  - No constant changes.
- **Lean:** `BQTF.quad_shift`, in `lean/BQTF/QuadShift.lean` (Sol-W2). It assumes `hϱ : 0 < ϱ` and `hlam : 0 < λ`. It proves the translation bound in probabilities for all t (QuadShift.lean ≈176), and takes the log cost only for |t| ≤ 1/λ (≈258).
- **Status:** **in paper (922fa52)**; **verified** (2026-11-26, Lean head). Writing applied (a) and (b) verbatim, plus Theory's amendment ("since δ_A ≤ λϱ/2"; "On (0,∞), Λ is …"), which matches QuadShift.lean ≈258. Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ; QuadShift finalized and checked at merge 1b141e0. Found by the PrekopaLaplace review and confirmed by the QuadShift review (lean/notes/reviews/QuadShift_2026-11-26.md).

## C-11: measurability of the joint posterior mass is not stated

- **Paper label:** appendix, proof of `thm:joint`, the "Transfer" display taking E Π_𝒞(U | y) (appendix_theory.tex ≈427–431, reused at general scales ≈436). This is the joint-theorem counterpart of C-02.
- **Current paper text:** the expectation of y ↦ Π_𝒞(U | y) is split over the good event, but nowhere is it said that this map is measurable.
- **Correct version:** add one sentence before the display: "For every Borel B the map y ↦ Π_𝒞(B | y) is Borel measurable: the product weight is jointly measurable in (y, Θ), so its integrals over B ∩ 𝒞 and over the closed set 𝒞 are measurable in y by Tonelli, and the denominator is positive and finite (Lemma~\ref{pf:lem:cond}), so their ratio is measurable."
- **Why it was needed:** a missing measurability condition. Without it the expectation is undefined. It is the paper-side counterpart of D8 in docs/statements.md. No constant changes.
- **Lean:** the measurability conjunct of `BQTF.JointConclusion`, from `BQTF.measurable_jointPosterior_apply` (`lean/BQTF/Joint/Product.lean`), used in `BQTF.joint_assembly` (`lean/BQTF/Joint/Transfer.lean`).
- **Status:** **in paper (3cae0ec)**; **verified** (2026-11-26, Lean head). The paper uses Theory's final wording, placed once in the Transfer step, before Theorem 1 is applied per level, and covering general scales. It is correct: the density of Π^⊗ is the product of the per-level weights over their normalizers, which are measurable, positive and finite. The denominator Π^⊗(𝒞 | y) is positive for every y by Lemma pf:lem:cond. This matches Lean's `measurable_jointPosterior_apply`. Earlier: **sent** (2026-11-26) to Writing and Theory, CC HQ. Theorem 2 was finalized and checked at merge d0366d5: `joint_theorem` and `joint_theorem_scale` use only propext, Classical.choice and Quot.sound. Found in the J6/J7 review (lean/notes/reviews/JointTransferMain_2026-11-26.md).
