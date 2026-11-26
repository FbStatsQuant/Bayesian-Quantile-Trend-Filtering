# PriorMass review — 2026-11-25

**Verdict: FAIL.** The build and mathematical assembly pass conditional on the upstream lemmas. Two public helpers depend on `sorryAx`, and `prior_mass` has direct proof paths to two unfinished lemmas outside the three named inputs. Findings by severity are **0 blocker, 2 major, 0 minor, 1 nit**.

Reviewed detached commit `7265e3e209f031e4a6e2f17d7a117d41792ed537`. The review worktree had a clean Git status before and after the checks.

## Findings

1. **Major — `lean/BQTF/Prior/Geometry.lean:98`.** `deltaA_priorMatrix` inherits `sorryAx` through the private helper `abs_sCol_succ_sub_le`. That helper calls `bfun_pascal`, whose proof is `sorry`. `prior_mass` invokes `deltaA_priorMatrix` at line 121 to discharge the quadratic shift's adjacent-column condition, so this is an active dependency in addition to the three requested assembly inputs. The Pascal bound is mathematically appropriate. Proving the existing `bfun_pascal` lemma would close this path. [Geometry.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Geometry.lean:98) · [Falling.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Falling.lean:13) · [PriorMass.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:121)
2. **Major — `lean/BQTF/Prior/Window.lean:137`.** The public `prior_smoothed_window` lemma inherits `sorryAx` independently through `gr_pos` at line 137 and `smoothed_truth` at line 180. The latter is one of the allowed inputs to `prior_mass`. The former creates a separate path via the call to `prior_smoothed_window` at `PriorMass.lean:75`. The window argument needs only `Cs r > 0`. Nonnegativity of the Gram quadratic forms and their infima suffices to prove this from the Lean definition of `Cs`. The helper could take the smoothing bound as a hypothesis and `prior_mass` could supply `smoothed_truth`, which would keep the expected smoothing placeholder in the assembly and satisfy the helper-level audit. [Window.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Window.lean:137) · [Smoothing call](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Window.lean:180) · [Gram.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Gram.lean:32) · [PriorMass.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:75)
3. **Nit — `lean/BQTF/PriorMass.lean:4`.** The declaration and docstring are byte-identical to `main` through `:= by`. Outside the proof, the diff also adds `import BQTF.Prior.Window` alongside two private assembly helpers. The import is needed for the helpers used here. The requested description of the surrounding diff as only a module-doc and `open` change omits that import. [PriorMass.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:4)

## Build and axiom audit

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.PriorMass` exited 0. Verbatim output follows.

```text
⚠ [8933/8942] Replayed BQTF.Falling
warning: BQTF/Falling.lean:13:8: declaration uses `sorry`
warning: BQTF/Falling.lean:18:8: declaration uses `sorry`
⚠ [8934/8942] Replayed BQTF.Coord
warning: BQTF/Coord.lean:32:8: declaration uses `sorry`
warning: BQTF/Coord.lean:37:8: declaration uses `sorry`
warning: BQTF/Coord.lean:43:8: declaration uses `sorry`
warning: BQTF/Coord.lean:49:8: declaration uses `sorry`
warning: BQTF/Coord.lean:56:8: declaration uses `sorry`
warning: BQTF/Coord.lean:65:8: declaration uses `sorry`
warning: BQTF/Coord.lean:72:8: declaration uses `sorry`
warning: BQTF/Coord.lean:79:8: declaration uses `sorry`
warning: BQTF/Coord.lean:86:8: declaration uses `sorry`
warning: BQTF/Coord.lean:95:8: declaration uses `sorry`
⚠ [8935/8942] Replayed BQTF.SplineApprox
warning: BQTF/SplineApprox.lean:26:8: declaration uses `sorry`
warning: BQTF/SplineApprox.lean:32:8: declaration uses `sorry`
warning: BQTF/SplineApprox.lean:38:8: declaration uses `sorry`
⚠ [8936/8942] Replayed BQTF.SmallBall
warning: BQTF/SmallBall.lean:31:8: declaration uses `sorry`
⚠ [8937/8942] Replayed BQTF.QuadShift
warning: BQTF/QuadShift.lean:33:8: declaration uses `sorry`
⚠ [8938/8942] Replayed BQTF.Gram
warning: BQTF/Gram.lean:35:8: declaration uses `sorry`
warning: BQTF/Gram.lean:39:8: declaration uses `sorry`
⚠ [8939/8942] Replayed BQTF.Smooth
warning: BQTF/Smooth.lean:17:8: declaration uses `sorry`
Build completed successfully (8942 jobs).
```

`~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/bqtf-prior-review.iBiM6mBS/Audit.lean` and the follow-up audit with `Upstream.lean` each exited 0. Verbatim `#print axioms` output follows.

