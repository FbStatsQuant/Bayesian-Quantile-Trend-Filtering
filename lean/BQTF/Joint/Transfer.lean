import BQTF.Joint.Conditioning
import BQTF.Joint.Gap
import BQTF.Joint.SupNormScale

/-!
# The constraint and the transfer (proof of `thm:joint`, "The constraint" and "Transfer")

Owner: TBD (assigned at the Theorem 2 trigger).

Statements, all at general scales `σ_j > 0` (the `σ = 1` case is `σ = fun _ => 1`):
* `mem_orderSet_of_near` — if `‖θ_l − θ*_l‖_∞ ≤ g₀/2` for every `l`, then `Θ ∈ 𝒞`;
* `prodPosterior_compl_orderSet_le` — on the good event, `Π^⊗(𝒞ᶜ ∣ y) ≤ Σ_l η_l`
  (`≤ J η_n ≤ 1/2` in the paper);
* `jointPosterior_jointFarSet_le` — if `Π^⊗(𝒞ᶜ ∣ y) ≤ 1/2` then
  `Π_𝒞(U ∣ y) ≤ 2 Σ_j Π_j(A_j ∣ y)`;
* `eventually_levels` — the two eventual conditions `max_l σ_{0l}s′_{n,l} ≤ g₀/2` and
  `Σ_l η′_{n,l} ≤ 1/2` (stated with `∀ᶠ n in atTop`, PLAN §5.5 item 5: `s_n` is not monotone);
* `joint_assembly` — the `E`-bound at one `n`, with the bad-event split
  `E Π_𝒞(U ∣ y) ≤ P(Ωᶜ) + 2 Σ_j E Π_j(A_j ∣ y)` (the proof may use the measurable hull of
  `Ωᶜ`, as `Main` does, since `Ω` is not assumed measurable).

Nonvacuity: the uniform example of `Joint/Gap` (`J = 2`, `τ = (1/4, 3/4)`, `θ*_j ≡ τ_j`,
`L = 1/4`, `f̲ = f̄ = 1`, `V̄ = 0`, `gmin = 1/2`, `σ = 1`, `λ_j = lamSeq 1 k n`) satisfies the
level and data hypotheses for every `n ≥ 1`, and `Θ = θ*` satisfies the hypothesis of
`mem_orderSet_of_near`. For `joint_assembly` at a fixed `n ≥ 1`, add `C_j = p_l = n^{1/(2r)}`
(`MainConclusion` holds since posteriors are `≤ 1`), `s = 0`, `η = 1/4` and `Ω_l = ∅`.
-/

open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal

noncomputable section

namespace BQTF

