import BQTF.SmallBall
import BQTF.QuadShift
import BQTF.Smooth
import BQTF.Prior.Window

/-!
# Prior mass (appendix, Proposition `pf:prop:prior`)

Combines the centered small-ball bound, the quadratic shift, and the smoothed truth.
-/

open Filter MeasureTheory
open scoped ENNReal

noncomputable section

namespace BQTF

private theorem smallBall_rate_bound (r n : ℕ) (hr : 2 ≤ r) (hn : r < n)
    {c Csb d : ℝ} (hc : 0 < c) (hCsb : 0 < Csb) (hd : 0 < d)
    (hsb : ∀ n : ℕ, r < n → ∀ lam ϱ : ℝ, 0 < lam → 0 < ϱ →
      ENNReal.ofReal (Real.exp (-(Csb * (1 + ((n : ℝ) ^ ((r : ℝ) - 1 / 2) / (lam * ϱ)) ^
        smoothingPower r)))) ≤ Qlam (n - r) lam (Bsb r n ϱ)) :
    let lam := c * (n : ℝ) ^ ((r : ℝ) - 1 / 2)
    let ε := Real.sqrt (epsSq r n)
    ENNReal.ofReal (Real.exp (-(Csb * (1 + (d / c) ^ smoothingPower r) * priorBudget r n))) ≤
      Qlam (n - r) lam (Bsb r n (ε / d)) := by
  intro lam ε
  have hn₀ : 0 < n := by omega
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn₀
  have hε : 0 < ε := by unfold ε epsSq; positivity
  have hlam : 0 < lam := by dsimp [lam]; positivity
  have hratio : (n : ℝ) ^ ((r : ℝ) - 1 / 2) / (lam * (ε / d)) = (d / c) / ε := by
    have hp : (n : ℝ) ^ ((r : ℝ) - 1 / 2) ≠ 0 := by positivity
    dsimp [lam]
    field_simp
  have hpow : ((n : ℝ) ^ ((r : ℝ) - 1 / 2) / (lam * (ε / d))) ^ smoothingPower r =
      (d / c) ^ smoothingPower r * priorBudget r n := by
    rw [hratio, Real.div_rpow (div_nonneg hd.le hc.le) hε.le,
      show ε ^ smoothingPower r = (priorBudget r n)⁻¹ from eps_smoothingPower r n hr,
      div_inv_eq_mul]
  refine le_trans (ENNReal.ofReal_le_ofReal (Real.exp_le_exp.mpr (neg_le_neg ?_)))
    (hsb n hn lam (ε / d) hlam (div_pos hε hd))
  rw [hpow, mul_assoc]
  apply mul_le_mul_of_nonneg_left _ hCsb.le
  rw [add_mul, one_mul]
  exact add_le_add_left (priorBudget_ge_one r n hn₀) _

private theorem neg_log_toReal_le {a : ℝ} {p : ℝ≥0∞} (ha : 0 ≤ a)
    (hp : ENNReal.ofReal (Real.exp (-a)) ≤ p) : -Real.log p.toReal ≤ a := by
  by_cases ht : p = ∞
  · simpa [ht] using ha
  have hp' := ENNReal.toReal_mono ht hp
  rw [ENNReal.toReal_ofReal (Real.exp_nonneg _)] at hp'
  have hlog := Real.log_le_log (Real.exp_pos _) hp'
  rw [Real.log_exp] at hlog
  linarith

