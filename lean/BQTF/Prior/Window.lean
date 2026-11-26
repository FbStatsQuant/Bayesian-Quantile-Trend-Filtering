import BQTF.Smooth
import BQTF.Prior.Geometry

open Filter

noncomputable section

namespace BQTF

/-- The exponent used to invert the smoothing error. -/
def smoothingPower (r : ℕ) : ℝ := 2 / (2 * (r : ℝ) - 1)

/-- The power of the sample size that equals `n * ε_n²`. -/
def priorBudget (r n : ℕ) : ℝ := (n : ℝ) ^ (1 / (2 * (r : ℝ)))

theorem priorBudget_eq (r n : ℕ) (hr : 0 < r) (hn : 0 < n) :
    priorBudget r n = (n : ℝ) * epsSq r n := by
  have hr' : (r : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hr.ne'
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  unfold priorBudget epsSq
  rw [mul_comm (n : ℝ), ← Real.rpow_add_one hn'.ne']
  congr 1
  field_simp
  ring

theorem priorBudget_ge_one (r n : ℕ) (hn : 0 < n) : 1 ≤ priorBudget r n := by
  unfold priorBudget
  apply Real.one_le_rpow
  · exact_mod_cast hn
  · positivity

theorem eps_smoothingPower (r n : ℕ) (hr : 2 ≤ r) :
    (Real.sqrt (epsSq r n)) ^ smoothingPower r = (priorBudget r n)⁻¹ := by
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have hden : (2 * (r : ℝ) - 1) ≠ 0 := by linarith
  have hr0 : (r : ℝ) ≠ 0 := by linarith
  unfold epsSq smoothingPower priorBudget
  rw [Real.sqrt_eq_rpow, ← Real.rpow_mul (Nat.cast_nonneg n),
    ← Real.rpow_mul (Nat.cast_nonneg n), ← Real.rpow_neg (Nat.cast_nonneg n)]
  congr 1
  field_simp

theorem priorBudget_tendsto (r : ℕ) (hr : 0 < r) :
    Tendsto (priorBudget r) atTop atTop := by
  have hr' : (0 : ℝ) < r := Nat.cast_pos.mpr hr
  exact (tendsto_rpow_atTop (show 0 < 1 / (2 * (r : ℝ)) by positivity)).comp
    tendsto_natCast_atTop_atTop

theorem lamSeq_eq_prior (c : ℝ) (k n : ℕ) :
    lamSeq c k n = c * (n : ℝ) ^ (((k + 1 : ℕ) : ℝ) - 1 / 2) := by
  unfold lamSeq
  push_cast
  congr 2
  ring

