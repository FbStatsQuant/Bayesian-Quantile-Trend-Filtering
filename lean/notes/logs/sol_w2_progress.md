# Sol-W2 progress

- Read the frozen specification, proof plan, and Owls build policy. Set up the worktree's shared Mathlib package link.
- Started the scale reduction with positive homogeneity, the Haar change of variables, and measurability of posterior probabilities for fixed measurable events.
- Reused the existing project build cache for the identical frozen Lean sources. Lake replayed those modules and is checking the new scale proofs.
- `lake build BQTF.Reduction` passed through the Owls wrapper. The scale modules contain zero local placeholders. The reduction uses the unit-scale theorem for the bound and proves measurability of the scaled event directly.
- `lake build BQTF.PriorMass` passed through the Owls wrapper. The matrix of `Asb` has the same small-ball events as `Asb`. Pascal's rule and contraction of the orthogonal residual give the adjacent-column bound.
- The positive-variation case uses the floored smoothing window from the appendix. The nonpositive case takes zero. Two applications of the small-ball bound give the central mass and control the shift coefficient uniformly in the sample size.
- The frozen interfaces suffice. All newly proved Lean files contain zero local placeholders.
- The aggregate `lake build BQTF` passed through the Owls wrapper after both changes. Its placeholder warnings came from upstream skeletons.

## Shift and width

- Stopped on `quad_shift` after isolating the specialized Prékopa–Leindler comparison in `sol_w2_questions.md`. The quadratic-shift declaration remains the frozen skeleton.
- Proved `width` using the frozen coordinate and spline lemmas. The concentration bound uses width as an input. The Rademacher second moment and log-sum-exp bound add no placeholders.
- The Owls build passed for `BQTF.Width` and the existing `BQTF.QuadShift` skeleton. The axiom audit reports `[propext, sorryAx, Classical.choice, Quot.sound]` for both declarations. For `width`, the placeholder axiom comes from the frozen coordinate and spline lemmas.
- After the Prékopa–Leindler interface freeze, proved central-slice maximality and the centered radius-loss bound in `Shift/SliceBounds.lean`. The Laplace normalization, product density, coordinate Fubini, and scalar integrals were proved independently.
- Proved `quad_shift` and passed the Owls module build and axiom audit. The only source of `sorryAx` is the frozen `prekopa_laplace` proof. The audit of the Laplace normalization and product density reports `[propext, Classical.choice, Quot.sound]`.
- Merged main at `0aa30fc` with the proved Prékopa–Leindler input. QuadShift now uses Coord's Laplace density and normalization proofs. The full Owls build passed. The scratch axiom audit of `quad_shift` and `prior_mass` reported only `[propext, Classical.choice, Quot.sound]` for each.
