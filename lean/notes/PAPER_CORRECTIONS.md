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
- **Status:** **in paper (906be2b)**. HQ ruled on 2026-11-25 that no Writing packet is needed. When `Gram` is finalized, the head runs the fidelity check of `gr_pos` against the 906be2b text directly and reports verified or mismatch to HQ. A packet is needed only if they differ, for example in the hypotheses or in the ≤ 1 part.
