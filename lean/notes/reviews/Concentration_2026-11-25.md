**Verdict — PASS WITH FINDINGS.**

**Counts** — blocker 0, major 0, minor 1, nit 1. Counts apply to the Lean review.

Reviewed detached commit `6b2d43d5a44b90ee477c2cf59294daac9c3f3078` against the `aaaedb4` statement freeze. The worktree started clean.

## Findings

1. **Minor — finite-supremum measurability is proved twice locally.** Both modules define the same private `measurable_finset_sup'` with a `Finset.Nonempty.cons_induction` proof. Mathlib already provides `Finset.measurable_sup'` for the function-valued supremum and `Finset.sup'_apply` identifies its evaluation with the pointwise supremum. Using those lemmas removes both inductions. [Concentration.lean:165](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:165) · [Symmetrization.lean:167](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:167) · [Mathlib Lattice.lean:200](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/.lake/packages/mathlib/Mathlib/MeasureTheory/Order/Lattice.lean:200) · [Mathlib Fold.lean:702](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/.lake/packages/mathlib/Mathlib/Data/Finset/Lattice/Fold.lean:702)
2. **Nit — the symmetrization proof can reuse Mathlib’s marginal projection API.** `integral_pi_eval_prob` encodes one coordinate’s integrand as a product with all other factors equal to one. Its sole caller already has measurability of `g = φ i t`, so `measurePreserving_eval` and `integral_map` yield the same equality there. The concentration module already uses this argument. [Symmetrization.lean:151](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:151) · [Symmetrization.lean:250](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:250) · [Concentration.lean:65](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:65) · [Mathlib Pi.lean:401](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/.lake/packages/mathlib/Mathlib/MeasureTheory/Constructions/Pi.lean:401)

Both API substitutions were checked in a scratch Lean file against the review worktree.

## Statement freeze and fidelity

- Compared the checked-out file to the committed blob, then compared byte slices against `git show aaaedb4:lean/BQTF/Concentration.lean`. The module docstring, the `GK` docstring and complete definition, and the `concentration` docstring and full statement through `:= by` are byte-identical. [Concentration.lean:7](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:7) · [Concentration.lean:22](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:22) · [Concentration.lean:598](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:598)
- The Lean result implies the paper’s lemma for nonempty compact symmetric `K`. Take `μ i` to be the law of observation $y_i$. The paper’s independence gives the product joint law `Measure.pi μ`, including when marginals differ. With `θs` set to the paper’s target, `lossHat τ (y - θs) δ` is the paper’s check-loss contrast and `lossExp` its expectation. The quantile level is in $(0,1)$ in both settings. Lean permits any fixed `θs` and arbitrary probability marginals. The proof uses the deterministic check-loss bounds and needs neither a density assumption nor moments of the observations. [Theory.tex:17](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/theory.tex:17) · [Appendix:31](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:31) · [Basic.lean:107](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Basic.lean:107) · [Concentration.lean:53](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:53)
- The expectation has coefficient $4$ against the width under independent fair signs. Symmetry is `δ ∈ K → -δ ∈ K`, and `dot` is the unnormalized inner product. The variance is under the same data law, with coefficient $1$ against the supremum of `l2sq δ = ∑ i, (δ i)^2`, the squared Euclidean norm. Lean also proves integrability. [Appendix:225](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:225) · [Basic.lean:25](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Basic.lean:25) · [Basic.lean:155](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Basic.lean:155) · [Concentration.lean:601](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:601)

## Proof and scope checks

