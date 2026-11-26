# Sol-P1 progress for J5

## Proof plan

Use the same interpolation constant as `supNorm_concentration`. Apply that theorem with
`(σ₀c, L/σ₀, σ₀f̲, σ₀f̄, V̄/σ₀)` and transfer the data hypotheses with `DataHyp.scale`.
Take the inverse image of its good event under division by `σ₀`. Use `pi_scaleData` and the
map formula for a measurable equivalence to transfer the complement bound, since J4 allows an
arbitrary event. Use `posterior_map_inv_smul` for the posterior and the identity
`|θᵢ/σ₀ − θ*ᵢ/σ₀| = |θᵢ − θ*ᵢ|/σ₀` to transfer the strict tail event.

Started on `t3/thm2-solP1-j5` at `cd697ade07b1b36d0bfafda5e9a9e3645a648fb4`.

## Implementation and verification

- Plan commit `4b868a7d939751b6f1f4ede0d65e238911f10290`.
- Proof commit `db5edff654f823e8e344bed0e138e3c560a11c7a`. Only the proof body in
  `BQTF/Joint/SupNormScale.lean` changed. The pullback preserves posterior tail mass and
  the outer measure of the bad event. No J5 paper gap surfaced.
- Full `lake build` through Owls succeeded (8978 jobs). The J5 file builds without warnings.
- The external scratch audit reported
  `'BQTF.supNorm_concentration_scale' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]`.
  J5 has zero local sorries. The `sorryAx` dependency comes from
  `BQTF.denominator` and `BQTF.localization` through `BQTF.supNorm_concentration`
  on this base. The audit confirmed that `interp`, `DataHyp.scale`, `pi_scaleData`, and
  `posterior_map_inv_smul` do not depend on `sorryAx`.
