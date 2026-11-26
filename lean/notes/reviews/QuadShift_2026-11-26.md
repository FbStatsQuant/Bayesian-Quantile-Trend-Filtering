# Quadratic shift review — 2026-11-26

## Verdict

**PASS WITH FINDINGS.** The Lean proof, frozen interface, merge, and `prior_mass` axiom audit pass at detached commit `e9477b2`. The Lean theorem implies the paper's bound for every positive radius. The paper should state that domain explicitly and restrict the first use of the logarithmic slice bound to the integration band.

## Axioms

From `lean/`, `~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/sol-qs.SHfPtF/Ax.lean` exited 0. All 24 `#print axioms` queries returned exactly `[propext, Classical.choice, Quot.sound]`.

| File | Checked declarations (all in `BQTF`) |
| --- | --- |
| `lean/BQTF/QuadShift.lean:465` | `quad_shift` |
| `lean/BQTF/PriorMass.lean:63` | `prior_mass` |
| `lean/BQTF/Shift/LaplaceMeasure.lean:10` | `continuous_laplacePDF`, `laplacePDF_nonneg`, `continuous_laplaceWeight`, `laplaceWeight_nonneg`, `Qlam_translate`, `Qlam_neg_preimage`, `Qlam_lintegral_insertNth` |
| `lean/BQTF/Shift/ScalarBounds.lean:13` | `continuous_shiftExcess`, `shiftExcess_nonneg`, `shiftExcess_le_abs`, `abs_add_abs_sub_eq_excess`, `lintegral_shiftExcess`, `lintegral_laplace_band` |
| `lean/BQTF/Shift/SliceBounds.lean:11` | `continuous_l2norm`, `l2norm_toE`, `l2norm_add_le`, `l2norm_smul_real`, `l2norm_neg_eq`, `measurableSet_laplaceSlice`, `laplaceSlice_mono_radius`, `laplaceSlice_le_center`, `laplaceSlice_center_log_loss` |

The source scan of the review files and `Coord.lean` found zero hits for `sorry`, `admit`, `native_decide`, `unsafe`, `axiom`, `set_option`, `implemented_by`, and global instance declarations or registrations. The probability instances in the new proofs are local bindings. The axiom result for `prior_mass` covers its transitive proof dependencies, including its shift call at `lean/BQTF/PriorMass.lean:152`.

## Freeze/merge

- `git diff main...e9477b2 -- lean/BQTF/QuadShift.lean` preserves the names, types, and docstrings of all three pre-existing declarations. The `BA` and `deltaA` definitions are byte-identical, as is the `quad_shift` docstring and signature through `:= by`. The diff removes the original `open` line and the `sorry` proof. See `lean/BQTF/QuadShift.lean:22` and `lean/BQTF/QuadShift.lean:461`.
- The merge base is `0aa30fc`, also the second parent of `e9477b2`. `Basic`, `Coord`, `PriorMass`, and the proved `PrekopaLaplace` modules match that parent and the local `main` in the reviewed paths. The merge kept the proved Prékopa theorem from that parent when resolving the add/add conflict with the branch stub. `LaplaceMeasure` imports `Coord` and uses `laplace_isProbabilityMeasure`, `Qlam_isProbabilityMeasure`, and `Qlam_eq_withDensity` from `lean/BQTF/Coord.lean:443`, `:456`, and `:486`. It uses the existing `laplacePDF`, `laplace`, and `Qlam` from `lean/BQTF/Basic.lean:90`. The `laplaceWeight` abbreviation names the same pointwise expression used by Coord's density theorem and makes its integration rewrites definitional. See `lean/BQTF/Shift/LaplaceMeasure.lean:18` and `:38`.
- The umbrella adds exactly the three requested helper imports and keeps every pre-existing import in order. The current `lean/BQTF.lean` source passed `~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean BQTF.lean` from `lean/`. The imports also expose the helper API directly. See `lean/BQTF.lean:10`.

## Fidelity

