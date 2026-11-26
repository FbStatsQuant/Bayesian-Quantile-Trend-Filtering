# Independent final audit at 5c3d923

**CLEAN.** All four compiled propositions imply their paper counterparts. All three rulings hold. The two public appendix interfaces discussed below are weaker than their paper lemmas. Neither difference reaches either top-level theorem. The checkout was detached at 5c3d92369dfe24dfff33ce2b4122596b6aeb98f4. I audited the supplied prebuilt checkout. Lean module references below are relative to lean/BQTF and paper references to paper/sections.

## (a) Score — ruling HOLDS

The historical axiom failure was real (Score_2026-11-25.md:3,102). Score.lean:815–816 still calls the two implicated lemmas, now implemented in SplineApprox.lean:28,875. Direct transitive axiom checks below clear each and score_events itself. Main.lean:326 uses the score estimate.

## (b) Denominator — ruling HOLDS

The reviewer found three admitted leaves through prior_mass at e2ceac0 (Denominator_2026-11-26.md:5–25,90). Both denominator and prior_mass now pass direct transitive axiom checks.

The paper fixes Cpr by a formula and obtains an eventual shift coefficient ≤2 (appendix_theory.tex:179–187). Its evidence lemma uses CE=(5/4)C₁+1+Cpr and the prior cutoff (line 194). PriorMass.lean:63–93 uses C₂+H U with H=(1+Kmax/2)/(1−exp(−2)). Denominator.lean:338–350 adds the same (5/4)C₁+1 to its own existential prior witness. It retains the complement bound 5/(4nε²). Its public cutoff permits dependence on margin constants, although the proof takes the prior cutoff. One cannot extract the paper's particular quantitative bound from this interface.

Main.lean:235–240 takes CE and the cutoff before n, level, law and truth. The main bound permits precisely this uniform choice and only asserts existence of the final M,C,n₀. Reduction.lean:39–46 reuses it. Joint/SupNorm.lean:192 uses denominator too. Neither theorem prescribes CE or a numerical final multiplier.

## (c) Joint sup norm — ruling HOLDS

The J4/J5 review correctly identifies a literal loss at the appendix interface (JointSupNorm_2026-11-26.md:5,60). Compare appendix_theory.tex:390–401 with Joint/SupNorm.lean:182–190. An existential event cannot guarantee the estimate on a previously prescribed intersection. The proof does construct the intersection at line 204 and bounds its complement at line 256. J5 calls J4 at Joint/SupNormScale.lean:49. Joint/Main.lean:84–88 obtains these estimates, then lines 114–125 pass the per-level witnesses to joint assembly. Only the pointwise bound on each witness and the probability of its complement are needed. Theorem 2 averages over the entire data law and specifies no good event. Joint/Main.lean:128–130 specializes the scaled result to unit scales.

## MainStatement — Theorem 1, unit scale

**Hypotheses** (Spec.lean:104–136,167–173 and theory.tex:17–51,57–66).

1. The order is a natural k≥1, the level lies strictly between zero and one, and c,L,f̲ are positive. Finite f̄,V̄ are real numbers. For nonempty admissible data with n≥1, the margins imply f̄≥f̲, and TV implies V̄≥0.
2. Each μᵢ is a probability law. The law of any vector of independent real observations is their product, exactly Measure.pi μ. Distinct marginal laws and infinite data moments are allowed.
3. The left-open and right-closed quantile inequalities bracket τ. B forces the left limit at the quantile to equal its CDF value and hence both equal τ. A gives strict growth on both sides relative to this point, ensuring uniqueness. A and B use the same closed perturbation radius.
4. TV is nᵏ times the sum of absolute order-(k+1) forward differences. Writing r=k+1, the alternating binomial stencil includes l=0,…,r, on n−r rows. Its last row ends at index n−1. There is no boundary or scale change. Any asymptotic cutoff can be enlarged past r.
5. At σ=1 the working check loss uses yᵢ−θᵢ and indicator u<0. The density relative to Lebesgue measure multiplies its likelihood by exp(−λ‖Dθ‖₁), flat along the polynomial kernel. λ=c n^((2k+1)/2), hence λ/nᵏ=c√n. The factors λᵐ and [τ(1−τ)/σ]ⁿ cancel at fixed hyperparameters (Spec.lean:45–78, methodology.tex:17–38). Basic.lean:25–41 distinguishes Euclidean and empirical norms. Its product Laplace prior in difference coordinates and relative-likelihood integral at Basic.lean:91–115 are proof objects. The public posterior uses the original density.
6. The witnesses M,C>0 and natural n₀ follow only k,c,L,f̲,f̄,V̄. All three precede n, τ, μ and θ*. A bound for each admissible row implies uniformity over the paper's arrays.

**Conclusion.** Spec.lean:140–158 integrates the measurable posterior probability of the strict event Δ²ₙ(θ−θ*)>M n^(-(2k+1)/(2k+2)) against the true product law. Δ²ₙ(v)=Σ min(|vᵢ|,vᵢ²)/n. The upper bound is C n^(-1/(2k+2)), without a logarithm. The nonnegative finite right side embeds faithfully into the extended nonnegative reals. **Top-level gaps: none.**

## MainStatementScale — Theorem 1, fixed positive scale

**Hypotheses.** Spec.lean:176–182 retains the order, tuning, quantile, independent probability laws, common margins and TV bound above. It adds σ₀>0 before the constants. Only the check-loss sum divides by σ₀ in the original posterior. The prior has the original λ. The paper conditions on tuning and scale, so the sampler's hyperpriors impose no premise (theory.tex:66,119–125).