/-- "The constraint": if every level is within `g₀/2` of its true curve in sup norm, then the
joint trend is ordered. -/
theorem mem_orderSet_of_near {k n J : ℕ} {τ : Fin J → ℝ} {gmin : ℝ} (hτ : LevelGrid J τ gmin)
    {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ} {L fl fu Vb : ℝ} (hL : 0 < L)
    (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    (Θ : Fin J → Fin n → ℝ) (hΘ : ∀ l i, |Θ l i - θs l i| ≤ gapConst L gmin fu / 2) :
    Θ ∈ orderSet J n := by
  sorry

/-- "The constraint", union bound: if `s_l ≤ g₀/2` and
`Π_l(‖θ − θ*_l‖_∞ > s_l ∣ y) ≤ η_l` for every level `l`, then `Π^⊗(𝒞ᶜ ∣ y) ≤ Σ_l η_l`. -/
theorem prodPosterior_compl_orderSet_le {k n J : ℕ} (hn : 1 ≤ n) {τ : Fin J → ℝ} {gmin : ℝ}
    (hτ : LevelGrid J τ gmin) (σ lam : Fin J → ℝ) (hσ : ∀ j, 0 < σ j)
    (hlam : ∀ j, 0 ≤ lam j) {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ}
    {L fl fu Vb : ℝ} (hL : 0 < L) (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    (y : Fin n → ℝ) (s η : Fin J → ℝ) (hs : ∀ l, s l ≤ gapConst L gmin fu / 2)
    (hη : ∀ l, posterior (τ l) (σ l) (lam l) k n y {θ | ∃ i, s l < |θ i - θs l i|}
      ≤ ENNReal.ofReal (η l)) :
    prodPosterior τ σ lam k n y (orderSet J n)ᶜ ≤ ∑ l, ENNReal.ofReal (η l) := by
  sorry

/-- "Transfer": if `Π^⊗(𝒞ᶜ ∣ y) ≤ 1/2` then
`Π_𝒞(U_M ∣ y) ≤ 2 Σ_j Π_j(A_j ∣ y)`, `A_j = farSet k θ*_j M`
(union bound + Lemma `pf:lem:cond` + `Π^⊗(𝒞 ∣ y) ≥ 1/2`). -/
theorem jointPosterior_jointFarSet_le {k n J : ℕ} (hn : 1 ≤ n) (τ σ lam : Fin J → ℝ)
    (hτ : ∀ j, 0 < τ j ∧ τ j < 1) (hσ : ∀ j, 0 < σ j) (hlam : ∀ j, 0 ≤ lam j)
    (θs : Fin J → Fin n → ℝ) (M : ℝ) (y : Fin n → ℝ)
    (hC : prodPosterior τ σ lam k n y (orderSet J n)ᶜ ≤ 1 / 2) :
    jointPosterior τ σ lam k n y (jointFarSet k θs M)
      ≤ 2 * ∑ j, posterior (τ j) (σ j) (lam j) k n y (farSet k (θs j) M) := by
  sorry

/-- The eventual conditions on `n₀` (proof of `thm:joint`, choice of `n₀`; "General scales"):
for `g > 0` (in use `g = g₀`), eventually `σ_{0l} s′_{n,l} ≤ g/2` for every level and
`Σ_l η′_{n,l} ≤ 1/2`, with `s′_{n,l} = supRad C_I k (σ_{0l}c_l) n`, `η′_{n,l} = etaSeq k (σ_{0l}f̲) n`. -/
theorem eventually_levels (k : ℕ) (hk : 1 ≤ k) {J : ℕ} (CI : ℝ) (σ₀ c : Fin J → ℝ)
    (hσ₀ : ∀ j, 0 < σ₀ j) (hc : ∀ j, 0 < c j) (fl : ℝ) (hfl : 0 < fl) (g : ℝ) (hg : 0 < g) :
    ∀ᶠ n in atTop, (∀ l, σ₀ l * supRad CI k (σ₀ l * c l) n ≤ g / 2) ∧
      ∑ l, etaSeq k (σ₀ l * fl) n ≤ 1 / 2 := by
  sorry

/-- Assembly at one `n` (proof of `thm:joint`, last display; "General scales"). Given
* the single-level conclusions `MainConclusion` at a common `M` with constants `C_j ≥ 0`;
* per-level radii `s_l ≤ g₀/2` and masses `η_l ≥ 0` with `Σ_l η_l ≤ 1/2` (nonnegativity
  permits the real sum bound to be transferred to the sum of the positive parts, i.e. to
  `Σ_l ofReal η_l`, which is the bound the union step yields; it keeps the proof short);
* per-level events `Ω_l` on which `Π_l(‖θ − θ*_l‖_∞ > s_l ∣ y) ≤ η_l`, with
  `P(Ω_lᶜ) ≤ p_l n^{−1/(2r)}`, `p_l ≥ 0`,

the joint conclusion holds with `C = 2 Σ_j C_j + Σ_l p_l`. -/
theorem joint_assembly {k n J : ℕ} (hn : 1 ≤ n) {τ : Fin J → ℝ} {gmin : ℝ}
    (hτ : LevelGrid J τ gmin) (σ lam : Fin J → ℝ) (hσ : ∀ j, 0 < σ j)
    (hlam : ∀ j, 0 ≤ lam j) {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ}
    {L fl fu Vb : ℝ} (hL : 0 < L) (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    {M : ℝ} {Cl p s η : Fin J → ℝ} (hCl : ∀ j, 0 ≤ Cl j) (hp : ∀ l, 0 ≤ p l)
    (hmain : ∀ j, MainConclusion k n (τ j) (σ j) (lam j) μ (θs j) M (Cl j))
    (hs : ∀ l, s l ≤ gapConst L gmin fu / 2) (hη0 : ∀ l, 0 ≤ η l) (hη : ∑ l, η l ≤ 1 / 2)
    (hΩ : ∀ l, ∃ Ω : Set (Fin n → ℝ),
      (∀ y ∈ Ω, posterior (τ l) (σ l) (lam l) k n y {θ | ∃ i, s l < |θ i - θs l i|}
        ≤ ENNReal.ofReal (η l)) ∧
      Measure.pi μ Ωᶜ ≤ ENNReal.ofReal (p l * massRate k n)) :
    JointConclusion k n τ σ lam μ θs M (2 * ∑ j, Cl j + ∑ l, p l) := by
  sorry

end BQTF
