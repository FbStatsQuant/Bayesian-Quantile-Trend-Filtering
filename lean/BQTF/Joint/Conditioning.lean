import BQTF.Joint.Product

/-!
# Conditioning (appendix, Lemma `pf:lem:cond`)

Owner: Neon-A.

For every `y`, `Π^⊗(𝒞 ∣ y) > 0`, so `Π_𝒞(· ∣ y)` is a probability measure, and for every level
`j` and Borel `A ⊆ ℝⁿ`, `Π_𝒞(θ_j ∈ A ∣ y) ≤ Π_j(A ∣ y) / Π^⊗(𝒞 ∣ y)`.

The paper assumes `n > r` (it cites Lemma `pf:lem:coord`(b) for properness). Here the
hypothesis is `n ≥ 1`, which is weaker, so these statements are at least as general: properness
holds for `n ≥ 1` (docs D4, `posterior_isProbability`), each `Π_j` has an everywhere-positive
density, and `𝒞` contains the nonempty open set of strictly ordered `Θ`.

Nonvacuity: as in `Joint/Product` (`J = 2`, `τ = (1/4, 3/4)`, `σ = 1`, `λ_j ≥ 0`, `n ≥ 1`).
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- Lemma `pf:lem:cond`, positivity: `Π^⊗(𝒞 ∣ y) > 0` for every `y`. -/
theorem prodPosterior_orderSet_pos (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) :
    0 < prodPosterior τ σ lam k n y (orderSet J n) := by
  have : ∀ j, IsProbabilityMeasure (posterior (τ j) (σ j) (lam j) k n y) :=
    fun j => posterior_isProbability k n hn (τ j) (σ j) (lam j) (hτ j) (hσ j) (hlam j) y
  -- Construct an explicit unit-volume open product box `B_ord ⊆ orderSet J n`.
  let Bj : Fin J → Set (Fin n → ℝ) :=
    fun j => Set.univ.pi fun _ : Fin n => Set.Ioo (j.val : ℝ) ((j.val : ℝ) + 1)
  let Bord : Set (Fin J → Fin n → ℝ) := Set.univ.pi Bj
  have hsub : Bord ⊆ orderSet J n := by
    intro Θ hΘ i j₁ j₂ hle
    by_cases heq : j₁ = j₂
    · subst heq; exact le_rfl
    · have hlt : j₁.val < j₂.val := lt_of_le_of_ne hle (fun h => heq (Fin.ext h))
      have h1 : Θ j₁ i < (j₁.val : ℝ) + 1 := (hΘ j₁ (Set.mem_univ j₁) i (Set.mem_univ i)).2
      have h2 : (j₂.val : ℝ) < Θ j₂ i := (hΘ j₂ (Set.mem_univ j₂) i (Set.mem_univ i)).1
      have hstep : (j₁.val : ℝ) + 1 ≤ (j₂.val : ℝ) := by exact_mod_cast hlt
      linarith
  have hBj_meas : ∀ j, MeasurableSet (Bj j) :=
    fun _ => MeasurableSet.univ_pi fun _ => measurableSet_Ioo
  have hfac_pos : ∀ j : Fin J, 0 < posterior (τ j) (σ j) (lam j) k n y (Bj j) := by
    intro j
    have hZ := lintegral_postWeight_pos_lt_top k n (τ j) (σ j) (lam j) (hτ j) (hσ j) (hlam j) y
    rw [posterior, Measure.smul_apply, withDensity_apply _ (hBj_meas j), smul_eq_mul]
    have hinv_pos : 0 < (∫⁻ θ, postWeight (τ j) (σ j) (lam j) k n y θ)⁻¹ :=
      ENNReal.inv_pos.mpr hZ.2.ne
    have hvol : volume (Bj j) = 1 := by
      change (Measure.pi fun _ : Fin n => (volume : Measure ℝ))
        (Set.univ.pi fun _ : Fin n => Set.Ioo (j.val : ℝ) ((j.val : ℝ) + 1)) = 1
      rw [Measure.pi_pi]
      simp [Real.volume_Ioo]
    have hsupp : Function.support (postWeight (τ j) (σ j) (lam j) k n y) = Set.univ := by
      ext θ
      simp only [Function.mem_support, Set.mem_univ, iff_true]
      exact (ENNReal.ofReal_pos.mpr (Real.exp_pos _)).ne'
    have hlint_pos : 0 < ∫⁻ θ in Bj j, postWeight (τ j) (σ j) (lam j) k n y θ ∂volume := by
      rw [lintegral_pos_iff_support (measurable_postWeight (τ j) (σ j) (lam j) k n y)]
      rw [hsupp, Measure.restrict_apply MeasurableSet.univ, Set.univ_inter, hvol]
      exact zero_lt_one
    exact ENNReal.mul_pos hinv_pos.ne' hlint_pos.ne'
  have hBord_pos : 0 < prodPosterior τ σ lam k n y Bord := by
    unfold prodPosterior
    rw [Measure.pi_pi]
    exact pos_iff_ne_zero.mpr (Finset.prod_ne_zero_iff.mpr fun j _ => (hfac_pos j).ne')
  exact lt_of_lt_of_le hBord_pos (measure_mono hsub)

/-- Lemma `pf:lem:cond`: `Π_𝒞(· ∣ y)` is a probability measure. -/
theorem jointPosterior_isProbability (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) :
    IsProbabilityMeasure (jointPosterior τ σ lam k n y) := by
  have : IsProbabilityMeasure (prodPosterior τ σ lam k n y) :=
    prodPosterior_isProbability k n hn τ σ lam hτ hσ hlam y
  constructor
  rw [jointPosterior_eq_cond k n hn τ σ lam hτ hσ hlam y MeasurableSet.univ, Set.univ_inter]
  have hpos := prodPosterior_orderSet_pos k n hn τ σ lam hτ hσ hlam y
  exact ENNReal.div_self hpos.ne' (measure_ne_top _ _)

/-- Lemma `pf:lem:cond`, the inequality: for every level `j` and measurable `A ⊆ ℝⁿ`,
`Π_𝒞(Θ : θ_j ∈ A ∣ y) ≤ Π_j(A ∣ y) / Π^⊗(𝒞 ∣ y)`. -/
theorem jointPosterior_level_le (k n : ℕ) (hn : 1 ≤ n) {J : ℕ} (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (y : Fin n → ℝ) (j : Fin J) {A : Set (Fin n → ℝ)} (hA : MeasurableSet A) :
    jointPosterior τ σ lam k n y {Θ | Θ j ∈ A}
      ≤ posterior (τ j) (σ j) (lam j) k n y A / prodPosterior τ σ lam k n y (orderSet J n) := by
  have hmeas : MeasurableSet {Θ : Fin J → Fin n → ℝ | Θ j ∈ A} := measurable_pi_apply j hA
  rw [jointPosterior_eq_cond k n hn τ σ lam hτ hσ hlam y hmeas,
    ← prodPosterior_level k n hn τ σ lam hτ hσ hlam y j hA]
  exact ENNReal.div_le_div_right (measure_mono Set.inter_subset_left) _

end BQTF
