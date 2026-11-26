# J4 (`BQTF/Joint/SupNorm.lean`) Handoff Note

Author: Neon-B  
Date: 2026-11-26  
Branch: `t3/prove-checkloss-score-lemmas` (merged `main` at `47df214`, skeleton `e5b1792` at `f3897e5`, docstring update `d9d189e` at `cda5829`; J3 `Gap.lean` proved at `885015f`).

## 1. What is proved

All **5** frozen theorems in `lean/BQTF/Joint/SupNorm.lean` are **completely proved with 0 sorries and 0 warnings**, and all frozen definitions, theorem statements, and docstrings from `d9d189e` are untouched:

| Declaration | Status | `#print axioms` (against current `main`) |
|---|---|---|
| `BQTF.supRad_tendsto` | Proved (0 sorries) | `[propext, Classical.choice, Quot.sound]` |
| `BQTF.etaSeq_tendsto` | Proved (0 sorries) | `[propext, Classical.choice, Quot.sound]` |
| `BQTF.eventually_supRad_le` | Proved (0 sorries) | `[propext, Classical.choice, Quot.sound]` |
| `BQTF.eventually_etaSeq_le` | Proved (0 sorries) | `[propext, Classical.choice, Quot.sound]` |
| `BQTF.supNorm_concentration` | Proved (0 sorries in file) | `[propext, sorryAx, Classical.choice, Quot.sound]` (`sorryAx` is inherited solely from unmerged `interp`, `denominator`, `localization` on `main`) |

Build verified via `cd lean && ~/.config/bvs-hq/owls/owls_run -j 3 -- lake build`: **Build completed successfully (8978 jobs)**, 0 warnings on `BQTF/Joint/SupNorm.lean`.

## 2. Remaining work for a fresh prover

- **Proof work remaining in `SupNorm.lean`:** None (0 sorries).
- **Post-merge check once `Interp`, `Denominator`, and `Localization` merge to `main`:** Rebase/merge onto `main`, re-run `owls_run -j 3 -- lake build`, and re-run `#print axioms BQTF.supNorm_concentration` from a scratch file outside the repo to verify that the inherited `sorryAx` disappears and only `[propext, Classical.choice, Quot.sound]` remain.

## 3. Theorem-1 lemmas used (exact names)

- From `BQTF/Interp.lean`:
  - `BQTF.interp` (`interp (k + 1) (by omega)` → produces `CI > 0` and coordinatewise sup bound on `Fin n → ℝ`).
- From `BQTF/Denominator.lean`:
  - `BQTF.OmegaE`
  - `BQTF.denominator` (produces `CE > 0`, `n₁ > k + 1`, and the `Ω_Eᶜ` probability tail `5 / 4 / (n * epsSq (k + 1) n)`).
- From `BQTF/Localization.lean`:
  - `BQTF.Kn`, `BQTF.OmegaG`
  - `BQTF.localization` (takes `CE`, produces `n₂'`, gives the `Ω_Gᶜ` probability tail `64 / (fl ^ 2 * n * rhoSq (k + 1) n)` and part (b)'s posterior bound on `OmegaG ∩ OmegaE` matching `etaSeq k fl n` definitionally).
- From `BQTF/Asym/Rates.lean`:
  - `BQTF.Asym.massRate_eq_inv` (`massRate k n = (n * epsSq (k + 1) n)⁻¹`)
  - `BQTF.Asym.mul_epsSq_le_mul_rhoSq` (`n * epsSq (k + 1) n ≤ n * rhoSq (k + 1) n` once `1 ≤ Real.log n`)
  - `BQTF.Asym.eventually_mul_epsSq_ge` (used to show `(n : ℝ) * rhoSq (k + 1) n → atTop` for `etaSeq_tendsto`)
  - `BQTF.Asym.eventually_log_ge_one` (absorbed into `n₂ := max n₁ (max n₂' nLog)`)
- Private helpers added inside `SupNorm.lean` (no new files created):
  - `Tn_lamSeq_eq`: `Tn (k + 1) n (lamSeq c k n) = (4 / c) * (n : ℝ) ^ ((1 : ℝ) / 2)` for `0 < n`.
  - `tendsto_nat_log_rpow_div_rpow`: `Real.log n ^ p / n ^ b → 0` for `0 < b` via Mathlib's `isLittleO_log_rpow_rpow_atTop`.

## 4. Pitfalls & notes

1. **Exponent reconciliation between `interp` and `supRad`:** `BQTF.interp (k + 1)` writes `empNorm δ ^ ((2 * (k + 1) - 2) / (2 * (k + 1) - 1)) * TVr ... ^ (1 / (2 * (k + 1) - 1))`, whereas `supRad` writes `(√(rhoSq (k + 1) n) ^ (2 * k) * Tn ...) ^ (1 / (2 * k + 1))` using a natural power `^ (2 * k)`. Reconciling them uses `Real.rpow_natCast`, `Real.rpow_mul` (needing `0 ≤ √(rhoSq ...)`), and `Real.mul_rpow` (needing `0 ≤ Tn ...` from `Tn_lamSeq_eq` + `0 < c`).
2. **`supRad_tendsto` simplifies cleanly via even power `2 * k`:** Since `2 * k` is even, `pow_mul` + `Real.sq_sqrt` gives `(√(rhoSq (k + 1) n)) ^ (2 * k) = rhoSq (k + 1) n ^ k` for `n ≥ 2`. The resulting exponent of `n` in `rhoSq ^ k * Tn` is `-d` with `d = (4 * k ^ 2 - 3) / (2 * (2 * k + 3)) > 0` for `k ≥ 1`, so the base goes to `0` and `Tendsto.rpow_const` + `Real.zero_rpow` finishes without expanding the outer `1 / (2 * k + 1)` power.
3. **`etaSeq_tendsto` has no `1 ≤ k` hypothesis:** It must work for all `k : ℕ` (including `k = 0`, where `r = k + 1 = 1`). `Asym.mul_epsSq_le_mul_rhoSq` and `Asym.eventually_mul_epsSq_ge` only require `1 ≤ k + 1` / `0 < k + 1`, so this holds uniformly.
4. **No measurability of `Ω = OmegaG ∩ OmegaE` needed:** `Set.compl_inter` + `MeasureTheory.measure_union_le` holds for outer measure directly; the existential witness exhibited is `OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE` (matching the order in `localization`'s part (b) without needing `Set.inter_comm`).
5. **Log threshold for `n ρ_n² ≥ n ε_n²`:** `Asym.mul_epsSq_le_mul_rhoSq` requires `1 ≤ Real.log n`, so `n₂` is chosen as `max n₁ (max n₂' nLog)` using `Asym.eventually_log_ge_one`.
