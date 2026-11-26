import BQTF.Joint.Conditioning
import BQTF.Joint.Gap
import BQTF.Joint.SupNormScale

/-!
# The constraint and the transfer (proof of `thm:joint`, "The constraint" and "Transfer")

Owner: Neon-C.

Statements, all at general scales `σ_j > 0` (the `σ = 1` case is `σ = fun _ => 1`):
* `mem_orderSet_of_near` — if `‖θ_l − θ*_l‖_∞ ≤ g₀/2` for every `l`, then `Θ ∈ 𝒞`;
* `prodPosterior_compl_orderSet_le` — on the good event, `Π^⊗(𝒞ᶜ ∣ y) ≤ Σ_l ofReal η_l`
  (`≤ J η_n ≤ 1/2` in the paper);
* `jointPosterior_jointFarSet_le` — if `Π^⊗(𝒞ᶜ ∣ y) ≤ 1/2` then
  `Π_𝒞(U ∣ y) ≤ 2 Σ_j Π_j(A_j ∣ y)`;
* `eventually_levels` — the two eventual conditions `max_l σ_{0l}s′_{n,l} ≤ g₀/2` and
  `Σ_l η′_{n,l} ≤ 1/2` (stated with `∀ᶠ n in atTop`, PLAN §5.5 item 5: `s_n` is not monotone);
* `joint_assembly` — the `E`-bound at one `n`, with the bad-event split
  `E Π_𝒞(U ∣ y) ≤ P(Ωᶜ) + 2 Σ_j E Π_j(A_j ∣ y)` (the proof may use the measurable hull of
  `Ωᶜ`, as `Main` does, since `Ω` is not assumed measurable).

Nonvacuity: the uniform example of `Joint/Gap` (`J = 2`, `τ = (1/4, 3/4)`, `θ*_j ≡ τ_j`,
`L = 1/4`, `f̲ = f̄ = 1`, `V̄ = 0`, `gmin = 1/2`, `σ = 1`, `λ_j = lamSeq 1 k n`) satisfies the
level and data hypotheses for every `n ≥ 1`, and `Θ = θ*` satisfies the hypothesis of
`mem_orderSet_of_near`. For `joint_assembly` at a fixed `n ≥ 1`, add `C_j = p_l = n^{1/(2r)}`
(`MainConclusion` holds since posteriors are `≤ 1`), `s = 0`, `η = 1/4` and `Ω_l = ∅`.
-/

open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal

noncomputable section

namespace BQTF

