import BQTF.Asym.Rates

/-! Growth and decay estimates used in the shell projection bounds. -/

open Filter

namespace BQTF.Asym

theorem mul_epsSq_pow (r n : ℕ) (hr : 0 < r) (hn : 0 < n) :
    ((n : ℝ) * epsSq r n) ^ (2 * r) = n := by
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  have hr' : 0 < (r : ℝ) := by exact_mod_cast hr
  rw [mul_epsSq_eq r n hr hn, ← Real.rpow_mul_natCast hn'.le]
  push_cast
  rw [one_div, inv_mul_cancel₀ (by positivity), Real.rpow_one]

theorem epsSq_eventually_le (r : ℕ) (hr : 1 ≤ r) (d : ℝ) (hd : 0 < d) :
    ∀ᶠ n : ℕ in atTop, epsSq r n ≤ d := by
  have hr' : (1 : ℝ) ≤ r := by exact_mod_cast hr
  have h : 0 < ((2 * r - 1 : ℝ) / (2 * r)) := by
    exact div_pos (by linarith) (by linarith)
  exact (((tendsto_rpow_neg_atTop h).comp tendsto_natCast_atTop_atTop).eventually
    (eventually_le_nhds hd))

theorem log_twice_eventually_le (r : ℕ) (hr : 0 < r) (d : ℝ) (hd : 0 < d) :
    ∀ᶠ n : ℕ in atTop, Real.log (2 * n) ≤ d * (n * epsSq r n) := by
  have h := ((isLittleO_log_rpow_atTop
    (show 0 < 1 / (2 * r : ℝ) by positivity)).def (show 0 < d / 2 by positivity))
  filter_upwards [tendsto_natCast_atTop_atTop.eventually h, eventually_ge_atTop (2 : ℕ)]
    with n hn hn₂
  have hnpos : 0 < n := by omega
  have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn₂
  have hlog : Real.log 2 ≤ Real.log n := Real.log_le_log (by norm_num) hn'
  have hlogn : 0 ≤ Real.log n := Real.log_nonneg (by linarith)
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg hlogn,
    abs_of_nonneg (by positivity), ← mul_epsSq_eq r n hr hnpos] at hn
  rw [Real.log_mul (by norm_num) (by positivity)]
  linarith

end BQTF.Asym
