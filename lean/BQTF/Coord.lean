import BQTF.Falling

/-!
# Coordinates (appendix, Lemma `pf:lem:coord`)

Owner: Neon-A. With `r = k + 1` and `n > r`: `D S = I`, `ker D = 𝒫`, the coordinates
`θ = N c + S u`, the ratio form of the posterior (eq. `pf:eq:ratio`), Pythagoras
(eq. `pf:eq:pyth`) and the volume formula (eq. `pf:eq:vol`).

In θ-coordinates `c − c̄(u) = Nᵀ(θ − θ*)` and `u = Dθ` (this follows from (a)–(c)), so the volume
formula is stated with `Nᵀ(θ − θ*)` and `Dθ`.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `u* = D θ*`. -/
def ustar (r n : ℕ) (θs : Fin n → ℝ) : Fin (n - r) → ℝ := diffOp r n θs

/-- `c* = Nᵀ(θ* − S u*)`. -/
def cstar (r n : ℕ) (θs : Fin n → ℝ) : Fin r → ℝ := NT r n (θs - Smul r n (ustar r n θs))

/-- `c̄(u) = c* − Nᵀ S (u − u*)`. -/
def cbar (r n : ℕ) (θs : Fin n → ℝ) (u : Fin (n - r) → ℝ) : Fin r → ℝ :=
  cstar r n θs - NT r n (Smul r n (u - ustar r n θs))

/-- Lemma `pf:lem:coord`(a), first part: `D S = I_m`. -/
theorem diffOp_Smul (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (u : Fin (n - r) → ℝ) :
    diffOp r n (Smul r n u) = u := by
  sorry

/-- Lemma `pf:lem:coord`(a), second part: `ker D = 𝒫`. -/
theorem diffOp_eq_zero_iff (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θ : Fin n → ℝ) :
    diffOp r n θ = 0 ↔ θ ∈ polySpace r n := by
  sorry

/-- `N` is orthonormal: `⟨N_p, N_q⟩ = 1(p = q)`, and `N` spans `𝒫` (part of the setting of
Lemma `pf:lem:coord`). -/
theorem Ncol_orthonormal (r n : ℕ) (hn : r ≤ n) :
    (∀ p q, dot (Ncol r n p) (Ncol r n q) = if p = q then 1 else 0) ∧
    Submodule.span ℝ (Set.range (Ncol r n)) = polySpace r n := by
  sorry

/-- Lemma `pf:lem:coord`(b): `(c, u) ↦ N c + S u` is a bijection `ℝ^r × ℝ^m → ℝⁿ`, with `u = Dθ`. -/
theorem coordMap_bijective (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) :
    Function.Bijective (coordMap r n) ∧
    ∀ cu, diffOp r n (coordMap r n cu) = cu.2 := by
  sorry

/-- Lemma `pf:lem:coord`(b), eq. `pf:eq:ratio`: at `σ = 1` the posterior is `N(B)/N(ℝⁿ)` with
`0 < N(ℝⁿ) < ∞`, for every measurable `B`, every `y` and every reference point `θ*`. -/
theorem posterior_eq_ratio (k n : ℕ) (hn : k + 1 < n) (τ lam : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (hlam : 0 < lam) (y θs : Fin n → ℝ) :
    0 < Nmass (k + 1) τ lam y θs Set.univ ∧ Nmass (k + 1) τ lam y θs Set.univ < ∞ ∧
    ∀ B, MeasurableSet B →
      posterior τ 1 lam k n y B = Nmass (k + 1) τ lam y θs B / Nmass (k + 1) τ lam y θs Set.univ := by
  sorry

/-- Properness (docs D4): for `n ≥ 1`, `τ ∈ (0,1)`, `σ > 0`, `λ ≥ 0` the posterior is a
probability measure. -/
theorem posterior_isProbability (k n : ℕ) (hn : 1 ≤ n) (τ σ lam : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (hσ : 0 < σ) (hlam : 0 ≤ lam) (y : Fin n → ℝ) :
    IsProbabilityMeasure (posterior τ σ lam k n y) := by
  sorry

/-- Lemma `pf:lem:coord`(c), eq. `pf:eq:pyth`: for `θ = N c + S u`, `δ = θ − θ*`,
`‖δ‖₂² = ‖c − c̄(u)‖₂² + ‖P^⊥ S (u − u*)‖₂²`. -/
theorem pythagoras (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θs : Fin n → ℝ)
    (c : Fin r → ℝ) (u : Fin (n - r) → ℝ) :
    l2sq (coordMap r n (c, u) - θs) =
      l2sq (c - cbar r n θs u) + l2sq (Pperp r n (Smul r n (u - ustar r n θs))) := by
  sorry

/-- `c − c̄(u) = Nᵀ(θ − θ*)` for `θ = N c + S u`. -/
theorem sub_cbar_eq (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (θs : Fin n → ℝ)
    (c : Fin r → ℝ) (u : Fin (n - r) → ℝ) :
    c - cbar r n θs u = NT r n (coordMap r n (c, u) - θs) := by
  sorry

/-- Lemma `pf:lem:coord`(c), eq. `pf:eq:vol`: for measurable `H ≥ 0` and `ϱ ≥ 0` on `ℝ^m`,
`∫ 1{‖c − c̄(u)‖₂ ≤ ϱ(u)} H(u) dν = V_r ∫ ϱ(u)^r H(u) dQ_λ(u)`. -/
theorem vol_formula (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (lam : ℝ) (hlam : 0 < lam)
    (θs : Fin n → ℝ) (H : (Fin (n - r) → ℝ) → ℝ≥0∞) (hH : Measurable H)
    (ϱ : (Fin (n - r) → ℝ) → ℝ) (hϱ : Measurable ϱ) (hϱ0 : ∀ u, 0 ≤ ϱ u) :
    ∫⁻ θ, Set.indicator {θ | l2norm (NT r n (θ - θs)) ≤ ϱ (diffOp r n θ)}
        (fun θ => H (diffOp r n θ)) θ ∂(nu r n lam) =
      Vr r * ∫⁻ u, ENNReal.ofReal (ϱ u ^ r) * H u ∂(Qlam (n - r) lam) := by
  sorry

/-- Lemma `pf:lem:coord`(c), last claim: `ν{‖δ‖₂ ≤ ϱ} ≤ V_r ϱ^r` for every constant `ϱ ≥ 0`. -/
theorem nu_ball_le (r n : ℕ) (hr : 1 ≤ r) (hn : r < n) (lam : ℝ) (hlam : 0 < lam)
    (θs : Fin n → ℝ) (ϱ : ℝ) (hϱ : 0 ≤ ϱ) :
    nu r n lam {θ | l2norm (θ - θs) ≤ ϱ} ≤ Vr r * ENNReal.ofReal (ϱ ^ r) := by
  sorry

end BQTF
