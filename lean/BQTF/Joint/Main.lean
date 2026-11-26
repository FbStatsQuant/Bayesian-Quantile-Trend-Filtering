import BQTF.Joint.Transfer
import BQTF.Main
import BQTF.Reduction

/-!
# Theorem `thm:joint` (Theorem 2)

Owner: Sol-P2.

`joint_theorem : JointStatement` (`σ_j = 1`) and `joint_theorem_scale : JointStatementScale`.
Planned constant choice (proof of `thm:joint` and "General scales"), with `M^{(l)}, C^{(l)}, n_0^{(l)}`
the constants of `main_theorem_scale` at `(σ_{0l}, c_l)`:
* `M = max_l M^{(l)}` (then `farSet` at `M` is inside `farSet` at `M^{(l)}`);
* `C = 2 Σ_l C^{(l)} + Σ_l {5/4 + 64/(σ_{0l} f̲)²}` (at `σ = 1`: `2 Σ_l C^{(l)} + J(5/4 + 64/f̲²)`);
* `n₀ ≥ max_l max{n_0^{(l)}, n_2^{(l)}}`, also past the `eventually_levels` threshold at
  `g = gapConst L gmin f̄` (`f̄ > 0` by `fl_le_fu_of_dataHyp`, for `J ≥ 1` and `n ≥ 1`) and `≥ 1`.

Witness recipe (Astra audit F3, accepted by the Lean head 2026-11-26):
* `J = 0`: take `M = C = n₀ = 1`; then `U_M = ∅` (`jointFarSet` over `Fin 0`), so both conjuncts
  of `JointConclusion` are trivial. This avoids the empty maximum and the empty sum `C = 0`.
* `J > 0`: split on `0 < f̄` **before** choosing `n₀`, because `DataHyp` is quantified after
  `n₀`.
  - In the branch `f̄ ≤ 0`, use positive dummy witnesses (e.g. `M = C = n₀ = 1`). Then contradict
    `DataHyp` at one level and one coordinate (`fl_le_fu_of_dataHyp` with `0 < f̲`; `n ≥ 1`).
  - In the branch `0 < f̄`, choose the constants as above, and take `n₀` as the common maximum
    of the per-level thresholds (each `n_0^{(l)}`, each `n_2^{(l)}`, the `eventually_levels`
    threshold, and `1`).
* Common `M`: `MainConclusion` is monotone in `M`. For `M′ ≥ M_j`, `farSet k θ* M′ ⊆ farSet k θ* M_j`
  (as `rate ≥ 0`), which gives the expectation bound with unchanged `C_j`. The measurability
  conjunct at `M′` comes from public `measurable_posterior_apply` (`Scale/Posterior`), since the far
  set is open. The far-set helper in `Main` is private, so prove this as a local helper here
  (or inline it). No extra hypothesis is needed.

`joint_theorem` is also the special case `σ₀ = fun _ => 1` of `joint_theorem_scale`.

Nonvacuity: the uniform example of `Joint/Gap` satisfies every hypothesis of both statements
for every `n` (`k = 1`, `J = 2`, `c = 1`, `σ₀ = 1`, `τ = (1/4, 3/4)`, `gmin = 1/2`, `L = 1/4`,
`f̲ = f̄ = 1`, `V̄ = 0`, `μ_i` uniform on `[0,1]`, `θ*_j ≡ τ_j`).
-/

open MeasureTheory Filter
open scoped ENNReal

noncomputable section

namespace BQTF

