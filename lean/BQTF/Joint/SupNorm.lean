import BQTF.Localization
import BQTF.Asym.Rates

/-!
# Supremum-norm concentration (appendix, Lemma `pf:lem:sup`)

Owner: TBD (assigned at the Theorem 2 trigger).

One level, `σ = 1`, in the setting of Theorem `thm:main`:
`s_n = C_I{ρ_n + (ρ_n^{2r−2} T_n)^{1/(2r−1)}}` and `η_n = r!{e^{−f̲ n ρ_n²/16} + e^{−n/8}}`, with
`r = k + 1`, `ρ_n = √(rhoSq r n)`, `T_n = Tn r n λ`, `λ = c n^{(2k+1)/2}`, and `C_I` the constant of
`interp` (depending on `r` only). Then `s_n → 0`, `η_n → 0`, and for `n ≥ n₂` there is an event
`Ω` (the paper's `Ω_E ∩ Ω_G`) with `Π_λ(‖θ − θ*‖_∞ > s_n ∣ y) ≤ η_n` on `Ω` and
`P(Ωᶜ) ≤ (5/4 + 64/f̲²) n^{−1/(2r)}`.

`s_n` is not monotone in `n` (Theory, PLAN §5.5 item 5), so thresholds on it are stated as
eventual conditions (`∀ᶠ n in atTop`), never as checks at one `n`.

`Ω` is existential and not asserted measurable: the paper never uses measurability of
`Ω_E ∩ Ω_G`, and the assembly (`Joint/Transfer`) uses a measurable hull, as `Main` does.

Nonvacuity: `k = 1`, `c = 1`, `L = 1/4`, `f̲ = f̄ = 1`, `V̄ = 0`, `τ = 1/2`, all `μ_i` uniform on
`[0,1]` and `θ* ≡ 1/2` satisfy `DataHyp` for every `n`.
-/

open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal Topology

noncomputable section

namespace BQTF

/-- The sup-norm radius `s_n = C_I{ρ_n + (ρ_n^{2r−2} T_n)^{1/(2r−1)}}` with `r = k + 1`
(so `2r − 2 = 2k`, `2r − 1 = 2k + 1`), `ρ_n = √(rhoSq r n)`, `T_n = Tn r n (lamSeq c k n)`.
Depends only on `(C_I, c, k)`, hence on `(c, r)` once `C_I = C_I(r)` is fixed. -/
def supRad (CI : ℝ) (k : ℕ) (c : ℝ) (n : ℕ) : ℝ :=
  CI * (Real.sqrt (rhoSq (k + 1) n) +
    (Real.sqrt (rhoSq (k + 1) n) ^ (2 * k) * Tn (k + 1) n (lamSeq c k n)) ^
      ((1 : ℝ) / (2 * k + 1)))

/-- `η_n = r!{e^{−f̲ n ρ_n²/16} + e^{−n/8}}` with `r = k + 1` (the bound of `localization`(b)).
Depends only on `(f̲, r)`. -/
def etaSeq (k : ℕ) (fl : ℝ) (n : ℕ) : ℝ :=
  Nat.factorial (k + 1) *
    (Real.exp (-(fl * n * rhoSq (k + 1) n / 16)) + Real.exp (-(n / 8 : ℝ)))

private lemma Tn_lamSeq_eq (k n : ℕ) (hn : 0 < n) (c : ℝ) :
    Tn (k + 1) n (lamSeq c k n) = (4 / c) * (n : ℝ) ^ ((1 : ℝ) / 2) := by
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  unfold Tn lamSeq
  rw [← Real.rpow_natCast]
  have he : (((k + 1 : ℕ) : ℝ) - (2 * k + 1 : ℝ) / 2) = 1 / 2 := by push_cast; ring
  rw [← he, Real.rpow_sub hn']
  ring

private lemma tendsto_nat_log_rpow_div_rpow (b p : ℝ) (hb : 0 < b) :
    Tendsto (fun n : ℕ => Real.log (n : ℝ) ^ p / (n : ℝ) ^ b) atTop (𝓝 0) :=
  ((isLittleO_log_rpow_rpow_atTop p hb).tendsto_div_nhds_zero).comp
    tendsto_natCast_atTop_atTop

/-- Lemma `pf:lem:sup`: `s_n → 0` (for `r ≥ 2`, i.e. `k ≥ 1`; any fixed `C_I`). -/
theorem supRad_tendsto (k : ℕ) (hk : 1 ≤ k) (CI c : ℝ) (hc : 0 < c) :
    Tendsto (fun n => supRad CI k c n) atTop (𝓝 0) := by
  have hk' : (1 : ℝ) ≤ k := by exact_mod_cast hk
  let b : ℝ := (2 * (k : ℝ) + 1) / (2 * (k : ℝ) + 3)
  have hb : 0 < b := div_pos (by linarith) (by linarith)
  have hrho_eq : ∀ n : ℕ, rhoSq (k + 1) n = (n : ℝ) ^ (-b) * Real.log (n : ℝ) := by
    intro n
    unfold rhoSq
    congr 2
    dsimp [b]
    push_cast
    ring
  have hrho0 : Tendsto (fun n : ℕ => rhoSq (k + 1) n) atTop (𝓝 0) := by
    refine (tendsto_nat_log_rpow_div_rpow b 1 hb).congr fun n => ?_
    rw [hrho_eq n, Real.rpow_one, Real.rpow_neg (Nat.cast_nonneg _)]
    ring
  have hsqrt0 : Tendsto (fun n : ℕ => Real.sqrt (rhoSq (k + 1) n)) atTop (𝓝 0) := by
    simpa using hrho0.sqrt
  let d : ℝ := (4 * (k : ℝ) ^ 2 - 3) / (2 * (2 * (k : ℝ) + 3))
  have hd : 0 < d := by
    dsimp [d]
    apply div_pos
    · nlinarith
    · linarith
  have hinside0 : Tendsto
      (fun n : ℕ => Real.sqrt (rhoSq (k + 1) n) ^ (2 * k) * Tn (k + 1) n (lamSeq c k n))
      atTop (𝓝 0) := by
    have hbase : Tendsto
        (fun n : ℕ => (4 / c) * (Real.log (n : ℝ) ^ (k : ℝ) / (n : ℝ) ^ d)) atTop (𝓝 0) := by
      simpa using (tendsto_nat_log_rpow_div_rpow d (k : ℝ) hd).const_mul (4 / c)
    refine hbase.congr' ?_
    filter_upwards [eventually_ge_atTop (2 : ℕ)] with n hn
    have hn0 : 0 < n := by omega
    have hn' : 0 < (n : ℝ) := by exact_mod_cast hn0
    have hlog_nn : 0 ≤ Real.log (n : ℝ) := Real.log_nonneg (by exact_mod_cast (show 1 ≤ n by omega))
    have hrho_nn : 0 ≤ rhoSq (k + 1) n := by
      rw [hrho_eq n]
      exact mul_nonneg (Real.rpow_nonneg hn'.le _) hlog_nn
    rw [pow_mul, Real.sq_sqrt hrho_nn, hrho_eq n, mul_pow, Tn_lamSeq_eq k n hn0 c]
    rw [← Real.rpow_natCast ((n : ℝ) ^ (-b)) k, ← Real.rpow_mul hn'.le,
      Real.rpow_natCast (Real.log (n : ℝ)) k]
    have hexp : -b * (k : ℝ) + (1 : ℝ) / 2 = -d := by
      dsimp [b, d]
      have hden : (2 * (k : ℝ) + 3) ≠ 0 := by linarith
      field_simp [hden]
      ring
    calc (4 / c) * (Real.log (n : ℝ) ^ k / (n : ℝ) ^ d)
        = (4 / c) * (Real.log (n : ℝ) ^ k * (n : ℝ) ^ (-d)) := by
          rw [Real.rpow_neg hn'.le]; ring
      _ = (4 / c) * (Real.log (n : ℝ) ^ k * ((n : ℝ) ^ (-b * (k : ℝ)) * (n : ℝ) ^ ((1 : ℝ) / 2))) := by
          rw [← hexp, Real.rpow_add hn']
      _ = (n : ℝ) ^ (-b * (k : ℝ)) * Real.log (n : ℝ) ^ k * ((4 / c) * (n : ℝ) ^ ((1 : ℝ) / 2)) := by
          ring
  have hq : (0 : ℝ) < (1 : ℝ) / (2 * k + 1) := by positivity
  have hpow0 : Tendsto
      (fun n : ℕ =>
        (Real.sqrt (rhoSq (k + 1) n) ^ (2 * k) * Tn (k + 1) n (lamSeq c k n)) ^
          ((1 : ℝ) / (2 * k + 1)))
      atTop (𝓝 0) := by
    have h1 := hinside0.rpow_const (p := (1 : ℝ) / (2 * k + 1)) (Or.inr hq.le)
    rwa [Real.zero_rpow hq.ne'] at h1
  have hsum0 := (hsqrt0.add hpow0).const_mul CI
  simpa only [supRad, add_zero, mul_zero] using hsum0

/-- Lemma `pf:lem:sup`: `η_n → 0`. -/
theorem etaSeq_tendsto (k : ℕ) (fl : ℝ) (hfl : 0 < fl) :
    Tendsto (fun n => etaSeq k fl n) atTop (𝓝 0) := by
  have hrho_atTop : Tendsto (fun n : ℕ => (n : ℝ) * rhoSq (k + 1) n) atTop atTop := by
    rw [tendsto_atTop_atTop]
    intro B
    obtain ⟨N₁, hN₁⟩ := Asym.eventually_mul_epsSq_ge (k + 1) (by omega) B
    obtain ⟨N₂, hN₂⟩ := Asym.eventually_log_ge_one
    refine ⟨max N₁ N₂, fun n hn => ?_⟩
    have hn1 := hN₁ n ((le_max_left _ _).trans hn)
    have hn2 := hN₂ n ((le_max_right _ _).trans hn)
    exact hn1.2.trans (Asym.mul_epsSq_le_mul_rhoSq (k + 1) n (by omega) hn1.1 hn2)
  have harg1 : Tendsto (fun n : ℕ => -(fl * n * rhoSq (k + 1) n / 16)) atTop atBot := by
    rw [tendsto_atTop_atBot]
    intro B
    obtain ⟨N, hN⟩ := tendsto_atTop_atTop.mp hrho_atTop (-16 * B / fl)
    refine ⟨N, fun n hn => ?_⟩
    have h1 := hN n hn
    have h2 := (div_le_iff₀ hfl).mp h1
    linarith
  have harg2 : Tendsto (fun n : ℕ => -(n / 8 : ℝ)) atTop atBot := by
    rw [tendsto_atTop_atBot]
    intro B
    obtain ⟨N, hN⟩ := exists_nat_ge (-8 * B)
    refine ⟨N, fun n hn => ?_⟩
    have h1 : (N : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  have hexp1 : Tendsto (fun n : ℕ => Real.exp (-(fl * n * rhoSq (k + 1) n / 16))) atTop (𝓝 0) :=
    Real.tendsto_exp_atBot.comp harg1
  have hexp2 : Tendsto (fun n : ℕ => Real.exp (-(n / 8 : ℝ))) atTop (𝓝 0) :=
    Real.tendsto_exp_atBot.comp harg2
  have hfull := (hexp1.add hexp2).const_mul (Nat.factorial (k + 1) : ℝ)
  simpa only [etaSeq, add_zero, mul_zero] using hfull

/-- Eventual form of `s_n → 0`: `s_n ≤ g` for all large `n` (PLAN §5.5 item 5). -/
theorem eventually_supRad_le (k : ℕ) (hk : 1 ≤ k) (CI c : ℝ) (hc : 0 < c) (g : ℝ)
    (hg : 0 < g) : ∀ᶠ n in atTop, supRad CI k c n ≤ g :=
  (supRad_tendsto k hk CI c hc).eventually (eventually_le_nhds hg)

/-- Eventual form of `η_n → 0`: `η_n ≤ e` for all large `n`. -/
theorem eventually_etaSeq_le (k : ℕ) (fl : ℝ) (hfl : 0 < fl) (e : ℝ) (he : 0 < e) :
    ∀ᶠ n in atTop, etaSeq k fl n ≤ e :=
  (etaSeq_tendsto k fl hfl).eventually (eventually_le_nhds he)

/-- Lemma `pf:lem:sup` (`σ = 1`). There is `C_I > 0` depending only on `k` (from `interp`) such
that for all constants `c, L, f̲ > 0`, `f̄`, `V̄` there is `n₂ > k + 1` with: for every `n ≥ n₂`,
every `τ ∈ (0,1)` and every law and target satisfying `DataHyp`, some event `Ω` (in the proof,
`Ω_E ∩ Ω_G`) satisfies
* `Π_λ(θ : ‖θ − θ*‖_∞ > s_n ∣ y) ≤ η_n` for every `y ∈ Ω`, and
* `P(Ωᶜ) ≤ (5/4 + 64/f̲²) n^{−1/(2r)}`.
`‖·‖_∞ > s` is written coordinatewise as `∃ i, s < |θ_i − θ*_i|`.

This is the existential consequence of Lemma `pf:lem:sup`. The proof can exhibit
`Ω_E ∩ Ω_G`. Callers receive an existential witness. (So neither the bound on the paper's
particular event nor the identity of `C_I` with a separately chosen `interp` witness can be
recovered from this statement alone; J5–J7 need only the existential version.) -/
theorem supNorm_concentration (k : ℕ) (hk : 1 ≤ k) :
    ∃ CI : ℝ, 0 < CI ∧ ∀ (c L fl fu Vb : ℝ), 0 < c → 0 < L → 0 < fl →
      ∃ n₂ : ℕ, k + 1 < n₂ ∧ ∀ n, n₂ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 →
        ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
          ∃ Ω : Set (Fin n → ℝ),
            (∀ y ∈ Ω, posterior τ 1 (lamSeq c k n) k n y
                {θ | ∃ i, supRad CI k c n < |θ i - θs i|} ≤ ENNReal.ofReal (etaSeq k fl n)) ∧
            Measure.pi μ Ωᶜ ≤ ENNReal.ofReal ((5 / 4 + 64 / fl ^ 2) * massRate k n) := by
  obtain ⟨CI, hCI, hInterp⟩ := interp (k + 1) (by omega)
  refine ⟨CI, hCI, fun c L fl fu Vb hc hL hfl => ?_⟩
  obtain ⟨CE, n₁, _, hn₁, hdenom⟩ := denominator k hk c L fl fu Vb hc hL hfl
  obtain ⟨n₂', _, hloc⟩ := localization k hk c L fl fu Vb hc hL hfl CE
  obtain ⟨nLog, hnLog⟩ := Asym.eventually_log_ge_one
  refine ⟨max n₁ (max n₂' nLog), hn₁.trans_le (le_max_left _ _), ?_⟩
  intro n hn τ hτ₀ hτ₁ μ θs hdata
  have hn1 : n₁ ≤ n := (le_max_left _ _).trans hn
  have hn2 : n₂' ≤ n := ((le_max_left _ _).trans (le_max_right _ _)).trans hn
  have hnlog : 1 ≤ Real.log (n : ℝ) := hnLog n (((le_max_right _ _).trans (le_max_right _ _)).trans hn)
  have hnr : k + 1 < n := hn₁.trans_le hn1
  have hn0 : 0 < n := by omega
  have hE := hdenom n hn1 τ hτ₀ hτ₁ μ θs hdata
  obtain ⟨_, hG, hpost_Kn⟩ := hloc n hn2 τ hτ₀ hτ₁ μ θs hdata
  refine ⟨OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE, ?_, ?_⟩
  · intro y hy
    have hsub : {θ : Fin n → ℝ | ∃ i, supRad CI k c n < |θ i - θs i|} ⊆
        {θ : Fin n → ℝ | θ - θs ∉ Kn k n c} := by
      intro θ hθ hmem
      rcases hθ with ⟨i, hi⟩
      have hδ : empNorm (θ - θs) ≤ Real.sqrt (rhoSq (k + 1) n) ∧
          TVr (k + 1) n (θ - θs) ≤ Tn (k + 1) n (lamSeq c k n) := hmem
      have hemp_nn : 0 ≤ empNorm (θ - θs) := Real.sqrt_nonneg _
      have hTV_nn : 0 ≤ TVr (k + 1) n (θ - θs) := by
        unfold TVr l1norm
        exact mul_nonneg (pow_nonneg (Nat.cast_nonneg n) _)
          (Finset.sum_nonneg fun j _ => abs_nonneg _)
      have hrho_nn : 0 ≤ Real.sqrt (rhoSq (k + 1) n) := Real.sqrt_nonneg _
      have hTn_nn : 0 ≤ Tn (k + 1) n (lamSeq c k n) := by
        rw [Tn_lamSeq_eq k n hn0 c]
        exact mul_nonneg (div_nonneg (by norm_num) hc.le) (Real.rpow_nonneg (Nat.cast_nonneg n) _)
      have hq_nn : (0 : ℝ) ≤ (1 : ℝ) / (2 * (k : ℝ) + 1) := by positivity
      have hp_nn : (0 : ℝ) ≤ (2 * (k : ℝ)) / (2 * (k : ℝ) + 1) := by positivity
      have hexp1 : (2 * ((k + 1 : ℕ) : ℝ) - 2) / (2 * ((k + 1 : ℕ) : ℝ) - 1) =
          (2 * (k : ℝ)) / (2 * (k : ℝ) + 1) := by push_cast; ring
      have hexp2 : (1 : ℝ) / (2 * ((k + 1 : ℕ) : ℝ) - 1) = (1 : ℝ) / (2 * (k : ℝ) + 1) := by
        push_cast; ring
      have hcoord : |(θ - θs) i| ≤ supRad CI k c n := by
        have hI := hInterp n hnr (θ - θs) i
        rw [hexp1, hexp2] at hI
        refine hI.trans ?_
        unfold supRad
        refine mul_le_mul_of_nonneg_left ?_ hCI.le
        refine add_le_add hδ.1 ?_
        have h1 : empNorm (θ - θs) ^ ((2 * (k : ℝ)) / (2 * (k : ℝ) + 1)) ≤
            Real.sqrt (rhoSq (k + 1) n) ^ ((2 * (k : ℝ)) / (2 * (k : ℝ) + 1)) :=
          Real.rpow_le_rpow hemp_nn hδ.1 hp_nn
        have h2 : TVr (k + 1) n (θ - θs) ^ ((1 : ℝ) / (2 * (k : ℝ) + 1)) ≤
            Tn (k + 1) n (lamSeq c k n) ^ ((1 : ℝ) / (2 * (k : ℝ) + 1)) :=
          Real.rpow_le_rpow hTV_nn hδ.2 hq_nn
        have hmul : empNorm (θ - θs) ^ ((2 * (k : ℝ)) / (2 * (k : ℝ) + 1)) *
              TVr (k + 1) n (θ - θs) ^ ((1 : ℝ) / (2 * (k : ℝ) + 1)) ≤
            Real.sqrt (rhoSq (k + 1) n) ^ ((2 * (k : ℝ)) / (2 * (k : ℝ) + 1)) *
              Tn (k + 1) n (lamSeq c k n) ^ ((1 : ℝ) / (2 * (k : ℝ) + 1)) :=
          mul_le_mul h1 h2 (Real.rpow_nonneg hTV_nn _) (Real.rpow_nonneg hrho_nn _)
        refine hmul.trans_eq ?_
        have hrhs_eq : Real.sqrt (rhoSq (k + 1) n) ^ ((2 * (k : ℝ)) / (2 * (k : ℝ) + 1)) =
            (Real.sqrt (rhoSq (k + 1) n) ^ (2 * k)) ^ ((1 : ℝ) / (2 * (k : ℝ) + 1)) := by
          rw [← Real.rpow_natCast (Real.sqrt (rhoSq (k + 1) n)) (2 * k),
            ← Real.rpow_mul hrho_nn]
          congr 1
          push_cast
          ring
        rw [hrhs_eq, ← Real.mul_rpow (pow_nonneg hrho_nn _) hTn_nn]
      exact not_lt_of_ge hcoord hi
    exact (measure_mono hsub).trans (hpost_Kn y hy)
  · have hcompl : (OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE)ᶜ =
        (OmegaG k n c τ fl μ θs)ᶜ ∪ (OmegaE k n τ (lamSeq c k n) θs CE)ᶜ :=
      Set.compl_inter _ _
    have hn' : 0 < (n : ℝ) := by exact_mod_cast hn0
    have heps_pos : 0 < (n : ℝ) * epsSq (k + 1) n :=
      mul_pos hn' (Real.rpow_pos_of_pos hn' _)
    have hle_rho : (n : ℝ) * epsSq (k + 1) n ≤ (n : ℝ) * rhoSq (k + 1) n :=
      Asym.mul_epsSq_le_mul_rhoSq (k + 1) n (by omega) hn0 hnlog
    have hrho_pos : 0 < (n : ℝ) * rhoSq (k + 1) n := heps_pos.trans_le hle_rho
    have hG_nn : 0 ≤ 64 / (fl ^ 2 * (n : ℝ) * rhoSq (k + 1) n) := by
      have : 0 < fl ^ 2 * (n : ℝ) * rhoSq (k + 1) n := by
        rw [mul_assoc]; exact mul_pos (sq_pos_of_pos hfl) hrho_pos
      exact div_nonneg (by norm_num) this.le
    have hE_nn : 0 ≤ 5 / 4 / ((n : ℝ) * epsSq (k + 1) n) :=
      div_nonneg (by norm_num) heps_pos.le
    calc Measure.pi μ (OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE)ᶜ
        ≤ Measure.pi μ (OmegaG k n c τ fl μ θs)ᶜ +
            Measure.pi μ (OmegaE k n τ (lamSeq c k n) θs CE)ᶜ := by
          rw [hcompl]; exact measure_union_le _ _
      _ ≤ ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n)) +
            ENNReal.ofReal (5 / 4 / (n * epsSq (k + 1) n)) :=
          add_le_add hG hE
      _ = ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n) +
            5 / 4 / (n * epsSq (k + 1) n)) :=
          (ENNReal.ofReal_add hG_nn hE_nn).symm
      _ ≤ ENNReal.ofReal ((5 / 4 + 64 / fl ^ 2) * massRate k n) := by
          apply ENNReal.ofReal_le_ofReal
          rw [Asym.massRate_eq_inv k n hn0]
          have hterm : 64 / (fl ^ 2 * (n : ℝ) * rhoSq (k + 1) n) ≤
              64 / (fl ^ 2 * (n : ℝ) * epsSq (k + 1) n) := by
            refine div_le_div_of_nonneg_left (by norm_num) ?_ ?_
            · rw [mul_assoc]; exact mul_pos (sq_pos_of_pos hfl) heps_pos
            · rw [mul_assoc, mul_assoc]
              exact mul_le_mul_of_nonneg_left hle_rho (sq_nonneg fl)
          have halg : 64 / (fl ^ 2 * (n : ℝ) * epsSq (k + 1) n) +
              5 / 4 / ((n : ℝ) * epsSq (k + 1) n) =
              (5 / 4 + 64 / fl ^ 2) * ((n : ℝ) * epsSq (k + 1) n)⁻¹ := by
            have hfl2 : fl ^ 2 ≠ 0 := (sq_pos_of_pos hfl).ne'
            have hx : (n : ℝ) * epsSq (k + 1) n ≠ 0 := heps_pos.ne'
            field_simp [hfl2, hx]
            ring
          linarith

end BQTF