- **Symmetrization.** The proof introduces an independent copy with the same joint law. For each class member it bounds the absolute centered sum by the integral of the absolute difference of the two samples, then takes the finite supremum. A fixed sign vector swaps exactly the negatively signed coordinate pairs. Each pair has matching marginals, so this preserves the product law even for non-identically distributed observations. The triangle inequality splits the signed difference into two equally distributed terms. The proof establishes the measurability and integrability needed for these comparisons and Fubini. [Symmetrization.lean:70](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:70) · [Symmetrization.lean:128](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:128) · [Symmetrization.lean:232](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:232) · [Symmetrization.lean:282](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:282) · [Symmetrization.lean:417](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:417)
- **Expectation and measurability.** Finite symmetric subsets exhaust a dense subset of $K$. Continuity identifies the pointwise limit of their maxima with the compact supremum. The empirical process and the linear process admit uniform bounds on these subsets, with the linear bound needed only on the support of the sign law. This gives measurability of `GK` and supports dominated convergence after the finite symmetrization and contraction bounds. The clamp in the symmetrization application is the identity on the finite index class and provides the uniform bound required by its API. [Concentration.lean:183](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:183) · [Concentration.lean:234](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:234) · [Concentration.lean:264](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:264) · [Concentration.lean:422](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:422) · [Concentration.lean:539](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:539)
- **Hygiene and reuse.** Source scans found no `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `unsafe`, heartbeat overrides or debug commands in the two reviewed sources. All nine public declarations have exactly the expected three axioms. Names and theorem docstrings describe their roles. Main’s `Cube.lean` describes the sign support via a finite Dirac sum, while symmetrization proves its almost-everywhere sign fact directly from the marginals. The sign flip in `Compare.lean` acts on the sign cube, and symmetrization’s swap acts on the two data samples. The concentration proof uses the existing contraction theorem. [Cube.lean:18](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Contraction/Cube.lean:18) · [Compare.lean:38](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Contraction/Compare.lean:38) · [Symmetrization.lean:32](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/Symmetrization.lean:32) · [Concentration.lean:616](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:616)
- **Diff scope.** `git diff aaaedb4...6b2d43d --name-status` uses merge base `0e2f0fc4fa46fcfb88c0eef348283a6839e08842` and reports only the paths below. The direct `git diff aaaedb4 -- lean/BQTF/Prob/EfronStein.lean` was empty, and the file has blob `1079f4a68eb9ed16c7617b1a494222b220a7cd46` at both tips. Its appearance as an addition in the three-dot diff is relative to the merge base. [BQTF.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF.lean) · [EfronStein.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Prob/EfronStein.lean)

```text
M	lean/BQTF.lean
M	lean/BQTF/Concentration.lean
A	lean/BQTF/Prob/EfronStein.lean
A	lean/BQTF/Prob/Symmetrization.lean
M	lean/notes/logs/neonB_progress.md
A	lean/notes/logs/neonB_questions.md
```

## C-06

**Confirmed.** For each original sample $y$, the Lean proof chooses a maximizer $\hat\delta(y)$ before introducing the coordinate $i$ and its replacement $z$. Evaluating the updated supremum at this same $\hat\delta(y)$ bounds $G_K(y)-G_K(y^{(i)})$ above by the difference of the centered absolute losses at that index. The common centering cancels after applying the reverse triangle inequality, and the range bound on the coordinate’s check-loss contrast gives $(G_K(y)-G_K(y^{(i)}))_+^2\le\hat\delta_i(y)^2$. The reverse comparison by this argument uses a maximizer at the updated sample. The one-sided inequality is what permits the same original-sample maximizer to control the terms for all coordinates and all replacements. Lean integrates over replacements, sums over coordinates, bounds the sum pointwise by the deterministic supremum of $\|\delta\|_2^2$, and then integrates over $y$. This implements C-06 without requiring a measurable choice of maximizer. The final theorem supplies `BQTF.Prob.efronStein_oneSided` to this argument. [C-06](/home/fb31/Bayesian-Quantile-Trend-Filtering/lean/notes/PAPER_CORRECTIONS.md:72) · [Concentration.lean:340](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:340) · [Concentration.lean:392](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:392) · [Concentration.lean:616](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:616)

The appendix line in both the review checkout and the main workspace already uses the positive part and the one-sided inequality. C-06’s description under “Current paper text” refers to the earlier wording. [Appendix:235](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:235) · [C-06](/home/fb31/Bayesian-Quantile-Trend-Filtering/lean/notes/PAPER_CORRECTIONS.md:72)

## Candidate paper corrections

1. Add **nonempty** to the hypotheses of Lemma `pf:lem:conc`. The empty set is compact and symmetric, and the proof requires a maximizer and finite real-valued suprema. The application to $K_n$ already satisfies nonemptiness because $0\in K(\rho,T)$. [Appendix:204](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:204) · [Appendix:225](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:225) · [Appendix:240](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:240)

## Exposition suggestions

- If expanding the proof, note that the Lipschitz loss contrasts give continuity in $\delta$, and hence the supremum equals a supremum over a countable dense subset of $K$. Together with the compact uniform bound, this gives measurability and square integrability. In the variance paragraph, an explicit pointwise comparison at the original maximizer would also show why the same maximizer works for every coordinate. [Appendix:235](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:235) · [Concentration.lean:264](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:264) · [Concentration.lean:340](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-neonB-6b2d43d/lean/BQTF/Concentration.lean:340)

## Build output

Ran `owls_run -j 2 -- lake build BQTF.Concentration BQTF.Prob.Symmetrization` in the prebuilt worktree’s `lean` directory. Exit status 0.

```text
Build completed successfully (8939 jobs).
```

## Axiom output

Ran `owls_run -j 2 -- lake env lean <scratch file>` in the same directory. The file was under `/tmp`, imported `BQTF.Concentration`, and printed the axioms of every public declaration in both modules. Exit status 0.

```text
'BQTF.GK' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.concentration_variance_of_efronStein' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.concentration_expectation_of_contraction' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.concentration' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.isProbabilityMeasure_rademacher1' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.isProbabilityMeasure_rademacher' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.ae_rademacher1_eq_neg_one_or_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.ae_rademacher_eq_neg_one_or_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.symmetrization_finset' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Head rulings (Lean head, 2026-11-26)

- **F1 (minor), duplicate `measurable_finset_sup'`, and F2 (nit), marginal API:** both are private helpers with no correctness impact. Deferred to the polish pass.
- **Paper candidate "K nonempty":** rejected as a correction and recorded as exposition. G_K is a supremum of nonnegative quantities. With the standard convention sup ∅ = 0, the lemma holds trivially for K = ∅, since the variance is 0 and the bound is ≥ 0. The only use, K_n, contains 0. The Lean `Nonempty` hypothesis is a `Finset.sup'` formalization artifact.
- **C-06:** confirmed. The Lean proof takes the maximizer at the original sample and uses the one-sided Efron–Stein inequality. This review also checked that the paper line (appendix:235, as committed by Writing at 58c9a02) states that argument. That check is the C-06 fidelity check, and C-06 is now **verified**.
- **Verdict upheld: PASS.** Merged into main with SmallBall, Smooth/Interp and PrekopaLaplace. Full build green (8971 jobs). `concentration` and `symmetrization_finset` use the standard 3 axioms only.
