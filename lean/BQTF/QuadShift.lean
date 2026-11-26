import BQTF.Basic
import BQTF.Shift.SliceBounds
import BQTF.Shift.ScalarBounds

/-!
# Quadratic shift (appendix, Lemma `pf:lem:qshift`)

Owner: Neon-B. A general matrix `A` with columns `a_1, …, a_m` (`m ≥ 2`),
`B_ϱ = {u : ‖A u‖₂ ≤ ϱ}`, `φ(ϱ) = −log Q_λ(B_ϱ)`, `δ_A = max_{j<m} ‖a_{j+1} − a_j‖₂`.

For λ > 0, `prekopa_laplace` in `Shift/PrekopaLaplace` proves joint log-concavity of the
product-Laplace slice mass in the shift and positive radius, in multiplicative form. This module
uses its consequences `laplaceSlice_le_center` and `laplaceSlice_center_log_loss` from
`Shift/SliceBounds`.
-/

open MeasureTheory Matrix Set Finset
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `B_ϱ(A) = {u : ‖A u‖₂ ≤ ϱ}` for a matrix `A ∈ ℝ^{p×m}`. -/
def BA {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) (ϱ : ℝ) : Set (Fin m → ℝ) :=
  {u | l2norm (A *ᵥ u) ≤ ϱ}

/-- `δ_A = max_{j < m} ‖a_{j+1} − a_j‖₂` (0-based: columns `j` and `j+1`, `j + 1 < m`). -/
def deltaA {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) : ℝ :=
  ⨆ j : {j : ℕ // j + 1 < m},
    l2norm (fun i => A i ⟨j.1 + 1, j.2⟩ - A i ⟨j.1, by have := j.2; omega⟩)

private def dropColumn {p d : ℕ} (A : Matrix (Fin p) (Fin (d + 1)) ℝ)
    (j : Fin (d + 1)) : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ) :=
  (Matrix.of fun i k => A i (j.succAbove k)).mulVecLin

private theorem mulVec_insertNth {p d : ℕ} (A : Matrix (Fin p) (Fin (d + 1)) ℝ)
    (j : Fin (d + 1)) (t : ℝ) (v : Fin d → ℝ) :
    A *ᵥ j.insertNth t v = dropColumn A j v + t • A.col j := by
  ext i
  simp only [Matrix.mulVec, dotProduct, dropColumn, Matrix.mulVecLin_apply, Matrix.of_apply,
    Pi.add_apply, Pi.smul_apply, smul_eq_mul, Matrix.col_apply]
  rw [Fin.sum_univ_succAbove _ j, Fin.insertNth_apply_same]
  simp only [Fin.insertNth_apply_succAbove]
  ring

private theorem measurableSet_BA {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) (ϱ : ℝ) :
    MeasurableSet (BA A ϱ) := by
  simpa [BA, Matrix.mulVecLin_apply] using measurableSet_laplaceSlice A.mulVecLin 0 ϱ

private theorem BA_neg_iff {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) (ϱ : ℝ)
    (v : Fin m → ℝ) : -v ∈ BA A ϱ ↔ v ∈ BA A ϱ := by
  simp [BA, Matrix.mulVec_neg, l2norm_neg_eq]

private theorem lintegral_BA_coord {p d : ℕ} {lam : ℝ} (hlam : 0 < lam)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) (ϱ : ℝ) (j : Fin (d + 1))
    {f : ℝ → ℝ≥0∞} (hf : Measurable f) :
    ∫⁻ x in BA A ϱ, f (x j) ∂Qlam (d + 1) lam =
      ∫⁻ t, ENNReal.ofReal (laplacePDF lam t) *
        (f t * laplaceSlice (dropColumn A j) lam (t • A.col j) ϱ) := by
  have hfun : Measurable ((BA A ϱ).indicator (fun x => f (x j))) :=
    (hf.comp (measurable_pi_apply j)).indicator (measurableSet_BA A ϱ)
  rw [← lintegral_indicator (measurableSet_BA A ϱ), Qlam_lintegral_insertNth hlam j hfun]
  have hsection (t : ℝ) :
      ∫⁻ v, (BA A ϱ).indicator (fun x => f (x j)) (j.insertNth t v) ∂Qlam d lam =
        f t * laplaceSlice (dropColumn A j) lam (t • A.col j) ϱ := by
    let S := {v | l2norm (dropColumn A j v + t • A.col j) ≤ ϱ}
    have hS : MeasurableSet S := measurableSet_laplaceSlice _ _ _
    calc
      _ = ∫⁻ v, S.indicator (fun _ => f t) v ∂Qlam d lam := by
        apply lintegral_congr
        intro v
        have he : j.insertNth t v ∈ BA A ϱ ↔ v ∈ S := by
          simp only [BA, S, Set.mem_ofPred_eq, mulVec_insertNth]
        by_cases hv : v ∈ S
        · rw [Set.indicator_of_mem (he.mpr hv), Set.indicator_of_mem hv,
            Fin.insertNth_apply_same]
        · rw [Set.indicator_of_notMem (mt he.mp hv), Set.indicator_of_notMem hv]
      _ = _ := lintegral_indicator_const hS _
  simp_rw [hsection]
  unfold laplace
  exact lintegral_withDensity_eq_lintegral_mul_non_measurable _
    (continuous_laplacePDF lam).measurable.ennreal_ofReal
    (Filter.Eventually.of_forall fun _ => ENNReal.ofReal_lt_top) _

