# Theorem 2 integration review

## Verdict

**PASS WITH FINDINGS.** J6, J7 and the joint specifications at detached commit `41244d841b8f74520c8ea634a62bb88491be68ba` implement the paper's fixed-grid theorem. The only pending Lean proof dependencies are the three expected Theorem 1 placeholders. The findings concern proof details in the paper and Lean documentation. No blockers or major findings.

## Axioms

Ran `#print axioms` from external scratch files against the prebuilt checkout via `owls_run -j 2 -- lake env lean`. “Standard” means exactly `propext`, `Classical.choice`, and `Quot.sound`.

| Public declaration | Reported axioms |
| --- | --- |
| `mem_orderSet_of_near` (`lean/BQTF/Joint/Transfer.lean:38`) | Standard |
| `prodPosterior_compl_orderSet_le` (`lean/BQTF/Joint/Transfer.lean:67`) | Standard |
| `jointPosterior_jointFarSet_le` (`lean/BQTF/Joint/Transfer.lean:115`) | Standard |
| `eventually_levels` (`lean/BQTF/Joint/Transfer.lean:159`) | Standard |
| `joint_assembly` (`lean/BQTF/Joint/Transfer.lean:189`) | Standard |
| `joint_theorem_scale` (`lean/BQTF/Joint/Main.lean:67`) | Standard plus `sorryAx` |
| `joint_theorem` (`lean/BQTF/Joint/Main.lean:128`) | Standard plus `sorryAx` |
| `JointStatement` and `JointStatementScale` (`lean/BQTF/Spec.lean:221`, `lean/BQTF/Spec.lean:232`) | Standard |

The scratch audit walked all declaration types and bodies reachable from the reviewed theorems, including private and generated declarations. It also ran `#print axioms` on each distinct direct BQTF dependency of the seven theorems and the branches carrying `sorryAx`. Both J7 theorems reach exactly three declarations that directly reference `sorryAx`. The dependency paths below omit the `BQTF.` prefix.

- `joint_theorem → joint_theorem_scale → main_theorem_scale → main_theorem → {denominator, localization, shells}`. The scale proof calls the unit theorem at `lean/BQTF/Reduction.lean:41`. The unit theorem calls the three placeholders at `lean/BQTF/Main.lean:237`, `lean/BQTF/Main.lean:238` and `lean/BQTF/Main.lean:265`.
- `joint_theorem_scale → supNorm_concentration_scale → supNorm_concentration → {denominator, localization}`. The calls are at `lean/BQTF/Joint/Main.lean:84`, `lean/BQTF/Joint/SupNormScale.lean:49` and `lean/BQTF/Joint/SupNorm.lean:192`.
- The exact sources are `BQTF.denominator` (`lean/BQTF/Denominator.lean:36`), `BQTF.localization` (`lean/BQTF/Localization.lean:48`) and `BQTF.shells` (`lean/BQTF/Shells.lean:48`). Each has a direct `sorry`. `quad_shift` reports only the standard axioms (`lean/BQTF/QuadShift.lean:465`). The traversal found zero direct `sorryAx` references in Joint declarations.

`eventually_levels` takes `CI` as a parameter and derives the two inequalities from `eventually_supRad_le` and `etaSeq_tendsto`, both standard-only. It has no J5 concentration premise (`lean/BQTF/Joint/Transfer.lean:159`). `joint_assembly` takes the per-level expectation and measurability bounds as `hmain` and the J5 tail and bad-event bounds as `hΩ` with abstract radii and coefficients (`lean/BQTF/Joint/Transfer.lean:193`). J7 chooses the Theorem 1 and J5 witnesses before introducing the grid and data. It applies `hMain` at each level with the corresponding threshold and `DataHyp`, enlarges the loss threshold with `mainConclusion_mono`, proves `hη0` by positivity, and applies `hSup` at the scaled-concentration threshold to obtain `hΩ`. Both hypotheses are discharged (`lean/BQTF/Joint/Main.lean:82`, `lean/BQTF/Joint/Main.lean:110`).