- `lean/BQTF/QuadShift.lean:465` covers any finite real matrix with at least two columns and every shift. The index type in `deltaA` is finite and nonempty given `m ≥ 2`, so its supremum is the paper's maximum over consecutive pairs. `{u | u - h ∈ BA A ϱ}` equals the translate `h + B_ϱ`, and `l2sq h` is `∑ i, h i ^ 2`. The mass and exponential are finite, so passing from the Lean inequality in `ℝ≥0∞` to the real inequality preserves the bound.
- The constants match `paper/sections/appendix_theory.tex:153` exactly. The adjacent-column threshold is `λϱ/2`, the log cost uses radius `ϱ/4`, and the formulas are `K = 4 δ_A φ(ϱ/4)/(λϱ)` and `c_K = (1 + K/2)/(1 - e^{-2})`. The exponent is `-c_K λ² ‖h‖₂²`. The exact band integral supplies `(1 - e^{-(2+K)})/(2+K)` and the proof uses `K ≥ 0` to obtain the paper's `(1 - e^{-2})/(2+K)`. See `lean/BQTF/Shift/ScalarBounds.lean:82` and `lean/BQTF/QuadShift.lean:310`.
- `hlam` makes explicit the domain of the paper's Laplace probability law. The density definition names that law in `paper/sections/appendix_theory.tex:58`, and the model sets `c > 0` in `paper/sections/theory.tex:62`. The printed lemma omits `hϱ`, which is required for its formula to be defined (candidate a). The explicit `hpos` is redundant for every positive rate and radius. The strict preimage `{u | ‖Au‖₂ < ϱ/4}` is an open neighborhood of zero by continuity, and Lebesgue measure assigns it positive mass. The strictly positive product Laplace density gives it positive `Q_λ`-mass. This holds for zero and rank-deficient matrices as well. Consequently the hypotheses cover the full positive-radius domain. The scratch theorem `BQTF.review_BA_pos` in `/tmp/sol-qs.SHfPtF/Fidelity.lean` verifies this for every positive radius and uses exactly the same three allowed axioms.
- The proof bounds the unnormalized coordinate excess directly by factoring the product law and using the centered slice maximum. This gives the same conditional excess bound as the paper's marginal density argument once normalized. The proof then uses symmetry, the convexity of the exponential, and Jensen to yield the stated shift bound. See `lean/BQTF/QuadShift.lean:320`, `:409`, and `:505`.

## Paper candidates

### (a) Positive radius

**Major — genuine statement gap.** `paper/sections/appendix_theory.tex:151` begins “Let $m\ge2$, $A$ any real matrix with columns $a_1,\dots,a_m$, $B_\varrho$ and $\varphi$ as above for this $A$,” and assumes “If $\delta_A\le\lambda\varrho/2$.” Line 153 defines “$K=\frac{4\delta_A\varphi(\varrho/4)}{\lambda\varrho}$.” The preceding small-ball lemma's “for all $n>r$, $\lambda>0$, $\varrho>0$” at line 137 is scoped to that lemma. The shared definitions at line 134 impose no radius restriction.

For `ϱ = 0`, a matrix with identical columns satisfies the adjacent-column hypothesis. The choice `A = 0` already gives `K = 0/0`. For a nonzero matrix with identical columns, the zero-radius ball lies in a proper linear subspace and has probability zero, so the log and conditional probability also fail to be defined as used in the proof. The paper's application at line 187 chooses `ϱ = ε_n/2 > 0`.

Suggested opening for line 151. “Let $m\ge2$, $\lambda>0$, and $\varrho>0$. Let $A$ be any real matrix with columns $a_1,\dots,a_m$, and define $B_\varrho$ and $\varphi$ as above for this $A$. Set $\delta_A=\max_{j<m}\|a_{j+1}-a_j\|_2$.”

### (b) Domain of the logarithmic slice bound