**Conclusion.** Same original-coordinate loss, event, expectation and exponents. M,C,n₀ may additionally depend on σ₀. Reduction.lean:39–53 uses transformed inputs σ₀c,L/σ₀,σ₀f̲,σ₀f̄,V̄/σ₀ internally and multiplies M by max(σ₀,σ₀²), as in appendix_theory.tex:49. **Top-level gaps: none.**

## JointStatement — Theorem 2, unit scales

**Hypotheses** (Spec.lean:191–196,221–228 and theory.tex:85–106).

1. Fix k≥1, finite J, positive cⱼ, scale one at each level, and λⱼ=cⱼ n^((2k+1)/2). For a paper grid with J≥2 choose its positive minimum adjacent spacing as gmin. Membership, strict order, and every consecutive comparison through the last pair then hold.
2. All levels use one vector of independent observations and the same μ. For each j the stated quantile, both margins at common L,f̲,f̄, and TV≤V̄ are exactly the single-level premises. No additional separation of the truth or independence across levels is assumed.
3. k,J,c,L,f̲,f̄,V̄,gmin precede positive M,C,n₀, which precede n, the grid, μ and all truths. Absolute grid locations cannot enter the constants.

**Conclusion.** Spec.lean:80–102,199–212 uses the product of level weights at the same y, restricted and normalized on trends weakly increasing in j at every i. This matches methodology.tex:172–183 and theory.tex:89–93. Joint/Product.lean:217 identifies the conditional-product ratio. Joint/Conditioning.lean:27 proves positive conditioning probability. The finite union inside the joint posterior is exactly the strict maximum-loss event. Its expectation under the original law has both exponents of Theorem 1. Joint/Main.lean:90–94 chooses the maximum radius multiplier and twice the sum of level mass constants plus the summed bad-event coefficients. **Top-level gaps: none.**

## JointStatementScale — Theorem 2, fixed level-specific scales

**Hypotheses.** Spec.lean:232–239 retains the three joint hypothesis groups above and places arbitrary positive σ₀ⱼ before the constants. Each level divides its own check loss by its own scale. Penalties and the common margins and TV bounds are in original units. No ordering or equality of scales is assumed.

**Conclusion.** The posterior restricts the original trends to the same weak order even when scales differ. The same simultaneous tail event, original-data expectation and exponents hold with constants additionally allowed to depend on the scale vector (theory.tex:106). Joint/Main.lean:83–94,109–125 assembles the per-level estimates in original coordinates. **Top-level gaps: none.**

## Direction of each documented difference

| Entry | Check |
|---|---|
| D1 | Equivalent. Insert a scalar at one coordinate and zero elsewhere. Conversely each coordinate of an admissible vector obeys the scalar bound. |
| D2 | Equivalent by the no-atom and strict local growth arguments above. CDF monotonicity excludes quantiles farther away. |
| D3 | Stronger conclusion. Measurability makes the lower integral the actual expectation of posterior probability. |
| D4 | Equivalent for the paper regime. Coord.lean:747 proves properness for n≥1, interior τ, σ>0 and λ≥0. Totalization cannot produce a spurious zero posterior there. |
| D5 | Equivalent. Joint/Product.lean:217 cancels positive finite level normalizers for measurable events. Joint/Conditioning.lean:27,82–83 addresses the remaining truncation denominator. |
| D6 | Safe. Taking the minimum adjacent gap gives the paper's exact dependency. A pre-constant lower bound gives at least that uniformity. |
| D7 | Safe. All natural J include J≥2. At J=0 the bad event is empty. At J=1 ordering imposes no restriction. |
| D8 | Stronger joint conclusion by the measurability argument of D3. |
| D9 | Equivalent on paper grids. A finite nonempty maximum exceeds a threshold exactly when one entry does. |
| D10 | Weaker explicit appendix coefficients, sufficient for both theorems as traced in (b). The paper's K→0 gives c_K→1/(1−exp(−2))<2 (appendix_theory.tex:153,187). |
| D11 | Safe. Joint/Gap.lean:115 derives the pairwise result using B at the lower quantile. Line 149 specializes it to adjacent pairs with min(L,gmin/f̄), deriving f̄>0 at line 157. Joint/Transfer.lean:46 uses the result. |
| D12 | Weaker prescribed-event appendix interface, sufficient for both joint conclusions by the witness use in (c). |

**Severity and nonvacuity.** No blocker, major or minor fidelity gap in the four top-level statements. D10 and D12 limit standalone appendix claims. No unresolved paper ambiguity affects the implications. For example, independent uniforms on [0,1] at levels 1/3 and 2/3 satisfy both margins with L=1/4 and f̲=f̄=1. The constant trends have zero TV, the spacing is 1/3, and arbitrary fixed positive scales and penalty coefficients work.

## Axioms and source scan

From lean/, the following command exited 0. AxiomCheck.lean:9–10,17–18 contain the four required type assignments. Exact output follows.

```sh
~/.config/bvs-hq/owls/owls_run -j 1 -- lake env lean AxiomCheck.lean
```

```text
'BQTF.main_theorem' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.main_theorem_scale' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.joint_theorem' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.joint_theorem_scale' depends on axioms: [propext, Classical.choice, Quot.sound]
```

The scratch check imported BQTF and printed seven additional transitive axiom sets. Lean exited 0 with this output.

```text
'BQTF.hJ_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.spline_approx' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.score_events' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.denominator' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.prior_mass' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.supNorm_concentration' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.supNorm_concentration_scale' depends on axioms: [propext, Classical.choice, Quot.sound]
```

The source scan exited 0. Its sole match sets a local elaboration resource limit and preserves kernel checking.

```sh
~/.config/bvs-hq/owls/owls_run -j 1 -- rg -n 'sorry|admit|native_decide|axiom |unsafe|implemented_by|set_option' BQTF
```

```text
BQTF/Main.lean:233:set_option maxHeartbeats 600000 in
```
