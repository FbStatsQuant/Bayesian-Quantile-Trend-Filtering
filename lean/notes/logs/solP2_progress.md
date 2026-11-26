# Sol-P2 · J7 progress

## Proof plan

- Prove monotonicity of `MainConclusion` under increasing the loss threshold. Reuse the public posterior and far-set measurability results where available.
- At general scales handle the empty grid by the empty far event. For a nonempty grid with a nonpositive upper density bound, choose positive witnesses and derive a contradiction from `DataHyp` at one level.
- In the positive branch choose levelwise constants from `main_theorem_scale` and thresholds from `supNorm_concentration_scale` with its common interpolation constant. Take the maximum loss threshold and the common sample threshold, including the bound from `eventually_levels`.
- Apply `joint_assembly` using the levelwise good events and the sum of their probability constants. Specialize to unit scales to obtain `joint_theorem`.
- Build and audit axioms on the branch based at `cd697ad`.

## Verification

- The plan and source discrepancy were recorded at `737b607ae2dd5761eb043ffa87a0757093289781`. The implementation is at `d539965a9ec04c092ebd65b334501abcb6eec1ac` on `t3/thm2-solP2-j7`. Its only Lean change is `lean/BQTF/Joint/Main.lean`.
- Both cases in the frozen witness recipe are covered. In the nonempty, positive-density branch, `Finset.sup'` gives the maximum loss threshold. The sample threshold is the maximum of 1, the eventual threshold, and the per-level thresholds for Theorem 1 and the good events. The unit-scale theorem specializes the general-scale theorem.
- The wrapped full build passed all 8,978 jobs. J7 emitted no warnings and contains no local sorries.
- The scratch `#print axioms` audit reports `[propext, Classical.choice, Quot.sound]` for `mainConclusion_mono` and `[propext, sorryAx, Classical.choice, Quot.sound]` for both public theorems. On this base, the latter inherit the stubs in `denominator`, `localization`, and `shells` through Theorem 1, in J5's `supNorm_concentration_scale`, and in J6's `eventually_levels` and `joint_assembly`.
