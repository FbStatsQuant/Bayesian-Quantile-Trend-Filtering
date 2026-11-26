# Neon-B Progress Log

Last updated: 2026-11-25

## Owned modules

| Module | Sorries left | Builds | Notes |
|---|---|---|---|
| `BQTF/CheckLoss.lean` | 0 | Yes (0 warnings) | Proved `ell_props`, `distFn_quantile_eq`, `knight`, `mFun_props`, `remK_moments`, plus score moment helpers (`integral_scoreZ_eq_zero`, `integral_scoreZ_sq`, `integral_scoreZ_pow_four`). |
| `BQTF/Score.lean` | 0 | Yes (0 warnings) | Proved `score_events` via orthogonal projection trace/symmetry (`orthProj_isProj`, `sum_projMat_diag`), exact mean/variance of quadratic forms of independent scores (`quadForm_mean_and_var`), and Mathlib's Hoeffding/Chebyshev (`hasSubgaussianMGF_of_mem_Icc_of_integral_eq_zero`, `measure_sum_ge_le_of_iIndepFun`, `meas_ge_le_variance_div_sq`). |
| `BQTF/Concentration.lean` | 1 | Not started | Next module (needs symmetrization, Ledoux–Talagrand contraction, and Efron–Stein; will audit Mathlib and report in `neonB_questions.md` before starting). |
| `BQTF/Prob/` | — | Not created yet | No helper modules needed for `CheckLoss` or `Score`. |

## Reassigned modules (untouched)
- Moved to Sol-W1: `BQTF/Shells.lean`, `BQTF/Localization.lean`, `BQTF/Denominator.lean` (never edited).
- Moved to Sol-W2: `BQTF/QuadShift.lean`, `BQTF/Width.lean` (never edited).