Scanned for `sorry`, `admit`, `native_decide`, `unsafe`, `axiom`, `set_option` including debug and skip patterns, `implemented_by`, and global instances. No hits in the Joint directory or `Spec.lean`. The broader BQTF scan found the three known placeholders, a locally scoped heartbeat allowance (`lean/BQTF/Main.lean:233`), and ordinary proof instances in `Prob/Symmetrization.lean:22`, `Shift/Rademacher.lean:10`, `Shift/PrekopaLaplace/Tensor.lean:130` and `Shift/PrekopaLaplace/BrunnMinkowski.lean:74` under `lean/BQTF`.

## Freeze

`git diff d9d189e 41244d8 -- lean/BQTF/Joint/Transfer.lean lean/BQTF/Joint/Main.lean lean/BQTF/Spec.lean` passes. Compared each public docstring and declaration header through `:= by` byte for byte. All seven match, including the relocated unit-scale theorem. `Spec.lean` is byte-identical. The two added named helpers are private. The scoped `git diff --check` passed.

## Fidelity

- **Quantifiers and scope.** In both statements, `M,C,n₀` come after `k,J,c,L,f̲,f̄,V̄,gmin` and any fixed scales, and before `n,τ,μ,θ*` (`lean/BQTF/Spec.lean:221`, `lean/BQTF/Spec.lean:232`). For a paper grid with `J ≥ 2`, take `gmin = min_{j<J}(τ_{j+1} − τ_j) > 0`. Its grid satisfies `LevelGrid`. The same witnesses work for every grid of that size with spacing at least `gmin` and all admissible data laws and true curves at every later `n` (`paper/sections/theory.tex:87`, `paper/sections/theory.tex:97`).
- **Hypotheses.** `LevelGrid` encodes interior levels, strict order and the chosen spacing bound. `DataHyp` uses the same marginal probability laws and the same A/B and signal constants at every level. The paper's vector displacement condition is equivalent to the coordinate form by taking a displacement supported on one coordinate. Independence gives the product law `Measure.pi μ`. A and B at `t=L` give `f̄ ≥ f̲ > 0` as soon as there is a sample coordinate and a level. J7 therefore discharges its `f̄ ≤ 0` branch by contradiction with `DataHyp`. Internal `hη0` follows from the factorial times a sum of exponentials, and the penalty and coefficient signs follow from the chosen witnesses. There is no stronger data or grid hypothesis (`lean/BQTF/Spec.lean:107`, `lean/BQTF/Spec.lean:125`, `lean/BQTF/Spec.lean:191`, `lean/BQTF/Joint/Main.lean:76`, `lean/BQTF/Joint/Main.lean:111`).
- **Event and expectation.** For nonempty finite `Fin J`, the strict maximum exceedance is equivalent to an exceedance at some level. Thus `jointFarSet` is exactly `U_M` with the paper's `Δ_n²` loss and threshold `M n^(-(2k+1)/(2k+2))`. Both use `λ_j = c_j n^((2k+1)/2)`. The marginal normalizers are finite and positive and the product gives positive mass to the order set. `jointPosterior_eq_cond` identifies Lean's canceled-normalizer definition with the paper's conditional probability. `JointConclusion` supplies data measurability, so the lower integral is the ordinary expectation of a bounded probability. The finite nonnegative right side is `C n^(-1/(2k+2))` (`lean/BQTF/Spec.lean:61`, `lean/BQTF/Spec.lean:135`, `lean/BQTF/Spec.lean:199`, `lean/BQTF/Joint/Product.lean:217`, `lean/BQTF/Joint/Conditioning.lean:27`, `paper/sections/theory.tex:89`, `paper/sections/theory.tex:104`).
- **Constants and thresholds.** Lean chooses `M = max_l M^(l)` and `C = 2 Σ_l C^(l) + Σ_l (5/4 + 64/(σ₀l f̲)²)`. At unit scales the latter is `2 Σ_l C^(l) + J(5/4 + 64/f̲²)`. Each `M^(l)` includes the factor `max(σ₀l, σ₀l²)` via reduction and is in original units. Increasing `M` shrinks the far set and preserves each single-level bound. The proof chooses `M,C` independently of spacing. It takes the maximum of 1, all single-level thresholds and a common eventual threshold. Each sup-norm threshold exceeds `r=k+1`. The eventual threshold applies to every later `n` and gives each original-unit radius `σ₀l supRad CI k (σ₀l c_l) n ≤ min(L,gmin/f̄)/2` and the sum `Σ_l etaSeq k (σ₀l f̲) n ≤ 1/2`. Finite-level convergence justifies both inequalities. No constant mismatch (`lean/BQTF/Joint/Main.lean:82`, `lean/BQTF/Joint/Main.lean:108`, `lean/BQTF/Joint/SupNormScale.lean:39`, `lean/BQTF/Reduction.lean:41`, `paper/sections/appendix_theory.tex:407`, `paper/sections/appendix_theory.tex:436`).
- **Constraint and transfer.** Each adjacent pair loses at most two half-gaps, preserving weak order even at the boundary. Transitivity gives the full coordinate order. Failure of ordering implies some level tail event, and the first union bound uses the product's exact level marginals. The second union bound uses the conditioned product and order probability at least `1/2`, giving transfer factor `2` (`lean/BQTF/Joint/Transfer.lean:38`, `lean/BQTF/Joint/Transfer.lean:83`, `lean/BQTF/Joint/Transfer.lean:121`, `paper/sections/appendix_theory.tex:414`, `paper/sections/appendix_theory.tex:423`).
- **Potentially nonmeasurable good events.** Lean sets `bad = toMeasurable P (⋃_l Ω_lᶜ)` and `good = badᶜ`. The hull has the outer measure of the union, so its probability is still bounded by the sum of the per-level charges. The complement is measurable and contained in every `Ω_l`. The joint posterior mass is at most 1 everywhere on `bad`, and on `good` the transfer bound integrates to at most twice the sum of the full single-level expectations. This is a split over a measurable partition with no extra event-measurability or level-independence premise (`lean/BQTF/Joint/Transfer.lean:201`, `lean/BQTF/Joint/Transfer.lean:217`, `lean/BQTF/Joint/Transfer.lean:245`).
- **Nonvacuity.** For every `n ≥ 1`, use `k=1`, `J=2`, `τ=(1/4,3/4)`, `gmin=1/2`, `c=(1,1)`, independent uniform `[0,1]` marginals, and constant curves `θ*_{ij}=τ_j`. Take `L=1/4`, `f̲=f̄=1` and `V̄=0`. The CDF is linear on both closed local intervals, so A and B hold with equality. Constant curves have zero second differences. Use `σ₀=(1,1)` for the unit theorem or `σ₀=(1/2,2)` for unequal scales. For every fixed `n,y` the far event has positive posterior mass: shifting both true curves by a common `t>max(1,M·rate)` gives loss `t` and strict order and exceedance on an open neighborhood. The joint density is positive there. The bound is eventually below 1 and tends to zero. Separately, `J=0` is trivial because the event is empty, and `J=1` is a single-level assertion because the constraint is the whole space (`lean/BQTF/Joint/Main.lean:36`, `lean/BQTF/Joint/Main.lean:70`, `lean/BQTF/Spec.lean:82`, `lean/BQTF/Spec.lean:199`).

