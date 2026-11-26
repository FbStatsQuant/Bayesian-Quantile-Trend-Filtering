# Neon-A Progress Log

Date: 2026-11-25
Branch: `t3/formalize-lean-proofs`

## Status by owned module

| Module | Sorries left | Builds (`lake build`) | Notes |
|---|---:|---|---|
| `BQTF.Falling` | 0 | Yes (0 warnings) | Committed (`502dfa1`). Sol review PASSED at `7c61aea` (untouched; non-blocking docstring nit deferred to later cleanup). |
| `BQTF.Coord` | 0 | Yes (0 warnings) | Committed (`7c61aea`). Sol review PASSED at `7c61aea` (untouched; optional Mathlib simplification nits deferred to later cleanup). |
| `BQTF.Gram` | 0 | Yes (0 warnings) | Committed (`879b0fe`). Under Sol review at `7c61aea` (untouched). |
| `BQTF.SplineApprox` | 0 | Yes (0 warnings) | Committed (`437ec8f`), Sol review PASSED and merged to `main` (`aaaedb4`). |
| `BQTF.Smooth` | 0 | Yes (0 warnings) | Committed (`1255f86`). Proved `smoothed_truth` using `gr_pos` and `gr_le_gramQuad` from `Gram`, surjectivity of `G_w`, local polynomial reproduction, and `‖K^{(j)}‖₂`, `‖K^{(j)}‖₁`, `‖d_j‖₂` bounds. |
| `BQTF.Interp` | 0 | Yes (0 warnings) | Committed (`9627577`). Under Sol review (untouched). Proved `interp` (`pf:lem:interp`) via local window polynomial approximation (`window_poly_approx`, handling the `w = r` boundary case C-04 separately via `polySpace r r = ⊤`), `poly_abs_le_sqrt_l2norm`, and window-width optimization. |
| `BQTF.SmallBall` | 0 | Yes (0 warnings) | Proved `small_ball` (`pf:lem:sb`) sorry-free end-to-end against merged `BQTF.Lin.EckartYoung` (`aaaedb4`); removed temporary `EckartYoungStub.lean`. Full `lake build` (8965 jobs) and `#print axioms` passed. |
| `BQTF.Lin.LaplaceMixture` | 0 | Yes (0 warnings) | Committed (`4368509`). Proved Andrews–Mallows scale mixture (`laplace_eq_map_exp_gaussian`, `Qlam_eq_map_exp_gaussian`) via characteristic functions and `expMeasure_sum_le_markov`. |
| `BQTF.Lin.GaussianSmallBall` | 0 | Yes (0 warnings) | Merged to `main` (`058c2ab`). Proved Gaussian rotation/singular-value diagonalization (`gaussian_norm_sq_measure_le`), 1D Gaussian bound `P(|γ| ≤ t) ≥ 0.48 min{t, 1}` (`gaussianReal_abs_le_lower`), and weighted-sum head/tail bound (`gaussian_weighted_sum_small_ball`). |
| `BQTF.Joint.Product` | 0 | Yes (0 warnings) | Theorem 2 J1: proved `measurableSet_orderSet`, `measurableSet_jointFarSet`, `prodPosterior_isProbability`, `prodPosterior_level`, `jointPosterior_eq_cond` (D5), and `measurable_jointPosterior_apply` (D8). |
| `BQTF.Joint.Conditioning` | 0 | Yes (0 warnings) | Theorem 2 J2 (Lemma `pf:lem:cond`): proved `prodPosterior_orderSet_pos`, `jointPosterior_isProbability`, and `jointPosterior_level_le`. |

## Issues / blockers encountered
- **C-04 (`BQTF.Interp`, confirmed):** When `⌈n x*⌉ = r`, the local window has length `w = r`, where `Coord.coordMap_bijective` does not apply (requires `r < w`). Handled separately in `window_poly_approx` by `polySpace r r = ⊤` (exact polynomial fit, error 0). Logged in `lean/notes/logs/neonA_questions.md`.
- **Theorem 1 complete and merged:** All 7 Neon-A modules (`Falling`, `Coord`, `Gram`, `SplineApprox`, `Smooth`, `Interp`, `SmallBall`) plus `Lin/LaplaceMixture` and `Lin/GaussianSmallBall` merged into `main` (`058c2ab`).
- **Theorem 2 J1 + J2 complete:** Merged `main` (`058c2ab`) and skeleton `e5b1792`, proved `BQTF.Joint.Product` and `BQTF.Joint.Conditioning` (0 sorries, 0 warnings, standard 3 axioms only), full `lake build` (8978 jobs) passed.
