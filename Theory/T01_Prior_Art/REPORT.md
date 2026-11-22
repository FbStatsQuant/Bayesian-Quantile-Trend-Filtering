# T-01 Prior-art sweep: posterior consistency / contraction for Bayesian quantile trend filtering

*Theory Department, 2026-11-22. Search only: no proofs and no proof plans. The audit trail is in `search_log.md`.*

## Verdict

**Not proven. Our target is open.**

No paper we found proves posterior consistency or a contraction rate for our model:
- an ALD working likelihood with learned scale σ;
- a Laplace prior on order-(k+1) discrete differences, with a Gamma hyperprior on λ;
- an n-dimensional trend on a fixed grid.

Nor does any paper prove one for a close variant, that is, any ALD or check-loss posterior with an ℓ₁, horseshoe or spike-and-slab prior on discrete differences.

The model itself is already in print with no theory. That is Onizuka, Hashimoto & Sugasawa, who use an ALD with Laplace or horseshoe priors on differences; I read their paper in full and it contains no theorem.

The ingredients exist, but each one is proven in a setting that differs from ours in an essential way:

| Ingredient | Where it is proven | How that setting differs from ours |
|---|---|---|
| Misspecified-ALD consistency, including a prior on σ | Sriram, Ramamoorthi & Ghosh (2013) | Finite-dimensional linear model; σ restricted to a compact interval |
| ALD likelihood with shrinkage priors | Li & He (2024) | Sparse linear model with p ≪ n; shrinkage on coefficients, not differences |
| Check-loss Gibbs posterior in a nonparametric setting | Syring & Martin (2023), Prop. 8 | Random design; Hölder truth; random-series sieve prior; deterministic, vanishing learning rate |
| Bayesian shrinkage on differences | Song & Cheng (2020); Banerjee (horseshoe fusion) | Gaussian likelihood only; t or horseshoe priors, not Laplace; piecewise-constant signals |

Even the Gaussian-likelihood analogue of our prior, Laplace on differences (the Bayesian fused lasso / trend filter), has no positive contraction theorem. Two sources point the other way:
- Castillo, Schmidt-Hieber & van der Vaart (2015, Thm 7) show that a Laplace prior on coefficients gives a suboptimal posterior.
- Song & Cheng remark, without proof, that their argument cannot cover a Laplace fusion prior.

For the joint, non-crossing version, only finite-dimensional consistency (Sriram et al.) and weak consistency of full-likelihood joint models (Yang & Tokdar) exist. Nothing covers a product of ALD posteriors restricted to the non-crossing set.

## Ranked table

How each paper was checked:
- **Full text (Head):** I read the theorem statements and assumptions myself, from the arXiv or author-hosted PDF.
- **Full text (agent):** a searcher reported reading the full text; I have not re-read it.
- **Abstract:** abstract or metadata only.

