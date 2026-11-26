import BQTF.Asym.ShellRates
import BQTF.SplineApprox

/-! Deterministic sample-size bounds for localization. -/

open Filter
open scoped Topology

namespace BQTF.Asym

theorem Tn_eq (k n : ℕ) (hn : 0 < n) (c : ℝ) (_hc : 0 < c) :
    Tn (k + 1) n (lamSeq c k n) = (4 / c) * Real.sqrt n := by
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  unfold Tn lamSeq
  rw [← Real.rpow_natCast, Real.sqrt_eq_rpow]
  have he : (((k + 1 : ℕ) : ℝ) - (2 * k + 1) / 2) = 1 / 2 := by push_cast; ring
  rw [← he, Real.rpow_sub hn']
  ring

private theorem tendsto_nat_log_div_pow (b p : ℝ) (hb : 0 < b) :
    Tendsto (fun n : ℕ => Real.log (n : ℝ) ^ p / (n : ℝ) ^ b) atTop (𝓝 0) :=
  ((isLittleO_log_rpow_rpow_atTop p hb).tendsto_div_nhds_zero).comp
    tendsto_natCast_atTop_atTop

private theorem rpow_log_nonneg {n : ℕ} (hn : 1 ≤ n) :
    0 ≤ Real.log (n : ℝ) := Real.log_nonneg (by exact_mod_cast hn)

theorem rhoSq_tendsto_zero (r : ℕ) (hr : 2 ≤ r) :
    Tendsto (fun n : ℕ => rhoSq r n) atTop (𝓝 0) := by
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  let b : ℝ := (2 * r - 1) / (2 * r + 1)
  have hb : 0 < b := div_pos (by linarith) (by linarith)
  refine (tendsto_nat_log_div_pow b 1 hb).congr ?_
  intro n
  unfold rhoSq
  rw [Real.rpow_neg (Nat.cast_nonneg _), Real.rpow_one]
  ring

theorem interpolation_factor_tendsto_zero (k : ℕ) (hk : 1 ≤ k) (c : ℝ) (hc : 0 < c) :
    Tendsto (fun n : ℕ =>
      let r := k + 1
      Real.sqrt (rhoSq r n) +
        Real.sqrt (rhoSq r n) ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) *
          Tn r n (lamSeq c k n) ^ ((1 : ℝ) / (2 * r - 1))) atTop (𝓝 0) := by
  let r := k + 1
  let b : ℝ := (2 * r - 1) / (2 * r + 1)
  let p : ℝ := (2 * r - 2) / (2 * r - 1)
  let q : ℝ := 1 / (2 * r - 1)
  have hr : 2 ≤ r := by dsimp [r]; omega
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  let d := b * (p / 2) - q / 2
  have hd : 0 < d := by
    dsimp [d, b, p, q]
    have hden : (0 : ℝ) < 2 * r - 1 := by linarith
    have h₁ : (0 : ℝ) < 2 * (2 * r + 1) * (2 * r - 1) := by positivity
    apply (mul_pos_iff_of_pos_right h₁).mp
    have he : ((2 * r - 1) / (2 * r + 1) * ((2 * r - 2) / (2 * r - 1) / 2) -
        1 / (2 * r - 1) / 2) * (2 * (2 * r + 1) * (2 * r - 1)) =
        4 * (r : ℝ) * (r - 2) + 1 := by
      field_simp [hden.ne']
      ring
    rw [he]
    nlinarith [mul_nonneg (show (0 : ℝ) ≤ r by positivity) (show 0 ≤ (r : ℝ) - 2 by linarith)]
  have hroot : Tendsto (fun n : ℕ => Real.sqrt (rhoSq r n)) atTop (𝓝 0) := by
    simpa using (rhoSq_tendsto_zero r hr).sqrt
  have hprod : Tendsto (fun n : ℕ => Real.sqrt (rhoSq r n) ^ p *
      Tn r n (lamSeq c k n) ^ q) atTop (𝓝 0) := by
    have h : Tendsto
        (fun n : ℕ => (4 / c) ^ q * (Real.log (n : ℝ) ^ (p / 2) / (n : ℝ) ^ d))
        atTop (𝓝 0) := by
      simpa using (tendsto_nat_log_div_pow d (p / 2) hd).const_mul ((4 / c) ^ q)
    refine h.congr' ?_
    filter_upwards [eventually_ge_atTop (2 : ℕ)] with n hn
    have hn₀ : 0 < n := by omega
    have hn' : 0 < (n : ℝ) := by exact_mod_cast hn₀
    have hlog := rpow_log_nonneg (show 1 ≤ n by omega)
    change _ = Real.sqrt (rhoSq r n) ^ p * Tn (k + 1) n (lamSeq c k n) ^ q
    rw [Tn_eq k n hn₀ c hc]
    unfold rhoSq
    change _ = Real.sqrt ((n : ℝ) ^ (-b) * Real.log n) ^ p *
      ((4 / c) * Real.sqrt n) ^ q
    have hs : Real.sqrt ((n : ℝ) ^ (-b) * Real.log n) ^ p =
        (n : ℝ) ^ (-b * (p / 2)) * Real.log n ^ (p / 2) := by
      rw [Real.sqrt_eq_rpow, ← Real.rpow_mul (by positivity),
        show (1 / 2 : ℝ) * p = p / 2 by ring, Real.mul_rpow (by positivity) hlog,
        ← Real.rpow_mul hn'.le]
    have ht : ((4 / c) * Real.sqrt n) ^ q =
        (4 / c) ^ q * (n : ℝ) ^ (1 / 2 * q) := by
      rw [Real.mul_rpow (by positivity) (Real.sqrt_nonneg _), Real.sqrt_eq_rpow,
        ← Real.rpow_mul hn'.le]
    have he : -b * (p / 2) + (1 / 2 : ℝ) * q = -d := by dsimp [d]; ring
    rw [hs, ht, div_eq_mul_inv (Real.log ↑n ^ (p / 2)), ← Real.rpow_neg hn'.le, ← he,
      Real.rpow_add hn']
    ring
  simpa [r, p, q] using hroot.add hprod


theorem eventually_width_bound (k : ℕ) (hk : 1 ≤ k) (c fl : ℝ) (hc : 0 < c) (hfl : 0 < fl) :
    ∀ᶠ n : ℕ in atTop,
      let r := k + 1
      let ρ := Real.sqrt (rhoSq r n)
      let T := Tn r n (lamSeq c k n)
      r < n ∧ 0 < ρ ∧ 0 < T ∧
      ∃ J : ℕ, 1 ≤ J ∧ J ≤ n - r ∧
        Real.sqrt n * (ρ * Real.sqrt (J + (r : ℝ)) +
          2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T *
            (J : ℝ) ^ (-((r : ℝ) - 1 / 2))) ≤ fl / 32 * n * rhoSq r n := by
  let r := k + 1
  let a : ℝ := 2 / (2 * r + 1)
  let C : ℝ := Real.sqrt (2 + (r : ℝ)) + 2 ^ r * cF r * 2 * (4 / c)
  have hr : 2 ≤ r := by dsimp [r]; omega
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have ha : 0 < a := by dsimp [a]; positivity
  have ha' : a < 1 := (div_lt_one (by positivity : 0 < (2 * r + 1 : ℝ))).mpr (by linarith)
  have hcF : 0 ≤ cF r := by unfold cF cInf; positivity
  have hC : 0 ≤ C := by dsimp [C]; positivity
  have hvanish : ∀ᶠ n : ℕ in atTop, (n : ℝ) ^ (- (1 - a)) ≤ 1 / 2 := by
    exact (((tendsto_rpow_neg_atTop (sub_pos.mpr ha')).comp tendsto_natCast_atTop_atTop).eventually
      (eventually_le_nhds (by norm_num)))
  have hlogLarge : ∀ᶠ n : ℕ in atTop, (32 * C / fl) ^ 2 ≤ Real.log n :=
    (Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop).eventually_ge_atTop _
  filter_upwards [hvanish, hlogLarge, eventually_ge_atTop (2 * (r + 1))]
    with n hnsmall hnlog hn
  have hn₂ : 2 ≤ n := by omega
  have hnr : r < n := by omega
  have hn₀ : 0 < n := by omega
  have hnr' : (2 * ((r : ℝ) + 1)) ≤ n := by exact_mod_cast hn
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn₀
  have hn₂' : (2 : ℝ) ≤ n := by exact_mod_cast hn₂
  have hlog : 0 < Real.log n := Real.log_pos (by linarith)
  let X := (n : ℝ) ^ a
  let ℓ := Real.sqrt (Real.log n)
  let ρ := Real.sqrt (rhoSq r n)
  let T := Tn r n (lamSeq c k n)
  let J := ⌈X⌉₊
  have hX : 1 ≤ X := Real.one_le_rpow (by linarith) ha.le
  have hX' : 0 < X := zero_lt_one.trans_le hX
  have hℓ : 0 < ℓ := Real.sqrt_pos.2 hlog
  have hJ : X ≤ J := Nat.le_ceil _
  have hJ' : (J : ℝ) ≤ X + 1 := (Nat.ceil_lt_add_one (zero_le_one.trans hX)).le
  have hXn : X ≤ n / 2 := by
    have he : X = (n : ℝ) * (n : ℝ) ^ (-(1 - a)) := by
      dsimp [X]
      conv_rhs => lhs; rw [← Real.rpow_one (n : ℝ)]
      rw [← Real.rpow_add hn']
      congr 1
      ring
    rw [he, div_eq_mul_inv]
    have h : (n : ℝ) ^ (-(1 - a)) ≤ (2 : ℝ)⁻¹ := by simpa [one_div] using hnsmall
    exact mul_le_mul_of_nonneg_left h hn'.le
  have hJm : J ≤ n - r := by
    have hrt : r ≤ n := hnr.le
    have hh : (J : ℝ) ≤ ((n - r : ℕ) : ℝ) := by
      rw [Nat.cast_sub hrt]
      linarith
    exact_mod_cast hh
  have hJpos : 1 ≤ J := by exact_mod_cast (hX.trans hJ)
  have he : rhoSq r n = (n : ℝ) ^ (a - 1) * Real.log n := by
    unfold rhoSq
    congr 2
    dsimp [a]
    field_simp
    ring
  have hρSq : 0 < rhoSq r n := by rw [he]; positivity
  have hρ : 0 < ρ := Real.sqrt_pos.2 hρSq
  have hT : 0 < T := by dsimp [T]; rw [Tn_eq k n hn₀ c hc]; positivity
  have hlog₂ : Real.sqrt (Real.log (2 * n)) ≤ 2 * ℓ := by
    rw [Real.log_mul (by norm_num) hn'.ne']
    apply (sq_le_sq₀ (Real.sqrt_nonneg _) (by positivity)).mp
    rw [Real.sq_sqrt (by positivity : 0 ≤ Real.log 2 + Real.log ↑n), mul_pow,
      show ℓ ^ 2 = Real.log n from Real.sq_sqrt hlog.le]
    linarith [Real.log_le_log (by norm_num : (0 : ℝ) < 2) hn₂']
  have hℓLarge : 32 * C / fl ≤ ℓ := by
    apply (sq_le_sq₀ (by positivity) hℓ.le).mp
    rw [show ℓ ^ 2 = Real.log n from Real.sq_sqrt hlog.le]
    exact hnlog
  have hRho : Real.sqrt n * ρ = Real.sqrt X * ℓ := by
    dsimp [ρ, ℓ]
    rw [he, Real.sqrt_mul (by positivity), ← mul_assoc, ← Real.sqrt_mul hn'.le]
    congr 2
    conv_lhs => lhs; rw [← Real.rpow_one (n : ℝ)]
    rw [← Real.rpow_add hn']
    congr 1
    ring
  have hFirst : Real.sqrt n * (ρ * Real.sqrt (J + (r : ℝ))) ≤
      Real.sqrt (2 + (r : ℝ)) * X * ℓ := by
    have hjr : (J : ℝ) + r ≤ (2 + (r : ℝ)) * X := by
      nlinarith [mul_nonneg (show 0 ≤ (r : ℝ) + 1 by positivity) (sub_nonneg.mpr hX)]
    rw [← mul_assoc, hRho]
    calc
      _ ≤ (Real.sqrt X * ℓ) * Real.sqrt ((2 + (r : ℝ)) * X) :=
        mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hjr) (by positivity)
      _ = _ := by
        rw [Real.sqrt_mul (by positivity : 0 ≤ 2 + (r : ℝ))]
        have hh := Real.sq_sqrt hX'.le
        nlinarith only [congrArg (fun z => z * ℓ * Real.sqrt (2 + (r : ℝ))) hh]
  let e : ℝ := -((r : ℝ) - 1 / 2)
  have hen : e ≤ 0 := by dsimp [e]; linarith
  have hScale : (n : ℝ) * X ^ e = X := by
    dsimp [X]
    rw [← Real.rpow_mul hn'.le]
    conv_lhs => lhs; rw [← Real.rpow_one (n : ℝ)]
    rw [← Real.rpow_add hn']
    congr 1
    dsimp [a, e]
    field_simp
    ring
  have hSecond : Real.sqrt n * (2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T *
        (J : ℝ) ^ e) ≤ (2 ^ r * cF r * 2 * (4 / c)) * X * ℓ := by
    have hp := Real.rpow_le_rpow_of_nonpos hX' hJ hen
    calc
      _ ≤ Real.sqrt n * (2 ^ r * cF r * (2 * ℓ) * T * X ^ e) := by gcongr
      _ = _ := by
        dsimp [T]
        rw [Tn_eq k n hn₀ c hc]
        calc
          _ = (2 ^ r * cF r * 2 * (4 / c)) * ((Real.sqrt n) ^ 2 * X ^ e) * ℓ := by ring
          _ = _ := by rw [Real.sq_sqrt hn'.le, hScale]
  refine ⟨hnr, hρ, hT, J, hJpos, hJm, ?_⟩
  change Real.sqrt n * (ρ * Real.sqrt (J + (r : ℝ)) +
    2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T * (J : ℝ) ^ e) ≤ _
  rw [mul_add]
  have hmul : C ≤ fl / 32 * ℓ := by
    have h := (div_le_iff₀ hfl).mp hℓLarge
    linarith
  have hsum : Real.sqrt (2 + (r : ℝ)) * X * ℓ +
      (2 ^ r * cF r * 2 * (4 / c)) * X * ℓ = C * X * ℓ := by dsimp [C]; ring
  apply (add_le_add hFirst hSecond).trans
  rw [hsum]
  calc
    _ ≤ (fl / 32 * ℓ) * X * ℓ :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hmul hX'.le) hℓ.le
    _ = _ := by
      have hnrho : (n : ℝ) * rhoSq r n = X * ℓ ^ 2 := by
        rw [he, show ℓ ^ 2 = Real.log n from Real.sq_sqrt hlog.le, ← mul_assoc]
        conv_lhs => lhs; lhs; rw [← Real.rpow_one (n : ℝ)]
        rw [← Real.rpow_add hn']
        dsimp [X]
        rw [show 1 + (a - 1) = a by ring]
      change _ = fl / 32 * n * rhoSq r n
      rw [mul_assoc (fl / 32) (n : ℝ), hnrho]
      ring


theorem eventually_radial_bounds (k : ℕ) (hk : 1 ≤ k) (c fl Vb CE : ℝ)
    (_hc : 0 < c) (hfl : 0 < fl) :
    ∀ᶠ n : ℕ in atTop,
      let r := k + 1
      let ρ := Real.sqrt (rhoSq r n)
      let ε := Real.sqrt (epsSq r n)
      let α := fl / 4 * n * rhoSq r n
      let x := (n : ℝ) * epsSq r n
      0 < ρ ∧ 0 < ε ∧
      c * Vb / (4 * Real.sqrt n) ≤ 1 / 2 ∧ α + 1 ≤ n / 32 ∧
      2 * Real.sqrt n * ρ / α ≤ Real.sqrt n * ε / 2 ∧ CE * x ≤ α / 4 ∧
      (Real.sqrt n * ρ) ^ r * Real.exp (CE * x) ≤
        (Real.sqrt n * ε / 2) ^ r * Real.exp (n / 8) := by
  let r := k + 1
  have hr : 2 ≤ r := by dsimp [r]; omega
  have hE := epsSq_eventually_le r (by omega) (1 / (16 * (1 + max 0 CE))) (by positivity)
  have hR := (rhoSq_tendsto_zero r hr).eventually
    (eventually_le_nhds (show 0 < min 1 (1 / (16 * fl)) by positivity))
  obtain ⟨N, hN⟩ := eventually_mul_epsSq_ge r (by omega) (16 / fl)
  have hlog := (Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop).eventually_ge_atTop
    (max 1 (16 * max 0 CE / fl))
  have hsmallLog : ∀ᶠ n : ℕ in atTop, Real.log (2 * n) ≤ 1 / (16 * r) * n := by
    have h := (isLittleO_log_rpow_atTop (by norm_num : 0 < (1 : ℝ))).def
      (show 0 < 1 / (32 * r : ℝ) by positivity)
    filter_upwards [tendsto_natCast_atTop_atTop.eventually h, eventually_ge_atTop (2 : ℕ)]
      with n h hn
    have hn' : (2 : ℝ) ≤ n := by exact_mod_cast hn
    have hLog0 : 0 ≤ Real.log (n : ℝ) := Real.log_nonneg (by linarith)
    simp only [Real.norm_eq_abs, abs_of_nonneg hLog0, Real.rpow_one,
      abs_of_nonneg (show (0 : ℝ) ≤ n by positivity)] at h
    rw [Real.log_mul (by norm_num) (by positivity)]
    have hh := Real.log_le_log (by norm_num : (0 : ℝ) < 2) hn'
    have he : 2 * (1 / (32 * r : ℝ) * n) = 1 / (16 * r : ℝ) * n := by field_simp; norm_num
    linarith only [h, hh, he]
  have hV : ∀ᶠ n : ℕ in atTop, c * Vb ≤ 2 * Real.sqrt n := by
    have h := ((tendsto_rpow_atTop (y := (1 / 2 : ℝ)) (by norm_num)).comp
      tendsto_natCast_atTop_atTop).eventually_ge_atTop (c * Vb / 2)
    filter_upwards [h] with n h
    change c * Vb / 2 ≤ (n : ℝ) ^ (1 / 2 : ℝ) at h
    rw [← Real.sqrt_eq_rpow] at h
    linarith
  filter_upwards [hE, hR, eventually_ge_atTop (max 64 N), hlog, hsmallLog, hV]
    with n he hρmax hn hlog hsmallLog hV
  let ρ := Real.sqrt (rhoSq r n)
  let ε := Real.sqrt (epsSq r n)
  let α := fl / 4 * n * rhoSq r n
  let x := (n : ℝ) * epsSq r n
  have hn₀ : 0 < n := by omega
  have hn₆₄ : (64 : ℝ) ≤ n := by exact_mod_cast (show 64 ≤ n by omega)
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn₀
  have hεSq : 0 < epsSq r n := Real.rpow_pos_of_pos hn' _
  have hε : 0 < ε := Real.sqrt_pos.2 hεSq
  have hcomparison : epsSq r n * Real.log n ≤ rhoSq r n := by
    have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
    unfold epsSq rhoSq
    apply mul_le_mul_of_nonneg_right _ (Real.log_nonneg (by linarith))
    apply Real.rpow_le_rpow_of_exponent_le (by linarith)
    exact neg_le_neg (div_le_div_of_nonneg_left (by linarith) (by linarith) (by linarith))
  have hlog₁ : 1 ≤ Real.log n := (le_max_left _ _).trans hlog
  have hεR : ε ≤ ρ := Real.sqrt_le_sqrt ((le_mul_of_one_le_right hεSq.le hlog₁).trans hcomparison)
  have hρ : 0 < ρ := hε.trans_le hεR
  have hρSq : 0 < rhoSq r n := hεSq.trans_le
    ((le_mul_of_one_le_right hεSq.le hlog₁).trans hcomparison)
  have hα : 0 < α := by dsimp [α]; positivity
  have hC : CE ≤ max 0 CE := le_max_right _ _
  have hx : 0 < x := mul_pos hn' hεSq
  have hαC : CE * x ≤ α / 4 := by
    have hl : 16 * max 0 CE / fl ≤ Real.log n := (le_max_right _ _).trans hlog
    have hh := (div_le_iff₀ hfl).mp hl
    have hCE := mul_le_mul_of_nonneg_right hC hx.le
    have hCompare := mul_le_mul_of_nonneg_left hcomparison (show 0 ≤ fl / 16 * n by positivity)
    have hConst := mul_le_mul_of_nonneg_right hh hx.le
    dsimp [x, α] at *
    nlinarith only [hCE, hCompare, hConst]
  have hCsmall : CE * x ≤ n / 16 := by
    have hh := (le_div_iff₀ (show 0 < 16 * (1 + max 0 CE) by positivity)).mp he
    have h₁ := mul_le_mul_of_nonneg_right hC hx.le
    have h₂ := mul_le_mul_of_nonneg_right hh hn'.le
    dsimp [x] at *
    nlinarith [mul_nonneg hn'.le hεSq.le]
  have hαsmall : α + 1 ≤ n / 32 := by
    have hh := (le_div_iff₀ (show 0 < 16 * fl by positivity)).mp (hρmax.trans (min_le_right _ _))
    dsimp [α]
    nlinarith only [mul_le_mul_of_nonneg_right hh hn'.le, hn₆₄]
  have hA1 : 2 * Real.sqrt n * ρ / α ≤ Real.sqrt n * ε / 2 := by
    rw [div_le_iff₀ hα]
    have hl : (16 : ℝ) ≤ x * fl := (div_le_iff₀ hfl).mp (hN n (by omega : N ≤ n)).2
    have hprod : (16 : ℝ) ≤ fl * n * (ε * ρ) := by
      have hh := mul_le_mul_of_nonneg_left hεR hε.le
      rw [← pow_two, show ε ^ 2 = epsSq r n from Real.sq_sqrt hεSq.le] at hh
      have ht := mul_le_mul_of_nonneg_left hh (show 0 ≤ fl * n by positivity)
      dsimp [x] at hl
      nlinarith only [hl, ht]
    have hrho : ρ ^ 2 = rhoSq r n := Real.sq_sqrt hρSq.le
    dsimp [α]
    rw [← hrho]
    nlinarith only [mul_le_mul_of_nonneg_right hprod
      (show 0 ≤ Real.sqrt n * ρ by positivity)]
  have hA2 : (Real.sqrt n * ρ) ^ r * Real.exp (CE * x) ≤
      (Real.sqrt n * ε / 2) ^ r * Real.exp (n / 8) := by
    have hρ₁ : ρ ≤ 1 := by simpa [ρ] using Real.sqrt_le_sqrt (hρmax.trans (min_le_left _ _))
    have he_inv : (n : ℝ)⁻¹ ≤ ε := by
      have hpow : (n : ℝ) ^ (-2 : ℝ) ≤ epsSq r n := by
        unfold epsSq
        apply Real.rpow_le_rpow_of_exponent_le (by linarith)
        have hrp : (0 : ℝ) < 2 * r := by positivity
        have hq : (2 * r - 1 : ℝ) / (2 * r) ≤ 2 := (div_le_iff₀ hrp).mpr (by linarith)
        linarith
      apply (sq_le_sq₀ (by positivity) hε.le).mp
      simpa only [Real.rpow_neg hn'.le, Real.rpow_two, inv_pow,
        show ε ^ 2 = epsSq r n from Real.sq_sqrt hεSq.le] using hpow
    have hrte : ρ ≤ n * ε := by
      refine hρ₁.trans ?_
      have hh := mul_le_mul_of_nonneg_left he_inv hn'.le
      simpa [hn'.ne'] using hh
    have hprod : Real.sqrt n * ρ ≤ (Real.sqrt n * ε / 2) * (2 * n) := by
      nlinarith only [mul_le_mul_of_nonneg_left hrte (Real.sqrt_nonneg n)]
    have hlogexp : (2 * n : ℝ) ^ r ≤ Real.exp (n / 16) := by
      rw [← Real.exp_log (show (0 : ℝ) < 2 * n by positivity), ← Real.exp_nat_mul]
      apply Real.exp_le_exp.mpr
      have hh := mul_le_mul_of_nonneg_left hsmallLog (show (0 : ℝ) ≤ r by positivity)
      have heq : (r : ℝ) * (1 / (16 * r) * n) = n / 16 := by field_simp
      exact hh.trans_eq heq
    calc
      _ ≤ ((Real.sqrt n * ε / 2) * (2 * n)) ^ r * Real.exp (CE * x) :=
        mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (by positivity) hprod _) (Real.exp_nonneg _)
      _ ≤ (Real.sqrt n * ε / 2) ^ r * (Real.exp (n / 16) * Real.exp (n / 16)) := by
        rw [mul_pow, mul_assoc]
        exact mul_le_mul_of_nonneg_left
          (mul_le_mul hlogexp (Real.exp_le_exp.mpr hCsmall) (Real.exp_nonneg _) (Real.exp_nonneg _))
          (by positivity)
      _ = _ := by rw [← Real.exp_add]; congr 2; ring
  refine ⟨hρ, hε, ?_, hαsmall, hA1, hαC, hA2⟩
  rw [div_le_iff₀ (by positivity)]
  linarith

end BQTF.Asym
