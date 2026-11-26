# Review of `BQTF.Prob.EfronStein`

**Verdict: FAIL.** 1 blocker, 0 major, 0 minor, 0 nit. The proof, build, and axiom audit pass. The source declaration fails the explicit byte-for-byte freeze.

Reviewed detached commit `532ef3c0a4da81daa0a0d4bab6eb27e0e3ed2760`.

## Findings

1. **Blocker. The source omits the qualified theorem name required by the freeze.** The supplied first line begins `theorem BQTF.Prob.efronStein_oneSided`, while the source begins `theorem efronStein_oneSided`. The enclosing `namespace BQTF.Prob` gives the declaration the expected fully qualified Lean name. After stripping the proof delimiter and adding the namespace prefix, `cmp` confirms that the full statement matches. To satisfy the literal freeze, close the namespace before the final theorem and spell out the names of the theorem and its auxiliary proof. A scratch copy of the module with this change elaborated successfully. [Declaration](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:276), [namespace](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:17).

## Statement and finiteness

The elaborated statement is the positive-part form in Boucheron, Lugosi, and Massart, Theorem 3.1, p. 54. Under `Measure.pi μ`, the entries of `y` are independent, and the inner integration draws an independent replacement `z` of law `μ i`. The coefficient of each squared positive-part term is one. Exchangeability under swapping the old and new coordinate explains why the squared positive part has half the expectation of the full squared difference. [Theorem 3.1](https://math.hse.ru/data/2016/11/24/1113029206/Concentration%20inequalities.pdf), [publisher’s chapter](https://doi.org/10.1093/acprof:oso/9780199535255.003.0003), [Lean statement](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:276).

Mathlib’s `MemLp.evariance_lt_top` gives finite extended variance for `hf`, and `MemLp.ofReal_variance_eq` identifies it with the ordinary variance embedded in `ℝ≥0∞`. On the right, for each `i` use `(x − x′)₊² ≤ 2x² + 2(x′)²` with `x = f(y)` and `x′ = f(update y i z)`. The resampling integral identity gives the same second moment for `x′` as for `x`. Each summand is bounded by `4 ∫ f² d(Measure.pi μ)`, which is finite by `hf.integrable_sq`. The sum is finite for every allowed `f`, including bounded measurable functions in Concentration. A scratch Lean proof confirmed that the full right-hand side is strictly below `⊤` under the frozen hypotheses. [Variance finiteness used by the induction](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:225), [variance conversion](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:29), [resampling integral](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:147).

## Proof and hygiene checks

- **Total variance.** Fubini identifies the product mean with the mean of the section means. The square-decomposition lemma with this mean as the constant gives the section variance plus the squared deviation of the section mean. The section calculation applies almost everywhere by Fubini on `F²`. Splitting the resulting nonnegative integral yields the two terms of the ENNReal equality. [Square decomposition](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:24), [product identity](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:116).
- **One-coordinate factor.** Swapping two independent draws from `ν` equates the squared positive and squared negative contributions. Their sum is the full squared difference, which integrates to twice `evariance` by the square decomposition and `ν(univ) = 1`. The proof uses the strict-order contradiction in ENNReal to derive the needed inequality from `P + P = E + E`. [One-coordinate bound](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:43).
- **Pointwise Jensen.** `L²` of `D` implies `L²` of `D₊` by domination. Monotonicity of integration gives `(∫ D)₊ ≤ ∫ D₊`. Squaring these nonnegative quantities preserves the order, and the nonnegative variance of `D₊` gives `(∫ D₊)² ≤ ∫ D₊²`. [Jensen helper](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:79).
- **Almost-everywhere resampling.** The singleton marginal is idempotent by `Function.update_idem` and preserves the full integral via `lintegral_eq_of_lmarginal_eq`. Applying this to the indicator of a measurable null superset of the exceptional set gives zero double integral, then two applications of `lintegral_eq_zero_iff` give the required nested almost-everywhere assertion. This works for an arbitrary predicate. [Marginal identity](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:147), [null sets](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:156).
- **Section means and induction.** The total Bochner integral defining `g` is measurable, and the total-variance equality bounds `evariance g` by finite product variance, giving `MemLp g 2`. The coordinate-zero inequality uses only `L²` sections. In the successor-coordinate inequalities, the section at `w` is `L²` almost everywhere and the section at the updated `w` is `L²` for almost every resample by `ae_ae_update`. Thus every use of Jensen and `integral_sub` has integrable sections, independently of the Bochner integral’s default values on exceptional sections. `Fin.sum_univ_succ` combines the coordinate-zero term with the inductive bounds, and the zero-dimensional base gives constant variance zero. [Base case](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:189), [section means](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:222), [successor coefficients](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:247).
- **Module and API.** The names describe the results, the file has a module docstring, and it imports only `Mathlib`. Source scan found no `sorry`, `admit`, custom `axiom`, `native_decide`, `implemented_by`, `unsafe`, heartbeat override, or debug escape. In the pinned Mathlib, `variance_map_equiv` is the real-valued counterpart of the extended-variance helper, and `integral_condVar_add_variance_condExp` is a conditional-expectation formulation of total variance. The local helpers give the ENNReal and product-section formulations used by this proof. The implementation already uses Mathlib’s marginal integration and variance lemmas. [Module](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF/Prob/EfronStein.lean:1), [Mathlib variance API](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/.lake/packages/mathlib/Mathlib/Probability/Moments/Variance.lean:333), [Mathlib total variance](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/.lake/packages/mathlib/Mathlib/Probability/CondVar.lean:134).
- **Diff scope.** `git diff main...HEAD` against merge base `c512269b91b23b5743c9b810637c432ba045758b` shows exactly the three expected paths. `lean/BQTF.lean` gains exactly `import BQTF.Prob.EfronStein`, and `git diff --check main...HEAD` is clean. The direct tree comparison against `main` at `0e2f0fc4fa46fcfb88c0eef348283a6839e08842` also contains independent main-side changes since the fork, including the later Contraction import. [Umbrella import](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/BQTF.lean:26), [worker log](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-cpopus1-532ef3c/lean/notes/logs/cp_opus1_progress.md:1).

## Candidate paper corrections

C-06 is supported by this review. The main checkout’s variance proof already uses the positive-part bound with a maximizer at the original sample and cites Theorem 3.1. For a fixed original sample, the same maximizer bounds every positive coordinate decrease. After integrating out the replacement, summing those pointwise bounds gives at most `sup_{δ ∈ K} ‖δ‖₂²` before taking expectation over the original sample, so the variance step only needs a pointwise maximizer. No further paper correction arises from the reviewed module. [C-06](/home/fb31/Bayesian-Quantile-Trend-Filtering/lean/notes/PAPER_CORRECTIONS.md:72), [concentration proof](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/appendix_theory.tex:235).

## Verbatim build output

Command run from the review worktree’s `lean` directory using `~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.Prob.EfronStein`. Exit status 0.

```text
Build completed successfully (8931 jobs).
```

## Verbatim axiom output

The scratch file imported `BQTF.Prob.EfronStein` and ran `#print axioms` on all nine public declarations. It ran from the review worktree’s `lean` directory with `~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/sol-es-review.UZrHK0/Audit.lean`. Exit status 0.

```text
'BQTF.Prob.efronStein_oneSided' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.lintegral_sq_sub_const' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.evariance_le_lintegral_posPart_sq' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.ofReal_posPart_sq_integral_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.evariance_comp_measurePreserving' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.evariance_prod_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.lintegral_lintegral_update' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.ae_ae_update' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Prob.efronStein_oneSided_aux' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Head rulings (Lean head, 2026-11-25)

- **F1 (blocker) — overturned, so the verdict is now PASS. Merge approved.** The freeze is a constraint on the elaborated declaration, meaning its fully qualified name and its type, and not on the spelling of the source. The reviewer confirmed that `BQTF.Prob.efronStein_oneSided` elaborates to exactly the frozen statement. Writing the declaration inside `namespace BQTF.Prob` is the house convention: CheckLoss, Contraction and EckartYoung use it too. Downstream, Concentration consumes the declaration by its qualified name. No change is required.
- Candidate C-06: support noted. C-06 stays open until Concentration is finalized, and Theory's verdict is pending.
- Merged into main together with EckartYoung, Width and SplineApprox. The full build is green at 8963 jobs, and `#print axioms BQTF.Prob.efronStein_oneSided` shows only the 3 standard axioms.