| # | Paper | Likelihood | Prior | Result | Key assumptions | Closeness | Checked |
|---|---|---|---|---|---|---|---|
| 1 | Onizuka, Hashimoto & Sugasawa (2023), *Fast and locally adaptive Bayesian quantile smoothing using calibrated variational approximations*, [arXiv:2211.04666](https://arxiv.org/abs/2211.04666), Stat. Comput. 2024 | ALD (Kozumi–Kobayashi mixture), scale σ² ~ IG | Laplace (Bayesian lasso) or horseshoe on order-(k+1) differences, as a σ-scaled Gaussian scale mixture; half-Cauchy global scale | **None.** Methodology plus calibrated VB; the only analysis is bootstrap calibration of credible intervals. A grep for theorem, proposition or lemma hits only the reference list. | n/a | **Exact model, no theory** | Full text (Head) |
| 2 | Syring & Martin (2023), *Gibbs posterior concentration rates under sub-exponential type losses*, Bernoulli 29(2), [arXiv:2012.04505](https://arxiv.org/abs/2012.04505) | Check-loss Gibbs posterior exp{−ω Σ ρ_τ}. This equals the ALD posterior with ω = 1/σ. | Hierarchical random series: prior on the number of basis functions J, then on the coefficients, restricted to a sup-norm sieve ‖θ‖∞ ≤ Δₙ | **Contraction.** Prop. 8: quantile curve in L²(P) at rate (log n)^{1/2} Δₙ² n^{−α/(2α+1)}, adaptive in α. Prop. 1: linear quantile regression at n^{−1/2}. General Thms 3.2–3.5 and 4.1. Thm 3.5 allows a plug-in random learning rate ω̂ₙ ∈ (ωₙ/2, ωₙ). | iid random design on a compact space; Hölder(α) truth; conditional density bounded below near θ*(x); one finite moment; ωₙ = cΔₙ^{−2} with c < 1/2. No prior on ω. | **Close** in loss and nonparametric setting; **adjacent** in prior (no difference or ℓ₁ prior, no TV class) and design | Full text (Head) |
| 3 | Sriram, Ramamoorthi & Ghosh (2013), *Posterior consistency of Bayesian quantile regression based on the misspecified asymmetric Laplace density*, Bayesian Analysis 8(2), [doi:10.1214/13-BA817](https://doi.org/10.1214/13-BA817); correction [doi:10.1214/17-BA1067](https://doi.org/10.1214/17-BA1067) | Misspecified ALD, independent but not identically distributed, fixed design | Proper or improper prior on a finite-dimensional (α, β) | **Consistency.** Thm 1: fixed neighbourhoods, a.s. Thm 2(a): rate n^{−δ}, δ < 1/2, a.s. Thm 2(b): Mₙ/√n, later qualified by the 2017 correction and the withdrawal note on arXiv:1812.03652. §6: consistency with a prior on σ supported on a compact [σ₁, σ₂], concentrating at σ₀ = lim n⁻¹ Σ E ρ_τ(Zᵢ). | Bounded covariates; uniform linear CDF growth at the quantile (Assumption 3(ii), the same as Padilla's Assumption A); first moments and a SLLN condition (Assumption 4) | **Close** in likelihood, fixed-design i.n.i.d. setting and learned σ; parametric only | Full text (Head); correction abstract only |
| 4 | Li & He (2024), *Posterior inference for quantile regression: adaptation to sparsity*, Statistica Sinica 34(2), [arXiv:2111.00642](https://arxiv.org/abs/2111.00642) | ALD working likelihood with unit scale (no σ) | Adaptive-lasso prior exp{−n^{1/2}λ Σ wⱼ\|βⱼ\|}, or clipped-absolute prior, on coefficients; flat intercept | **Contraction.** Thm 1 (fixed p): active block at Mₙ/√n, inactive block at Mₙ/(nλ) in sup norm, plus a TV approximation. Thm 2: adjusted credible sets. Thm 3 (growing p, clipped-absolute prior): Mₙ√(s/n), under s⁴p²log²n = o(n). | Random design with bounded support; densities at 0; separation (beta-min); n^{−1/2} ≪ λ ≪ 1 | **Adjacent**: ALD plus an ℓ₁-type prior with a theorem, but sparse linear, p ≪ n, no differences | Full text (Head) |
| 5 | Song & Cheng (2020), *Bayesian fusion estimation via t-shrinkage*, Sankhyā A, [arXiv:1812.10594](https://arxiv.org/abs/1812.10594) | Gaussian, σ² ~ IG | Independent t_df(sσ) on first differences (k = 0) | **Contraction.** Thm 2.1: ‖θ−θ*‖ ≲ σ*√(\|G*\| log n), where \|G*\| is the number of blocks. Thm 2.2: block selection. Thm 3.1: negative result for another prior. §2.2 remark: the result "can not be generalized to light tailed distributions such as Laplace-fusion prior", since it would need max\|ϑ*ᵢ\|/σ* = o(1). | \|G*\| ≺ n/log n; prior mass conditions (6); scale s polynomially small in n | **Adjacent**: shrinkage on differences, but Gaussian, k = 0 and a t prior. The Laplace remark is negative evidence for our prior. | Full text (Head) |
| 6 | Banerjee, *Horseshoe shrinkage methods for Bayesian fusion estimation*, [arXiv:2102.07378](https://arxiv.org/abs/2102.07378) | Gaussian, σ² ~ IG | Horseshoe on first differences (graph extension in Thm 9) | Contraction. Thm 4: σ₀√(s₀ log n / n) in normalized ℓ₂. Thm 5: structure recovery. | s₀ ≺ n/log n blocks; condition on the global scale τ | Adjacent | Full text (agent) |
| 7 | Liu, Martin & Shen, *Empirical priors and posterior concentration in a piecewise polynomial sequence model*, Statistica Sinica (SS-2022-0335), [arXiv:1712.03848](https://arxiv.org/abs/1712.03848) | Gaussian, known σ² | Empirical (data-centred) prior over partitions and within-block polynomials of degree K | Contraction. Thm 1: ε²ₙ = \|B_θ*\| log n / n, adaptive to the number of pieces. Thm 2: the posterior mean attains the same rate. | Known σ² and degree; piecewise polynomial truth | Adjacent: the closest signal class (piecewise quadratic for k = 2) with a Bayesian rate, but Gaussian, not Laplace, and empirical Bayes | Full text (agent) |
| 8 | Castillo, Schmidt-Hieber & van der Vaart (2015), *Bayesian linear regression with sparse priors*, Ann. Statist., [arXiv:1403.0735](https://arxiv.org/abs/1403.0735) | Gaussian | iid Laplace ("LASSO prior") on coefficients | **Negative.** Thm 7: with √n/λ → ∞, the posterior puts vanishing mass on ℓ₂-balls of radius ≍ √n/λ at β₀ = 0, so the full posterior is suboptimal even though the mode is optimal. | Sequence model, fixed λ | Adjacent: the template for why a plain Laplace prior can fail. It concerns coefficients, not differences. | Full text (agent) |
| 9 | Agapiou & Wang, *Laplace priors and spatial inhomogeneity in Bayesian inverse problems*, Bernoulli, [arXiv:2112.05679](https://arxiv.org/abs/2112.05679); Agapiou & Savva (2024), Bernoulli 30(3), [arXiv:2209.06045](https://arxiv.org/abs/2209.06045); Giordano (2023), EJS 17, [arXiv:2208.14350](https://arxiv.org/abs/2208.14350) | Gaussian white noise, inverse problems, density estimation | Besov B^α₁₁ (Laplace-type) priors on wavelet coefficients, rescaled with n; hierarchical or empirical-Bayes scale and regularity (Agapiou & Savva; Giordano Thm 7) | **Contraction**, minimax for B₁₁ classes, which is roughly the bounded-variation scale. Agapiou & Wang Thm 2.4, with Thm 4.1 showing Gaussian priors are slower. Agapiou & Savva Thm 2.5 (adaptive). Giordano Thms 1 and 7. | Prior rescaled with n; wavelet synthesis prior; Gaussian or iid-density likelihoods | Adjacent: Laplace-type priors *can* be rate-optimal on BV-type classes when scaled correctly, but on coefficients rather than differences | Full text (agent) |
| 10 | Sriram, Ramamoorthi & Ghosh, *Simultaneous Bayesian estimation of multiple quantiles…* (IIMB WP 359, 2012), and the published version *On Bayesian quantile regression using a pseudo-joint asymmetric Laplace likelihood*, Sankhyā A (2016), [doi:10.1007/s13171-015-0079-2](https://doi.org/10.1007/s13171-015-0079-2) | Product of ALDs across τ levels (pseudo-likelihood) | Finite-dimensional linear coefficients; monotonicity may be built into the prior | Consistency. WP Thm 1: fixed-neighbourhood consistency for simultaneous linear quantiles; scales in a compact interval. | Same type of assumptions as #3 | **Close** for the joint pseudo-ALD idea; finite-dimensional; no truncation to the non-crossing set; no rate | Full text (agent, WP); abstract (2016). The WP URL returned 403 to me. |
| 11 | Yang & Tokdar (2017), *Joint estimation of quantile planes over arbitrary predictor spaces*, JASA, [arXiv:1507.03130](https://arxiv.org/abs/1507.03130) | Full joint likelihood induced by a non-crossing quantile-process parameterization | Gaussian-process priors on transformed coefficient functions | Weak posterior consistency. Thm 4 (KL support) with Thm 3 (Schwartz). No rate. | Smooth coefficient curves; positive quantile densities; tail conditions | Adjacent to close for the joint non-crossing version; a different likelihood | Full text (agent) |
| 12 | Das & Ghosal (2017), *Bayesian quantile regression using random B-spline series prior*, CSDA, [arXiv:1609.02950](https://arxiv.org/abs/1609.02950) | Conditional density induced by a monotone quantile function | Random B-splines over the τ direction | Weak consistency of the conditional distribution (Schwartz argument); no quantile contraction rate | Linear in the covariate | Adjacent | Full text (agent) |
| 13 | Bhattacharya, Pati & Yang (2019), *Bayesian fractional posteriors*, Ann. Statist., [arXiv:1611.01125](https://arxiv.org/abs/1611.01125) | Fractional (tempered) likelihood under misspecification | Generic | General contraction around the KL minimizer under a prior-mass condition only (Thm 3.2) | — | Adjacent: general tool, not quantile-specific | Full text (agent, partial) |
| 14 | Sriram & Ramamoorthi, *On posterior concentration rates for Bayesian quantile regression based on the misspecified asymmetric Laplace likelihood*, [arXiv:1812.03652](https://arxiv.org/abs/1812.03652) | Misspecified ALD | Generic | Claimed general rates, including nonlinear quantiles and a B-spline example. **Withdrawn (v3, Aug 2020): Assumption 2b may be incorrect.** | — | Close in aim; **not usable** | Full text of v2 (agent); withdrawal notice |
| 15 | Heng, Zhou & Chi, *Bayesian trend filtering via proximal MCMC*, [arXiv:2201.00092](https://arxiv.org/abs/2201.00092) | Gaussian | Priors on the trend-filtering penalty (epigraph) | Computational only. Thm 4.1: the Moreau–Yosida surrogate is proper. Thm 4.2: the surrogate converges to the target. No statistical contraction. | — | Adjacent | Full text (agent) |
| 16 | Jantre, Bhattacharya & Maiti, *Quantile regression neural networks: a Bayesian approach*, [arXiv:2009.13591](https://arxiv.org/abs/2009.13591) | ALD | Normal priors on network weights, width growing with n | Consistency. Thm 1: integrated L₁. Thm 2: Hellinger. No explicit rate. Built on KL neighbourhoods, so its coverage of misspecification needs care. | Sieve conditions | Adjacent | Full text (agent) |
| 17 | Madrid Padilla & Chatterjee (2022), *Risk bounds for quantile trend filtering*, Biometrika, [arXiv:2007.07472](https://arxiv.org/abs/2007.07472) | Check loss (frequentist) | ℓ₁ penalty or constraint on order-r differences | Risk bounds in the Huber-type loss Δ²ₙ: slow rate n^{−2r/(2r+1)}, fast rate (s+1)/n·log | Assumption A; no moments | Frequentist counterpart and benchmark; not Bayesian | Full text (Head, during onboarding) |

Also screened and judged further away, with details in the search log:
- Sriram (2015, SPL; sandwich correction; σ fixed or on a compact interval);
- Yang, Wang & He (2016, ISR);
- Liu, Li & Pang (arXiv:2508.01738, smoothed-check-loss posterior, linear);
- Bhattacharya & Martin (2022, multivariate quantile Gibbs posterior);
- Mai (arXiv:2409.01687, PAC-Bayes sparse quantile; notes that posterior theory for sparse Bayesian quantile regression is not established);
- Onizuka et al. spatial version ([arXiv:2202.09534](https://arxiv.org/abs/2202.09534), no theory);
- Tokdar & Kadane (2012);
- Kleijn & van der Vaart (2006, 2012);
- Lassas & Siltanen (2004; total-variation priors are not discretization-invariant);
- Roualdes (2015, Bayesian trend filtering, no theory);
- Gao, van der Vaart & Zhou (2020; no trend-filtering, total-variation or fused example);
- *Bayesian analysis for quantile smoothing spline* ([doi:10.1080/24754269.2021.1946372](https://doi.org/10.1080/24754269.2021.1946372); ALD with a spline, posterior propriety only);
- *Posterior rates of convergence for composite quantile regression* ([doi:10.1080/03610926.2024.2438312](https://doi.org/10.1080/03610926.2024.2438312); density estimation with ALD mixtures, abstract only);
- *Bayesian quantile estimation and regression with martingale posteriors* (JRSSB, [doi:10.1093/jrsssb/qkaf080](https://doi.org/10.1093/jrsssb/qkaf080); predictive martingale posterior, linear quantile regression, abstract only).

## Gaps that would make our result new

Each gap is a separate novelty claim.

1. **Nonparametric fixed-grid quantile signal.** No Bayesian contraction result exists for an n-dimensional quantile sequence on a fixed grid under a misspecified ALD or check-loss likelihood. The only nonparametric quantile rate is Syring & Martin's Prop. 8, which needs a random design, a Hölder truth, a sieve random-series prior and a deterministic, vanishing learning rate. Nothing covers the bounded-variation classes of order (k+1) (Padilla's slow rate) or piecewise polynomials with few knots (Padilla's fast rate).
2. **ℓ₁ (Laplace) prior on order-(k+1) differences.** No positive contraction result exists under *any* likelihood, Gaussian included. Positive results on differences exist only for t, horseshoe and empirical priors, and mostly for k = 0. Results on Laplace coefficients are negative (Castillo et al.), and a remark about Laplace fusion points the same way (Song & Cheng). Even the Gaussian analogue would therefore be new.
3. **Hyperprior λ ~ Gamma on the Laplace rate.** No result treats this. Integrating λ out gives a radial ℓ₁ marginal prior on Dθ. The closest results are hierarchical Besov-Laplace priors on wavelet coefficients (Agapiou & Savva; Giordano).
4. **Learned ALD scale with σ ~ IG (non-compact support), equivalently a prior on the Gibbs learning rate ω = 1/σ.** Only Sriram et al. (2013, §6) cover this, and only for a parametric model with compact support for σ. Syring & Martin allow plug-in or deterministic learning rates only, not a prior that is integrated out.
5. **Joint non-crossing posterior.** No contraction rate exists for any joint Bayesian quantile model. In particular, nothing covers a product of ALD posteriors truncated to the ordering set. Existing results give consistency only: finite-dimensional (Sriram et al.) or weak (Yang & Tokdar).
6. **Loss and tail conditions.** No Bayesian result is stated in Padilla's Huber-type loss Δ²ₙ or under moment-free (Assumption A only) errors. Sriram et al. and Syring & Martin both assume a finite first moment.
7. **Improper prior.** Our prior is flat on polynomials of degree ≤ k. Improper priors are handled only parametrically (Sriram et al., Assumption 1b) or for an unpenalized intercept (Li & He).

**Caveats on coverage.** We could not open three items:
- the full text of the Sriram et al. (2016) Sankhyā paper;
- the 2017 correction;
- the IIMB working paper (it returned 403 to me; agent H read it).

Google Scholar was not queried directly; the searchers used a general web index, arXiv, OpenAlex and publisher pages. The OpenAlex forward-citation screen for Kozumi & Kobayashi (580 citers) used titles only.