/-- "The constraint": if every level is within `g₀/2` of its true curve in sup norm, then the
joint trend is ordered. -/
theorem mem_orderSet_of_near {k n J : ℕ} {τ : Fin J → ℝ} {gmin : ℝ} (hτ : LevelGrid J τ gmin)
    {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ} {L fl fu Vb : ℝ} (hL : 0 < L)
    (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    (Θ : Fin J → Fin n → ℝ) (hΘ : ∀ l i, |Θ l i - θs l i| ≤ gapConst L gmin fu / 2) :
    Θ ∈ orderSet J n := by
  intro i j₁ j₂ hle
  have hadj : ∀ (j : ℕ) (hj : j + 1 < J), Θ ⟨j, by omega⟩ i ≤ Θ ⟨j + 1, hj⟩ i := by
    intro j hj
    have hgap := level_gap hτ hL hfl h i j hj
    have h1 := (abs_le.mp (hΘ ⟨j, by omega⟩ i)).2
    have h2 := (abs_le.mp (hΘ ⟨j + 1, hj⟩ i)).1
    linarith
  have hstep : ∀ (m : ℕ) (hm : m < J), j₁.val ≤ m → Θ j₁ i ≤ Θ ⟨m, hm⟩ i := by
    intro m
    induction m with
    | zero =>
      intro hm hle0
      have heq : j₁ = ⟨0, hm⟩ := Fin.ext (Nat.eq_zero_of_le_zero hle0)
      rw [heq]
    | succ m ih =>
      intro hm hles
      rcases Nat.eq_or_lt_of_le hles with heq | hlt
      · have : j₁ = ⟨m + 1, hm⟩ := Fin.ext heq
        rw [this]
      · exact (ih (by omega) (by omega)).trans (hadj m hm)
  exact hstep j₂.val j₂.isLt hle

/-- "The constraint", union bound: if `s_l ≤ g₀/2` and
`Π_l(‖θ − θ*_l‖_∞ > s_l ∣ y) ≤ ofReal η_l` for every level `l`, then
`Π^⊗(𝒞ᶜ ∣ y) ≤ Σ_l ofReal η_l`. -/
theorem prodPosterior_compl_orderSet_le {k n J : ℕ} (hn : 1 ≤ n) {τ : Fin J → ℝ} {gmin : ℝ}
    (hτ : LevelGrid J τ gmin) (σ lam : Fin J → ℝ) (hσ : ∀ j, 0 < σ j)
    (hlam : ∀ j, 0 ≤ lam j) {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ}
    {L fl fu Vb : ℝ} (hL : 0 < L) (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    (y : Fin n → ℝ) (s η : Fin J → ℝ) (hs : ∀ l, s l ≤ gapConst L gmin fu / 2)
    (hη : ∀ l, posterior (τ l) (σ l) (lam l) k n y {θ | ∃ i, s l < |θ i - θs l i|}
      ≤ ENNReal.ofReal (η l)) :
    prodPosterior τ σ lam k n y (orderSet J n)ᶜ ≤ ∑ l, ENNReal.ofReal (η l) := by
  let B : Fin J → Set (Fin n → ℝ) := fun l => {θ | ∃ i, s l < |θ i - θs l i|}
  have hB_meas : ∀ l : Fin J, MeasurableSet (B l) := by
    intro l
    have heq : B l = ⋃ i : Fin n, {θ : Fin n → ℝ | s l < |θ i - θs l i|} := by
      ext θ; simp [B]
    rw [heq]
    refine MeasurableSet.iUnion fun i => ?_
    exact measurableSet_lt measurable_const (((measurable_pi_apply i).sub measurable_const).abs)
  have hsub : (orderSet J n)ᶜ ⊆ ⋃ l : Fin J, {Θ : Fin J → Fin n → ℝ | Θ l ∈ B l} := by
    intro Θ hΘ
    by_contra hnot
    apply hΘ
    refine mem_orderSet_of_near hτ hL hfl h Θ fun l i => ?_
    have hnotl : Θ l ∉ B l := fun hl => hnot (Set.mem_iUnion.mpr ⟨l, hl⟩)
    exact (not_lt.mp fun hlt => hnotl ⟨i, hlt⟩).trans (hs l)
  calc prodPosterior τ σ lam k n y (orderSet J n)ᶜ
      ≤ prodPosterior τ σ lam k n y (⋃ l : Fin J, {Θ : Fin J → Fin n → ℝ | Θ l ∈ B l}) :=
        measure_mono hsub
    _ ≤ ∑ l : Fin J, prodPosterior τ σ lam k n y {Θ : Fin J → Fin n → ℝ | Θ l ∈ B l} :=
        measure_iUnion_fintype_le _ _
    _ = ∑ l : Fin J, posterior (τ l) (σ l) (lam l) k n y (B l) :=
        Finset.sum_congr rfl fun l _ =>
          prodPosterior_level k n hn τ σ lam hτ.mem hσ hlam y l (hB_meas l)
    _ ≤ ∑ l : Fin J, ENNReal.ofReal (η l) :=
        Finset.sum_le_sum fun l _ => hη l

private lemma measurableSet_farSet {n : ℕ} (k : ℕ) (θs : Fin n → ℝ) (M : ℝ) :
    MeasurableSet (farSet k θs M) := by
  unfold farSet lossΔ
  have hcont : Continuous (fun θ : Fin n → ℝ =>
      (∑ i : Fin n, min |(θ - θs) i| ((θ - θs) i ^ 2)) / (n : ℝ)) := by
    refine (continuous_finsetSum _ fun i _ => ?_).div_const _
    have hcoord : Continuous (fun θ : Fin n → ℝ => θ i - θs i) :=
      (continuous_apply i).sub continuous_const
    exact hcoord.abs.min (hcoord.pow 2)
  exact measurableSet_lt measurable_const hcont.measurable

/-- "Transfer": if `Π^⊗(𝒞ᶜ ∣ y) ≤ 1/2` then
`Π_𝒞(U_M ∣ y) ≤ 2 Σ_j Π_j(A_j ∣ y)`, `A_j = farSet k θ*_j M`
(union bound + Lemma `pf:lem:cond` + `Π^⊗(𝒞 ∣ y) ≥ 1/2`). -/
theorem jointPosterior_jointFarSet_le {k n J : ℕ} (hn : 1 ≤ n) (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (θs : Fin J → Fin n → ℝ) (M : ℝ) (y : Fin n → ℝ)
    (hC : prodPosterior τ σ lam k n y (orderSet J n)ᶜ ≤ 1 / 2) :
    jointPosterior τ σ lam k n y (jointFarSet k θs M)
      ≤ 2 * ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) := by
  have : IsProbabilityMeasure (prodPosterior τ σ lam k n y) :=
    prodPosterior_isProbability k n hn τ σ lam hτ hσ hlam y
  have hC_ge : (1 / 2 : ℝ≥0∞) ≤ prodPosterior τ σ lam k n y (orderSet J n) := by
    have hsum : prodPosterior τ σ lam k n y (orderSet J n) +
        prodPosterior τ σ lam k n y (orderSet J n)ᶜ = 1 := by
      rw [measure_add_measure_compl (measurableSet_orderSet J n), measure_univ]
    have h2 : (1 / 2 : ℝ≥0∞) + prodPosterior τ σ lam k n y (orderSet J n)ᶜ ≤
        prodPosterior τ σ lam k n y (orderSet J n) +
        prodPosterior τ σ lam k n y (orderSet J n)ᶜ := by
      calc (1 / 2 : ℝ≥0∞) + prodPosterior τ σ lam k n y (orderSet J n)ᶜ
          ≤ 1 / 2 + 1 / 2 := add_le_add le_rfl hC
        _ = 1 := ENNReal.add_halves 1
        _ = prodPosterior τ σ lam k n y (orderSet J n) +
              prodPosterior τ σ lam k n y (orderSet J n)ᶜ := hsum.symm
    exact (ENNReal.add_le_add_iff_right (measure_ne_top _ _)).mp h2
  have hinv : (prodPosterior τ σ lam k n y (orderSet J n))⁻¹ ≤ 2 := by
    calc (prodPosterior τ σ lam k n y (orderSet J n))⁻¹
        ≤ (1 / 2 : ℝ≥0∞)⁻¹ := ENNReal.inv_le_inv.mpr hC_ge
      _ = 2 := by rw [one_div, inv_inv]
  calc jointPosterior τ σ lam k n y (jointFarSet k θs M)
      = jointPosterior τ σ lam k n y (⋃ j, {Θ | Θ j ∈ farSet k (θs j) M}) := by
        rw [jointFarSet_eq_iUnion]
    _ ≤ ∑ j, jointPosterior τ σ lam k n y {Θ | Θ j ∈ farSet k (θs j) M} :=
        measure_iUnion_fintype_le _ _
    _ ≤ ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) /
          prodPosterior τ σ lam k n y (orderSet J n) :=
        Finset.sum_le_sum fun j _ =>
          jointPosterior_level_le k n hn τ σ lam hτ hσ hlam y j (measurableSet_farSet k (θs j) M)
    _ ≤ ∑ j, 2 * posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) := by
        refine Finset.sum_le_sum fun j _ => ?_
        rw [div_eq_mul_inv, mul_comm (2 : ℝ≥0∞)]
        gcongr
    _ = 2 * ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) :=
        (Finset.mul_sum _ _ _).symm