private theorem BA_mass_as_slices {p d : ℕ} {lam : ℝ} (hlam : 0 < lam)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) (ϱ : ℝ) (j : Fin (d + 1)) :
    Qlam (d + 1) lam (BA A ϱ) =
      ∫⁻ t, ENNReal.ofReal (laplacePDF lam t) *
        laplaceSlice (dropColumn A j) lam (t • A.col j) ϱ := by
  simpa using lintegral_BA_coord hlam A ϱ j (f := fun _ => 1) measurable_const

private theorem BA_mass_le_center {p d : ℕ} {lam : ℝ} (hlam : 0 < lam)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) {ϱ : ℝ} (hϱ : 0 < ϱ) (j : Fin (d + 1)) :
    Qlam (d + 1) lam (BA A ϱ) ≤ laplaceSlice (dropColumn A j) lam 0 ϱ := by
  rw [BA_mass_as_slices hlam A ϱ j]
  calc
    _ ≤ ∫⁻ t, ENNReal.ofReal (laplacePDF lam t) * laplaceSlice (dropColumn A j) lam 0 ϱ :=
      lintegral_mono fun t => mul_le_mul' le_rfl (laplaceSlice_le_center _ hlam _ hϱ)
    _ = _ := by
      rw [lintegral_mul_const _ (continuous_laplacePDF lam).measurable.ennreal_ofReal]
      have hp := (laplace_isProbabilityMeasure lam hlam).measure_univ
      rw [laplace, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ] at hp
      rw [hp, one_mul]

