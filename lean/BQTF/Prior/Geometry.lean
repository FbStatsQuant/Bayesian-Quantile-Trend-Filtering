import BQTF.SmallBall
import BQTF.QuadShift
import BQTF.Falling

open Finset Matrix
open scoped InnerProductSpace

noncomputable section

namespace BQTF

private theorem l2norm_eq_norm_toE {n : ℕ} (v : Fin n → ℝ) : l2norm v = ‖toE n v‖ := by
  rw [EuclideanSpace.norm_eq, l2norm, l2sq]
  change Real.sqrt (∑ i, v i ^ 2) = Real.sqrt (∑ i, ‖v i‖ ^ 2)
  simp only [Real.norm_eq_abs, sq_abs]

private theorem l2sq_nonneg {n : ℕ} (v : Fin n → ℝ) : 0 ≤ l2sq v :=
  Finset.sum_nonneg fun i _ => sq_nonneg (v i)

private theorem empNorm_eq_div {n : ℕ} (v : Fin n → ℝ) :
    empNorm v = l2norm v / Real.sqrt n := by
  unfold empNorm l2norm
  rw [Real.sqrt_div (l2sq_nonneg v)]

/-- Orthogonal residuals contract the empirical norm. -/
theorem empNorm_Pperp_le (r n : ℕ) (v : Fin n → ℝ) :
    empNorm (Pperp r n v) ≤ empNorm v := by
  let V := (polySpace r n).map (toE n).toLinearMap
  have h : toE n (Pperp r n v) = Vᗮ.starProjection (toE n v) := by
    rw [Submodule.starProjection_orthogonal]
    simp [Pperp, Pproj, orthProj, V]
  rw [empNorm_eq_div, empNorm_eq_div, l2norm_eq_norm_toE, l2norm_eq_norm_toE, h]
  exact div_le_div_of_nonneg_right (Vᗮ.norm_starProjection_apply_le _) (Real.sqrt_nonneg _)

private theorem empNorm_le_of_abs_le {n : ℕ} (hn : 0 < n) {v : Fin n → ℝ} {B : ℝ}
    (hB : 0 ≤ B) (hv : ∀ i, |v i| ≤ B) : empNorm v ≤ B := by
  unfold empNorm
  refine (Real.sqrt_le_sqrt ?_).trans_eq (Real.sqrt_sq hB)
  have hsum : l2sq v ≤ (n : ℝ) * B ^ 2 := by
    calc
      l2sq v ≤ ∑ _ : Fin n, B ^ 2 := by
        apply Finset.sum_le_sum
        intro i _
        rw [← sq_abs (v i)]
        exact pow_le_pow_left₀ (abs_nonneg _) (hv i) 2
      _ = _ := by simp
  exact (div_le_iff₀ (Nat.cast_pos.mpr hn)).mpr (by simpa only [mul_comm] using hsum)

private theorem scaled_l2norm_eq_empNorm (n : ℕ) (v : Fin n → ℝ) :
    l2norm (((n : ℝ) ^ (-(1 / 2 : ℝ))) • v) = empNorm v := by
  rw [empNorm_eq_div, l2norm_eq_norm_toE, l2norm_eq_norm_toE, map_smul, norm_smul,
    Real.norm_eq_abs, Real.rpow_neg (Nat.cast_nonneg n), ← Real.sqrt_eq_rpow,
    abs_of_nonneg (inv_nonneg.mpr (Real.sqrt_nonneg _)), div_eq_inv_mul]

private def AsbLinear (r n : ℕ) : (Fin (n - r) → ℝ) →ₗ[ℝ] (Fin n → ℝ) where
  toFun := Asb r n
  map_add' u v := by
    have h : Smul r n (u + v) = Smul r n u + Smul r n v := by
      ext i
      simp only [Smul, Pi.add_apply, add_mul, Finset.sum_add_distrib]
    simp only [Asb, h, map_add, smul_add]
  map_smul' a u := by
    have h : Smul r n (a • u) = a • Smul r n u := by
      ext i
      simp only [Smul, Pi.smul_apply, smul_eq_mul, mul_assoc, Finset.mul_sum]
    simp only [RingHom.id_apply, Asb, h, map_smul]
    exact smul_comm _ _ _

/-- Matrix of the operator in the small-ball event, in the coordinate bases. -/
def priorMatrix (r n : ℕ) : Matrix (Fin n) (Fin (n - r)) ℝ :=
  (AsbLinear r n).toMatrix'