/-- Proposition `pf:prop:prior`: with `λ = c n^{r−1/2}` and `V* ≤ V̄`, there is `n₁` depending
only on `(c, V̄, r)` such that for `n ≥ n₁` there is `u°` with `‖P^⊥ S(u* − u°)‖_n ≤ ε_n/2` and
`−log Q_λ(u° + B_{ε_n/2}) ≤ C_pr n ε_n²`. The constant `C_pr` is existential here, with the
paper's dependence `(c, V̄, r)` (its explicit value is not needed for Theorem `thm:main`). -/
theorem prior_mass (k : ℕ) (hk : 1 ≤ k) (c Vb : ℝ) (hc : 0 < c) :
    ∃ Cpr : ℝ, ∃ n₁ : ℕ, 0 < Cpr ∧ k + 1 < n₁ ∧ ∀ n, n₁ ≤ n → ∀ θs : Fin n → ℝ,
      TVr (k + 1) n θs ≤ Vb →
      ∃ u0 : Fin (n - (k + 1)) → ℝ,
        empNorm (Pperp (k + 1) n (Smul (k + 1) n (ustar (k + 1) n θs - u0)))
          ≤ Real.sqrt (epsSq (k + 1) n) / 2 ∧
        ENNReal.ofReal (Real.exp (-(Cpr * n * epsSq (k + 1) n)))
          ≤ Qlam (n - (k + 1)) (lamSeq c k n)
              {u | u - u0 ∈ Bsb (k + 1) n (Real.sqrt (epsSq (k + 1) n) / 2)} := by
  let r := k + 1
  have hr : 2 ≤ r := by dsimp [r]; omega
  obtain ⟨Csb, hCsb, hsb⟩ := small_ball r hr
  obtain ⟨U, NW, hU, hW⟩ := prior_smoothed_window r hr c Vb hc
  let C₂ := Csb * (1 + (2 / c) ^ smoothingPower r)
  let C₈ := Csb * (1 + (8 / c) ^ smoothingPower r)
  have hC₂ : 0 < C₂ := by dsimp [C₂]; positivity
  have hC₈ : 0 < C₈ := by dsimp [C₈]; positivity
  -- The proposition needs a uniform shift constant, so a bound on K suffices.
  let Kmax := 4 * C₈ * (2 / c)
  let D := 1 - Real.exp (-2)
  have hD : 0 < D := by
    dsimp [D]
    rw [sub_pos, ← Real.exp_zero]
    exact Real.exp_lt_exp.mpr (by norm_num)
  let H := (1 + Kmax / 2) / D
  have hH : 0 < H := by dsimp [H, Kmax]; positivity
  obtain ⟨NK, hNK⟩ := eventually_atTop.mp
    ((priorBudget_tendsto r (by omega)).eventually_ge_atTop (4 / c))
  let n₁ := max (r + 2) (max NW NK)
  have hn₁ : r + 2 ≤ n₁ := le_max_left _ _
  refine ⟨C₂ + H * U, n₁, by positivity, by omega, ?_⟩
  intro n hn θs hTV
  have hnr : r < n := by omega
  have hm : 2 ≤ n - r := by omega
  have hn₀ : 0 < n := by omega
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn₀
  have hnW : NW ≤ n := (le_max_left _ _).trans ((le_max_right _ _).trans hn)
  have hnK : NK ≤ n := (le_max_right _ _).trans ((le_max_right _ _).trans hn)
  obtain ⟨u₀, hu, hu_cost⟩ := hW n hnW hnr θs hTV
  let s := priorBudget r n
  let lam := c * (n : ℝ) ^ ((r : ℝ) - 1 / 2)
  let ε := Real.sqrt (epsSq r n)
  let ϱ := ε / 2
  let A := priorMatrix r n
  let δ := deltaA A
  have hs : 0 < s := lt_of_lt_of_le zero_lt_one (priorBudget_ge_one r n hn₀)
  have hlam : 0 < lam := by dsimp [lam]; positivity
  have hε : 0 < ε := by unfold ε epsSq; positivity
  have hϱ : 0 < ϱ := by dsimp [ϱ]; positivity
  have hlamϱ : 0 < lam * ϱ := mul_pos hlam hϱ
  have hball : ENNReal.ofReal (Real.exp (-(C₂ * s))) ≤ Qlam (n - r) lam (BA A ϱ) := by
    rw [BA_priorMatrix]
    exact smallBall_rate_bound r n hr hnr hc hCsb (by norm_num : (0 : ℝ) < 2) hsb
  have hball₈ : ENNReal.ofReal (Real.exp (-(C₈ * s))) ≤ Qlam (n - r) lam (BA A (ϱ / 4)) := by
    rw [BA_priorMatrix, show ϱ / 4 = ε / 8 by dsimp [ϱ]; ring]
    exact smallBall_rate_bound r n hr hnr hc hCsb (by norm_num : (0 : ℝ) < 8) hsb
  have hpos : 0 < Qlam (n - r) lam (BA A (ϱ / 4)) :=
    (ENNReal.ofReal_pos.mpr (Real.exp_pos _)).trans_le hball₈
  have ⟨hδ₀, hδn⟩ := deltaA_priorMatrix r n hr hm
  have hδs : δ * s ≤ (2 / c) * (lam * ϱ) := by
    calc
      _ ≤ (n : ℝ) ^ (r - 2) * s := mul_le_mul_of_nonneg_right hδn hs.le
      _ ≤ (n : ℝ) ^ ((r : ℝ) - 1 / 2) * ε := priorBudget_delta_bound r n hr hn₀
      _ = _ := by dsimp [lam, ϱ]; field_simp
  have hδ : δ ≤ lam * ϱ / 2 := by
    apply (mul_le_mul_iff_left₀ hs).mp
    calc
      _ ≤ (2 / c) * (lam * ϱ) := hδs
      _ = (lam * ϱ / 2) * (4 / c) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left (hNK n hnK) (by positivity)
  let φ := -Real.log (Qlam (n - r) lam (BA A (ϱ / 4))).toReal
  have hφ : φ ≤ C₈ * s := neg_log_toReal_le (by positivity) hball₈
  have hK : 4 * δ * φ / (lam * ϱ) ≤ Kmax := by
    apply (div_le_iff₀ hlamϱ).mpr
    calc
      _ ≤ 4 * δ * (C₈ * s) := mul_le_mul_of_nonneg_left hφ (by positivity)
      _ = 4 * C₈ * (δ * s) := by ring
      _ ≤ 4 * C₈ * ((2 / c) * (lam * ϱ)) := mul_le_mul_of_nonneg_left hδs (by positivity)
      _ = _ := by unfold Kmax; ring
  let cK := (1 + (4 * δ * φ / (lam * ϱ)) / 2) / D
  have hcK : cK ≤ H := by
    dsimp [cK, H]
    gcongr
  have hl2 : 0 ≤ l2sq u₀ := Finset.sum_nonneg fun i _ => sq_nonneg (u₀ i)
  have hshift_cost : cK * lam ^ 2 * l2sq u₀ ≤ H * U * s := by
    calc
      _ ≤ H * lam ^ 2 * l2sq u₀ :=
        mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hcK (sq_nonneg _)) hl2
      _ ≤ _ := by rw [mul_assoc, mul_assoc]; exact mul_le_mul_of_nonneg_left hu_cost hH.le
  have hshift := quad_shift hm A lam ϱ hlam hϱ hpos hδ u₀
  change Qlam (n - r) lam (BA A ϱ) * ENNReal.ofReal (Real.exp (-(cK * lam ^ 2 * l2sq u₀)))
      ≤ Qlam (n - r) lam {u | u - u₀ ∈ BA A ϱ} at hshift
  refine ⟨u₀, hu, ?_⟩
  rw [lamSeq_eq_prior]
  change ENNReal.ofReal (Real.exp (-((C₂ + H * U) * (n : ℝ) * epsSq r n))) ≤
    Qlam (n - r) lam {u | u - u₀ ∈ Bsb r n ϱ}
  rw [mul_assoc, ← priorBudget_eq r n (by omega) hn₀, ← BA_priorMatrix]
  calc
    _ = ENNReal.ofReal (Real.exp (-(C₂ * s))) * ENNReal.ofReal (Real.exp (-(H * U * s))) := by
      rw [← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
      congr 2
      dsimp [s]
      ring
    _ ≤ Qlam (n - r) lam (BA A ϱ) * ENNReal.ofReal (Real.exp (-(cK * lam ^ 2 * l2sq u₀))) := by
      exact mul_le_mul' hball (ENNReal.ofReal_le_ofReal (Real.exp_le_exp.mpr (neg_le_neg hshift_cost)))
    _ ≤ _ := hshift

end BQTF
