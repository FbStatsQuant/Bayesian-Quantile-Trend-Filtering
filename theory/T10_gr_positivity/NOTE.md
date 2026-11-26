# T-10: positivity of g_r

Theory Department, 2026-11-25. The Lean department flagged a gap in `paper/sections/appendix_theory.tex:164`. The constant g_r = inf_{w≥r} λ_min(G_w) is used in Lemmas `pf:lem:smooth` and `pf:lem:interp`, but the appendix never proves that it is positive.

**Verdict.** The claim is true as stated: 0 < g_r ≤ 1, and g_r depends only on r. Only the justification was missing.

**Setup.** G_w = w^{-1} Σ_{k=0}^{w-1} b(k/w) b(k/w)^T, with b(x) = (1, x, …, x^{r-1})^T, for w ≥ r.

**Argument.**
1. *Upper bound.* (G_w)_{11} = 1, so λ_min(G_w) ≤ 1.
2. *Each G_w is positive definite.* For v ≠ 0, v^T G_w v = w^{-1} Σ_k p(k/w)², where p = v^T b is a nonzero polynomial of degree at most r−1. Such a polynomial cannot vanish at w ≥ r distinct points, so v^T G_w v > 0.
3. *The limit H is positive definite.* Let H = ∫_0^1 b b^T dx be the Hilbert matrix, with H_{ab} = 1/(a+b+1). By the same argument, ∫p² > 0 for p ≢ 0, so H is positive definite.
4. *Quantitative closeness.* Each entry (G_w)_{ab} = w^{-1} Σ_k (k/w)^{a+b} is a left Riemann sum of the nondecreasing function x^{a+b} on [0,1]. So 0 ≤ H_{ab} − (G_w)_{ab} ≤ (f(1) − f(0))/w ≤ 1/w, and the error is 0 for a+b = 0. Then ‖H − G_w‖_op ≤ ‖H − G_w‖_F ≤ r/w, and Weyl's inequality gives λ_min(G_w) ≥ λ_min(H) − r/w.
5. *Conclusion.* For w ≥ 2r/λ_min(H), λ_min(G_w) ≥ λ_min(H)/2. The finitely many w with r ≤ w < 2r/λ_min(H) each give a positive value by step 2. So g_r ≥ min{λ_min(H)/2, min of finitely many positive numbers} > 0.

**For the formal proof (Lean).**
- No eigenvalue continuity or compactness is needed: only the root count, Riemann-sum monotonicity, Frobenius ≥ operator norm, and Weyl's inequality.
- Weyl's inequality is just the Rayleigh quotient: v^T G_w v ≥ v^T H v − |v^T(H − G_w)v| ≥ λ_min(H) − ‖H − G_w‖_F for unit v.
- A fully explicit lower bound would need a lower bound on λ_min(H), the Hilbert matrix, which decays like e^{−3.5 r}. The paper does not need one; positivity is enough.

**Insertion.** `INSERT.tex` replaces line 164 of `appendix_theory.tex` (diff in `appendix_theory.diff`). It moves the definitions into a display, to avoid an overfull line, and adds the argument above in five sentences. A scratch build of the whole paper compiles with no errors and no new warnings. The only overfull box is the pre-existing 33pt one in `appendix_pmala.tex` ("Starting values and warm-up").