**Minor — genuine local domain gap as written.** `paper/sections/appendix_theory.tex:160` defines “$\Lambda(s)=\log Q_{-j}\{\|A_{-j}v\|_2\le s\}$” and immediately says “Shifting $v$ by $-te_{j'}$ gives $g(t)\ge e^{-\lambda|t|}e^{\Lambda(\varrho-|t|\delta_A)}$.” The same line later restricts the slope argument with “For $|t|\le1/\lambda$, $a=|t|\delta_A\le\varrho/2$.”

The later restriction covers every use in the integral estimate, so the proof needs only a local domain clarification. The first inequality as printed can invoke the real logarithm of zero. For instance, `λ = 1`, `ϱ = 2` and `A = [0, 1]` satisfy the hypotheses, and `t = 3` gives reduced radius `-1`. An explicitly extended-real convention would also define that expression. Lean states the unrestricted translation bound directly in probabilities at `lean/BQTF/QuadShift.lean:176`, then bounds the log cost only for `|t| ≤ 1/λ` at `:258`.

Suggested wording for the first use. “For $s>0$, write $\Lambda(s)=\log Q_{-j}\{\|A_{-j}v\|_2\le s\}$. For $|t|\le1/\lambda$ we have $\varrho-|t|\delta_A\ge\varrho/2>0$. Shifting $v$ by $-te_{j'}$ gives $g(t)\ge e^{-\lambda|t|+\Lambda(\varrho-|t|\delta_A)}$.” The subsequent concavity claims apply on `(0, ∞)`.

No further mathematical gaps surfaced in the quadratic-shift argument.

## Minors

- **Minor — `lean/BQTF/Shift/SliceBounds.lean:15`.** The norm identification, triangle inequality, scalar rule, and measurable-slice theorem repeat existing results in `lean/BQTF/Shift/PrekopaLaplace/Slice.lean:16`, `:21`, `:25`, and `:35`. The names live in distinct namespaces. The new API can reuse the existing proofs directly.
- **Nit — `lean/BQTF/QuadShift.lean:11`.** The module header still calls Prékopa and Borell “Classical inputs expected.” It can describe the proved Prékopa–Leindler slice result and its two uses in `SliceBounds`. The frozen theorem docstring already describes the result.

## Summary

- PASS WITH FINDINGS at `e9477b2`.
- `quad_shift`, `prior_mass`, and all 22 public helper theorems use only the allowed axioms.
- Frozen declarations, the umbrella import check, and Coord/Prékopa integration pass.
- The Lean bound and constants match the paper for positive radii, with automatic positive small-ball mass.
- State `ϱ > 0` in the paper and put the integration band before the first reduced-radius logarithm.

## Lean head rulings (2026-11-26)

- **Verdict: PASS, accepted.** I re-ran the axiom check on main after the merge. `quad_shift` and `prior_mass` use only propext, Classical.choice and Quot.sound. The full build is green (8974 jobs).
- **(a) Positive radius: ACCEPTED as paper correction C-10(a), major.** With ϱ = 0, the printed lemma defines K = 0/0, and the small-ball mass can vanish. Lean assumes `hϱ`. The paper's only use (line 187, ϱ = ε_n/2) is positive, so no downstream statement changes.
- **(b) Domain of Λ: ACCEPTED as C-10(b), minor.** The band restriction |t| ≤ 1/λ already covers every use in the integral. The first display, however, can take log 0 for large |t|. The fix is a reorder of the existing sentence, and no constant changes.
- **Minor, SliceBounds duplicates PrekopaLaplace/Slice helpers: DEFERRED** to the polish pass. It is a cleanup only; both copies are proved.
- **Nit, QuadShift header still says "Classical inputs expected": DEFERRED** to the polish pass.
- **The redundant `hpos` hypothesis**, which follows from ϱ > 0 and λ > 0 per the reviewer's scratch proof `review_BA_pos`, is a nit. It only weakens nothing: the Lean statement still implies the paper's. Recorded for the polish pass; the frozen statement stays as is.
