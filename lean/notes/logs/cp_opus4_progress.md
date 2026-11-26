# CP-Opus4 progress: `BQTF.prekopa_laplace`

Files: `lean/BQTF/Shift/PrekopaLaplace.lean` (frozen statement) + helpers in
`lean/BQTF/Shift/PrekopaLaplace/`.

Route (all on `ℝ≥0∞`, `lintegral`, no integrability side conditions):
1. `BrunnMinkowski.lean`: weighted 1-D Brunn–Minkowski `(1−t)|A| + t|B| ≤ |C|` for nonempty
   measurable `A, B` and any `C ⊇ (1−t)A + tB` (compact case by splitting `C` at
   `(1−t) max K + t min L`; inner regularity via compact subsets).
2. `OneDim.lean`: 1-D Prékopa–Leindler for measurable `f g h : ℝ → ℝ≥0∞` (layer cake for
   `min f 1`, linear PL from BM on level sets, normalisation at levels `α ≤ sup f`,
   weighted AM–GM, monotone convergence in truncation level `n + 1`).
3. Tensorization: products, measurable linear transfers, `Measure.pi` over `Fin d` by
   induction, log-concave densities (Laplace).
4. Final: indicators of `{x | ‖A x + b‖₂ ≤ s}`; `t = 0`, `t = 1` separately.

## Log
- 2026-11-25: build setup (packages symlink, build copy). Statement checked: true as frozen
  (closed sets, probability law, `0^0 = 1` handled by the `t ∈ {0,1}` split; `hs₀ hs₁` unused).
- 2026-11-25: steps 1–2 done, `BQTF.Shift.PrekopaLaplace.OneDim` builds, no sorry.
- 2026-11-25: steps 3–4 done. `Tensor.lean` (`PLProp`, products, transfer, `Measure.pi` induction,
  Laplace log-concavity, `plProp_Qlam`), `Slice.lean` (l2norm triangle/homogeneity, closed
  slices, joint convexity). `prekopa_laplace` proved; statement and `laplaceSlice` unchanged
  (only the two helper imports were added). `lake build BQTF.Shift.PrekopaLaplace` and
  `lake build BQTF` pass; `#print axioms BQTF.prekopa_laplace` = [propext, Classical.choice,
  Quot.sound]. Root import added to `lean/BQTF.lean`.
- Note for users: `hs₀ hs₁` are unused (the inequality holds for all real radii); the linter
  warns about them, left as frozen.
