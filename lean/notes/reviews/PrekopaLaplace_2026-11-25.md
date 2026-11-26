**Verdict — PASS WITH FINDINGS.**

The Lean and integration review yielded **0 blocker, 1 major, 1 minor, and 1 nit**. The theorem and all its public helpers pass the axiom audit. The reviewed commit needs a one-file merge resolution.

## Findings

1. **Major — the commit conflicts with main in the umbrella module.** `git merge-tree --write-tree --messages` reports a content conflict in `lean/BQTF.lean` against both current `main` (`a1bfc6f`) and the requested baseline `aaaedb4`. Both sides append imports after `BQTF.Prob.Contraction`. Keep main's `BQTF.Prob.EfronStein` and `BQTF.Lin.EckartYoung` imports and add `BQTF.Shift.PrekopaLaplace`. This is an integration finding. [Main imports](/home/fb31/Bayesian-Quantile-Trend-Filtering/lean/BQTF.lean:26) · [Reviewed imports](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF.lean:27)
2. **Minor — the truncated layer-cake proof rederives a formula available in the pinned Mathlib.** Apply `MeasureTheory.lintegral_eq_lintegral_meas_lt` to the real-valued `x ↦ (min (f x) 1).toReal`. Its positive strict superlevel sets agree with the desired ENNReal superlevel sets for levels below 1 and are empty at levels at least 1. The truncation is finite even where `f x = ⊤`. This gives a reuse path for `lintegral_min_one` and its dedicated interval-volume calculation. The current Tonelli proof is correct. [OneDim.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/OneDim.lean:48) · [Mathlib Layercake.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/Layercake.lean:496)
3. **Nit — the `slice_convex` docstring reads as a convexity claim about the membership indicator.** The lemma proves that the joint feasible set is convex. A precise docstring would be “The feasible set of triples `(x, b, s)` satisfying `‖A x + b‖₂ ≤ s` is convex.” [Slice.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/Slice.lean:39)

## Mathematical and integration checks

