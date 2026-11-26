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