/-- The eventual conditions on `n₀` (proof of `thm:joint`, choice of `n₀`; "General scales"):
for `g > 0` (in use `g = g₀`), eventually `σ_{0l} s′_{n,l} ≤ g/2` for every level and
`Σ_l η′_{n,l} ≤ 1/2`, with `s′_{n,l} = supRad C_I k (σ_{0l}c_l) n`, `η′_{n,l} = etaSeq k (σ_{0l}f̲) n`. -/
theorem eventually_levels (k : ℕ) (hk : 1 ≤ k) {J : ℕ} (CI : ℝ) (σ₀ c : Fin J → ℝ)
    (hσ₀ : ∀ j, 0 < σ₀ j) (hc : ∀ j, 0 < c j) (fl : ℝ) (hfl : 0 < fl) (g : ℝ) (hg : 0 < g) :
    ∀ᶠ n in atTop, (∀ l, σ₀ l * supRad CI k (σ₀ l * c l) n ≤ g / 2) ∧
      ∑ l, etaSeq k (σ₀ l * fl) n ≤ 1 / 2 := by
  have h1 : ∀ᶠ n in atTop, ∀ l : Fin J, σ₀ l * supRad CI k (σ₀ l * c l) n ≤ g / 2 := by
    rw [eventually_all]
    intro l
    have hsup := eventually_supRad_le k hk CI (σ₀ l * c l) (mul_pos (hσ₀ l) (hc l))
      ((g / 2) / σ₀ l) (div_pos (half_pos hg) (hσ₀ l))
    filter_upwards [hsup] with n hn
    calc σ₀ l * supRad CI k (σ₀ l * c l) n
        ≤ σ₀ l * ((g / 2) / σ₀ l) := mul_le_mul_of_nonneg_left hn (hσ₀ l).le
      _ = g / 2 := mul_div_cancel₀ _ (hσ₀ l).ne'
  have h2 : ∀ᶠ n in atTop, ∑ l : Fin J, etaSeq k (σ₀ l * fl) n ≤ 1 / 2 := by
    have hsum : Tendsto (fun n => ∑ l : Fin J, etaSeq k (σ₀ l * fl) n) atTop (nhds 0) := by
      have ht := tendsto_finsetSum (Finset.univ : Finset (Fin J)) fun l _ =>
        etaSeq_tendsto k (σ₀ l * fl) (mul_pos (hσ₀ l) hfl)
      simpa only [Finset.sum_const_zero] using ht
    exact hsum.eventually (eventually_le_nhds (by norm_num : (0 : ℝ) < 1 / 2))
  exact h1.and h2