```text
'BQTF.prior_mass' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.small_ball' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.quad_shift' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.smoothed_truth' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.empNorm_Pperp_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.priorMatrix' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.BA_priorMatrix' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.deltaA_priorMatrix' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.smoothingPower' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.priorBudget' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.priorBudget_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.priorBudget_ge_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.eps_smoothingPower' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.priorBudget_tendsto' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.lamSeq_eq_prior' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.priorBudget_delta_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.prior_smoothed_window' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.bfun_pascal' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.gr_pos' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.Cs' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.ustar' depends on axioms: [propext, Classical.choice, Quot.sound]
```

The axiom list for `prior_mass` contains the standard three axioms and `sorryAx`. Lean lists each axiom once, so the output by itself does not identify which proof paths use `sorryAx`. The two findings above follow from the call sites and the upstream declarations. All other public declarations in `Prior/` passed the axiom check. The three reviewed files contain no local `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `unsafe`, or debug escapes. They contain no `maxHeartbeats` raises. `git diff --check` produced no output.

## Mathematical review

- **Quadratic shift hypotheses.** Set $s=n^{1/(2r)}$, $\varepsilon=\sqrt{\mathrm{epsSq}(r,n)}$, and $\varrho=\varepsilon/2$. For every $n\ge n_1$, the maximum defining $n_1$ gives $n\ge r+2$ and $s\ge4/c$, hence $m=n-r\ge2$. Both $\lambda=c n^{r-1/2}$ and $\varrho$ are strictly positive. The radius $\varrho/4=\varepsilon/8$ lower bound gives $Q_\lambda(B_A(\varrho/4))\ge\exp(-C_8 s)>0$. The actual column estimate yields $\delta_A s\le (2/c)\lambda\varrho$, so dividing by $s>0$ gives $\delta_A\le\lambda\varrho/2$. These bounds use only the size and rate assumptions. In particular, they apply when the truth has zero variation and the admissible class is nonempty. [Threshold and hypotheses](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:89) · [Shift call](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:152)
- **Uniform shift cost.** With $b=2/(2r-1)$ and $C_d=C_{\rm sb}(1+(d/c)^b)$, the eighth-radius estimate gives $\varphi(\varrho/4)\le C_8s$. Together with $\delta_A\ge0$ and the column bound, it gives $K\le8C_8/c$. Thus $H=(1+(8C_8/c)/2)/(1-e^{-2})$ bounds $c_K$ uniformly for all $n\ge n_1$. The centered estimate at $\varrho$ gives the separate contribution $C_2s$. The code chooses $C_{\rm pr}=C_2+HU$, where $U$ is the smoothing-cost constant. This establishes the frozen existential constant. The appendix supplies a sharper explicit constant by taking a larger threshold. [Uniform coefficient](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:133) · [Combined estimate](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/PriorMass.lean:147)
- **Window and variation.** For $\bar V>0$, set $D=(2C_s\bar V)^{-b}$ and $x=nD/s$. This equals the paper's real-valued window before rounding. Eventually $r\le x\le n-r$ and $x/2\le w=\lfloor x\rfloor\le x$. The upper bound on $w$ controls the approximation and $w\ge x/2$ controls the penalty. After contracting by $P^\perp$, the approximation is at most $\varepsilon/2$ and the penalty cost is at most $Us$, with $U=2(cC_s\bar V)^2/D$. If $\bar V\le0$, the hypothesis forces each component of $u^*$ to vanish because $n^{r-1}\lVert u^*\rVert_1\le0$ and $n>0$. The center and cost are zero. The zero-bound case admits truths. With a strictly negative bound no truth meets the hypothesis. A truth with $V^*=0$ is also covered by the positive-bound branch. All constants and thresholds are chosen before $n$ and the truth and depend only on $c,\bar V,r$, with $r=k+1$. [Window threshold](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Window.lean:72) · [Variation cases](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Window.lean:121) · [Rounded window](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Window.lean:171)
- **Geometry and conventions.** The new matrix represents `Asb` in the coordinate bases, so `BA` equals `Bsb` at every radius. The column proof uses the zero-based Pascal difference with argument $i-j-2$. Contraction of $P^\perp$ and the $n^{-1/2}$ normalization pass the pointwise difference bound to the Euclidean column norm without an extra $\sqrt n$. The definitions agree with `Basic.lean` for `Fin` indices, empirical norms, projection, variation, and rates. The helper names describe their statements. [Geometry.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Prior/Geometry.lean:69) · [Basic.lean](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/BQTF/Basic.lean:25)

## Candidate paper corrections

The current proof of Proposition `pf:prop:prior` supports its conclusion and explicit constant under the standing assumptions. The following additions spell out compressed steps.

1. **Window feasibility and the floor.** For $\bar V>0$, write $x=(2C_s\bar V)^{-b}n^{1-1/(2r)}$. Then $x\to\infty$ and $x/n\to0$. Increase $n_1$ so $n\ge2r$ and $r\le x\le n/2$. Thus $r\le\lfloor x\rfloor\le m$ and $\lfloor x\rfloor\ge x-1\ge x/2$. Include one line on contraction by $P^\perp$ when applying the smoothing bound. The appendix already uses a floored window and the right factor of two. [Appendix](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/../paper/sections/appendix_theory.tex:185)
2. **Shift applicability and decay.** State $m\ge2$ explicitly and record positivity of the ball mass at $\varepsilon_n/8$. Pascal's identity and contraction give $\delta_A\le n^{r-2}$, so
   $$
   \frac{\delta_A}{\lambda\varrho}\le\frac{2}{c}n^{-1-1/(4r)},
   \qquad
   K\le\frac{8C_8}{c}n^{-1+1/(4r)},\qquad \varrho=\varepsilon_n/2 .
   $$
   The first bound yields the shift hypothesis eventually. The second uses the small-ball estimate and proves $K\to0$ uniformly with $c,r$ fixed. Since $(1-e^{-2})^{-1}<2$, it also justifies the factor $c_K\le2$ used in the paper. Lean uses a looser uniform bound sufficient for its existential statement. [Appendix](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/../paper/sections/appendix_theory.tex:187)
3. **Zero variation.** In the existing $\bar V=0$ case, state explicitly that $V^*=n^{r-1}\lVert u^*\rVert_1=0$ implies $u^*=0$, so $u^\circ=0$ has zero approximation error. Any nonempty class has $\bar V\ge0$. This is an implicit step in the paper, and Lean handles the real-valued bound by allowing an empty class when $\bar V<0$. The Lean conversions between matrix forms and between `ENNReal` and real-valued logs are formalization details. [Appendix](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW2-7265e3e/lean/../paper/sections/appendix_theory.tex:185)

## Head rulings (2026-11-25)

- **Verdict FAIL is overturned to PASS.** Both "major" findings come from my review brief, which listed only small_ball, quad_shift and smoothed_truth as expected sources of sorryAx. That list was too narrow. `prior_mass` may legitimately use any frozen interface lemma. `bfun_pascal` (Falling) and `gr_pos` (Gram) are frozen interface lemmas, and both are already proved on Neon-A's branch (7c61aea, under review / PASS). Their sorryAx disappears when that batch merges, and I will re-run `#print axioms BQTF.prior_mass` then. I asked for no restructuring of `prior_smoothed_window`.
  - **Finding 1 (major → observation):** sorryAx via `bfun_pascal`. No action.
  - **Finding 2 (major → observation):** sorryAx via `gr_pos` and `smoothed_truth`. No action. Using `gr_pos` for `Cs r > 0` is correct.
- **Finding 3 (nit, the added `import BQTF.Prior.Window` was not described):** accepted; this is an inaccuracy in my brief. No action.
- **Paper candidates 1–3 (window feasibility; shift applicability with m ≥ 2 and K → 0; the zero-variation case):** not corrections. The reviewer states that the current proof supports its conclusion and explicit constant, and that these only spell out compressed steps. I agree; none is a gap.

Merged to main by a path-level merge of 7265e3e (PriorMass, Prior/, the BQTF.lean imports). The full `lake build` is green.
