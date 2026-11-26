import BQTF.Denominator
import BQTF.Width
import BQTF.Interp
import BQTF.Concentration

/-!
# Localization (appendix, Proposition `pf:prop:local`)

Owner: Neon-B. `ρ_n² = n^{−(2r−1)/(2r+1)} log n`, `T_n = 4n^r/λ`, `K_n = K(ρ_n, T_n)`,
`s_0 = min{1, L, 3f̲/(4f̄)}`, `Ω_G = {G_{K_n} ≤ (f̲/4) n ρ_n²}`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `K_n = K(ρ_n, T_n)` with `λ = c n^{r−1/2}`. -/
def Kn (k n : ℕ) (c : ℝ) : Set (Fin n → ℝ) :=
  Kset (k + 1) n (Real.sqrt (rhoSq (k + 1) n)) (Tn (k + 1) n (lamSeq c k n))

/-- `s_0 = min{1, L, 3f̲/(4f̄)}`. -/
def s0 (L fl fu : ℝ) : ℝ := min 1 (min L (3 * fl / (4 * fu)))

/-- `Ω_G = {y : G_{K_n}(y) ≤ (f̲/4) n ρ_n²}`. -/
def OmegaG (k n : ℕ) (c τ fl : ℝ) (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {y | GK τ μ θs (Kn k n c) y ≤ fl / 4 * n * rhoSq (k + 1) n}

/-- Proposition `pf:prop:local`. For every `C_E` (in use, the constant of `denominator`) there is
`n₂` such that for `n ≥ n₂` and every law and target satisfying the hypotheses:
(a) `sup_{δ ∈ K_n} ‖δ‖_∞ ≤ s_0`;
(b) `P(Ω_Gᶜ) ≤ 64/(f̲² n ρ_n²)`, and on `Ω_G ∩ Ω_E`,
`Π_λ(θ − θ* ∉ K_n ∣ y) ≤ r! {e^{−f̲ n ρ_n²/16} + e^{−n/8}}`.
(The paper's `n₂` depends on `(c, r, L, f̲, f̄, V̄)`; here also on `C_E`, which depends on those.) -/
theorem localization (k : ℕ) (hk : 1 ≤ k) (c L fl fu Vb : ℝ) (hc : 0 < c) (hL : 0 < L)
    (hfl : 0 < fl) (CE : ℝ) :
    ∃ n₂ : ℕ, k + 1 < n₂ ∧ ∀ n, n₂ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 →
      ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
        (∀ δ ∈ Kn k n c, ∀ i, |δ i| ≤ s0 L fl fu) ∧
        Measure.pi μ (OmegaG k n c τ fl μ θs)ᶜ
          ≤ ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n)) ∧
        ∀ y ∈ OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE,
          posterior τ 1 (lamSeq c k n) k n y {θ | θ - θs ∉ Kn k n c}
            ≤ ENNReal.ofReal (Nat.factorial (k + 1) *
                (Real.exp (-(fl * n * rhoSq (k + 1) n / 16)) + Real.exp (-(n / 8 : ℝ)))) := by
  sorry

end BQTF
