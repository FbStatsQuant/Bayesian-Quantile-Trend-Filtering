# BQTF scale reduction review

**Verdict — PASS WITH FINDINGS.** One minor paper notation finding. The Lean reduction checks against the frozen statement and depends on the unfinished unit-scale theorem as expected.

| Severity | Count |
| --- | ---: |
| Blocker | 0 |
| Major | 0 |
| Minor | 1 |
| Nit | 0 |

## Review scope

Reviewed the reduction introduced in `622131175a93e237b5c8bd9863f0db9fa97b8062` using the prebuilt, detached worktree at `7265e3e209f031e4a6e2f17d7a117d41792ed537`. The three reviewed files and `Spec.lean` are byte-for-byte unchanged between those commits. `Spec.lean` also has an empty diff against `main`, including `MainStatementScale` at `lean/BQTF/Spec.lean:169`.

The only alteration to existing text in `lean/BQTF/Reduction.lean` outside the theorem proof is the removal of `Owner: head.` from the module doc at line 7. The diff also adds proof support outside the theorem body: the `BQTF.Scale.Data` import, two `open` commands and the private loss and measurability lemmas. The theorem docstring and declaration type are unchanged.

The three reviewed files contain no `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `unsafe`, debug escape or `maxHeartbeats` override. The detached worktree was clean after the checks.

## Build and axiom audit

**Build passed (exit 0).** Ran `~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.Reduction` from the detached worktree’s `lean/` directory. Lake replayed cached dependency warnings. Output verbatim follows.

```text
⚠ [8933/8954] Replayed BQTF.Falling
warning: BQTF/Falling.lean:13:8: declaration uses `sorry`
warning: BQTF/Falling.lean:18:8: declaration uses `sorry`
⚠ [8934/8954] Replayed BQTF.Coord
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
⚠ [8935/8954] Replayed BQTF.SplineApprox
warning: BQTF/SplineApprox.lean:26:8: declaration uses `sorry`
warning: BQTF/SplineApprox.lean:32:8: declaration uses `sorry`
warning: BQTF/SplineApprox.lean:38:8: declaration uses `sorry`
⚠ [8936/8954] Replayed BQTF.CheckLoss
warning: BQTF/CheckLoss.lean:62:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:70:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:75:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:81:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:91:8: declaration uses `sorry`
⚠ [8937/8954] Replayed BQTF.Score
warning: BQTF/Score.lean:33:8: declaration uses `sorry`
⚠ [8938/8954] Replayed BQTF.SmallBall
warning: BQTF/SmallBall.lean:31:8: declaration uses `sorry`
⚠ [8939/8954] Replayed BQTF.QuadShift
warning: BQTF/QuadShift.lean:33:8: declaration uses `sorry`
⚠ [8940/8954] Replayed BQTF.Gram
warning: BQTF/Gram.lean:35:8: declaration uses `sorry`
warning: BQTF/Gram.lean:39:8: declaration uses `sorry`
⚠ [8941/8954] Replayed BQTF.Smooth
warning: BQTF/Smooth.lean:17:8: declaration uses `sorry`
⚠ [8945/8954] Replayed BQTF.Denominator
warning: BQTF/Denominator.lean:30:8: declaration uses `sorry`
⚠ [8946/8954] Replayed BQTF.Width
warning: BQTF/Width.lean:17:8: declaration uses `sorry`
⚠ [8947/8954] Replayed BQTF.Interp
warning: BQTF/Interp.lean:16:8: declaration uses `sorry`
⚠ [8948/8954] Replayed BQTF.Concentration
warning: BQTF/Concentration.lean:25:8: declaration uses `sorry`
⚠ [8949/8954] Replayed BQTF.Localization
warning: BQTF/Localization.lean:37:8: declaration uses `sorry`
⚠ [8950/8954] Replayed BQTF.Shells
warning: BQTF/Shells.lean:35:8: declaration uses `sorry`
⚠ [8951/8954] Replayed BQTF.Main
warning: BQTF/Main.lean:14:8: declaration uses `sorry`
Build completed successfully (8954 jobs).
```

**Axiom audit passed (exit 0).** Ran `owls_run -j 2 -- lake env lean <scratch>/Audit.lean` from the same directory, with the scratch file outside the worktree. The audit ran `#check`, printed axioms for the two main declarations and every public Scale declaration, and inspected the direct constants of the two main declarations for routes to `sorryAx`. Output verbatim follows.

