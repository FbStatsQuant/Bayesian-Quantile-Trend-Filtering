import BQTF.Joint.Transfer
import BQTF.Main
import BQTF.Reduction

/-!
# Theorem `thm:joint` (Theorem 2)

Owner: TBD (assigned at the Theorem 2 trigger).

`joint_theorem : JointStatement` (`σ_j = 1`) and `joint_theorem_scale : JointStatementScale`.
Planned constant choice (proof of `thm:joint` and "General scales"), with `M^{(l)}, C^{(l)}, n_0^{(l)}`
the constants of `main_theorem_scale` at `(σ_{0l}, c_l)`:
* `M = max_l M^{(l)}` (then `farSet` at `M` is inside `farSet` at `M^{(l)}`);
* `C = 2 Σ_l C^{(l)} + Σ_l {5/4 + 64/(σ_{0l} f̲)²}` (at `σ = 1`: `2 Σ_l C^{(l)} + J(5/4 + 64/f̲²)`);
* `n₀ ≥ max_l max{n_0^{(l)}, n_2^{(l)}}`, also past the `eventually_levels` threshold at
  `g = gapConst L gmin f̄` (`f̄ > 0` by `fl_le_fu_of_dataHyp`, for `J ≥ 1` and `n ≥ 1`) and `≥ 1`.

Witness recipe (Astra audit F3, accepted by the Lean head 2026-11-26):
* `J = 0`: take `M = C = n₀ = 1`; then `U_M = ∅` (`jointFarSet` over `Fin 0`), so both conjuncts
  of `JointConclusion` are trivial. This avoids the empty maximum and the empty sum `C = 0`.
* `J > 0`: split on `0 < f̄` **before** choosing `n₀`, because `DataHyp` is quantified after
  `n₀`.
  - In the branch `f̄ ≤ 0`, use positive dummy witnesses (e.g. `M = C = n₀ = 1`). Then contradict
    `DataHyp` at one level and one coordinate (`fl_le_fu_of_dataHyp` with `0 < f̲`; `n ≥ 1`).
  - In the branch `0 < f̄`, choose the constants as above, and take `n₀` as the common maximum
    of the per-level thresholds (each `n_0^{(l)}`, each `n_2^{(l)}`, the `eventually_levels`
    threshold, and `1`).
* Common `M`: `MainConclusion` is monotone in `M`. For `M′ ≥ M_j`, `farSet k θ* M′ ⊆ farSet k θ* M_j`
  (as `rate ≥ 0`), which gives the expectation bound with unchanged `C_j`. The measurability
  conjunct at `M′` comes from public `measurable_posterior_apply` (`Scale/Posterior`), since the far
  set is open. The far-set helper in `Main` is private, so prove this as a local helper here
  (or inline it). No extra hypothesis is needed.

`joint_theorem` is also the special case `σ₀ = fun _ => 1` of `joint_theorem_scale`.

Nonvacuity: the uniform example of `Joint/Gap` satisfies every hypothesis of both statements
for every `n` (`k = 1`, `J = 2`, `c = 1`, `σ₀ = 1`, `τ = (1/4, 3/4)`, `gmin = 1/2`, `L = 1/4`,
`f̲ = f̄ = 1`, `V̄ = 0`, `μ_i` uniform on `[0,1]`, `θ*_j ≡ τ_j`).
-/

noncomputable section

namespace BQTF

/-- **Theorem `thm:joint`** at `σ_1 = ⋯ = σ_J = 1`. -/
theorem joint_theorem : JointStatement := by
  sorry

/-- **Theorem `thm:joint`**, general fixed scales `σ_{0j} > 0`. -/
theorem joint_theorem_scale : JointStatementScale := by
  sorry

end BQTF
