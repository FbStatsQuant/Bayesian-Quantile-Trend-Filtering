# Review of BQTF.Lin.EckartYoung

**Verdict — PASS WITH FINDINGS.** 0 blockers, 0 major, 1 minor, 2 nits.

Reviewed detached commit `84f23e3ca31301993ba2250b3e7d282a57bcdf1e`. The module build and the axiom audit passed. The theorem proves the Frobenius lower bound used in Lemma `pf:lem:sb`.

## Findings

1. **Minor — The root import needs a merge resolution.** Both branches added an import immediately after `import BQTF.Reduction`. A three-way merge preview against `main` at `65e309b` reports a conflict there. Keep both `import BQTF.Prob.Contraction` and `import BQTF.Lin.EckartYoung` when integrating. The reviewed commit itself adds exactly one line. [Review BQTF.lean:26](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF.lean:26) · [Main BQTF.lean:26](/home/fb31/Bayesian-Quantile-Trend-Filtering/lean/BQTF.lean:26)
2. **Nit — The frozen declaration uses a qualified name at the declaration site.** The file spells the name `eckartYoung_tail` inside `namespace BQTF.Lin`. A byte comparison up to the proof delimiter found only the missing literal `BQTF.Lin.` prefix. Qualifying the source name for comparison gives a byte-for-byte match. A scratch Lean example with the frozen hypotheses and conclusion elaborated against `BQTF.Lin.eckartYoung_tail`. [EckartYoung.lean:19](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:19) · [EckartYoung.lean:114](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:114)
3. **Nit — The module docstring calls a squared norm the Frobenius norm.** Use “squared Frobenius norm” for `‖T - H‖_F²` and identify the singular value indices as zero-based. [EckartYoung.lean:6](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:6)

## Proof and scope checks

- **Weighted tail.** For \(J\le d\), split `range d` at \(J\) and set \(c=f(J)\). The missing tail mass \(\sum_{q=J}^{d-1}(1-W_q)\) is bounded by the head mass \(\sum_{q<J}W_q\) by the total-mass hypothesis. Antitonicity bounds the missing tail contribution above by \(c\) times its mass and the weighted head contribution below by \(c\) times its mass. The factor \(c\) is nonnegative. This also covers \(J=0\) and \(J=d\). For \(J>d\), the tail is empty and the weighted sum is nonnegative. [EckartYoung.lean:25](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:25)
- **Frobenius and orthonormal sums.** `frob_eq_adjoint` expands each squared norm by Parseval, switches the finite sums, moves the map across the inner product and applies Parseval in the domain. A fixed codomain basis thus gives the same Frobenius sum for every domain orthonormal basis. `orthonormal_sum_le` uses the same adjoint identity and applies Bessel to the domain family for each adjoint image. [EckartYoung.lean:69](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:69) · [EckartYoung.lean:82](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:82)
- **Spectral expansion and order.** `norm_sq_eq_sum_eigen` expresses \(\|Tx\|^2\) as \(\langle T^*Tx,x\rangle\) and expands it in the orthonormal eigenbasis. The main proof pairs each eigenvector with its eigenvalue at the same `Fin d` index. Mathlib's `sq_singularValues_fin` identifies this eigenvalue with the square of the singular value at that index, and `singularValues_antitone` together with nonnegativity gives the required antitone squares. [EckartYoung.lean:99](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:99) · [EckartYoung.lean:162](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:162) · [SingularValues.lean:128](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/.lake/packages/mathlib/Mathlib/Analysis/InnerProductSpace/SingularValues.lean:128) · [SingularValues.lean:141](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/.lake/packages/mathlib/Mathlib/Analysis/InnerProductSpace/SingularValues.lean:141)
- **Kernel and weights.** The kernel basis is included into the domain by a linear isometry, preserving orthonormality. Squared inner products give \(w_q\ge0\), Bessel gives \(w_q\le1\), and Parseval followed by summing over the kernel basis gives \(\sum_qw_q=\dim\ker H\). Rank–nullity gives \(\dim\ker H\ge d-J\). On the kernel \((T-H)u_k=Tu_k\), so the restricted sum is bounded by the full Frobenius error. The spectral expansion gives the weighted sum, which the weighted-tail lemma bounds below. [EckartYoung.lean:122](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:122) · [EckartYoung.lean:137](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:137) · [EckartYoung.lean:148](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:148) · [EckartYoung.lean:169](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:169)
- **Paper application and indexing.** Take \(T=G\), \(E=\mathbb R^m\), \(F=\mathbb R^n\), the standard domain orthonormal basis, and \(H=n^{-1/2}(P_J-P)S\operatorname{diag}(V_j^{1/2})\). Since \(\mathcal P\subseteq V_J\), the map \(P_J-P\) projects onto \(V_J\cap\mathcal P^\perp\), of dimension at most \(J\). The squared column norms of \(G-H\) sum to \(n^{-1}\sum_j V_j\|(I-P_J)s_j\|_2^2\). With \(d=m\), Lean's squared singular value at index \(q\) is the paper's \(\mu_{q+1}\), so `Ico J d` corresponds to paper indices \(J+1,\ldots,d\). For \(d=2, J=1\), the checked interval is `{1}`, which selects \(\mu_2\). The formal inequality is the lower-bound half of the best-approximation formula. This is the half used by the paper, which supplies a specific rank-\(J\)-bounded approximation. [EckartYoung.lean:114](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:114) · [appendix_theory.tex:112](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/paper/sections/appendix_theory.tex:112) · [appendix_theory.tex:144](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/paper/sections/appendix_theory.tex:144)
- **Hygiene.** The module imports only Mathlib, has a module docstring, and puts its four appropriately named helpers in `BQTF.Lin.EckartYoung` and the exported theorem in `BQTF.Lin`. The bundled Mathlib search found no duplicate declarations. The implementation uses Mathlib's Parseval, Bessel, spectral and rank–nullity lemmas. The source scan found no `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `unsafe`, heartbeat overrides, or debug escapes. [EckartYoung.lean:1](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF/Lin/EckartYoung.lean:1)
- **Diff scope.** The merge base with sampled `main` is `896174f`. The branch diff `git diff main...HEAD` adds one import to `lean/BQTF.lean`, adds the reviewed module, and adds `lean/notes/logs/cp_opus3_progress.md`. The whitespace check passed. The tip-to-tip diff also includes changes from intervening commits on `main`. [BQTF.lean:26](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/BQTF.lean:26) · [cp_opus3_progress.md:1](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/lean/notes/logs/cp_opus3_progress.md:1)

