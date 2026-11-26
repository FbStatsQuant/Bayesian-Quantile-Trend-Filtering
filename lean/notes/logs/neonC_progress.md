# Neon-C Progress Log (J6: `BQTF/Joint/Transfer.lean`)

Date: 2026-11-26  
Branch: `t3/thm2-neonC-j6` (branched from `cd697ad`)

## Proof Plan for `lean/BQTF/Joint/Transfer.lean`

All 5 frozen declarations (signatures and docstrings untouched) were proved directly in `lean/BQTF/Joint/Transfer.lean`, with one private helper (`measurableSet_farSet`):

1. **`mem_orderSet_of_near`**:
   - Fix `i : Fin n` and prove `Monotone (fun j => Θ j i)`.
   - For adjacent indices `j` and `j + 1 < J`, `level_gap` gives `θs j i + g₀ ≤ θs (j+1) i`, and `hΘ` gives `|Θ l i - θs l i| ≤ g₀ / 2` at both levels, so `Θ j i ≤ Θ (j+1) i` by `abs_le` + `linarith`.
   - Extend adjacent inequalities to arbitrary `j₁ ≤ j₂ : Fin J` by induction on `j₂.val`.

2. **`prodPosterior_compl_orderSet_le`**:
   - Define `B l := {θ | ∃ i, s l < |θ i - θs l i|}` (measurable as a finite `iUnion` over `Fin n`).
   - Show `(orderSet J n)ᶜ ⊆ ⋃ l, {Θ | Θ l ∈ B l}` by contrapositive using `hs` and `mem_orderSet_of_near`.
   - Apply `measure_mono`, `measure_iUnion_fintype_le`, `prodPosterior_level` (with `hτ.mem`), and `Finset.sum_le_sum` with `hη`.

3. **`jointPosterior_jointFarSet_le`**:
   - Since `prodPosterior` is a probability measure (`prodPosterior_isProbability`) and `orderSet J n` is measurable (`measurableSet_orderSet`), `hC : Π^⊗(𝒞ᶜ) ≤ 1/2` implies `1/2 ≤ Π^⊗(𝒞)` via `ENNReal.add_halves 1` and `ENNReal.add_le_add_iff_right`.
   - Rewrite `jointFarSet k θs M = ⋃ j, {Θ | Θ j ∈ farSet k (θs j) M}` via `jointFarSet_eq_iUnion`.
   - Apply `measure_iUnion_fintype_le`, then `jointPosterior_level_le` at each `j` (using `measurableSet_farSet`).
   - Bound `a / Π^⊗(𝒞) ≤ a / (1/2) = 2 * a` in `ℝ≥0∞` and factor `2 *` out of the finite sum.

4. **`eventually_levels`**:
   - First conjunct: `Filter.eventually_all` over `Fin J`; for each `l`, apply `eventually_supRad_le` with `σ₀ l * c l > 0` and target `(g / 2) / σ₀ l > 0`, then multiply by `σ₀ l > 0`.
   - Second conjunct: `tendsto_finsetSum` of `etaSeq_tendsto k (σ₀ l * fl)` shows `∑ l, etaSeq k (σ₀ l * fl) n → 0`, so `.eventually (eventually_le_nhds ...)` gives `∑ l, etaSeq ... ≤ 1 / 2` eventually.
   - Combine with `Filter.Eventually.and`.

5. **`joint_assembly`**:
   - Measurability conjunct: `measurable_jointPosterior_apply τ σ lam k n (measurableSet_jointFarSet k θs M)`.
   - Extract per-level witnesses `Ω : Fin J → Set (Fin n → ℝ)` via `choose Ω hΩ_post hΩ_prob using hΩ`.
   - Set `P := Measure.pi μ`, `bad := toMeasurable P (⋃ l, (Ω l)ᶜ)` (`MeasurableSet bad`), `good := badᶜ`.
   - For `y ∈ good`, `y ∈ Ω l` for all `l`, so `prodPosterior_compl_orderSet_le`, `ENNReal.ofReal_sum_of_nonneg` (using `hη0`), and `hη` yield `Π^⊗(𝒞ᶜ ∣ y) ≤ 1/2`, and `jointPosterior_jointFarSet_le` bounds `Π_𝒞(U ∣ y) ≤ 2 ∑ j, Π_j(A_j ∣ y)`.
   - Split `∫⁻ y, F y ∂P = (∫⁻ y in bad, F y ∂P) + ∫⁻ y in good, F y ∂P` via `lintegral_add_compl`.
   - On `bad`: `F y ≤ 1` (`jointPosterior_isProbability`), so `∫⁻ y in bad, F y ∂P ≤ P bad = P (⋃ l, (Ω l)ᶜ) ≤ ∑ l, P (Ω l)ᶜ ≤ ofReal ((∑ l, p l) * massRate k n)`.
   - On `good`: dominate by `∫⁻ y, 2 * ∑ j, Π_j(A_j ∣ y) ∂P = 2 * ∑ j, ∫⁻ y, Π_j(A_j ∣ y) ∂P ≤ ofReal ((2 * ∑ j, Cl j) * massRate k n)` using `(hmain j).1` and `(hmain j).2`.
   - Combine the two `ENNReal.ofReal` terms with `ENNReal.ofReal_add` and `ring`.
   - Note: works uniformly for all `J : ℕ` (including `J = 0`) without needing `IsProbabilityMeasure (Measure.pi μ)`.

## Milestones & Verification

- [x] Branch `t3/thm2-neonC-j6` created from `cd697ad`, `.lake` cache linked/copied, proof plan written.
- [x] All 5 frozen theorems proved in `lean/BQTF/Joint/Transfer.lean` (commit `de23fe3357851cf8695d33f9d6ea6cfedc69baa6`); `git diff cd697ad -- lean/BQTF/Joint/Transfer.lean` confirms only the 5 `sorry` lines were removed and zero frozen names, types, or docstrings were altered.
- [x] Full build verified via `cd lean && ~/.config/bvs-hq/owls/owls_run -j 3 -- lake build`: **Build completed successfully (8978 jobs)**, 0 errors, 0 warnings on `BQTF/Joint/Transfer.lean`.
- [x] Forbidden-token scan (`sorry|admit|native_decide|unsafe|axiom|implemented_by|skipKernelTC`) on `BQTF/Joint/Transfer.lean`: clean (0 matches).
- [x] `#print axioms` check run from an external scratch file via `owls_run -j 3 -- lake env lean`:
  - `BQTF.mem_orderSet_of_near`: `[propext, Classical.choice, Quot.sound]`
  - `BQTF.prodPosterior_compl_orderSet_le`: `[propext, Classical.choice, Quot.sound]`
  - `BQTF.jointPosterior_jointFarSet_le`: `[propext, Classical.choice, Quot.sound]`
  - `BQTF.eventually_levels`: `[propext, Classical.choice, Quot.sound]`
  - `BQTF.joint_assembly`: `[propext, Classical.choice, Quot.sound]`
  (Zero `sorryAx`, not even inherited!)
- [x] No new paper gaps encountered beyond those already recorded in `cp_opus5_skeleton_notes.md` and `Thm2Skeleton_Astra_2026-11-25.md`.
