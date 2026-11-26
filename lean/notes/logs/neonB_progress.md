# Neon-B Progress Log

Last updated: 2026-11-26

## Theorem 1 modules (all merged on `main`)

| Module | Sorries left | Builds | Notes |
|---|---|---|---|
| `BQTF/CheckLoss.lean` | 0 | Yes (0 warnings) | Merged on `main` (`5f8ba95`). |
| `BQTF/Score.lean` | 0 | Yes (0 warnings) | Merged on `main` (`5f8ba95`). |
| `BQTF/Prob/Symmetrization.lean` | 0 | Yes (0 warnings) | Merged on `main` (`058c2ab`). Standard axioms only. |
| `BQTF/Concentration.lean` | 0 | Yes (0 warnings) | Merged on `main` (`058c2ab`). Standard axioms only. |

## Theorem 2 modules

| Module | Sorries left | Builds | Notes |
|---|---|---|---|
| `BQTF/Joint/Gap.lean` (J3) | 0 | Yes (0 warnings) | Proved `fl_le_fu_of_dataHyp`, `quantile_gap`, and `level_gap` (`885015f`). `#print axioms` on all 4 theorems shows only `[propext, Classical.choice, Quot.sound]`. |
| `BQTF/Joint/SupNorm.lean` (J4) | 0 | Yes (0 warnings) | Proved `supRad_tendsto`, `etaSeq_tendsto`, `eventually_supRad_le`, `eventually_etaSeq_le`, and `supNorm_concentration` against frozen `interp`/`denominator`/`localization`. Full `lake build` (8978 jobs) passed; `#print axioms` shows only the 3 standard axioms on the first 4 theorems, and only inherited `sorryAx` (from unmerged `interp`/`denominator`/`localization` on `main`) on `supNorm_concentration`. |