## Candidate paper corrections

- Name the rank-at-most-\(J\) approximant \(n^{-1/2}(P_J-P)S\operatorname{diag}(V_j^{1/2})\) and invoke the tail lower bound on its squared Frobenius error. This makes the step from Eckart–Young–Mirsky to the weighted residual column sum explicit. [appendix_theory.tex:144](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/paper/sections/appendix_theory.tex:144)
- Restrict the choice \(J=\lfloor q/2\rfloor\) to \(2\le q\le m\), where \(J\ge q/3\) and \(q-J\ge q/2\) give the stated constant \(b=2\cdot 3^{2r-1}b_0\). For \(q=1\), use \(\mu_1\le\sum_q\mu_q\le b_0\le b\). If extending the sequence beyond \(m\), set those entries to zero. [appendix_theory.tex:145](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus3-84f23e3/paper/sections/appendix_theory.tex:145)

## Build output

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.Lin.EckartYoung` exited 0.

```text
Build completed successfully (8931 jobs).
```

## Axiom output

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/sol-ey-review.IF2e55/Audit.lean` exited 0.

```text
'BQTF.Lin.eckartYoung_tail' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Lin.EckartYoung.frob_eq_adjoint' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Lin.EckartYoung.orthonormal_sum_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Lin.EckartYoung.norm_sq_eq_sum_eigen' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Lin.EckartYoung.weighted_tail_le' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Head rulings (Lean head, 2026-11-25)

- **F1 (minor), import conflict:** resolved at merge. Both `import BQTF.Prob.Contraction` and `import BQTF.Lin.EckartYoung` are kept.
- **F2 (nit), qualified name:** no change. This is the same ruling as for EfronStein F1: the freeze applies to the elaborated name and type, and those match.
- **F3 (nit), docstring:** deferred to the final polish pass.
- **Paper candidates:** (i) Naming the approximant is exposition, so it is rejected as a correction. (ii) The q=1 edge case of J=⌊q/2⌋ is also rejected as a correction. The paper's own clause "also ∑_q μ_q ≤ b_0" covers q=1, since μ_1 ≤ b_0 ≤ b, so the claim is true and is only stated tersely. The SmallBall review will confirm how the Lean proof handles q=1.
- **Verdict upheld: PASS. Merged.** Axioms: standard 3.
