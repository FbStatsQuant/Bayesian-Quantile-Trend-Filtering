import BQTF.Basic

/-! Rate comparisons for the posterior contraction bound. -/

namespace BQTF.Asym

open Filter

theorem rate_eq_epsSq (k n : ℕ) : rate k n = epsSq (k + 1) n := by
  unfold rate epsSq
  push_cast
  congr 2
  ring

theorem mul_epsSq_eq (r n : ℕ) (hr : 0 < r) (hn : 0 < n) :
    (n : ℝ) * epsSq r n = (n : ℝ) ^ (1 / (2 * r : ℝ)) := by
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  have hr' : (r : ℝ) ≠ 0 := by exact_mod_cast hr.ne'
  unfold epsSq
  conv_lhs => lhs; rw [← Real.rpow_one (n : ℝ)]
  rw [← Real.rpow_add hn']
  congr 1
  field_simp
  ring

theorem massRate_eq_inv (k n : ℕ) (hn : 0 < n) :
    massRate k n = ((n : ℝ) * epsSq (k + 1) n)⁻¹ := by
  rw [mul_epsSq_eq _ _ (by omega) hn, massRate, ← Real.rpow_neg (by positivity)]
  push_cast
  congr 2
  ring

theorem mul_epsSq_le (r n : ℕ) (hn : 1 ≤ n) : (n : ℝ) * epsSq r n ≤ n := by
  have hn' : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hexp : -((2 * r - 1 : ℝ) / (2 * r)) ≤ 0 := by
    cases r with
    | zero => simp
    | succ r =>
      push_cast
      have hr : (0 : ℝ) ≤ r := by positivity
      exact neg_nonpos.mpr (div_nonneg (by linarith) (by positivity))
  have h : epsSq r n ≤ 1 := by
    simpa [epsSq] using Real.rpow_le_rpow_of_exponent_le hn' hexp
  nlinarith [mul_le_mul_of_nonneg_left h (show 0 ≤ (n : ℝ) by positivity)]

theorem mul_epsSq_le_mul_rhoSq (r n : ℕ) (hr : 1 ≤ r)
    (hn : 1 ≤ n) (hlog : 1 ≤ Real.log n) :
    (n : ℝ) * epsSq r n ≤ (n : ℝ) * rhoSq r n := by
  have hn' : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hr' : (1 : ℝ) ≤ r := by exact_mod_cast hr
  have hnum : 0 ≤ (2 * r - 1 : ℝ) := by linarith
  have hexp : -((2 * r - 1 : ℝ) / (2 * r)) ≤ -((2 * r - 1 : ℝ) / (2 * r + 1)) := by
    exact neg_le_neg (div_le_div_of_nonneg_left hnum (by positivity) (by linarith))
  unfold epsSq rhoSq
  gcongr
  exact (Real.rpow_le_rpow_of_exponent_le hn' hexp).trans (le_mul_of_one_le_right
    (by positivity) hlog)

theorem eventually_mul_epsSq_ge (r : ℕ) (hr : 0 < r) (B : ℝ) :
    ∃ N : ℕ, ∀ n ≥ N, 0 < n ∧ B ≤ (n : ℝ) * epsSq r n := by
  have hpow : Tendsto (fun n : ℕ => (n : ℝ) ^ (1 / (2 * r : ℝ))) atTop atTop :=
    (tendsto_rpow_atTop (by positivity)).comp tendsto_natCast_atTop_atTop
  have h := (eventually_gt_atTop (0 : ℕ)).and (hpow.eventually_ge_atTop B)
  obtain ⟨N, hN⟩ := eventually_atTop.mp h
  refine ⟨N, fun n hn => ⟨(hN n hn).1, ?_⟩⟩
  rw [mul_epsSq_eq r n hr (hN n hn).1]
  exact (hN n hn).2

theorem eventually_log_ge_one : ∃ N : ℕ, ∀ n ≥ N, 1 ≤ Real.log n :=
  eventually_atTop.mp
    ((Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop).eventually_ge_atTop 1)

/-- A fixed positive exponential rate is bounded by a constant times the inverse scale. -/
theorem exp_neg_mul_le_inv {b x : ℝ} (hb : 0 < b) (hx : 0 < x) :
    Real.exp (-(b * x)) ≤ b⁻¹ * x⁻¹ := by
  rw [← mul_inv, Real.exp_neg]
  exact inv_anti₀ (mul_pos hb hx) (by linarith [Real.add_one_le_exp (b * x)])

end BQTF.Asym
