# Main theorem assembly

- Read the specification, Owls policy, appendix, and frozen assembly lemmas.
- The denominator, localization, and shells thresholds can be combined by taking their maximum.
- The posterior is measurable by a jointly measurable Lebesgue density and parametric integration.
- The probability bound on the union of bad events can be used through a measurable hull.
- The proof covers the localized far set with dyadic shells using the least dyadic upper endpoint. The strict lower endpoint and weak upper endpoint match `Eshell`.
- The shell polynomial prefactor cancels the evidence prefactor up to `(8a)^(r/2)`. The remaining dyadic terms are dominated by a geometric series of ratio one half.
- The existential constants use a threshold with `M ≥ 1` and reciprocal bounds for the exponential terms. This yields the specified mass rate with constants depending only on the allowed parameters.
- Copied the baseline BQTF build artifacts from the main checkout into this worktree's ignored build directory after confirming the imported BQTF sources agree. The local build reused the prebuilt Mathlib.
- `owls_run -j 3 -- lake build BQTF.Main` passed. The proof and its rate helpers contain no local proof holes.
- No frozen interface gap was found. Joint measurability of the posterior weight is established from `postWeight`, and all sample-size thresholds are chosen before the data and quantile level.
- Lean confirmed the theorem has type `MainStatement` and printed `[propext, sorryAx, Classical.choice, Quot.sound]`. The `sorryAx` dependency comes from the frozen lemmas.

## Shells, localization and denominator

- Branch `t3/sol-w1-assembly` starts from the Main proof commit. Shells goes first because it uses the definitions in Localization but does not require the localization or denominator proofs. Its Laplace moment helper can also serve Localization.
- Shells uses Cauchy–Schwarz on the product of the restricted data and prior measures. Tonelli handles the score and remainder in opposite integration orders. The score bound uses the finite-product Laplace moment formula and the frozen coordinate volume formula.
- `owls_run -j 3 -- lake build BQTF.Shells` passed. The frozen theorem header and statement agree with the branch base. No interface gap or paper correction was needed for this proof.
- Lean reported `[propext, sorryAx, Classical.choice, Quot.sound]` for `BQTF.shells`. The proof and its new helpers have no local proof holes.
- Recorded a one-sided Efron–Stein correction to the concentration proof in `sol_w1_questions.md`. It does not require a change to the frozen concentration lemma.

## Localization

- Instantiated the width bound at `J = ceil(n^(2/(2r+1)))`. This choice gives the two width terms the same order and leaves the frozen probability and posterior constants intact.
- Used the two ray cases from the appendix. The empirical-norm case integrates a radial exponential in the polynomial coordinates. The variation case uses the exponential moment of the sum of independent scaled absolute Laplace variables.
- `owls_run -j 3 -- lake build BQTF.Localization` passed. No frozen interface change was needed. Localization only uses the evidence event definition, so it could be proved before Denominator as assigned.
- Axiom check for `BQTF.localization`: `[propext, sorryAx, Classical.choice, Quot.sound]`. The local proof and its new helpers contain no proof holes.

## Denominator

- Used the shifted prior-mass set and the polynomial-coordinate ball. Pythagoras bounds its squared error by `(5/4) n ε²`.
- Applied Jensen under the normalized prior restricted to that set. Fubini controls the mean of the averaged check loss. For variance, the coordinate averages are independent and Popoviciu's inequality bounds each variance by the squared mean absolute displacement. Jensen bounds that square by the mean squared displacement.
- `owls_run -j 3 -- lake build BQTF.Denominator` passed. The frozen interfaces were sufficient and the concentration estimate uses no moment assumption on the observations.
- Axiom check for `BQTF.denominator`: `[propext, sorryAx, Classical.choice, Quot.sound]`. The local proof contains no proof holes.