```text
BQTF.main_theorem_scale : BQTF.MainStatementScale
'BQTF.main_theorem_scale' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.main_theorem' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.scaleData' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.scaleData_prob' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.pi_scaleData' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.DataHyp.scale' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.l1norm_diffOp_smul' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.posterior_map_inv_smul' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.measurable_posterior_apply' depends on axioms: [propext, Classical.choice, Quot.sound]
Direct references of BQTF.main_theorem_scale carrying sorryAx: [BQTF.main_theorem]
Direct references of BQTF.main_theorem carrying sorryAx: [sorryAx]
```

`main_theorem` itself is an admitted proof at `lean/BQTF/Main.lean:14`. It is the sole direct route to `sorryAx` in `main_theorem_scale`. Every public Scale declaration uses only the three standard axioms shown above.

## Mathematical review

- **Data, quantiles and Assumptions A and B.** The measurable coordinate map \(S(x)=x/\sigma_0\) pushes the product law to the product of the pushed marginal laws, preserving probability and independence. With \(\sigma_0>0\), the inverse images of both open and closed lower half-lines have endpoint \(\sigma_0 x\), so both quantile inequalities transfer to \(\theta^*/\sigma_0\) at the same \(\tau\). In particular \(F'_i(x)=F_i(\sigma_0 x)\). For \(|t|\le L/\sigma_0\), the new CDF increment is the old one at displacement \(\sigma_0 t\). Its bounds become \(\sigma_0\underline f |t|\) and \(\sigma_0\bar f |t|\). This works for arbitrary probability laws. See `lean/BQTF/Scale/Data.lean:7`, `:17`, `:23` and `:39`.
- **TV and penalty.** Linearity of the difference operator and homogeneity of its \(\ell^1\) norm give \(\operatorname{TV}(\theta^*/\sigma_0)=\operatorname{TV}(\theta^*)/\sigma_0\le\bar V/\sigma_0\). In the posterior exponent, writing \(y=\sigma_0 y'\) and \(\theta=\sigma_0\theta'\) cancels the likelihood’s \(1/\sigma_0\) via positive homogeneity of the check loss. The penalty becomes \(\sigma_0\lambda\|D^{(k+1)}\theta'\|_1\). Thus \(\lambda'=\sigma_0\lambda=\operatorname{lamSeq}(\sigma_0c,k,n)\) and \(c'=\sigma_0c>0\). See `lean/BQTF/Scale/Data.lean:72`, `lean/BQTF/Scale/Posterior.lean:14`, `:21` and `lean/BQTF/Reduction.lean:64`.
- **Haar change of variables.** For the pushforward by \(S\), the factor is \(J=|(\sigma_0^{-1})^{\dim(\mathbb R^n)}|^{-1}=\sigma_0^n\), in the direction used by the code. The weighted measure pushes forward to \(J\) times the weighted unit-scale measure. The normalizing integral has the same factor, and Lean cancels it in \(\mathbb R_{\ge0}\cup\{\infty\}\) using \(0<J<\infty\). The measure identity is valid for the totalized definition even though the helper does not require positivity and finiteness of the normalizing integral. In the theorem’s statistical regime that integral is positive and finite: the check loss at \(0<\tau<1\) is bounded below by \(\min(\tau,1-\tau)|u|\), and the nonnegative penalty only lowers the integrand. See `lean/BQTF/Scale/Posterior.lean:47`.
- **Loss and far set.** For \(a=\max(\sigma_0,\sigma_0^2)>0\), \(\min(\sigma_0|u|,\sigma_0^2 u^2)\le a\min(|u|,u^2)\) by bounding each argument of the minimum. Summation gives \(\Delta_n^2(\sigma_0 v)\le a\Delta_n^2(v)\). Consequently \(\Delta_n^2(\theta-\theta^*)>aM\,\operatorname{rate}(k,n)\) implies \(\Delta_n^2(S\theta-S\theta^*)>M\,\operatorname{rate}(k,n)\). The original far set is contained in the inverse image of the unit-scale far set. Pointwise monotonicity of the mapped posterior gives the bound before integration. Continuity makes the far sets Borel, and joint measurability of the weight gives a measurable posterior evaluation for any fixed Borel set. Transport of the data integral then gives the expectation under the rescaled product law. See `lean/BQTF/Reduction.lean:17`, `:31`, `:51`, `:66` and `lean/BQTF/Scale/Posterior.lean:75`.
- **Uniformity and feasibility.** The unit-scale theorem receives \((k,\sigma_0c,L/\sigma_0,\sigma_0\underline f,\sigma_0\bar f,\bar V/\sigma_0)\). Its \((M,C,n_0)\) are then used as \((aM,C,n_0)\), all chosen before \(n,\tau,\mu,\theta^*\). The two rates keep their original exponents. The data class is nonempty for compatible constants. For example, take independent uniform laws on \([-1,1]\), \(\tau=1/2\), a zero target and \(L=1\), \(\underline f=\bar f=1/2\), \(\bar V=0\). For \(n\ge1\) the assumptions with \(L>0\) force \(\bar f\ge\underline f\) and the signal bound forces \(\bar V\ge0\). Allowing arbitrary real values in the statement handles infeasible choices by implication. The scale map is applied to data only with \(\sigma_0>0\). See `lean/BQTF/Reduction.lean:39` and `lean/docs/statements.md:71`.
- **Helpers and conventions.** The helper names match their statements. In particular `posterior_map_inv_smul` maps in the direction indicated by the name, `DataHyp.scale` transports all five fields, and `l1norm_diffOp_smul` explicitly restricts its scalar to the nonnegative case. The proof uses `Fin n → ℝ`, the explicit \(\ell^1\) norm, order \(r=k+1\), the TV factor \(n^k\), and `Measure.pi μ` as in `lean/BQTF/Basic.lean:7` and `:133`.

## Findings

1. **Minor — `paper/sections/appendix_theory.tex:49`.** The sentence giving the transformed assumptions uses \(V^*\le\bar V/\sigma_0\), although \(V^*\) was defined at line 22 as TV of the original target. Read literally, this can fail for \(\sigma_0>1\) when the original target attains the positive bound \(\bar V\). The bound applies to the rescaled target, whose TV is \(V^*/\sigma_0\). The Lean proof uses the rescaled target in this inequality.

## Candidate paper corrections

- Write \(\theta^{*\prime}=\theta^*/\sigma_0\) and \(\operatorname{TV}^{(r)}(\theta^{*\prime})=V^*/\sigma_0\le\bar V/\sigma_0\) at `paper/sections/appendix_theory.tex:49`. The CDF relation \(F_{y_i/\sigma_0}(x)=F_{y_i}(\sigma_0 x)\) also states in one line how the quantile and both assumptions transfer.
- The same paragraph can make the posterior and expectation transport explicit by saying that the common Jacobian \(\sigma_0^n\) cancels in the posterior ratio and that expectations use the pushforward of the original product law.
- The paragraph already gives the correct non-homogeneous loss bound and the multiplier for \(M\). An optional clarification is to state the resulting far-set inclusion and record \((M_{\sigma_0},C_{\sigma_0},n_{0,\sigma_0})=(\max(\sigma_0,\sigma_0^2)M',C',n_0')\), where the primed constants come from the unit-scale theorem for the transformed inputs. The omitted details are routine consequences of the stated reduction. The explicit Borel and measurability proofs in Lean formalize those steps.

## Head rulings (2026-11-25)

- **Finding 1 (minor, paper line 49: "V* ≤ V̄/σ₀"):** accepted as correction **C-05**. I checked it. Line 22 defines V* = TV^{(r)}(θ*) for the original target. Line 49 needs the TV of the rescaled target θ*/σ₀, which is V*/σ₀ ≤ V̄/σ₀. As written, the inequality fails for σ₀ > 1 when V* = V̄ > 0. Lean (`main_theorem_scale`) uses the correct rescaled bound.
- **Paper candidates 2–3 (spell out the Jacobian cancellation; record the explicit rescaled constants):** not corrections. The reviewer calls them routine, optional details, and I agree.

Merged to main by a path-level merge of 7265e3e (Reduction, Scale/, the BQTF.lean imports). The full `lake build` is green.
