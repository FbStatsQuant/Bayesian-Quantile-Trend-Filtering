import BQTF.Shift.PrekopaLaplace
import BQTF.Shift.LaplaceMeasure

open MeasureTheory
open scoped ENNReal

noncomputable section

namespace BQTF

theorem continuous_l2norm {n : ℕ} : Continuous (l2norm : (Fin n → ℝ) → ℝ) := by
  unfold l2norm l2sq
  fun_prop

theorem l2norm_add_le {n : ℕ} (u v : Fin n → ℝ) :
    l2norm (u + v) ≤ l2norm u + l2norm v :=
  PL.l2norm_add_le u v

theorem l2norm_smul_real {n : ℕ} (c : ℝ) (v : Fin n → ℝ) :
    l2norm (c • v) = |c| * l2norm v :=
  PL.l2norm_smul c v

theorem l2norm_neg_eq {n : ℕ} (v : Fin n → ℝ) : l2norm (-v) = l2norm v := by
  simpa using PL.l2norm_smul (-1) v

theorem measurableSet_laplaceSlice {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    (b : Fin p → ℝ) (s : ℝ) : MeasurableSet {x | l2norm (A x + b) ≤ s} :=
  PL.measurableSet_slice A b s

theorem laplaceSlice_mono_radius {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    (lam : ℝ) (b : Fin p → ℝ) : Monotone (laplaceSlice A lam b) :=
  fun _ _ h => measure_mono (fun _ hx => hx.trans h)

private theorem laplaceSlice_neg {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    {lam : ℝ} (hlam : 0 < lam) (b : Fin p → ℝ) (s : ℝ) :
    laplaceSlice A lam (-b) s = laplaceSlice A lam b s := by
  unfold laplaceSlice
  rw [← Qlam_neg_preimage hlam (measurableSet_laplaceSlice A b s)]
  congr 1
  ext x
  change (l2norm (A x + -b) ≤ s) ↔ (l2norm (A (-x) + b) ≤ s)
  rw [map_neg, show -A x + b = -(A x + -b) by abel, l2norm_neg_eq]

/-- A Laplace slice takes its maximum at zero shift. -/
theorem laplaceSlice_le_center {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    {lam : ℝ} (hlam : 0 < lam) (b : Fin p → ℝ) {s : ℝ} (hs : 0 < s) :
    laplaceSlice A lam b s ≤ laplaceSlice A lam 0 s := by
  have h := prekopa_laplace A lam hlam b (-b) s s hs hs (1 / 2) (by norm_num) (by norm_num)
  rw [laplaceSlice_neg A hlam, show (1 - 1 / 2 : ℝ) = 1 / 2 by norm_num,
    ← ENNReal.rpow_add_of_nonneg _ _ (by norm_num) (by norm_num),
    show (1 / 2 + 1 / 2 : ℝ) = 1 by norm_num, ENNReal.rpow_one,
    smul_neg, add_neg_cancel, ← add_mul,
    show (1 / 2 + 1 / 2 : ℝ) = 1 by norm_num, one_mul] at h
  exact h

/-- The logarithmic mass lost by reducing the radius by at most half. -/
theorem laplaceSlice_center_log_loss {p d : ℕ} (A : (Fin d → ℝ) →ₗ[ℝ] (Fin p → ℝ))
    {lam ϱ a : ℝ} (hlam : 0 < lam) (hϱ : 0 < ϱ) (ha : 0 ≤ a) (haϱ : a ≤ ϱ / 2)
    (hpos : 0 < laplaceSlice A lam 0 (ϱ / 4)) :
    Real.log (laplaceSlice A lam 0 ϱ).toReal -
        Real.log (laplaceSlice A lam 0 (ϱ - a)).toReal ≤
      4 * (-Real.log (laplaceSlice A lam 0 (ϱ / 4)).toReal) * a / ϱ := by
  let H := laplaceSlice A lam 0
  let : IsProbabilityMeasure (Qlam d lam) := Qlam_isProbabilityMeasure d lam hlam
  have hb (s : ℝ) : H s ≤ 1 := prob_le_one
  have ht (s : ℝ) : H s ≠ ⊤ := ne_top_of_le_ne_top ENNReal.one_ne_top (hb s)
  have hsmall : 0 < (H (ϱ / 4)).toReal := ENNReal.toReal_pos hpos.ne' (ht _)
  have hbig : 0 < (H ϱ).toReal :=
    ENNReal.toReal_pos (hpos.trans_le (laplaceSlice_mono_radius A lam 0 (by linarith))).ne' (ht _)
  have hlog (s : ℝ) : Real.log (H s).toReal ≤ 0 :=
    Real.log_nonpos ENNReal.toReal_nonneg (by simpa using ENNReal.toReal_mono ENNReal.one_ne_top (hb s))
  let t := (a / (3 * ϱ / 4))
  have ht₀ : 0 ≤ t := div_nonneg ha (by positivity)
  have ht₁ : t ≤ 1 := (div_le_one (by positivity)).mpr (by linarith)
  have hrad : (1 - t) * ϱ + t * (ϱ / 4) = ϱ - a := by
    dsimp [t]
    field_simp
    ring
  have h := prekopa_laplace A lam hlam 0 0 ϱ (ϱ / 4) hϱ (by positivity) t ht₀ ht₁
  simp only [smul_zero, add_zero, hrad] at h
  change H ϱ ^ (1 - t) * H (ϱ / 4) ^ t ≤ H (ϱ - a) at h
  have h' := ENNReal.toReal_mono (ht _) h
  rw [ENNReal.toReal_mul, ← ENNReal.toReal_rpow, ← ENNReal.toReal_rpow] at h'
  have hh := Real.log_le_log
    (mul_pos (Real.rpow_pos_of_pos hbig _) (Real.rpow_pos_of_pos hsmall _)) h'
  rw [Real.log_mul (Real.rpow_pos_of_pos hbig _).ne' (Real.rpow_pos_of_pos hsmall _).ne',
    Real.log_rpow hbig, Real.log_rpow hsmall] at hh
  calc
    _ ≤ t * (-Real.log (H (ϱ / 4)).toReal) := by
      have := mul_nonpos_of_nonneg_of_nonpos ht₀ (hlog ϱ)
      linarith
    _ ≤ 4 * (-Real.log (H (ϱ / 4)).toReal) * a / ϱ := by
      have hcoef : t ≤ 4 * a / ϱ := by
        dsimp [t]
        rw [show 3 * ϱ / 4 = (3 / 4 : ℝ) * ϱ by ring, div_mul_eq_div_div]
        apply div_le_div_of_nonneg_right _ hϱ.le
        apply (div_le_iff₀ (by norm_num : (0 : ℝ) < 3 / 4)).mpr
        linarith
      calc
        _ ≤ (4 * a / ϱ) * (-Real.log (H (ϱ / 4)).toReal) :=
          mul_le_mul_of_nonneg_right hcoef (neg_nonneg.mpr (hlog _))
        _ = _ := by ring

end BQTF