- **Freeze.** Compared the bytes from the module docstring through the theorem's `:= by` to `git show 8ebfb2f:lean/BQTF/Shift/PrekopaLaplace.lean`. The compared blocks are identical, including the definition, both declaration docstrings, and the full theorem statement. The diff adds two imports and replaces the proof placeholder. [PrekopaLaplace.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace.lean:19)
- **Classical statement and geometry.** The product Laplace density is log-concave for positive `lam`. The joint constraint is the epigraph of a norm composed with a linear map in `(x,b)`. For fixed `b,s` its section is closed and Borel. The triangle inequality and nonnegative homogeneity put every convex combination of two feasible triples in the interpolated section. Applying Prékopa–Leindler to the three measurable indicators gives the multiplicative inequality. For interior weights a zero-mass input gives a zero left side, even if the set itself is nonempty. At either endpoint the corresponding zero exponent gives one, including on a zero-mass slice, and the inequality is equality. The slices have mass at most one. The argument works at all real radii, since the interpolated membership proof uses the two membership inequalities and negative-radius slices are empty. Keeping `hs₀` and `hs₁` preserves the frozen statement and accounts for both build warnings. [Slice.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/Slice.lean:28) · [PrekopaLaplace.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace.lean:30) · [Prékopa 1973, Theorems 2 and 6](https://acta.bibl.u-szeged.hu/14411/1/math_034_335-343.pdf)
- **Weighted Brunn–Minkowski on ℝ.** For nonempty compact sets the two affine copies fit on opposite sides of the split at the weighted sum of the left set's maximum and the right set's minimum. Removing the right minimum leaves volume unchanged because a singleton is Lebesgue-null. The split uses a measurable half-line, so splitting the measure of the target works even for an arbitrary containing set. For Borel inputs, inner regularity recovers each volume by compact subsets. Adding a fixed input point to each compact approximant supplies nonemptiness, including for the empty compact approximant. The suprema and both positive scalars are handled on ENNReal, including infinite volume. [BrunnMinkowski.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/BrunnMinkowski.lean:26)
- **Prékopa–Leindler on ℝ.** Tonelli applies to the jointly measurable level indicator. The integral over levels in `(0,1)` gives the pointwise truncation, including values zero and infinity. The normalized strict superlevel sets are nonempty at each such level because the finite positive normalizers are bounded by the respective pointwise suprema. This remains true when a supremum is unattained or is carried by a null set. Weighted Brunn–Minkowski therefore applies at every integrated level. The minimum is bounded by the weighted geometric mean, and weighted AM–GM turns the integrated arithmetic bound into the desired geometric bound. Cancellation uses a finite, strictly positive scale. When either pointwise supremum vanishes, the corresponding integral is zero. Otherwise the caps are the smaller of the supremum and `n+1`, which truncates each input at `n+1` pointwise. Monotone convergence, the positive-power order isomorphisms and the common index `max i j` handle the limit, including infinite integrals and products involving zero under ENNReal conventions. [OneDim.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/OneDim.lean:78)
- **Tensorization.** Tonelli with an s-finite second measure gives measurable fiber integrals. The pointwise input inequality holds on all fibers. Applying the second-factor inequality at each pair of first coordinates produces the pointwise hypothesis for the first factor. Transport composes with a measurable measure-preserving equivalence that commutes with the weighted combination. The density step absorbs the density into each integrand using ENNReal power and multiplication identities with nonnegative exponents. Log-concavity of the Laplace density follows from the absolute-value triangle inequality with positive rate. The `Fin 0` product is the Dirac measure on the single empty tuple, so the inequality is the input inequality at that tuple. The step to `Fin (d+1)` splits out coordinate zero by a measure-preserving equivalence and checks compatibility coordinatewise. [Tensor.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/Tensor.lean:37)
- **Global σ-finiteness.** Unfolding `laplace` reaches Mathlib's `SigmaFinite.withDensity_ofReal` for Lebesgue measure and the real density expression, so the instance is sound for all real rates. Main's `laplace_isProbabilityMeasure` is a lemma requiring a proof that the rate is positive. A caller can install its result locally and obtain a second σ-finiteness route through finiteness. `SigmaFinite` is Prop-valued, so proof irrelevance makes the two proofs definitionally equal. There is no competing unconditional Laplace instance on main. A global instance is appropriate for this canonical measure property. A local instance would also suffice for the single use here. [Tensor.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/BQTF/Shift/PrekopaLaplace/Tensor.lean:130) · [Coord.lean](/home/fb31/Bayesian-Quantile-Trend-Filtering/lean/BQTF/Coord.lean:443) · [Mathlib WithDensity.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus4-cfff45c/lean/.lake/packages/mathlib/Mathlib/MeasureTheory/Measure/WithDensity.lean:622)
- **Consumer.** At `2a81e65`, `BQTF.QuadShift` uses `SliceBounds`, which imports the frozen theorem. The midpoint application at equal radii with opposite shifts, together with reflection symmetry, gives the central-slice maximum. The application at zero shift with radii `ϱ` and `ϱ/4` gives the radius loss bound after taking logs using positive finite masses. Both applications fit the statement as written. The consumer was checked at source level. [Center maximum](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/t3-a5c4af88-a63f8ed8da1bb844/lean/BQTF/Shift/SliceBounds.lean:50) · [Radius loss bound](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/t3-a5c4af88-a63f8ed8da1bb844/lean/BQTF/Shift/SliceBounds.lean:62) · [QuadShift.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/t3-a5c4af88-a63f8ed8da1bb844/lean/BQTF/QuadShift.lean:267)
- **Hygiene and diff.** The five files contain no placeholders, custom axioms, `native_decide`, `implemented_by`, unsafe code, heartbeat overrides, or debug commands. The names and docs are suitable apart from finding 3. Searching Mathlib at `065356127b1dc0016f66b7283ce0ce2c4055aa55` found a Brunn–Minkowski bibliography reference and geometry-of-numbers material on Minkowski's convex body theorem. The search yielded no formalization of Brunn–Minkowski or Prékopa–Leindler. The helpers' only external imports are `Mathlib` and `BQTF.Basic`. Within the helpers, `Tensor` imports `OneDim`, which imports `BrunnMinkowski`. There is no dependency on `QuadShift`. `git diff main...cfff45c --name-status` lists exactly `lean/BQTF.lean`, the five scoped source files, and `lean/notes/logs/cp_opus4_progress.md`. `git diff --check main...cfff45c` passes.

## Candidate paper corrections

- **State `ϱ > 0` in the quadratic-shift lemma and make the positive rate explicit there.** The displayed implication allows `ϱ = 0` when the columns coincide, so the formula for `K` can divide by zero. With positive radius, the centered section contains a neighborhood of the origin and has positive mass because the Laplace density is positive. This also gives finiteness of the logs used in the proof. [appendix_theory.tex](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:150)
- **Place the restriction `|t| ≤ 1/λ` before the shifted lower bound involving `Λ(ϱ − |t|δ_A)`.** As written, that lower bound uses a real logarithm of zero whenever the shifted radius is negative. In the range used by the proof the radius is at least `ϱ/2 > 0`. [appendix_theory.tex](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:160)

## Paper exposition suggestions

- The Prékopa citation supports the conditional marginal at line 158. The product Laplace density multiplied by the indicator of the convex ball constraint is log-concave and normalization preserves that property. Use the pointwise marginal obtained by integrating that density, whose evenness follows from simultaneous reflection. Prékopa's Theorem 8 applies directly to this marginal. [appendix_theory.tex](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:158) · [Prékopa 1973, Theorem 8](https://acta.bibl.u-szeged.hu/14411/1/math_034_335-343.pdf)
- At line 160, the joint section mass follows by integrating the log-concave function of `(v,b,s)` obtained by multiplying the product density by the convex constraint's indicator. This makes both uses of the result explicit. At zero shift the log of the mass is concave in positive radius. At fixed radius, reflection and midpoint log-concavity make the centered section largest. Radius monotonicity follows by set inclusion and nonpositivity follows from the mass bound of one. Prékopa's Theorem 6 suffices for the concavity claim, which the appendix cites jointly to Prékopa and Borell. [appendix_theory.tex](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:160) · [Prékopa 1973, Theorem 6](https://acta.bibl.u-szeged.hu/14411/1/math_034_335-343.pdf) · [Borell 1975](https://link.springer.com/article/10.1007/BF02018814)

## Verbatim build output

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.Shift.PrekopaLaplace` exited 0 in the review worktree's `lean` directory. Lake replayed the prebuilt target.

```text
⚠ [8937/8937] Replayed BQTF.Shift.PrekopaLaplace
warning: BQTF/Shift/PrekopaLaplace.lean:28:17: Variable name `hs₀` is not explicitly referenced.

Hint: The binding can be removed (if unused) or named `_` (if used implicitly). Alternatively, prefix the name with `_` to silence this warning:
  [apply] _hs₀

Note: This linter can be disabled with `set_option linter.unusedVariables false`
warning: BQTF/Shift/PrekopaLaplace.lean:28:32: Variable name `hs₁` is not explicitly referenced.

Hint: The binding can be removed (if unused) or named `_` (if used implicitly). Alternatively, prefix the name with `_` to silence this warning:
  [apply] _hs₁

Note: This linter can be disabled with `set_option linter.unusedVariables false`
Build completed successfully (8937 jobs).
```

## Verbatim axiom output

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/bqtf-prekopa-review.xn4MJ0b7/Axioms.lean` exited 0. All 33 public declarations in the five files depend only on `propext`, `Classical.choice`, and `Quot.sound`.

```text
'BQTF.prekopa_laplace' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.laplaceSlice' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.ofReal_mul_volume_affine_preimage' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.bm_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.volume_eq_iSup_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.nonempty_compact_subsets' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.bm_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.volume_level' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.lintegral_min_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.measurable_level' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.pl_one_linear' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.rpow_mul_rpow_le_add' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.min_le_rpow_mul_rpow' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.scale_rpow' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.pl_one_trunc' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.iSup_lintegral_min_nat' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.pl_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.l2norm_eq_norm_toE' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.l2norm_add_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.l2norm_smul' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.continuous_l2norm_affine' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.measurableSet_slice' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.slice_convex' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.PLProp' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.plProp_volume_real' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.PLProp.prod' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.PLProp.of_measurePreserving' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.PLProp.withDensity' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.plProp_pi' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.laplace_logconcave' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.laplace_sigmaFinite' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.plProp_laplace' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.PL.plProp_Qlam' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Head rulings (Lean head, 2026-11-26)

- **F1 ("major"), umbrella import conflict:** resolved at merge. BQTF.lean keeps EfronStein and EckartYoung and adds `import BQTF.Shift.PrekopaLaplace`. This was an integration issue, not a correctness one.
- **F2 (minor), layer-cake reuse, and F3 (nit), docstring:** deferred to the polish pass.
- **Paper candidates (ϱ > 0 in quad shift; placing |t| ≤ 1/λ before the shifted bound):** these concern the quadratic-shift lemma, not this module. I've forwarded them to the QuadShift review, which will rule on them against Sol-W2's proof.
- **Verdict upheld: PASS.** Merged. `prekopa_laplace` uses the standard 3 axioms only. The prior_mass sorryAx now comes only from QuadShift (Sol-W2, 2a81e65, not yet merged).
