# Review of BQTF.Prob.Contraction

**Verdict — PASS WITH FINDINGS.** 0 blockers, 0 major, 0 minor, 1 nit.

Reviewed detached commit `1aba014edf0f84a688f3e5cb76c50f9c0e253ada`. The build and axiom audit passed. All 13 public source declarations depend only on `propext`, `Classical.choice`, and `Quot.sound`.

## Findings

1. **Nit — The declaration spelling differs from the frozen text.** The file spells the name `contraction_abs` inside `namespace BQTF.Prob`. The supplied text spells it `BQTF.Prob.contraction_abs` at the declaration site. Comparing the statement up to the proof delimiter, those prefix bytes are the sole difference. The rest is byte-identical, and a scratch Lean example with the frozen type elaborated using the fully qualified theorem. The difference has no downstream API impact. [Contraction.lean:21](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction.lean:21)

## Proof and scope checks

- **Measure identity.** Each coordinate law puts mass \(1/2\) at each of \(-1\) and \(1\). On measurable rectangles, the proof expands the product of the coordinate masses and uses the product of membership indicators. The result is a sum of Dirac masses with weight \(2^{-n}\) on each of the \(2^n\) sign vectors. The empty coordinate product gives one atom of mass one when \(n=0\). [Cube.lean:17](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Cube.lean:17)
- **Integral for every function.** Singletons are measurable in \(\mathbb R^n\). Under a Dirac mass at \(\varepsilon\), any real-valued \(g\) is almost everywhere equal to the constant \(g(\varepsilon)\), which has finite norm. Each scaled Dirac measure has a finite coefficient, so integrability survives scaling and finite summation. The proof supplies integrability for each summand before applying the finite-sum integral rule, and point evaluation computes the Dirac integrals. A separate scratch Lean example proved `Integrable g (rademacher n)` for arbitrary real-valued `g`. [Cube.lean:46](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Cube.lean:46)
- **One-coordinate comparison and induction.** The two-point inequality selects maximizers for \(A+f\) and \(A-f\). The bound on \(|f(s)-f(t)|\) lets the proof order those same points by \(g\) and bound their contribution by the two right-hand maxima. Flipping coordinate \(k\) preserves the sign cube and leaves the terms away from \(k\) unchanged. Summing the paired inequalities counts each cube summand twice. The induction starts with no replacements and inserts a fresh coordinate at each step, where the original Lipschitz hypothesis still applies. At the full coordinate set the maps are all identities. This is the coordinate comparison used in the proof of the contraction principle. [Compare.lean:18](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Compare.lean:18) · [Compare.lean:62](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Compare.lean:62) · [Compare.lean:105](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Compare.lean:105) · [Boucheron–Lugosi–Massart, Theorem 11.6 and proof](https://math.hse.ru/data/2016/11/24/1113029206/Concentration%20inequalities.pdf)
- **Absolute-value comparison.** Adjoining zero makes both one-sided contracted maxima nonnegative. Their averages agree by global sign reversal, and the one-sided comparison bounds each by the linear maximum in expectation. The symmetry of `T` makes its linear maximum nonnegative, so adjoining zero leaves it unchanged. [Contraction.lean:27](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction.lean:27)
- **Hygiene and imports.** Both helper files have module docstrings, and all 13 declarations are in `BQTF.Prob`. The names describe the operations and inequalities, and the bundled Mathlib search found no matching declarations. All imports outside the three reviewed files go through `BQTF.Basic`, which reaches Mathlib via its existing `BQTF.Spec` import. The source scan was clean for placeholders, custom axioms, native or unsafe proof shortcuts, option overrides, and debug escapes. [Cube.lean:1](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Cube.lean:1) · [Compare.lean:1](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Prob/Contraction/Compare.lean:1) · [Basic.lean:1](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Basic.lean:1) · [Spec.lean:1](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF/Spec.lean:1)
- **Diff against main.** The reviewed commit's parent is its merge base with local `main` (`84d3a06`). The branch diff `git diff main...HEAD` adds exactly one import to `lean/BQTF.lean`, the three contraction files, and the two `cp_opus2_*` logs. `git diff --check main...HEAD` passed. The tip-to-tip diff also includes unrelated changes from the intervening history on `main` (`896174f`). [BQTF.lean:26](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus2-1aba014/lean/BQTF.lean:26)

## Candidate paper corrections

- State that \(K\) is nonempty in Lemma `pf:lem:conc`. The lemma uses real suprema and its proof takes a maximizer in \(K\). [appendix_theory.tex:226](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:226)

The bridge from the finite Lean theorem to the compact-set use can be made exact. Conditional on the data, take a maximizer of each of the two continuous objectives on \(K\) for each sign vector. Include their negatives to obtain one finite symmetric subset with the same maxima for every sign vector. [appendix_theory.tex:235](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:235)

## Build output

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.Prob.Contraction` exited 0.

```text
Build completed successfully (8935 jobs).
```

## Axiom output

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/sol-contraction-review.5Jv5Ke/Audit.lean` exited 0.

```text
'BQTF.Prob.contraction_abs' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.signCube' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.mem_signCube' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.rademacher_eq_sum_dirac' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.integral_rademacher' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.sup'_add_sup'_sub_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.flipAt' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.flipAt_flipAt' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.flipAt_mem' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.sum_signCube_flipAt' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.cubeSup' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.cubeSup_le_update' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.cubeSup_comparison' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Head rulings (2026-11-25)

**Verdict upheld: PASS. Merge approved.**

1. **Nit: the theorem is written `theorem contraction_abs` inside `namespace BQTF.Prob`.** No change needed. This is the standard way to write a namespaced declaration in Lean. Its fully qualified name is `BQTF.Prob.contraction_abs` and its type is byte-identical to the frozen interface, both confirmed by the reviewer.

There are no candidate paper corrections. The paper cites Ledoux–Talagrand Thm 4.12 as stated.