private theorem mainConclusion_mono {k n : ℕ} {τ σ lam : ℝ} {μ : Fin n → Measure ℝ}
    {θs : Fin n → ℝ} {M M' C : ℝ} (hM : M ≤ M')
    (h : MainConclusion k n τ σ lam μ θs M C) :
    MainConclusion k n τ σ lam μ θs M' C := by
  have hcont : Continuous (fun θ : Fin n → ℝ => lossΔ (θ - θs)) := by
    unfold lossΔ
    fun_prop
  have hfar : MeasurableSet (farSet k θs M') :=
    measurableSet_lt measurable_const hcont.measurable
  have hrate : 0 ≤ rate k n := by
    unfold rate
    positivity
  have hsub : farSet k θs M' ⊆ farSet k θs M := by
    intro θ hθ
    exact (mul_le_mul_of_nonneg_right hM hrate).trans_lt hθ
  exact ⟨measurable_posterior_apply τ σ lam k n hfar,
    (lintegral_mono fun _ => measure_mono hsub).trans h.2⟩

/-- **Theorem `thm:joint`**, general fixed scales `σ_{0j} > 0`. -/
theorem joint_theorem_scale : JointStatementScale := by
  classical
  intro k hk J σ₀ c hσ₀ hc L fl fu Vb hL hfl gmin hgmin
  by_cases hJ : J = 0
  · subst J
    refine ⟨1, 1, 1, one_pos, one_pos, Nat.one_pos, ?_⟩
    intro n _ τ _ μ θs _
    have hfar : jointFarSet k θs 1 = ∅ := by simp [jointFarSet]
    simp [JointConclusion, hfar, measurable_const]
  have hJpos : 0 < J := Nat.pos_of_ne_zero hJ
  let first : Fin J := ⟨0, hJpos⟩
  by_cases hfu : fu ≤ 0
  · refine ⟨1, 1, 1, one_pos, one_pos, Nat.one_pos, ?_⟩
    intro n hn τ _ μ θs hdata
    exact ((hfl.trans_le (fl_le_fu_of_dataHyp hn hL (hdata first))).not_ge hfu).elim
  choose Ml Cl nMain hMl hCl hMain using
    (fun j => main_theorem_scale k hk (σ₀ j) (c j) L fl fu Vb (hσ₀ j) (hc j) hL hfl)
  obtain ⟨CI, _, hSupScale⟩ := supNorm_concentration_scale k hk
  choose nSup _ hSup using
    (fun j => hSupScale (σ₀ j) (c j) L fl fu Vb (hσ₀ j) (hc j) hL hfl)
  obtain ⟨N, heventual⟩ := eventually_atTop.mp
    (eventually_levels k hk CI σ₀ c hσ₀ hc fl hfl _ (gapConst_pos hL hgmin (lt_of_not_ge hfu)))
  have hlevels : (Finset.univ : Finset (Fin J)).Nonempty := ⟨first, Finset.mem_univ _⟩
  let M := Finset.univ.sup' hlevels Ml
  let p (l : Fin J) : ℝ := 5 / 4 + 64 / (σ₀ l * fl) ^ 2
  let C := 2 * ∑ l, Cl l + ∑ l, p l
  let nLevels := Finset.univ.sup fun j => max (nMain j) (nSup j)
  let n₀ := max 1 (max N nLevels)
  have hMle (j : Fin J) : Ml j ≤ M := Finset.le_sup' Ml (Finset.mem_univ j)
  have hp (j : Fin J) : 0 < p j := by
    dsimp [p]
    positivity
  have hC : 0 < C := by
    have hsumCl : 0 ≤ ∑ j, Cl j := Finset.sum_nonneg fun j _ => (hCl j).le
    have hsumP : 0 < ∑ j, p j := Finset.sum_pos (fun j _ => hp j) hlevels
    exact add_pos_of_nonneg_of_pos (mul_nonneg (by norm_num) hsumCl) hsumP
  have hone : 1 ≤ n₀ := le_max_left _ _
  have hN : N ≤ n₀ := (le_max_left _ _).trans (le_max_right _ _)
  have hLevel (j : Fin J) : max (nMain j) (nSup j) ≤ n₀ :=
    (Finset.le_sup (f := fun j => max (nMain j) (nSup j)) (Finset.mem_univ j)).trans
      ((le_max_right _ _).trans (le_max_right _ _))
  refine ⟨M, C, n₀, (hMl first).trans_le (hMle first), hC, hone, ?_⟩
  intro n hn τ hτ μ θs hdata
  obtain ⟨hs, hη⟩ := heventual n (hN.trans hn)
  have hlam (j : Fin J) : 0 ≤ lamSeq (c j) k n := by
    unfold lamSeq
    exact mul_nonneg (hc j).le (Real.rpow_nonneg (Nat.cast_nonneg n) _)
  refine joint_assembly (hone.trans hn) hτ σ₀ (fun j => lamSeq (c j) k n) hσ₀ hlam
    hL hfl hdata (fun j => (hCl j).le) (fun j => (hp j).le) ?_ hs ?_ hη ?_
  · intro j
    have hnMain := (le_max_left (nMain j) (nSup j)).trans ((hLevel j).trans hn)
    exact mainConclusion_mono (hMle j)
      (hMain j n hnMain (τ j) (hτ.mem j).1 (hτ.mem j).2 μ (θs j) (hdata j))
  · intro j
    unfold etaSeq
    positivity
  · intro j
    have hnSup := (le_max_right (nMain j) (nSup j)).trans ((hLevel j).trans hn)
    exact hSup j n hnSup (τ j) (hτ.mem j).1 (hτ.mem j).2 μ (θs j) (hdata j)

/-- **Theorem `thm:joint`** at `σ_1 = ⋯ = σ_J = 1`. -/
theorem joint_theorem : JointStatement := by
  intro k hk J c hc
  exact joint_theorem_scale k hk J (fun _ => 1) c (fun _ => one_pos) hc

end BQTF
