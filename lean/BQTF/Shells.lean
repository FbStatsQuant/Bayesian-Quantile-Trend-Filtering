import BQTF.Score
import BQTF.Coord
import BQTF.Localization

/-!
# Shells (appendix, Proposition `pf:prop:shell`)

Owner: Neon-B. `E_a = {θ : ‖δ‖_∞ ≤ s_0, a n ε_n² < ‖δ‖₂² ≤ 2a n ε_n²}`,
`J = ⌊(f̲²/128) M n ε_n²⌋ − r`, `C_fine = 2^{2r+1} c_F² (256/f̲²)^{2r−1}`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- The shell `E_a`. -/
def Eshell (k n : ℕ) (L fl fu a : ℝ) (θs : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {θ | (∀ i, |θ i - θs i| ≤ s0 L fl fu) ∧ a * n * epsSq (k + 1) n < l2sq (θ - θs) ∧
       l2sq (θ - θs) ≤ 2 * a * n * epsSq (k + 1) n}

/-- `J = ⌊(f̲²/128) M n ε_n²⌋ − r` (natural-number floor and subtraction). -/
def Jshell (k n : ℕ) (fl M : ℝ) : ℕ := ⌊fl ^ 2 / 128 * M * n * epsSq (k + 1) n⌋₊ - (k + 1)

/-- `C_fine = 2^{2r+1} c_F² (256/f̲²)^{2r−1}`. -/
def Cfine (r : ℕ) (fl : ℝ) : ℝ := 2 ^ (2 * r + 1) * cF r ^ 2 * (256 / fl ^ 2) ^ (2 * r - 1)

/-- Proposition `pf:prop:shell`: for `M > 0` there is `n₃` such that for `n ≥ n₃`:
`1 ≤ J ≤ m`, `J ≥ (f̲²/256) M n ε_n²`, and for every `a ≥ M`
`E[N(E_a) 1_{Ω_ζ(J)}] ≤ V_r (2a n ε_n²)^{r/2} exp{−(f̲/8) a n ε_n² + (1 + C_fine/(c² M^{2r−1})) n ε_n²}`.
(The paper's `n₃` depends on `(M, c, r, f̲, V̄)`; here it may depend on all of
`(M, c, k, L, f̲, f̄, V̄)`, which suffices for Theorem `thm:main`.) -/
theorem shells (k : ℕ) (hk : 1 ≤ k) (c L fl fu Vb : ℝ) (hc : 0 < c) (hL : 0 < L) (hfl : 0 < fl)
    (M : ℝ) (hM : 0 < M) :
    ∃ n₃ : ℕ, k + 1 < n₃ ∧ ∀ n, n₃ ≤ n →
      1 ≤ Jshell k n fl M ∧ Jshell k n fl M ≤ n - (k + 1) ∧
      fl ^ 2 / 256 * M * n * epsSq (k + 1) n ≤ Jshell k n fl M ∧
      ∀ a, M ≤ a → ∀ τ : ℝ, 0 < τ → τ < 1 →
        ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
          ∫⁻ y, Set.indicator (OmegaZeta (k + 1) n (Jshell k n fl M) τ θs)
              (fun y => Nmass (k + 1) τ (lamSeq c k n) y θs (Eshell k n L fl fu a θs)) y
              ∂(Measure.pi μ)
            ≤ Vr (k + 1) * ENNReal.ofReal ((2 * a * n * epsSq (k + 1) n) ^ ((k + 1 : ℝ) / 2)) *
              ENNReal.ofReal (Real.exp (-(fl / 8 * a * n * epsSq (k + 1) n) +
                (1 + Cfine (k + 1) fl / (c ^ 2 * M ^ (2 * (k + 1) - 1))) * n * epsSq (k + 1) n)) := by
  sorry

end BQTF