private theorem l1norm_add_le {d : ℕ} (x y : Fin d → ℝ) :
    l1norm (x + y) ≤ l1norm x + l1norm y := by
  simp only [l1norm, Pi.add_apply, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => abs_add_le _ _

private theorem l1norm_single_eq {d : ℕ} (k : Fin d) (t : ℝ) :
    l1norm (Pi.single k t) = |t| := by
  unfold l1norm
  rw [Finset.sum_eq_single k]
  · simp
  · intro i _ hi
    simp [Pi.single_eq_of_ne hi]
  · simp

private theorem Qlam_translate_lower {d : ℕ} {lam : ℝ} (hlam : 0 < lam)
    (h : Fin d → ℝ) {S : Set (Fin d → ℝ)} (hS : MeasurableSet S) :
    ENNReal.ofReal (Real.exp (-(lam * l1norm h))) * Qlam d lam S ≤
      Qlam d lam {x | x - h ∈ S} := by
  rw [Qlam_translate hlam h hS, Qlam_eq_withDensity d lam hlam, withDensity_apply _ hS,
    ← lintegral_const_mul _ (continuous_laplaceWeight lam).measurable.ennreal_ofReal]
  apply lintegral_mono
  intro x
  dsimp only
  rw [← ENNReal.ofReal_mul (Real.exp_nonneg _)]
  apply ENNReal.ofReal_le_ofReal
  unfold laplaceWeight
  rw [mul_left_comm, ← Real.exp_add]
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Real.exp_le_exp.mpr
  calc
    _ = -(lam * (l1norm x + l1norm h)) := by ring
    _ ≤ _ := neg_le_neg (mul_le_mul_of_nonneg_left (l1norm_add_le x h) hlam.le)

private theorem adjacent_le_deltaA {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ)
    (k : ℕ) (hk : k + 1 < m) :
    l2norm (A.col ⟨k + 1, hk⟩ - A.col ⟨k, by omega⟩) ≤ deltaA A := by
  let f (j : {j : ℕ // j + 1 < m}) :=
    l2norm (fun i => A i ⟨j.1 + 1, j.2⟩ - A i ⟨j.1, by have := j.2; omega⟩)
  let g (j : {j : ℕ // j + 1 < m}) : Fin m := ⟨j, by have := j.2; omega⟩
  let : Finite {j : ℕ // j + 1 < m} :=
    Finite.of_injective g (fun _ _ h => Subtype.ext (congrArg Fin.val h))
  exact le_ciSup (Set.finite_range f).bddAbove ⟨k, hk⟩

private theorem exists_nearbyColumn {p d : ℕ} (hd : 2 ≤ d + 1)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) (j : Fin (d + 1)) :
    ∃ k : Fin d, l2norm (A.col j - A.col (j.succAbove k)) ≤ deltaA A := by
  by_cases hj : j.val + 1 < d + 1
  · let i : Fin (d + 1) := ⟨j.val + 1, hj⟩
    obtain ⟨k, hk⟩ := Fin.exists_succAbove_eq (show i ≠ j by
      intro h
      have := congrArg Fin.val h
      dsimp [i] at this
      omega)
    refine ⟨k, ?_⟩
    rw [hk, show A.col j - A.col i = -(A.col i - A.col j) by abel, l2norm_neg_eq]
    exact adjacent_le_deltaA A j.val hj
  · have hval := j.isLt
    let i : Fin (d + 1) := ⟨j.val - 1, by omega⟩
    obtain ⟨k, hk⟩ := Fin.exists_succAbove_eq (show i ≠ j by
      intro h
      have := congrArg Fin.val h
      dsimp [i] at this
      omega)
    refine ⟨k, ?_⟩
    rw [hk]
    have hj' : (j.val - 1) + 1 < d + 1 := by omega
    have hje : (⟨(j.val - 1) + 1, hj'⟩ : Fin (d + 1)) = j := by
      apply Fin.ext
      change j.val - 1 + 1 = j.val
      omega
    simpa only [hje] using adjacent_le_deltaA A (j.val - 1) hj'

private theorem slice_neighbor_lower {p d : ℕ} {lam ϱ : ℝ} (hlam : 0 < lam)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) (j : Fin (d + 1))
    {k : Fin d} (hk : l2norm (A.col j - A.col (j.succAbove k)) ≤ deltaA A) (t : ℝ) :
    ENNReal.ofReal (Real.exp (-(lam * |t|))) *
        laplaceSlice (dropColumn A j) lam 0 (ϱ - |t| * deltaA A) ≤
      laplaceSlice (dropColumn A j) lam (t • A.col j) ϱ := by
  let B := dropColumn A j
  let h : Fin d → ℝ := Pi.single k (-t)
  let S := {x | l2norm (B x + 0) ≤ ϱ - |t| * deltaA A}
  have hS : MeasurableSet S := measurableSet_laplaceSlice _ _ _
  have hhn : l1norm h = |t| := by rw [l1norm_single_eq]; exact abs_neg _
  change ENNReal.ofReal (Real.exp (-(lam * |t|))) * Qlam d lam S ≤ _
  rw [← hhn]
  refine (Qlam_translate_lower hlam h hS).trans (measure_mono ?_)
  intro x hx
  have hx' : l2norm (B (x - h)) ≤ ϱ - |t| * deltaA A := by
    simpa only [S, Set.mem_ofPred_eq, add_zero] using hx
  have hB : B h = (-t) • A.col (j.succAbove k) := by
    rw [show B h = (Matrix.of fun i k => A i (j.succAbove k)) *ᵥ (Pi.single k (-t)) from rfl,
      Matrix.mulVec_single]
    ext i
    simp [Matrix.col_apply, smul_eq_mul, mul_comm]
  have he : B x + t • A.col j = B (x - h) + t • (A.col j - A.col (j.succAbove k)) := by
    rw [map_sub, hB, neg_smul, smul_sub]
    abel
  change l2norm (B x + t • A.col j) ≤ ϱ
  rw [he]
  calc
    _ ≤ l2norm (B (x - h)) + l2norm (t • (A.col j - A.col (j.succAbove k))) :=
      l2norm_add_le _ _
    _ ≤ (ϱ - |t| * deltaA A) + |t| * deltaA A := by
      rw [l2norm_smul_real]
      exact add_le_add hx' (mul_le_mul_of_nonneg_left hk (abs_nonneg _))
    _ = _ := sub_add_cancel _ _

private def smallBallCost {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) (lam ϱ : ℝ) : ℝ :=
  -Real.log (Qlam m lam (BA A (ϱ / 4))).toReal

private def shiftSlope {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) (lam ϱ : ℝ) : ℝ :=
  4 * deltaA A * smallBallCost A lam ϱ / (lam * ϱ)

private def shiftConstant (K : ℝ) : ℝ := (1 + K / 2) / (1 - Real.exp (-2))

private theorem shiftDen_pos : 0 < 1 - Real.exp (-2) := by
  rw [sub_pos, ← Real.exp_zero]
  exact Real.exp_lt_exp.mpr (by norm_num)

private theorem smallBallCost_nonneg {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ)
    {lam : ℝ} (hlam : 0 < lam) (ϱ : ℝ) : 0 ≤ smallBallCost A lam ϱ := by
  let : IsProbabilityMeasure (Qlam m lam) := Qlam_isProbabilityMeasure m lam hlam
  exact neg_nonneg.mpr (Real.log_nonpos ENNReal.toReal_nonneg
    (by simpa using ENNReal.toReal_mono ENNReal.one_ne_top (prob_le_one (μ := Qlam m lam) (s := BA A (ϱ / 4)))))

private theorem BA_mass_ge_center_fraction {p d : ℕ} (hd : 2 ≤ d + 1)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) {lam ϱ : ℝ} (hlam : 0 < lam) (hϱ : 0 < ϱ)
    (hpos : 0 < Qlam (d + 1) lam (BA A (ϱ / 4))) (hδ : deltaA A ≤ lam * ϱ / 2)
    (j : Fin (d + 1)) :
    laplaceSlice (dropColumn A j) lam 0 ϱ *
        ENNReal.ofReal ((1 - Real.exp (-2)) / (2 + shiftSlope A lam ϱ)) ≤
      Qlam (d + 1) lam (BA A ϱ) := by
  let B := dropColumn A j
  let H := laplaceSlice B lam 0
  let G (t : ℝ) := laplaceSlice B lam (t • A.col j) ϱ
  let δ := deltaA A
  let φ := smallBallCost A lam ϱ
  let K := shiftSlope A lam ϱ
  let W := Icc (-lam⁻¹) lam⁻¹
  let : IsProbabilityMeasure (Qlam d lam) := Qlam_isProbabilityMeasure d lam hlam
  let : IsProbabilityMeasure (Qlam (d + 1) lam) := Qlam_isProbabilityMeasure _ lam hlam
  obtain ⟨k, hk⟩ := exists_nearbyColumn hd A j
  have hδ₀ : 0 ≤ δ := (Real.sqrt_nonneg _).trans hk
  have hφ : 0 ≤ φ := smallBallCost_nonneg A hlam ϱ
  have hK : 0 ≤ K := by dsimp [K, shiftSlope]; positivity
  have hH₀ : 0 < H (ϱ / 4) :=
    hpos.trans_le (BA_mass_le_center hlam A (by positivity) j)
  have hHtop (s : ℝ) : H s ≠ ⊤ := measure_ne_top _ _
  have hHρ : 0 < (H ϱ).toReal :=
    ENNReal.toReal_pos (hH₀.trans_le (laplaceSlice_mono_radius B lam 0 (by linarith))).ne' (hHtop _)
  have hφ_center : -Real.log (H (ϱ / 4)).toReal ≤ φ := by
    apply neg_le_neg
    exact Real.log_le_log (ENNReal.toReal_pos hpos.ne' (measure_ne_top _ _))
      (ENNReal.toReal_mono (hHtop _) (BA_mass_le_center hlam A (by positivity) j))
  have hshift (t : ℝ) (ht : t ∈ W) :
      H ϱ * ENNReal.ofReal (Real.exp (-(lam * (1 + K) * |t|))) ≤ G t := by
    let a := |t| * δ
    have ha : 0 ≤ a := by dsimp [a]; positivity
    have haϱ : a ≤ ϱ / 2 := by
      calc
        _ ≤ lam⁻¹ * δ := mul_le_mul_of_nonneg_right (abs_le.mpr ht) hδ₀
        _ ≤ lam⁻¹ * (lam * ϱ / 2) := mul_le_mul_of_nonneg_left hδ (inv_nonneg.mpr hlam.le)
        _ = _ := by field_simp
    have hloss := laplaceSlice_center_log_loss B hlam hϱ ha haϱ hH₀
    have hscale : 4 * φ * a / ϱ = lam * K * |t| := by
      dsimp [a, K, shiftSlope, δ, φ]
      field_simp
    have hscale' : 4 * (-Real.log (H (ϱ / 4)).toReal) * a / ϱ ≤ lam * K * |t| := by
      rw [← hscale]
      gcongr
    have hm1 : H ϱ * ENNReal.ofReal (Real.exp (-(lam * K * |t|))) ≤ H (ϱ - a) := by
      rw [← ENNReal.ofReal_toReal (hHtop ϱ), ← ENNReal.ofReal_mul hHρ.le,
        ENNReal.ofReal_le_iff_le_toReal (hHtop _)]
      have hpos' : 0 < (H (ϱ - a)).toReal :=
        ENNReal.toReal_pos (hH₀.trans_le (laplaceSlice_mono_radius B lam 0 (by linarith))).ne' (hHtop _)
      calc
        _ = Real.exp (Real.log (H ϱ).toReal + -(lam * K * |t|)) := by
          rw [Real.exp_add, Real.exp_log hHρ]
        _ ≤ Real.exp (Real.log (H (ϱ - a)).toReal) := by
          apply Real.exp_le_exp.mpr
          linarith [hloss.trans hscale']
        _ = _ := Real.exp_log hpos'
    calc
      _ = ENNReal.ofReal (Real.exp (-(lam * |t|))) *
          (H ϱ * ENNReal.ofReal (Real.exp (-(lam * K * |t|)))) := by
        rw [← mul_left_comm (H ϱ), ← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
        congr 3
        ring
      _ ≤ ENNReal.ofReal (Real.exp (-(lam * |t|))) * H (ϱ - a) :=
        mul_le_mul' le_rfl hm1
      _ ≤ G t := slice_neighbor_lower hlam A j hk t
  have hcut :
      (∫⁻ t in W, ENNReal.ofReal (lam / 2 * Real.exp (-((2 + K) * lam * |t|))) * H ϱ) ≤
        ∫⁻ t, ENNReal.ofReal (laplacePDF lam t) * G t := by
    refine (lintegral_mono_ae ?_).trans (lintegral_mono' Measure.restrict_le_self le_rfl)
    filter_upwards [ae_restrict_mem (show MeasurableSet W from measurableSet_Icc)] with t ht
    have hpdf : ENNReal.ofReal (lam / 2 * Real.exp (-((2 + K) * lam * |t|))) =
        ENNReal.ofReal (laplacePDF lam t) *
          ENNReal.ofReal (Real.exp (-(lam * (1 + K) * |t|))) := by
      rw [← ENNReal.ofReal_mul (laplacePDF_nonneg hlam.le _)]
      unfold laplacePDF
      rw [mul_assoc (lam / 2), ← Real.exp_add]
      congr 3
      ring
    rw [hpdf, mul_assoc, mul_comm (ENNReal.ofReal (Real.exp _)) (H ϱ)]
    exact mul_le_mul' le_rfl (hshift t ht)
  rw [BA_mass_as_slices hlam A ϱ j]
  calc
    _ ≤ H ϱ * ENNReal.ofReal ((1 - Real.exp (-(2 + K))) / (2 + K)) := by
      apply mul_le_mul' le_rfl (ENNReal.ofReal_le_ofReal _)
      apply div_le_div_of_nonneg_right _ (by positivity)
      exact sub_le_sub_left (Real.exp_le_exp.mpr (by linarith)) _
    _ = ∫⁻ t in W, ENNReal.ofReal (lam / 2 * Real.exp (-((2 + K) * lam * |t|))) * H ϱ := by
      rw [lintegral_mul_const _ (by fun_prop), lintegral_laplace_band hlam hK, mul_comm]
    _ ≤ _ := hcut

private theorem BA_coord_excess_le {p d : ℕ} (hd : 2 ≤ d + 1)
    (A : Matrix (Fin p) (Fin (d + 1)) ℝ) {lam ϱ : ℝ} (hlam : 0 < lam) (hϱ : 0 < ϱ)
    (hpos : 0 < Qlam (d + 1) lam (BA A (ϱ / 4))) (hδ : deltaA A ≤ lam * ϱ / 2)
    (j : Fin (d + 1)) (a : ℝ) :
    ∫⁻ x in BA A ϱ, ENNReal.ofReal (shiftExcess a (x j)) ∂Qlam (d + 1) lam ≤
      Qlam (d + 1) lam (BA A ϱ) *
        ENNReal.ofReal (shiftConstant (shiftSlope A lam ϱ) * lam * a ^ 2) := by
  let H := laplaceSlice (dropColumn A j) lam 0 ϱ
  let K := shiftSlope A lam ϱ
  let cK := shiftConstant K
  let C := (1 - Real.exp (-2)) / (2 + K)
  obtain ⟨k, hk⟩ := exists_nearbyColumn hd A j
  have hδ₀ : 0 ≤ deltaA A := (Real.sqrt_nonneg _).trans hk
  have hφ := smallBallCost_nonneg A hlam ϱ
  have hK : 0 ≤ K := by dsimp [K, shiftSlope]; positivity
  have hC : 0 < C := div_pos shiftDen_pos (by positivity)
  have hcK : 0 < cK := div_pos (by positivity) shiftDen_pos
  have hi : ENNReal.ofReal C * ENNReal.ofReal (2 * cK) = 1 := by
    rw [← ENNReal.ofReal_mul hC.le, ← ENNReal.ofReal_one]
    congr 1
    dsimp [C, cK, shiftConstant]
    have hd' := shiftDen_pos.ne'
    have hk' : 2 + K ≠ 0 := by positivity
    field_simp
  have hmass := BA_mass_ge_center_fraction hd A hlam hϱ hpos hδ j
  have hcenter : H ≤ Qlam (d + 1) lam (BA A ϱ) * ENNReal.ofReal (2 * cK) := by
    calc
      H = (H * ENNReal.ofReal C) * ENNReal.ofReal (2 * cK) := by rw [mul_assoc, hi, mul_one]
      _ ≤ _ := mul_le_mul' hmass le_rfl
  have hpdf (t : ℝ) : laplacePDF lam t ≤ lam / 2 := by
    unfold laplacePDF
    refine mul_le_of_le_one_right (by positivity) ?_
    exact Real.exp_le_one_iff.mpr (neg_nonpos.mpr (mul_nonneg hlam.le (abs_nonneg _)))
  rw [lintegral_BA_coord hlam A ϱ j (continuous_shiftExcess a).measurable.ennreal_ofReal]
  calc
    _ ≤ ∫⁻ t, (ENNReal.ofReal (lam / 2) * ENNReal.ofReal (shiftExcess a t)) * H := by
      apply lintegral_mono
      intro t
      dsimp only
      rw [mul_assoc]
      exact mul_le_mul' (ENNReal.ofReal_le_ofReal (hpdf t))
        (mul_le_mul' le_rfl (laplaceSlice_le_center _ hlam _ hϱ))
    _ = ENNReal.ofReal (lam / 2) * ENNReal.ofReal (a ^ 2) * H := by
      have hmeas : Measurable (fun t =>
          ENNReal.ofReal (lam / 2) * ENNReal.ofReal (shiftExcess a t)) :=
        measurable_const.mul (continuous_shiftExcess a).measurable.ennreal_ofReal
      rw [lintegral_mul_const _ hmeas,
        lintegral_const_mul _ (continuous_shiftExcess a).measurable.ennreal_ofReal, lintegral_shiftExcess]
    _ ≤ _ := by
      refine (mul_le_mul' le_rfl hcenter).trans_eq ?_
      rw [← ENNReal.ofReal_mul (by positivity : 0 ≤ lam / 2)]
      calc
        _ = Qlam (d + 1) lam (BA A ϱ) *
            (ENNReal.ofReal (2 * cK) * ENNReal.ofReal (lam / 2 * a ^ 2)) := by ac_rfl
        _ = _ := by
          rw [← ENNReal.ofReal_mul (by positivity : 0 ≤ 2 * cK)]
          congr 2
          ring

private def vectorExcess {m : ℕ} (h x : Fin m → ℝ) : ℝ :=
  ∑ i, shiftExcess (h i) (x i)

private theorem continuous_vectorExcess {m : ℕ} (h : Fin m → ℝ) :
    Continuous (vectorExcess h) := by
  unfold vectorExcess shiftExcess
  fun_prop

private theorem weight_two_shifts {m : ℕ} {lam : ℝ} (hlam : 0 ≤ lam)
    (h x : Fin m → ℝ) :
    2 * (laplaceWeight lam x * Real.exp (-(lam * vectorExcess h x))) ≤
      laplaceWeight lam (x + h) + laplaceWeight lam (x - h) := by
  have hsum : l1norm (x + h) + l1norm (x - h) = 2 * (l1norm x + vectorExcess h x) := by
    unfold l1norm vectorExcess
    simp only [Pi.add_apply, Pi.sub_apply, ← Finset.sum_add_distrib, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => abs_add_abs_sub_eq_excess _ _
  let u := -(lam * l1norm (x + h))
  let v := -(lam * l1norm (x - h))
  let w := (lam / 2) ^ m
  have hc : Real.exp (1 / 2 * u + 1 / 2 * v) ≤ 1 / 2 * Real.exp u + 1 / 2 * Real.exp v :=
    convexOn_exp.2 (Set.mem_univ u) (Set.mem_univ v) (by norm_num) (by norm_num) (by norm_num)
  have he : 1 / 2 * u + 1 / 2 * v = -(lam * l1norm x) + -(lam * vectorExcess h x) := by
    dsimp [u, v]
    linear_combination (-lam / 2) * hsum
  rw [he, Real.exp_add] at hc
  have hc' := mul_le_mul_of_nonneg_left hc (show 0 ≤ 2 * w by dsimp [w]; positivity)
  unfold laplaceWeight
  dsimp [w, u, v] at hc'
  linarith

private theorem symmetric_translate_lower {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ)
    {lam : ℝ} (hlam : 0 < lam) (ϱ : ℝ) (h : Fin m → ℝ) :
    ∫⁻ x in BA A ϱ, ENNReal.ofReal (Real.exp (-(lam * vectorExcess h x))) ∂Qlam m lam ≤
      Qlam m lam {x | x - h ∈ BA A ϱ} := by
  let B := BA A ϱ
  have hB : MeasurableSet B := measurableSet_BA _ _
  let T := {x | x - h ∈ B}
  have hT : MeasurableSet T := hB.preimage (by fun_prop)
  have hneg : Qlam m lam {x | x - (-h) ∈ B} = Qlam m lam T := by
    rw [← Qlam_neg_preimage hlam hT]
    congr 1
    ext x
    change x - (-h) ∈ B ↔ -x - h ∈ B
    rw [show -x - h = -(x - (-h)) by abel, BA_neg_iff]
  have hplus := Qlam_translate hlam h hB
  have hminus := Qlam_translate hlam (-h) hB
  have hg : Measurable (fun x => ENNReal.ofReal (Real.exp (-(lam * vectorExcess h x)))) :=
    (show Continuous (fun x => Real.exp (-(lam * vectorExcess h x))) by
      have := continuous_vectorExcess h
      fun_prop).measurable.ennreal_ofReal
  have hwp : Measurable (fun x => ENNReal.ofReal (laplaceWeight lam (x + h))) :=
    (continuous_laplaceWeight lam).measurable.ennreal_ofReal.comp (by fun_prop)
  have hw : Measurable (fun x => ENNReal.ofReal (laplaceWeight (d := m) lam x)) :=
    (continuous_laplaceWeight lam).measurable.ennreal_ofReal
  conv_lhs =>
    rw [Qlam_eq_withDensity m lam hlam,
      setLIntegral_withDensity_eq_lintegral_mul₀ hw.aemeasurable hg.aemeasurable hB]
  change (∫⁻ x in B, ENNReal.ofReal (laplaceWeight lam x) *
    ENNReal.ofReal (Real.exp (-(lam * vectorExcess h x)))) ≤ Qlam m lam T
  apply (ENNReal.mul_le_mul_iff_right (by norm_num : (2 : ℝ≥0∞) ≠ 0) (by simp)).mp
  have hwg : Measurable (fun x =>
      ENNReal.ofReal (laplaceWeight lam x) *
        ENNReal.ofReal (Real.exp (-(lam * vectorExcess h x)))) := hw.mul hg
  rw [← lintegral_const_mul _ hwg]
  calc
    _ ≤ ∫⁻ x in B, ENNReal.ofReal (laplaceWeight lam (x + h)) +
        ENNReal.ofReal (laplaceWeight lam (x - h)) := by
      apply lintegral_mono
      intro x
      dsimp only
      rw [← ENNReal.ofReal_mul (laplaceWeight_nonneg hlam.le _),
        show (2 : ℝ≥0∞) = ENNReal.ofReal 2 by norm_num,
        ← ENNReal.ofReal_mul (by norm_num : (0 : ℝ) ≤ 2),
        ← ENNReal.ofReal_add (laplaceWeight_nonneg hlam.le _) (laplaceWeight_nonneg hlam.le _)]
      exact ENNReal.ofReal_le_ofReal (weight_two_shifts hlam.le h x)
    _ = _ := by
      rw [lintegral_add_left hwp]
      change Qlam m lam T = _ at hplus
      rw [← hplus, show (∫⁻ x in B, ENNReal.ofReal (laplaceWeight lam (x - h))) =
          Qlam m lam {x | x - (-h) ∈ B} by simpa only [sub_eq_add_neg] using hminus.symm, hneg,
        two_mul]

/-- Lemma `pf:lem:qshift`: if `δ_A ≤ λϱ/2` then for every `h ∈ ℝ^m`,
`Q_λ(h + B_ϱ) ≥ Q_λ(B_ϱ) exp{−c_K λ² ‖h‖₂²}` with `c_K = (1 + K/2)/(1 − e^{−2})`,
`K = 4 δ_A φ(ϱ/4)/(λϱ)`. The hypothesis `Q_λ(B_{ϱ/4}) > 0` (always true, since `B_{ϱ/4}`
contains a neighbourhood of `0`) makes `φ(ϱ/4)` finite. -/
theorem quad_shift {p m : ℕ} (hm : 2 ≤ m) (A : Matrix (Fin p) (Fin m) ℝ) (lam ϱ : ℝ)
    (hlam : 0 < lam) (hϱ : 0 < ϱ) (hpos : 0 < Qlam m lam (BA A (ϱ / 4)))
    (hδ : deltaA A ≤ lam * ϱ / 2) (h : Fin m → ℝ) :
    let K := 4 * deltaA A * (-Real.log (Qlam m lam (BA A (ϱ / 4))).toReal) / (lam * ϱ)
    let cK := (1 + K / 2) / (1 - Real.exp (-2))
    Qlam m lam (BA A ϱ) * ENNReal.ofReal (Real.exp (-(cK * lam ^ 2 * l2sq h)))
      ≤ Qlam m lam {u | u - h ∈ BA A ϱ} := by
  cases m with
  | zero => omega
  | succ d =>
    let B := BA A ϱ
    let Q := Qlam (d + 1) lam
    let Z := Q B
    let ν := Z⁻¹ • Q.restrict B
    let K := shiftSlope A lam ϱ
    let cK := shiftConstant K
    change Z * ENNReal.ofReal (Real.exp (-(cK * lam ^ 2 * l2sq h))) ≤ Q {u | u - h ∈ B}
    let : IsProbabilityMeasure Q := Qlam_isProbabilityMeasure _ lam hlam
    have hZ₀ : Z ≠ 0 := (hpos.trans_le (measure_mono (fun x hx =>
      show l2norm (A *ᵥ x) ≤ ϱ from (show l2norm (A *ᵥ x) ≤ ϱ / 4 from hx).trans
        (by linarith)))).ne'
    have hZtop : Z ≠ ⊤ := measure_ne_top _ _
    have hν : IsProbabilityMeasure ν := by
      constructor
      change (Z⁻¹ • Q.restrict B) Set.univ = _
      rw [Measure.smul_apply, Measure.restrict_apply_univ, smul_eq_mul]
      exact ENNReal.inv_mul_cancel hZ₀ hZtop
    let : IsProbabilityMeasure ν := hν
    have hres : Q.restrict B = Z • ν := by
      change _ = Z • (Z⁻¹ • Q.restrict B)
      rw [smul_smul, ENNReal.mul_inv_cancel hZ₀ hZtop, one_smul]
    obtain ⟨k, hk⟩ := exists_nearbyColumn hm A (0 : Fin (d + 1))
    have hδ₀ : 0 ≤ deltaA A := (Real.sqrt_nonneg _).trans hk
    have hφ := smallBallCost_nonneg A hlam ϱ
    have hK : 0 ≤ K := by dsimp [K, shiftSlope]; positivity
    have hcK : 0 < cK := div_pos (by positivity) shiftDen_pos
    have hint (i : Fin (d + 1)) : Integrable (fun x => shiftExcess (h i) (x i)) ν := by
      refine Integrable.of_bound (((continuous_shiftExcess (h i)).comp
        (continuous_apply i)).aestronglyMeasurable) |h i| ?_
      exact Filter.Eventually.of_forall fun x => by
        rw [Real.norm_eq_abs, abs_of_nonneg (shiftExcess_nonneg _ _)]
        exact shiftExcess_le_abs _ _
    have hcoord (i : Fin (d + 1)) :
        ∫ x, shiftExcess (h i) (x i) ∂ν ≤ cK * lam * h i ^ 2 := by
      have hci := BA_coord_excess_le hm A hlam hϱ hpos hδ i (h i)
      change (∫⁻ x, ENNReal.ofReal (shiftExcess (h i) (x i)) ∂Q.restrict B) ≤
        Z * ENNReal.ofReal (cK * lam * h i ^ 2) at hci
      rw [hres, lintegral_smul_measure, smul_eq_mul] at hci
      have he := (ENNReal.mul_le_mul_iff_right hZ₀ hZtop).mp hci
      rw [← ofReal_integral_eq_lintegral_ofReal (hint i)
        (Filter.Eventually.of_forall (fun x => shiftExcess_nonneg (h i) (x i)))] at he
      exact (ENNReal.ofReal_le_ofReal_iff (by positivity)).mp he
    have hlint : Integrable (vectorExcess h) ν :=
      integrable_finsetSum _ (fun i _ => hint i)
    have hl : ∫ x, vectorExcess h x ∂ν ≤ cK * lam * l2sq h := by
      unfold vectorExcess l2sq
      rw [integral_finsetSum _ (fun i _ => hint i), Finset.mul_sum]
      exact Finset.sum_le_sum (fun i _ => hcoord i)
    let f (x : Fin (d + 1) → ℝ) := -(lam * vectorExcess h x)
    have hfi : Integrable f ν := by
      simpa only [f, neg_mul] using hlint.const_mul (-lam)
    have hfcont : Continuous (fun x => Real.exp (f x)) := by
      have := continuous_vectorExcess h
      dsimp [f]
      fun_prop
    have hgi : Integrable (fun x => Real.exp (f x)) ν := by
      refine Integrable.of_bound hfcont.aestronglyMeasurable 1 ?_
      exact Filter.Eventually.of_forall fun x => by
        rw [Real.norm_eq_abs, abs_of_nonneg (Real.exp_nonneg _), Real.exp_le_one_iff]
        exact neg_nonpos.mpr (mul_nonneg hlam.le (Finset.sum_nonneg fun i _ => shiftExcess_nonneg _ _))
    have hj := convexOn_exp.map_integral_le (μ := ν) (f := f)
      Real.continuous_exp.continuousOn isClosed_univ
      (Filter.Eventually.of_forall fun _ => Set.mem_univ _) hfi hgi
    have hj' : Real.exp (-(cK * lam ^ 2 * l2sq h)) ≤ ∫ x, Real.exp (f x) ∂ν := by
      refine le_trans (Real.exp_le_exp.mpr ?_) hj
      unfold f
      rw [integral_neg, integral_const_mul]
      have hm := mul_le_mul_of_nonneg_left hl hlam.le
      linarith
    have hfinal := symmetric_translate_lower A hlam ϱ h
    change (∫⁻ x, ENNReal.ofReal (Real.exp (f x)) ∂Q.restrict B) ≤ _ at hfinal
    rw [hres, lintegral_smul_measure, smul_eq_mul, ← ofReal_integral_eq_lintegral_ofReal hgi
      (Filter.Eventually.of_forall fun _ => Real.exp_nonneg _)] at hfinal
    exact (mul_le_mul' le_rfl (ENNReal.ofReal_le_ofReal hj')).trans hfinal

end BQTF