/-- Assembly at one `n` (proof of `thm:joint`, last display; "General scales"). Given
* the single-level conclusions `MainConclusion` at a common `M` with constants `C_j ≥ 0`;
* per-level radii `s_l ≤ g₀/2` and masses `η_l ≥ 0` with `Σ_l η_l ≤ 1/2` (nonnegativity
  permits the real sum bound to be transferred to the sum of the positive parts, i.e. to
  `Σ_l ofReal η_l`, which is the bound the union step yields; it keeps the proof short);
* per-level events `Ω_l` on which `Π_l(‖θ − θ*_l‖_∞ > s_l ∣ y) ≤ η_l`, with
  `P(Ω_lᶜ) ≤ p_l n^{−1/(2r)}`, `p_l ≥ 0`,

the joint conclusion holds with `C = 2 Σ_j C_j + Σ_l p_l`. -/
theorem joint_assembly {k n J : ℕ} (hn : 1 ≤ n) {τ : Fin J → ℝ} {gmin : ℝ}
    (hτ : LevelGrid J τ gmin) (σ lam : Fin J → ℝ) (hσ : ∀ j, 0 < σ j)
    (hlam : ∀ j, 0 ≤ lam j) {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ}
    {L fl fu Vb : ℝ} (hL : 0 < L) (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    {M : ℝ} {Cl p s η : Fin J → ℝ} (hCl : ∀ j, 0 ≤ Cl j) (hp : ∀ l, 0 ≤ p l)
    (hmain : ∀ j, MainConclusion k n (τ j) (σ j) (lam j) μ (θs j) M (Cl j))
    (hs : ∀ l, s l ≤ gapConst L gmin fu / 2) (hη0 : ∀ l, 0 ≤ η l) (hη : ∑ l, η l ≤ 1 / 2)
    (hΩ : ∀ l, ∃ Ω : Set (Fin n → ℝ),
      (∀ y ∈ Ω, posterior (τ l) (σ l) (lam l) k n y {θ | ∃ i, s l < |θ i - θs l i|}
        ≤ ENNReal.ofReal (η l)) ∧
      Measure.pi μ Ωᶜ ≤ ENNReal.ofReal (p l * massRate k n)) :
    JointConclusion k n τ σ lam μ θs M (2 * ∑ j, Cl j + ∑ l, p l) := by
  refine ⟨measurable_jointPosterior_apply τ σ lam k n (measurableSet_jointFarSet k θs M), ?_⟩
  choose Ω hΩ_post hΩ_prob using hΩ
  let P : Measure (Fin n → ℝ) := Measure.pi μ
  let bad : Set (Fin n → ℝ) := toMeasurable P (⋃ l : Fin J, (Ω l)ᶜ)
  let good : Set (Fin n → ℝ) := badᶜ
  have hbad : MeasurableSet bad := measurableSet_toMeasurable _ _
  have hmr_nn : 0 ≤ massRate k n := Real.rpow_nonneg (Nat.cast_nonneg n) _
  let F : (Fin n → ℝ) → ℝ≥0∞ := fun y => jointPosterior τ σ lam k n y (jointFarSet k θs M)
  have hbad_int : ∫⁻ y in bad, F y ∂P ≤ P bad := by
    have hF1 : ∀ y, F y ≤ 1 := fun y => by
      have : IsProbabilityMeasure (jointPosterior τ σ lam k n y) :=
        jointPosterior_isProbability k n hn τ σ lam hτ.mem hσ hlam y
      exact prob_le_one
    calc ∫⁻ y in bad, F y ∂P
        ≤ ∫⁻ _ in bad, (1 : ℝ≥0∞) ∂P := lintegral_mono hF1
      _ = P bad := by rw [setLIntegral_const, one_mul]
  have hbad_prob : P bad ≤ ENNReal.ofReal ((∑ l, p l) * massRate k n) := by
    calc P bad
        = P (⋃ l : Fin J, (Ω l)ᶜ) := measure_toMeasurable _
      _ ≤ ∑ l : Fin J, P (Ω l)ᶜ := measure_iUnion_fintype_le _ _
      _ ≤ ∑ l : Fin J, ENNReal.ofReal (p l * massRate k n) :=
          Finset.sum_le_sum fun l _ => hΩ_prob l
      _ = ENNReal.ofReal (∑ l : Fin J, p l * massRate k n) :=
          (ENNReal.ofReal_sum_of_nonneg fun l _ => mul_nonneg (hp l) hmr_nn).symm
      _ = ENNReal.ofReal ((∑ l, p l) * massRate k n) := by rw [Finset.sum_mul]
  have hgood_pt : ∀ y ∈ good,
      F y ≤ 2 * ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) := by
    intro y hy
    have hyΩ : ∀ l : Fin J, y ∈ Ω l := by
      intro l
      by_contra hnot
      exact hy (subset_toMeasurable P _ (Set.mem_iUnion.mpr ⟨l, hnot⟩))
    have hC : prodPosterior τ σ lam k n y (orderSet J n)ᶜ ≤ 1 / 2 := by
      calc prodPosterior τ σ lam k n y (orderSet J n)ᶜ
          ≤ ∑ l, ENNReal.ofReal (η l) :=
            prodPosterior_compl_orderSet_le hn hτ σ lam hσ hlam hL hfl h y s η hs
              (fun l => hΩ_post l y (hyΩ l))
        _ = ENNReal.ofReal (∑ l, η l) :=
            (ENNReal.ofReal_sum_of_nonneg fun l _ => hη0 l).symm
        _ ≤ ENNReal.ofReal (1 / 2) := ENNReal.ofReal_le_ofReal hη
        _ = 1 / 2 := by
            rw [one_div, ENNReal.ofReal_inv_of_pos (by norm_num)]
            norm_num
    exact jointPosterior_jointFarSet_le hn τ σ lam hτ.mem hσ hlam θs M y hC
  have hgood_int : ∫⁻ y in good, F y ∂P ≤ ENNReal.ofReal ((2 * ∑ j, Cl j) * massRate k n) := by
    calc ∫⁻ y in good, F y ∂P
        ≤ ∫⁻ y in good, 2 * ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) ∂P :=
          setLIntegral_mono' hbad.compl hgood_pt
      _ ≤ ∫⁻ y, 2 * ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) ∂P :=
          setLIntegral_le_lintegral _ _
      _ = 2 * ∫⁻ y, ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) ∂P :=
          lintegral_const_mul 2 (Finset.measurable_sum _ fun j _ => (hmain j).1)
      _ = 2 * ∑ j, ∫⁻ y, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) ∂P := by
          rw [lintegral_finsetSum _ fun j _ => (hmain j).1]
      _ ≤ 2 * ∑ j, ENNReal.ofReal (Cl j * massRate k n) := by
          gcongr with j
          exact (hmain j).2
      _ = ENNReal.ofReal ((2 * ∑ j, Cl j) * massRate k n) := by
          rw [← ENNReal.ofReal_sum_of_nonneg fun j _ => mul_nonneg (hCl j) hmr_nn,
            ← ENNReal.ofReal_ofNat (n := 2),
            ← ENNReal.ofReal_mul (by norm_num : (0 : ℝ) ≤ 2), ← Finset.sum_mul, mul_assoc]
  calc ∫⁻ y, F y ∂P
      = (∫⁻ y in bad, F y ∂P) + ∫⁻ y in good, F y ∂P := (lintegral_add_compl F hbad).symm
    _ ≤ ENNReal.ofReal ((∑ l, p l) * massRate k n) +
          ENNReal.ofReal ((2 * ∑ j, Cl j) * massRate k n) :=
        add_le_add (hbad_int.trans hbad_prob) hgood_int
    _ = ENNReal.ofReal ((2 * ∑ j, Cl j + ∑ l, p l) * massRate k n) := by
        rw [← ENNReal.ofReal_add
          (mul_nonneg (Finset.sum_nonneg fun l _ => hp l) hmr_nn)
          (mul_nonneg (mul_nonneg (by norm_num) (Finset.sum_nonneg fun j _ => hCl j)) hmr_nn)]
        congr 1
        ring

end BQTF