theorem BA_priorMatrix (r n : ℕ) (ϱ : ℝ) : BA (priorMatrix r n) ϱ = Bsb r n ϱ := by
  ext u
  simp only [BA, priorMatrix, LinearMap.toMatrix'_mulVec, Bsb, Set.mem_ofPred_eq]
  rfl

private theorem Smul_single (r n : ℕ) (j : Fin (n - r)) :
    Smul r n (Pi.single j 1) = sCol r n j := by
  ext i
  unfold Smul
  rw [Finset.sum_eq_single j]
  · simp
  · intro k _ hkj
    simp [Pi.single_eq_of_ne hkj]
  · simp

private theorem priorMatrix_col (r n : ℕ) (j : Fin (n - r)) (i : Fin n) :
    priorMatrix r n i j = (n : ℝ) ^ (-(1 / 2 : ℝ)) * Pperp r n (sCol r n j) i := by
  rw [priorMatrix, LinearMap.toMatrix'_apply]
  change ((n : ℝ) ^ (-(1 / 2 : ℝ)) • Pperp r n (Smul r n (Pi.single j 1))) i = _
  rw [Smul_single]
  rfl

private theorem abs_sCol_succ_sub_le (r n j : ℕ) (hr : 2 ≤ r) (i : Fin n) :
    |sCol r n (j + 1) i - sCol r n j i| ≤ (n : ℝ) ^ (r - 2) := by
  let t : ℤ := (i : ℤ) - (j : ℤ) - 2
  have hpascal := bfun_pascal (r - 1) (by omega) t
  have hs : sCol r n (j + 1) i - sCol r n j i = -bfun (r - 2) t := by
    unfold sCol
    push_cast
    rw [show (i : ℤ) - ((j : ℤ) + 1) - 1 = t by dsimp [t]; ring,
      show (i : ℤ) - (j : ℤ) - 1 = t + 1 by dsimp [t]; ring,
      show r - 2 = r - 1 - 1 by omega]
    linarith
  rw [hs, abs_neg]
  unfold bfun
  split_ifs with ht
  · rw [abs_of_nonneg (Nat.cast_nonneg _)]
    have htn : t.toNat ≤ n := by
      have hi := i.isLt
      dsimp [t] at *
      omega
    exact_mod_cast (Nat.choose_le_pow t.toNat (r - 2)).trans
      (Nat.pow_le_pow_left htn (r - 2))
  · simp

/-- Pascal's identity bounds the change between adjacent columns by the degree-`r-2` growth rate. -/
theorem deltaA_priorMatrix (r n : ℕ) (hr : 2 ≤ r) (hm : 2 ≤ n - r) :
    0 ≤ deltaA (priorMatrix r n) ∧ deltaA (priorMatrix r n) ≤ (n : ℝ) ^ (r - 2) := by
  let j₀ : {j : ℕ // j + 1 < n - r} := ⟨0, by omega⟩
  let : Nonempty {j : ℕ // j + 1 < n - r} := ⟨j₀⟩
  let f (j : {j : ℕ // j + 1 < n - r}) :=
    l2norm (fun i => priorMatrix r n i ⟨j.1 + 1, j.2⟩ -
      priorMatrix r n i ⟨j.1, by have := j.2; omega⟩)
  have hf (j : {j : ℕ // j + 1 < n - r}) : f j ≤ (n : ℝ) ^ (r - 2) := by
    have hcols : (fun i => priorMatrix r n i ⟨j.1 + 1, j.2⟩ -
        priorMatrix r n i ⟨j.1, by have := j.2; omega⟩) =
        (n : ℝ) ^ (-(1 / 2 : ℝ)) • Pperp r n (sCol r n (j.1 + 1) - sCol r n j.1) := by
      ext i
      simp only [priorMatrix_col, Pi.smul_apply, smul_eq_mul, map_sub, Pi.sub_apply, mul_sub]
    dsimp [f]
    rw [hcols, scaled_l2norm_eq_empNorm]
    refine (empNorm_Pperp_le _ _ _).trans (empNorm_le_of_abs_le (by omega) (by positivity) ?_)
    exact abs_sCol_succ_sub_le r n j.1 hr
  have hb : BddAbove (Set.range f) :=
    ⟨(n : ℝ) ^ (r - 2), by rintro _ ⟨j, rfl⟩; exact hf j⟩
  change 0 ≤ (⨆ j, f j) ∧ (⨆ j, f j) ≤ _
  exact ⟨(Real.sqrt_nonneg _).trans (le_ciSup hb j₀), ciSup_le hf⟩

end BQTF