/-- The adjacent-column bound, multiplied by the prior mass exponent, is at most
the small-ball radius times the penalty, up to the factor `2 / c`. -/
theorem priorBudget_delta_bound (r n : ℕ) (hr : 2 ≤ r) (hn : 0 < n) :
    (n : ℝ) ^ (r - 2) * priorBudget r n ≤
      (n : ℝ) ^ ((r : ℝ) - 1 / 2) * Real.sqrt (epsSq r n) := by
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hn₁ : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have hp : 0 < 2 * (r : ℝ) := by linarith
  rw [← Real.rpow_natCast, Nat.cast_sub hr, Nat.cast_ofNat, priorBudget, epsSq,
    Real.sqrt_eq_rpow, ← Real.rpow_mul hn'.le, ← Real.rpow_add hn', ← Real.rpow_add hn']
  apply Real.rpow_le_rpow_of_exponent_le hn₁
  apply (mul_le_mul_iff_right₀ hp).mp
  field_simp
  nlinarith

private theorem window_size (r : ℕ) (hr : 2 ≤ r) {D : ℝ} (hD : 0 < D) :
    ∃ N : ℕ, 2 * r ≤ N ∧ ∀ n, N ≤ n →
      (r : ℝ) ≤ (n : ℝ) * D / priorBudget r n ∧
      (n : ℝ) * D / priorBudget r n ≤ ((n - r : ℕ) : ℝ) := by
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have hexp : 0 < (1 : ℝ) - 1 / (2 * (r : ℝ)) := by
    have hp : (1 : ℝ) < 2 * (r : ℝ) := by linarith
    have h := (div_lt_iff₀ (zero_lt_one.trans hp)).mpr (by simpa using hp : (1 : ℝ) < 1 * (2 * (r : ℝ)))
    linarith
  have hgrow : Tendsto (fun n : ℕ => D * (n : ℝ) ^ (1 - 1 / (2 * (r : ℝ)))) atTop atTop :=
    ((tendsto_rpow_atTop hexp).comp tendsto_natCast_atTop_atTop).const_mul_atTop hD
  obtain ⟨N₁, hN₁⟩ := eventually_atTop.mp (hgrow.eventually_ge_atTop (r : ℝ))
  obtain ⟨N₂, hN₂⟩ := eventually_atTop.mp
    ((priorBudget_tendsto r (by omega)).eventually_ge_atTop (2 * D))
  refine ⟨max (2 * r) (max N₁ N₂), le_max_left .., ?_⟩
  intro n hn
  have hnr : 2 * r ≤ n := (le_max_left _ _).trans hn
  have hn' : (0 : ℝ) < n := by exact_mod_cast (show 0 < n by omega)
  have hs : 0 < priorBudget r n := by unfold priorBudget; positivity
  have h₁ := hN₁ n ((le_max_left _ _).trans ((le_max_right _ _).trans hn))
  have h₂ := hN₂ n ((le_max_right _ _).trans ((le_max_right _ _).trans hn))
  constructor
  · change (r : ℝ) ≤ D * (n : ℝ) ^ (1 - 1 / (2 * (r : ℝ))) at h₁
    rw [Real.rpow_sub hn', Real.rpow_one] at h₁
    rw [← mul_div_assoc, mul_comm D (n : ℝ)] at h₁
    exact h₁
  · calc
      (n : ℝ) * D / priorBudget r n = (n : ℝ) * (D / priorBudget r n) := mul_div_assoc ..
      _ ≤ (n : ℝ) * (1 / 2) :=
        mul_le_mul_of_nonneg_left ((div_le_iff₀ hs).mpr (by linarith)) hn'.le
      _ ≤ ((n - r : ℕ) : ℝ) := by
        rw [Nat.cast_sub (by omega : r ≤ n)]
        have hnr' : (2 : ℝ) * r ≤ n := by exact_mod_cast hnr
        linarith

private theorem ustar_eq_zero_of_TVr_le_zero (r n : ℕ) (hn : 0 < n)
    (θs : Fin n → ℝ) (h : TVr r n θs ≤ 0) : ustar r n θs = 0 := by
  have hp : 0 < (n : ℝ) ^ (r - 1) := by have : (0 : ℝ) < n := Nat.cast_pos.mpr hn; positivity
  have hs : l1norm (ustar r n θs) ≤ 0 := by
    apply (mul_le_mul_iff_right₀ hp).mp
    simpa only [TVr, ustar, mul_zero] using h
  ext i
  apply abs_eq_zero.mp
  have hi : |ustar r n θs i| ≤ l1norm (ustar r n θs) :=
    Finset.single_le_sum (fun j _ => abs_nonneg (ustar r n θs j)) (Finset.mem_univ i)
  exact (hi.trans hs).antisymm (abs_nonneg _)

/-- The smoothed truth has the required approximation error and a penalty cost bounded by
a constant times `n * ε_n²`. -/
theorem prior_smoothed_window (r : ℕ) (hr : 2 ≤ r) (c Vb : ℝ) (hc : 0 < c) :
    ∃ U : ℝ, ∃ N : ℕ, 0 ≤ U ∧ ∀ n, N ≤ n → r < n → ∀ θs : Fin n → ℝ,
      TVr r n θs ≤ Vb → ∃ u₀ : Fin (n - r) → ℝ,
        empNorm (Pperp r n (Smul r n (ustar r n θs - u₀))) ≤ Real.sqrt (epsSq r n) / 2 ∧
        (c * (n : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 * l2sq u₀ ≤ U * priorBudget r n := by
  by_cases hV : 0 < Vb
  swap
  · refine ⟨0, 0, le_rfl, ?_⟩
    intro n _ hn θs hTV
    have hu := ustar_eq_zero_of_TVr_le_zero r n (by omega) θs (hTV.trans (le_of_not_gt hV))
    refine ⟨0, ?_, ?_⟩
    · have hzero : Smul r n 0 = 0 := by ext i; simp [Smul]
      rw [hu, sub_self, hzero, map_zero]
      simpa [empNorm, l2sq] using (show 0 ≤ Real.sqrt (epsSq r n) / 2 by positivity)
    · simp [l2sq]
  have hCs : 0 < Cs r := by
    have := (gr_pos r (by omega)).1
    unfold Cs
    positivity
  let a : ℝ := (r : ℝ) - 1 / 2
  let b : ℝ := smoothingPower r
  let H : ℝ := 2 * Cs r * Vb
  let D : ℝ := (H ^ b)⁻¹
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have ha : 0 < a := by dsimp [a]; linarith
  have hba : b * a = 1 := by
    have hd : (2 * (r : ℝ) - 1) ≠ 0 := by linarith
    dsimp [b, a, smoothingPower]
    field_simp
  have hH : 0 < H := by dsimp [H]; positivity
  have hD : 0 < D := by dsimp [D]; positivity
  obtain ⟨N, _, hN⟩ := window_size r hr hD
  let U := (c * Cs r * Vb) ^ 2 * (2 / D)
  refine ⟨U, N, by dsimp [U]; positivity, ?_⟩
  intro n hn hnr θs hTV
  let ε := Real.sqrt (epsSq r n)
  have hn₀ : 0 < n := by omega
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn₀
  have hε : 0 < ε := by unfold ε epsSq; positivity
  let s := priorBudget r n
  have hs : 0 < s := by unfold s priorBudget; positivity
  let x := (n : ℝ) * (ε / H) ^ b
  have hx : x = (n : ℝ) * D / s := by
    unfold x D
    rw [Real.div_rpow hε.le hH.le, show ε ^ b = s⁻¹ from eps_smoothingPower r n hr]
    simp only [div_eq_mul_inv]
    ring
  have hx₁ : (r : ℝ) ≤ x := hx ▸ (hN n hn).1
  have hx₂ : x ≤ ((n - r : ℕ) : ℝ) := hx ▸ (hN n hn).2
  have hx₀ : 0 ≤ x := (Nat.cast_nonneg r).trans hx₁
  let w := Nat.floor x
  have hw : r ≤ w := Nat.le_floor hx₁
  have hwx : (w : ℝ) ≤ x := Nat.floor_le hx₀
  have hwm : w ≤ n - r := by exact_mod_cast hwx.trans hx₂
  have hwpos : (0 : ℝ) < w := by exact_mod_cast (show 0 < w by omega)
  have hxhalf : x / 2 ≤ (w : ℝ) := by
    have h := Nat.lt_floor_add_one x
    change x < (w : ℝ) + 1 at h
    linarith
  obtain ⟨u, hu, hu_approx⟩ := smoothed_truth r n hr hnr θs w hw hwm
  refine ⟨u, ?_, ?_⟩
  · have hpow : ((w : ℝ) / n) ^ a ≤ ε / H := by
      calc
        ((w : ℝ) / n) ^ a ≤ ((ε / H) ^ b) ^ a := by
          apply Real.rpow_le_rpow (by positivity) _ ha.le
          exact (div_le_iff₀ hn').mpr (by simpa only [x, mul_comm] using hwx)
        _ = ε / H := by rw [← Real.rpow_mul (div_nonneg hε.le hH.le), hba, Real.rpow_one]
    calc
      _ ≤ empNorm (Smul r n (ustar r n θs - u)) := empNorm_Pperp_le _ _ _
      _ ≤ Cs r * TVr r n θs * ((w : ℝ) / n) ^ a := hu_approx
      _ ≤ (Cs r * Vb) * (ε / H) := by
        exact (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hTV hCs.le)
          (Real.rpow_nonneg (by positivity) _)).trans (mul_le_mul_of_nonneg_left hpow (by positivity))
      _ = ε / 2 := by dsimp [H]; field_simp
  · have hU : l2norm u ≤ Cs r * Vb / ((n : ℝ) ^ (r - 1) * Real.sqrt w) :=
      hu.trans (div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hTV hCs.le) (by positivity))
    have hsq : l2sq u ≤ (Cs r * Vb / ((n : ℝ) ^ (r - 1) * Real.sqrt w)) ^ 2 := by
      have h := pow_le_pow_left₀ (Real.sqrt_nonneg (l2sq u)) hU 2
      have hl2 : 0 ≤ l2sq u := Finset.sum_nonneg fun i _ => sq_nonneg (u i)
      simpa only [l2norm, Real.sq_sqrt hl2] using h
    have hp : (n : ℝ) ^ a = (n : ℝ) ^ (r - 1) * Real.sqrt n := by
      rw [Real.sqrt_eq_rpow, ← Real.rpow_natCast, Nat.cast_sub (by omega : 1 ≤ r),
        Nat.cast_one, ← Real.rpow_add hn']
      congr 1
      dsimp [a]
      ring
    have hratio : (n : ℝ) / w ≤ (2 / D) * s := by
      have hh : (n : ℝ) * D ≤ 2 * ((w : ℝ) * s) := by
        have h := (div_le_iff₀ hs).mp (show (n : ℝ) * D / s ≤ 2 * w by rw [← hx]; linarith)
        linarith
      apply (div_le_iff₀ hwpos).mpr
      apply (mul_le_mul_iff_left₀ hD).mp
      calc
        (n : ℝ) * D ≤ 2 * ((w : ℝ) * s) := hh
        _ = (2 / D * s * (w : ℝ)) * D := by field_simp
    calc
      _ ≤ (c * (n : ℝ) ^ a) ^ 2 * (Cs r * Vb / ((n : ℝ) ^ (r - 1) * Real.sqrt w)) ^ 2 :=
        mul_le_mul_of_nonneg_left hsq (sq_nonneg _)
      _ = (c * Cs r * Vb) ^ 2 * ((n : ℝ) / w) := by
        rw [hp, div_pow, mul_pow c, mul_pow ((n : ℝ) ^ (r - 1)),
          mul_pow ((n : ℝ) ^ (r - 1)), Real.sq_sqrt hn'.le,
          Real.sq_sqrt (Nat.cast_nonneg w)]
        have hnPow : (n : ℝ) ^ (r - 1) ≠ 0 := by positivity
        field_simp
      _ ≤ _ := by
        unfold U
        rw [mul_assoc ((c * Cs r * Vb) ^ 2)]
        exact mul_le_mul_of_nonneg_left hratio (sq_nonneg _)

end BQTF