## Paper candidates

1. **Minor, justify measurability and the expectation split.** `paper/sections/appendix_theory.tex:427`–`paper/sections/appendix_theory.tex:431`, also used at general scales in `paper/sections/appendix_theory.tex:436`. The displayed split requires measurability of posterior evaluations and of the splitting event. The concrete good events admit a measurability proof, but the joint argument does not supply one. The replacement below works with the event bounds interpreted as outer-probability bounds and preserves the constant.

   > For every fixed Borel trend set, the posterior evaluation is measurable in the data. Its numerator and denominator are integrals of nonnegative jointly Borel functions and the denominator is finite and positive. In particular, this applies to the open loss exceedances and the integrals restricted to the closed order set. Let D be a measurable hull of the union of the level bad events under the data law. Its probability is the outer probability of that union, which is at most the sum of the individual outer probabilities. On D use the posterior bound 1. On its complement every level's good-event bound holds, so use twice the sum of the single-level posterior tails.

2. **Minor, supply the side conditions when applying separation and conditioning.** `paper/sections/appendix_theory.tex:412` invokes the gap constant with positive `f̄` and subsequently uses the conditioning lemma with `n>r` (`paper/sections/appendix_theory.tex:362`, `paper/sections/appendix_theory.tex:373`). Both are available from the existing assumptions or by enlarging a threshold. In particular, the supremum-norm argument uses `n>r≥2` for its logarithm bound at `paper/sections/appendix_theory.tex:404`.

   > At displacement L, Assumptions A and B give f̄ ≥ f̲ > 0. Enlarge the supremum-norm threshold n₂ to at least r+1 if necessary. Choose n₀ at least r+1 and at least all single-level contraction and supremum-norm thresholds. Require both eventual inequalities for every n ≥ n₀. Use the same lower threshold r+1 at general scales.

The separation proof already covers both distances at most `L` and greater than `L`. The half-gap boundary is included in the weak ordering. The paper's `J ≥ 2` scope requires no empty-grid clause.

## Minors

- **Nit, state the encoded mass bound in the docstring.** `lean/BQTF/Joint/Transfer.lean:65` writes the bound as `Σ_l η_l`. The signature uses `Σ_l ENNReal.ofReal (η_l)`, the sum of the positive parts in extended nonnegative reals. The forms agree under the nonnegativity supplied in assembly.
- **Nit, stale module overview.** `lean/BQTF/Spec.lean:14` describes Theorem 2 as future work, while the file already defines both statements and J7 proves them.

### Five-line summary

1. PASS WITH FINDINGS for J6 and J7 at `41244d8`.
2. All five J6 declarations use only the standard axioms.
3. Both J7 proofs inherit `sorryAx` exactly from Theorem 1's denominator, localization and shells.
4. The freeze passes, and the specifications imply the paper with the stated constants and a nonvacuous data class.
5. Paper findings concern measurable expectation splitting and explicit conditions for separation and conditioning.

## Lean head rulings (2026-11-26)

- **Verdict: PASS, accepted (J6 and J7).**
  - J6 uses the standard 3 axioms only.
  - Both J7 theorems discharge their assembly hypotheses from J5 and Theorem 1; there is no undischarged hypothesis.
  - The freeze is intact.
  - `JointStatement` and `JointStatementScale` imply thm:joint at unit and at general scales, with matching constants.
  - After the merge I re-ran the axiom check on main, now that Theorem 1 is complete.
- **Paper candidate 1, measurability before the expectation in the thm:joint proof: ACCEPTED as C-11 (minor), slimmed.**
  - This is the joint counterpart of C-02: the paper takes E Π_𝒞(U | y) without stating that y ↦ Π_𝒞(B | y) is measurable.
  - The packet adds only that sentence, with the same Tonelli argument as C-02, applied to the product weight on the closed set 𝒞.
  - The measurable-hull part is REJECTED as exposition. The paper's concrete good events are Borel (the Denominator review proved this for Ω_E), so the hull is a Lean-side device.
- **Paper candidate 2 (f̄ ≥ f̲ > 0 at the gap constant; n₀ ≥ r + 1): REJECTED as exposition.** Both follow from the standing assumptions and n > r, as the reviewer states.
- **Nit, the Transfer.lean:65 docstring writing Σ η_l for Σ ofReal η_l: DEFERRED.** It is a frozen docstring, so Astra decides in the polish pass.
- **Nit, the stale Spec.lean:14 module overview: DEFERRED** to the polish pass. It is a module comment, not a frozen declaration.
