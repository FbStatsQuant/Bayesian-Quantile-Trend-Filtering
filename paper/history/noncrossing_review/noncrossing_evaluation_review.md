# Evaluating the joint, non-crossing contribution of the BQTF paper

*Literature review and concrete recommendations. Prepared for Felipe Bedoya, 5 September 2026, from the manuscript in `PMALA version Tex Project` (main.tex and sections/*.tex as of that date).*

---

## 0. The short version

Your paper lists "joint estimation of multiple quantile levels under exact non-crossing constraints" as contribution 3 of 5, and then never evaluates it. Every table in Section 4 either uses the individual sampler (interior levels) or uses the joint sampler purely as a delivery vehicle for the sentinel trick at extreme levels, benchmarked against a competitor (Onizuka et al.) that fits each quantile separately. There is no experiment at interior levels with the joint sampler, no crossing metric anywhere, no baseline that itself enforces non-crossing, no coverage number for any interval, and the word "non-crossing" does not appear in the Discussion. All three data applications use the individual sampler, including the growth-chart example, which is the canonical non-crossing application in the entire literature and where you benchmark against LMS, a method that is non-crossing *by construction*, while admitting your own curves cross once. The ADMM crossing you observe in the SPod data at τ = 0.01 is the single best piece of evidence in the paper for the joint method and it is buried in one clause.

The literature has settled conventions for all of this. Below: what the standard baselines and metrics are (with citations), what a referee from this literature will object to in the current draft, and a concrete plan of experiments and rewrites.

---

## 1. What the current draft does, and what it does not do

| Aspect | Current draft | Gap relative to the joint/non-crossing literature |
|---|---|---|
| Joint sampler at interior levels | Not run. Sec. 4.2 uses the individual sampler at τ ∈ {0.05,…,0.95}. | No evidence the constraint helps (or is harmless) where most users will apply it. |
| Joint sampler at extreme levels | Run with sentinels; compared with Onizuka HS/Laplace fit *individually*. | Confounds three things: the constraint, the sentinels, and the prior. No ablation. |
| Crossing metrics | None. | Every non-crossing paper reports at least one (Sec. 3). |
| Non-crossing baselines | None. LMS in the growth example is non-crossing by construction, but treated as a generic "reference method". | The standard set is: unconstrained fits + rearrangement, constrained frequentist fits (Bondell et al.; Brantley et al.'s own multi-quantile `detrendr`), and a Bayesian joint model. |
| Uncertainty | MCIW only. Text says "empirical coverage remains the appropriate criterion" and then never reports it. | Onizuka et al. report CP. Under Gaussian and mixed-normal noise your joint MCIWs are roughly 4× to 45× smaller than competitors'; without CP this reads as undercoverage. |
| Joint-posterior functionals | None. | The one thing an individual sampler cannot give you: credible intervals for θ_{0.9} − θ_{0.1}, predictive CDF, etc. |
| Nature of the joint posterior | Written as "the joint posterior". | It is a product of ALD pseudo-likelihoods for the same data, i.e. a composite/pseudo-likelihood (Sriram et al. 2016). Must be named as such. |
| Data applications | All three use the individual sampler. | Growth charts and SPod (τ = 0.01 crossing) are ready-made joint showcases. |

---

## 2. Baselines used in the non-crossing literature

The field has three families of non-crossing methods and one convention for baselines. In essentially every paper I could read in full (Chernozhukov et al. 2010; Takeuchi et al. 2006; Sangnier et al. 2016; Cannon 2018; Brantley et al. 2020; Rodrigues & Fan 2017; Rodrigues et al. 2019; Yang & Tokdar 2017; Chen & Tokdar 2021; Xu & Reich 2023; Kohns & Szendrei 2025), the comparison set is built as follows.

**(a) The same estimator with the constraint switched off.** This is universal and it is the baseline you are missing. Brantley et al. (2020) literally compare `detrendr` with and without the non-crossing constraint (their "Study 2"). For you this is the individual P-MALA sampler run at the same τ grid. It isolates the effect of the constraint from the effect of the prior and the sampler.

**(b) Unconstrained fits followed by post-hoc monotonization.** Rearrangement (Chernozhukov, Fernández-Val & Galichon 2010, Econometrica; `quantreg::rearrange`) is the standard, with isotonic regression/PAVA as the secondary option. This baseline matters for a reason that is not cosmetic: Proposition 4 of Chernozhukov et al. proves that for *any* initial estimate, rearranging weakly improves the L_p distance to the true quantile function, for every p ∈ [1, ∞], strictly when crossing occurs. Fakoor et al. (2023, JMLR) show the same for the weighted interval score. So an unconstrained method plus sorting is a free lunch, and the honest bar for a constrained method is to beat the *rearranged* unconstrained fits, not the raw ones. Szendrei et al. (2024) exclude rearrangement from their comparison on the grounds that it does not change the coefficients; that argument does not apply to you because your object of interest is the fitted curve. In the Bayesian setting the analogue is Rodrigues & Fan (2017, JCGS): independent single-τ ALD fits, then a Gaussian-process regression across τ with bandwidth chosen as the smallest value that removes all crossings. It is cheap to implement and is the correct "Bayesian post-hoc" baseline.

**(c) Frequentist constrained estimators.** Bondell, Reich & Wang (2010, Biometrika) is the citation everyone benchmarks against for linear and basis-expansion curves. For your setting the directly relevant one is Brantley, Guinness & Chi (2020), whose multi-quantile `detrendr` solves min Σ_j [ρ_{τ_j}(y − θ_j) + λ_j‖D^{(k+1)}θ_j‖_1] subject to θ_{ij} ≤ θ_{ij'} for j ≤ j', with λ_j chosen per quantile by eBIC. This is the exact frequentist analogue of your model. Your introduction currently describes Brantley et al. as returning "a single point estimate at a prespecified penalty level" and never mentions that they already impose exact non-crossing constraints across quantiles. That is a fairness problem and a referee who knows the paper will flag it; your Notes.txt says you want to reduce reliance on Brantley et al., but the constrained multi-quantile fit is precisely the thing you must acknowledge and compare to. For smooth-curve settings, `quantregGrowth::gcrq` (Muggeo et al. 2013, 2021) fits non-crossing P-spline quantile curves and is what Rodrigues et al. (2019) benchmark against for growth data; COBS (He & Ng) is the older alternative. GAMLSS/LMS (Cole & Green 1992; Rigby & Stasinopoulos 2005) is non-crossing by construction through a parametric conditional distribution and is the field standard for growth charts; you already run it, but should present it as a non-crossing competitor, not a generic reference.

**(d) Bayesian joint models with a proper likelihood.** `qrjoint` (Yang & Tokdar 2017, already in your bib) is the most-used Bayesian joint baseline, but it is a linear-in-covariates quantile-plane model; Rodrigues et al. (2019) report that feeding it a B-spline design overfits or yields near-parallel curves, so it is not a natural fit for trend filtering and you can say so. The closest Bayesian competitors for nonparametric univariate curves are Rodrigues, Dortet-Bernadet & Fan (2019, CSDA; "PQPS", quantile pyramids plus penalized O'Sullivan splines, non-crossing by construction) and Wang & Cai (2024, Comm. Stat. Theory & Methods; a "composite Bayesian" pseudo-ALD likelihood with B-splines, a smoothness penalty and a penalty on differences of neighbouring quantile curves, targeting extreme quantiles and inference on quantile differences). Wang & Cai is uncomfortably close to your setting in spirit and is not cited; I could not get its full text, so check whether code exists. Kohns & Szendrei (2025, arXiv) use the same product-of-ALD likelihood as you with a fused shrinkage prior across τ for *linear* coefficients ("soft" non-crossing); not a direct competitor but the right citation for the product-ALD-with-general-Bayes justification. `qgam`/`mqgam` (Fasiolo et al. 2021, already in your bib) is an independent-fit method, but it is the only Bayesian-flavoured quantile smoother with calibrated intervals, so it is the right baseline for coverage.

**Recommended baseline set for you**, in order of importance: (1) your own individual sampler at the same grid; (2) the same plus rearrangement of the posterior mean *and* rearrangement draw by draw; (3) Onizuka HS individual plus rearrangement; (4) Brantley et al.'s constrained multi-quantile `detrendr` (eBIC); (5) Rodrigues & Fan GP adjustment applied to your individual fits and to Onizuka; (6) `gcrq` for the smooth-signal and growth designs; (7) PQPS if the authors' code is obtainable. Onizuka individual is still fine to keep as the "Bayesian per-quantile" reference, but it cannot be the *only* competitor in a section whose point is joint estimation.

---

## 3. Metrics used for joint / non-crossing evaluation

Let τ_1 < ⋯ < τ_K, θ̂_i(τ_k) the estimate at index i, Q_i(τ_k) the truth, and ρ_τ(u) = u(τ − 1{u<0}).

**Accuracy of the quantile process.** Per-τ RMSE/MSE over the design (Brantley 2020; Onizuka 2024; you already do this) is standard, but the joint literature always adds an aggregate over τ: RMISE averaged over the grid (Rodrigues & Fan 2017; Rodrigues et al. 2019; Xu & Reich 2023 call it RMISE_QP), or the L_1 distance in τ, which on a grid is (1/K) Σ_k |θ̂_i(τ_k) − Q_i(τ_k)| and is the discretized Wasserstein-1 distance between the estimated and true conditional distributions at index i (W_1(F̂, F) = ∫_0^1 |Q̂(τ) − Q(τ)| dτ; Panaretos & Zemel 2019). W_1 is a natural summary because it is exactly the quantity rearrangement is guaranteed to improve (Chernozhukov et al. 2010), so a W_1 table with "unconstrained / rearranged / joint" columns tells the whole story in one place.

**Proper scores.** The grid-averaged pinball loss (2/K) Σ_k (1/n) Σ_i ρ_{τ_k}(y_i − θ̂_i(τ_k)) on held-out data approximates the CRPS (Laio & Tamea 2007; Gneiting & Ranjan 2011), and quantile-weighted versions with weights τ(1−τ), (1−τ)² or τ² emphasize centre or tails (Gneiting & Ranjan 2011; used by Kohns & Szendrei 2025 and Szendrei et al. 2024). This is the natural way to score the *whole* estimated conditional distribution rather than K separate curves, which is the point of a joint method. The interval score IS_α = (u − l) + (2/α)(l − y)1{y<l} + (2/α)(y − u)1{y>u} (Winkler 1972; Gneiting & Raftery 2007) scores the (τ_k, τ_{K+1−k}) pairs as prediction intervals; the weighted interval score of Bracher et al. (2021) aggregates them.

**Crossing metrics.** Three definitions are in use and you should report at least two, applied to every unconstrained competitor (for constrained methods they are zero by construction and are reported as such):
- *Crossing rate* (Park et al. 2022): the proportion of adjacent pairs that cross, 100 · (1/(n(K−1))) Σ_i Σ_k 1{θ̂_i(τ_k) > θ̂_i(τ_{k+1})}; a lower bound on all-pairs crossing.
- *Crossing loss* (Sangnier et al. 2016; Rodrigues & Pereira 2020): the magnitude of violation, (1/n) Σ_i Σ_k max(0, θ̂_i(τ_k) − θ̂_i(τ_{k+1})).
- *Fraction of replicate datasets with any crossing* (Rodrigues & Fan 2017 report 405–500 of 500 for unconstrained ALD fits) or *count of crossing pairs over a dense τ grid* (Brando et al. 2022).
For Bayesian methods there is a fourth metric that nobody reports and that is uniquely available to you: the **posterior crossing probability**, i.e. the fraction of posterior draws in which the K curves cross anywhere, for individual samplers. Posterior means can be ordered while most draws are not; that means an individual sampler's posterior predictive distribution is not a valid distribution even when its point estimate looks fine. Your joint sampler has this at exactly zero, draw by draw. That is the cleanest way to say what "exact" buys over "the posterior means happen not to cross".

**Uncertainty.** Pointwise frequentist coverage of 95% (or 90%) credible bands at each τ, with width alongside, appears in every Bayesian joint paper (Yang & Tokdar 2017; Chen & Tokdar 2021; Reich et al. 2011; Rodrigues et al. 2019; Wu & Narisetty 2021; Onizuka et al. 2024). Joint (simultaneous over τ at a fixed index, or over the whole curve) coverage is reported by nobody I could find, which is an opening for you. Coverage of the *interquantile range* θ_i(τ_K) − θ_i(τ_1), or of the tail asymmetry (θ(0.95) − θ(0.5)) − (θ(0.5) − θ(0.05)), is a functional whose credible interval only a joint posterior can produce coherently; Wu & Narisetty (2021) make exactly this point for slope differences across τ. Chernozhukov et al. (2009, Biometrika) show rearranged bands are shorter with coverage at least nominal, so rearranged competitor bands are the fair comparator for width.

**Calibration of the quantile property.** Takeuchi et al. (2006) and Dai et al. (2023) report the "ramp loss" |n⁻¹ Σ_i 1{y_i > θ̂_i(τ)} − τ|, precisely to expose the cost of hard non-crossing constraints: a constrained fit can be pushed off the τ-quantile by its neighbours. You already report in-sample exceedance fractions in the applications; make it a systematic metric and report it for the joint sampler with and without sentinels.

**Computation.** ESS, ESS per second, and wall time per Gibbs sweep (Wu & Narisetty note that monotonicity constraints reduce ESS). Report ESS of the joint sampler relative to K individual runs; the sequential scan makes it K times more expensive per sweep, and the reader will want to know what the constraint costs in mixing.

---

## 4. Problems a referee from this literature will raise, in order of severity

**4.1 Interval widths without coverage.** Under Gaussian and mixed-normal noise your joint-sampler MCIWs at extreme levels are 0.017–0.16 against 0.25–1.26 for the competitors (Tables pc_ext_mciw and vs_ext_mciw), and the text explains this as "geometric confinement" by sentinels spaced 0.003 below and 0.01 above the target. That is a statement that the posterior spread is set by a tuning choice, not by the data. Onizuka et al. (2024) report coverage probability in every table and find MCMC coverage at τ = 0.05/0.95 "far away from the nominal 0.95"; you dropped that column. You must report CP. Expect it to be far below nominal for the sentinel-confined targets; then the honest framing is that the sentinel construction is a point-estimation stabilizer and that tail credible intervals are exploratory, or you calibrate them (4.3).

**4.2 The ALD posterior variance is known to be wrong.** The ALD posterior is consistent (Sriram, Ramamoorthi & Ghosh 2013) but its asymptotic covariance is n⁻¹V⁻¹ rather than n⁻¹τ(1−τ)V⁻¹SV⁻¹, and it scales with the nuisance scale σ, which has no bearing on the quantile itself (Sriram 2015; Yang, Wang & He 2016; Padellini & Rue 2018). Your paper presents learning σ as a feature ("the effective likelihood temperature adapts to the data"). From the general-Bayes viewpoint (Bissiri, Holmes & Walker 2016) 1/σ is the learning rate, and the entire calibration literature (Syring & Martin 2019; Fasiolo et al. 2021's `qgam`) exists because the learning rate must be *set for coverage*, not learned by conjugacy; Yang, Wang & He recommend fixing σ. You need a paragraph acknowledging this and a coverage table showing what your intervals actually do. Ji, Lee & Rabe-Hesketh (2024/25) show raw ALD interval coverage ranging 0.70–0.95 at nominal 0.90 depending on σ, degrading at extreme τ.

**4.3 The joint posterior is a pseudo-posterior.** Your Section 2.3 writes down Π_k ALD_{τ_k}(y | θ_{τ_k}, σ_{τ_k}) · 1(C) and calls it "the joint posterior". Each y_i enters K times; this is a composite (pseudo-joint) likelihood. Sriram, Ramamoorthi & Ghosh (2016, Sankhya A) study exactly this object, prove posterior consistency for it, and warn that the *normalized* version is misleading; Kohns & Szendrei (2025) and Huber, Poon & Zhu (2026) adopt it with a Bissiri-type justification; Wu & Narisetty (2021) criticize it because "it cannot quantify the joint uncertainty for multiple quantile levels". You should (i) call it a pseudo-joint posterior, cite Sriram et al. 2016 for consistency, (ii) note that Brantley et al.'s constrained estimator is its MAP, and (iii) be explicit that cross-quantile credible statements are not automatically valid without calibration, then show empirically how the intervals behave. Feng, Chen & He (2015, Bernoulli) and Wu & Narisetty (2021) are the proper-likelihood alternatives to cite as "future work" fixes.

**4.4 No isolation of the constraint's effect.** The extreme-quantile tables compare {joint + sentinels + global Laplace prior + learned σ} against {individual + horseshoe}. Nothing tells the reader which ingredient does what. Minimum ablation: individual P-MALA (drifts, as you say in the text — show the number), joint without sentinels, joint with sentinels at two or three spacings, and Onizuka + rearrangement.

**4.5 Crossing is rare in your current designs.** At n = 400 with five well-separated interior levels and a global penalty, independent fits will rarely cross; your own growth-chart example crosses once in 880 comparisons. If you evaluate the joint sampler only there, the constraint will look inert. The literature showcases non-crossing at small n (50–200), dense τ grids (19 levels at 0.05 spacing, or 0.01 spacing), heavy tails (t_2, t_3, Cauchy), strong heteroscedasticity (the Bondell designs), and sparse regions of the design (your Munich upper tail, your growth-chart age extremes). Report the crossing rate of the unconstrained fit in every design so the reader can see when the constraint bites.

**4.6 Brantley et al. already did exact non-crossing quantile trend filtering.** See 2(c). Your contribution is the Bayesian version of it, plus the sentinel device. Say so plainly; it is a perfectly good contribution and hiding the antecedent weakens rather than strengthens it.

---

## 5. Concrete plan

### 5.1 New simulation block: "Joint estimation at interior levels"

Keep your three signals and three noise laws so the section is self-contained, and add the designs where crossing actually happens.

*Grids.* K = 5 at {0.05, 0.25, 0.5, 0.75, 0.95} (matches Section 4.2) and K = 19 at {0.05, 0.10, …, 0.95} (the modal grid in the joint literature: Xu & Reich 2023; Kohns & Szendrei 2025; Rodrigues & Fan use 91 levels).

*Sample sizes.* n ∈ {100, 200, 400}. Crossing frequency and the value of the constraint both fall with n, and showing that is itself informative.

*Extra noise laws.* t_3 (heavy tails, as in Cannon 2018 and Xu & Reich 2023) and one Bondell-type location-scale design y = f(x) + (0.1 + x/10 + x²/10) ε with f a bump function (Rodrigues et al. 2019, Design 4, which also has an abrupt smoothness change and is thus in your trend-filtering wheelhouse).

*Methods.* Joint P-MALA (no sentinels; sentinels are an extreme-level device and should not appear here), individual P-MALA, individual P-MALA + rearrangement (of the posterior mean; and of every draw, which gives a rearranged posterior), Onizuka HS + rearrangement, Brantley constrained `detrendr` (eBIC), Rodrigues & Fan GP adjustment on your individual fits, `gcrq` on the smooth signal.

*Metrics per design.* Per-τ MSE (appendix); grid-averaged MSE and W_1 (main text); grid-averaged pinball on a held-out replicate (CRPS proxy); crossing rate and crossing loss for the unconstrained methods; posterior crossing probability for the Bayesian individual samplers; 95% pointwise CP and MCIW per τ; CP and width for the interquantile range θ(0.95) − θ(0.05) and for the median-centred asymmetry; ramp loss; ESS/sec.

*Expected story, stated honestly.* At n = 400 with K = 5 the joint and rearranged-individual estimates will be close in MSE and W_1; the constraint's visible payoff will be in posterior crossing probability, in the interquantile-range intervals, and at n = 100 with K = 19 and heavy tails. If the joint sampler does not beat *rearranged* individual fits in W_1, say so; the contribution is still real because rearrangement gives no coherent posterior and no interval for cross-quantile functionals.

### 5.2 Ablation for the extreme-level section

Same designs as your Section 4.3. Columns: individual P-MALA (report the drift; the reader has only your word that it is "essentially useless"), joint without sentinels, joint with sentinels at the current spacing, joint with sentinels at a coarser spacing (e.g., 0.005 below / 0.02 above for τ = 0.01), Onizuka HS, Onizuka HS + rearrangement. Add CP for every method. Add the ramp loss so the reader can see whether sentinel confinement pushes the target off the nominal level. This turns the sentinel section from "a heuristic that works" into a characterized device.

### 5.3 Data applications: use the joint sampler where the science is about the joint

*Growth charts.* This is the application every non-crossing paper uses (Chernozhukov et al. 2009; Schnabel & Eilers 2013; Muggeo et al. 2013; Rodrigues & Fan 2017 use an IgG chart). Refit with the joint sampler at the WHO-style centile set {0.03, 0.10, 0.25, 0.50, 0.75, 0.90, 0.97} (or at least your five levels), compare with LMS/GAMLSS *and* `gcrq`, report the crossing count of the independent fits (currently one crossing in 880 comparisons for boys; count posterior draws too), and show a credible band for a centile *spread* (e.g., the 3rd-to-97th range as a function of age), which none of the competitors can produce with uncertainty. Also show the fraction of children in each centile band against nominal, per age region.

*SPod.* You already observe that the eBIC-tuned ADMM baseline at τ = 0.01 crosses the τ = 0.05 and 0.10 curves. That is the argument for the joint method in a sentence; make it a figure. Fit the joint sampler at {0.01, 0.05, 0.10} (with sentinels below 0.01 if needed), overlay against Brantley's *constrained* multi-quantile `detrendr` (which cannot cross) and the individually tuned `detrendr` (which does), and show that event-detection thresholds are consistent across levels.

*Munich.* Refit jointly at the five levels; compare with Onizuka + rearrangement. The interesting quantity here is the rent dispersion (0.9 minus 0.1 curve) as a function of floor size, with a credible band; the left-boundary behaviour you describe (horseshoe chasing two high rents) becomes a statement about the interquantile range with uncertainty.

### 5.4 Fix the uncertainty story

Report CP everywhere. Then choose one calibration route and apply it at least in an appendix: (a) Yang–Wang–He (2016) sandwich adjustment on the posterior covariance with σ fixed (needs derivation for the penalized estimator; `qgam`'s treatment is the template); (b) Sriram's (2015) two-step sandwich re-posterior; (c) Ji, Lee & Rabe-Hesketh's (2024) infinitesimal-jackknife covariance computed from MCMC draws, which requires no resampling and is probably the least work for you; (d) Syring & Martin's (2019) bootstrap calibration of the learning rate 1/σ, which fits your general-Bayes reading of the model. If you keep σ learned, say why, and show what it does to coverage. Be cautious about extreme τ: all these adjustments rest on central-order asymptotics (Chernozhukov & Fernández-Val 2011), and Ji et al. and Fasiolo et al. both see residual undercoverage in the tails even after adjustment.

### 5.5 Rewrite

Abstract and contribution list: move the joint/non-crossing contribution up and reframe it as "a pseudo-joint posterior over a *non-crossing quantile process*, which yields a coherent posterior predictive conditional distribution and credible statements for cross-quantile functionals (interquantile ranges, tail asymmetry) that per-quantile samplers cannot provide". Introduction: one paragraph on the non-crossing literature (He 1997; Koenker & Ng 2005; Dette & Volgushev 2008; Bondell et al. 2010; Chernozhukov et al. 2010; Tokdar & Kadane 2012; Yang & Tokdar 2017; Rodrigues & Fan 2017; Rodrigues et al. 2019; Brantley et al. 2020), stating explicitly that Brantley et al. impose exact non-crossing in the optimization and that you provide its Bayesian counterpart. Section 2.3: call the posterior pseudo-joint, cite Sriram et al. 2016. Discussion: a paragraph on non-crossing (what was shown, what the constraint costs in ESS, what remains: proper-likelihood alternatives, fused/interquantile shrinkage across τ à la Jiang, Wang & Bondell 2013 and Kohns & Szendrei 2025 as a natural extension of your prior, since you already have a D operator — a penalty on θ_{τ_{k+1}} − θ_{τ_k} is one more block in the ADMM).

### 5.6 Things I would not do

Do not add `qrjoint` as a competitor for trend filtering; it is a quantile-plane model and Rodrigues et al. document that it misbehaves with spline designs. Do not compare against ML non-crossing networks; they are the wrong model class and the comparison will look like padding. Do not report only crossing counts of *point estimates* for the Bayesian competitors; report draw-level crossing, which is where the difference lives.

---

## 6. Sources

Verification status: **[V]** bibliographic record confirmed from CrossRef, arXiv, or publisher page during this sweep and, where content is described, the content was read; **[V-bib]** bibliographic record confirmed, content taken from abstract or from secondary descriptions in other verified papers; **[U]** could not be fetched in this session, cite after checking. A `.bib` file with all entries accompanies this document.

### Non-crossing quantile regression, frequentist
- He, X. (1997). Quantile curves without crossing. *The American Statistician* 51(2), 186–192. doi:10.1080/00031305.1997.10473959 **[V-bib]**
- Koenker, R. & Ng, P. (2005). Inequality constrained quantile regression. *Sankhyā* 67(2), 418–440. **[U]** (no DOI; pages from Chernozhukov et al.'s reference list)
- Dette, H. & Volgushev, S. (2008). Non-crossing non-parametric estimates of quantile curves. *JRSS-B* 70(3), 609–627. doi:10.1111/j.1467-9868.2008.00651.x **[V-bib]**
- Chernozhukov, V., Fernández-Val, I. & Galichon, A. (2010). Quantile and probability curves without crossing. *Econometrica* 78(3), 1093–1125. doi:10.3982/ECTA7880 **[V]** (Prop. 4: rearrangement weakly improves every L_p error)
- Chernozhukov, V., Fernández-Val, I. & Galichon, A. (2009). Improving point and interval estimators of monotone functions by rearrangement. *Biometrika* 96(3), 559–575. doi:10.1093/biomet/asp030 **[V-bib]**
- Bondell, H. D., Reich, B. J. & Wang, H. (2010). Noncrossing quantile regression curve estimation. *Biometrika* 97(4), 825–838. doi:10.1093/biomet/asq048 **[V-bib]** (simulation designs confirmed via Rodrigues & Fan 2017, who reuse them)
- Jiang, L., Wang, H. J. & Bondell, H. D. (2013). Interquantile shrinkage in regression models. *JCGS* 22(4), 970–986. doi:10.1080/10618600.2012.707454 **[V-bib]**
- Takeuchi, I., Le, Q. V., Sears, T. D. & Smola, A. J. (2006). Nonparametric quantile estimation. *JMLR* 7, 1231–1264. **[V]** (ramp loss; hard non-crossing constraints on a grid)
- Wu, Y. & Liu, Y. (2009). Stepwise multiple quantile regression estimation using non-crossing constraints. *Statistics and Its Interface* 2(3), 299–310. doi:10.4310/SII.2009.v2.n3.a4 **[U]** (author order inconsistent between CrossRef and the authors' pages)
- Liu, Y. & Wu, Y. (2011). Simultaneous multiple non-crossing quantile regression estimation using kernel constraints. *J. Nonparametric Statistics* 23(2), 415–437. doi:10.1080/10485252.2010.537336 **[U]**
- Schnabel, S. K. & Eilers, P. H. C. (2013). Simultaneous estimation of quantile curves using quantile sheets. *AStA Advances in Statistical Analysis* 97(1), 77–87. doi:10.1007/s10182-012-0198-1 **[V]**
- Muggeo, V. M. R., Sciandra, M., Tomasello, A. & Calvo, S. (2013). Estimating growth charts via nonparametric quantile regression: a practical framework with application in ecology. *Environmental and Ecological Statistics* 20(4), 519–531. doi:10.1007/s10651-012-0232-1 **[V-bib]** (R: quantregGrowth)
- Muggeo, V. M. R., Torretta, F., Eilers, P. H. C., Sciandra, M. & Attanasio, M. (2021). Multiple smoothing parameters selection in additive regression quantiles. *Statistical Modelling* 21(5), 428–448. doi:10.1177/1471082X20929802 **[V-bib]**
- Muggeo, V. M. R., Sottile, G. & Cilluffo, G. (2023). Joint modelling of non-crossing additive quantile regression via constrained B-spline varying coefficients. *Statistical Modelling* 23(5–6), 540–554. doi:10.1177/1471082X231181734 **[V-bib]**
- Frumento, P. & Bottai, M. (2016). Parametric modeling of quantile regression coefficient functions. *Biometrics* 72(1), 74–84. doi:10.1111/biom.12410 **[V-bib]**
- Sottile, G. & Frumento, P. (2023). Parametric estimation of non-crossing quantile functions. *Statistical Modelling* 23(2), 173–195. doi:10.1177/1471082X211036517 **[V-bib]**
- Koenker, R., Ng, P. & Portnoy, S. (1994). Quantile smoothing splines. *Biometrika* 81(4), 673–680. doi:10.1093/biomet/81.4.673 **[V-bib]**
- Brantley, H. L., Guinness, J. & Chi, E. C. (2020). Baseline drift estimation for air quality data using quantile trend filtering. *Annals of Applied Statistics* 14(2), 585–604. doi:10.1214/19-AOAS1318 **[V]** (multi-quantile with exact non-crossing constraint; RMSE per τ; no UQ)
- Szendrei, T., Bhattacharjee, A. & Schaffer, M. E. (2024). Fused LASSO as non-crossing quantile regression. arXiv:2403.14036; IZA DP 17149. **[V]** (working paper)
- Dai, S., Kuosmanen, T. & Zhou, X. (2023). Non-crossing convex quantile regression. *Economics Letters* 233, 111396. doi:10.1016/j.econlet.2023.111396 **[V]** (ramp loss)
- Ando, T. & Li, K.-C. (2025). Simplex quantile regression without crossing. *Annals of Statistics* 53(1). doi:10.1214/24-AOS2458 **[U]**

### Bayesian joint / non-crossing quantile estimation
- Tokdar, S. T. & Kadane, J. B. (2012). Simultaneous linear quantile regression: a semiparametric Bayesian approach. *Bayesian Analysis* 7(1), 51–72. doi:10.1214/12-BA702 **[V]**
- Yang, Y. & Tokdar, S. T. (2017). Joint estimation of quantile planes over arbitrary predictor spaces. *JASA* 112(519), 1107–1120. doi:10.1080/01621459.2016.1192545 **[V]** (already in your bib)
- Chen, X. & Tokdar, S. T. (2021). Joint quantile regression for spatial data. *JRSS-B* 83(4), 826–852. doi:10.1111/rssb.12467 **[V]** (ALD methods "may severely underestimate uncertainty"; lower coverage than all others)
- Reich, B. J., Fuentes, M. & Dunson, D. B. (2011). Bayesian spatial quantile regression. *JASA* 106(493), 6–20. doi:10.1198/jasa.2010.ap09237 **[V]**
- Reich, B. J. (2012). Spatiotemporal quantile regression for detecting distributional changes in environmental processes. *JRSS-C* 61(4), 535–553. doi:10.1111/j.1467-9876.2011.01025.x **[V]**
- Reich, B. J. & Smith, L. B. (2013). Bayesian quantile regression for censored data. *Biometrics* 69(3), 651–660. doi:10.1111/biom.12053 **[V-bib]** (R: BSquare)
- Rodrigues, T. & Fan, Y. (2017). Regression adjustment for noncrossing Bayesian quantile regression. *JCGS* 26(2), 275–284. doi:10.1080/10618600.2016.1172016 **[V]** (post-hoc GP adjustment; RMISE; crossing frequency 405–500/500 datasets)
- Rodrigues, T., Dortet-Bernadet, J.-L. & Fan, Y. (2019). Pyramid quantile regression. *JCGS* 28(3), 732–746. doi:10.1080/10618600.2019.1575225 **[V]**
- Rodrigues, T., Dortet-Bernadet, J.-L. & Fan, Y. (2019). Simultaneous fitting of Bayesian penalised quantile splines. *CSDA* 134, 93–109. doi:10.1016/j.csda.2018.12.009 (arXiv:1711.09317) **[V]** (closest Bayesian competitor for univariate curves; RMISE and 95% coverage at τ up to 0.99; baselines COBS, gcrq, qrjoint, Bondell et al.)
- Das, P. & Ghosal, S. (2017). Bayesian quantile regression using random B-spline series prior. *CSDA* 109, 121–143. doi:10.1016/j.csda.2016.11.014 **[V-bib]**
- Das, P. & Ghosal, S. (2018). Bayesian non-parametric simultaneous quantile regression for complete and grid data. *CSDA* 127, 172–186. doi:10.1016/j.csda.2018.04.007 **[V]**
- Xu, S. G. & Reich, B. J. (2023). Bayesian nonparametric quantile process regression and estimation of marginal quantile effects. *Biometrics* 79(1), 151–164. doi:10.1111/biom.13576 **[V]** (RMISE per τ and averaged; baselines MCQRNN, Das & Ghosal)
- Taddy, M. A. & Kottas, A. (2010). A Bayesian nonparametric approach to inference for quantile regression. *JBES* 28(3), 357–369. doi:10.1198/jbes.2009.07331 **[V-bib]**
- Sriram, K., Ramamoorthi, R. V. & Ghosh, P. (2016). On Bayesian quantile regression using a pseudo-joint asymmetric Laplace likelihood. *Sankhya A* 78(1), 87–104. doi:10.1007/s13171-015-0079-2 **[V-bib]** (product-of-ALD pseudo-likelihood; posterior consistency; normalized version misleading)
- Wu, T. & Narisetty, N. N. (2021). Bayesian multiple quantile regression for linear models using a score likelihood. *Bayesian Analysis* 16(3), 875–903. doi:10.1214/20-BA1217 **[V]**
- Feng, Y., Chen, Y. & He, X. (2015). Bayesian quantile regression with approximate likelihood. *Bernoulli* 21(2), 832–850. doi:10.3150/13-BEJ589 **[V]**
- Hu, Y., Wang, H. J., He, X. & Guo, J. (2021). Bayesian joint-quantile regression. *Computational Statistics* 36(3), 2033–2053. doi:10.1007/s00180-020-00998-w **[V-bib]** (borrows strength across tail quantiles; closest antecedent to the sentinel idea)
- Wang, Q. & Cai, Z. (2024). A composite Bayesian approach for quantile curve fitting with non-crossing constraints. *Communications in Statistics – Theory and Methods* 53(20), 7119–7143. doi:10.1080/03610926.2023.2259524 **[V-bib]** (online 2023; pseudo-composite ALD, B-splines, penalty on neighbouring-curve differences; not cited in your draft)
- Kohns, D. & Szendrei, T. (2025). Joint quantile shrinkage: a state-space approach toward non-crossing Bayesian quantile models. arXiv:2506.13257. **[V]** (product-ALD likelihood with general-Bayes justification; crossing incidence metric; soft non-crossing)
- Huber, F., Poon, A. & Zhu, D. (2026). Soft-noncrossing Bayesian panel quantile regression for measuring climate tail risk. arXiv:2608.04664. **[V]**
- Santos, B. & Kneib, T. (2020). Noncrossing structured additive multiple-output Bayesian quantile regression models. *Statistics and Computing* 30(4), 855–869. doi:10.1007/s11222-020-09925-x **[V]**
- Castillo-Mateo, J., Gelfand, A. E., Asín, J., Cebrián, A. C. & Abaurrea, J. (2024). Bayesian joint quantile autoregression. *TEST* 33(1), 335–357. doi:10.1007/s11749-023-00895-6 **[V]**
- An, H. & MacEachern, S. N. (2023). A process of dependent quantile pyramids. arXiv:2306.02126. **[V]**
- Onizuka, T., Hashimoto, S. & Sugasawa, S. (2024). Fast and locally adaptive Bayesian quantile smoothing using calibrated variational approximations. *Statistics and Computing* 34(1), 15. doi:10.1007/s11222-023-10327-y **[V]** (single τ; reports MSE, MAD, MCIW **and CP**)
- Heng, Q., Zhou, H. & Chi, E. C. (2023). Bayesian trend filtering via proximal Markov chain Monte Carlo. *JCGS* 32(3), 938–949. doi:10.1080/10618600.2023.2170089 **[V]** (your intro cites this as "Heng, Zhou, and Chi" without a bib entry; add it)

### Validity of ALD-based posterior uncertainty and calibration
- Yu, K. & Moyeed, R. A. (2001). Bayesian quantile regression. *Statistics & Probability Letters* 54(4), 437–447. doi:10.1016/S0167-7152(01)00124-9 **[V-bib]**
- Sriram, K., Ramamoorthi, R. V. & Ghosh, P. (2013). Posterior consistency of Bayesian quantile regression based on the misspecified asymmetric Laplace density. *Bayesian Analysis* 8(2), 479–504. doi:10.1214/13-BA817 (correction: 12(4), 1217–1219, 2017) **[V-bib]**
- Sriram, K. (2015). A sandwich likelihood correction for Bayesian quantile regression based on the misspecified asymmetric Laplace density. *Statistics & Probability Letters* 107, 18–26. doi:10.1016/j.spl.2015.07.035 **[V]**
- Yang, Y., Wang, H. J. & He, X. (2016). Posterior inference in Bayesian quantile regression with asymmetric Laplace likelihood. *International Statistical Review* 84(3), 327–344. doi:10.1111/insr.12114 **[V-bib]**
- Padellini, T. & Rue, H. (2018). Model-aware quantile regression for discrete data. arXiv:1804.03714. **[V]**
- Bissiri, P. G., Holmes, C. C. & Walker, S. G. (2016). A general framework for updating belief distributions. *JRSS-B* 78(5), 1103–1130. doi:10.1111/rssb.12158 **[V-bib]**
- Syring, N. & Martin, R. (2019). Calibrating general posterior credible regions. *Biometrika* 106(2), 479–486. doi:10.1093/biomet/asy054 **[V]**
- Ji, F., Lee, J. & Rabe-Hesketh, S. (2024/2025). Valid standard errors for Bayesian quantile regression with clustered and independent data. arXiv:2407.09772; *J. Educational and Behavioral Statistics*, doi:10.3102/10769986251379738 **[V]**
- Fasiolo, M., Wood, S. N., Zaffran, M., Nedellec, R. & Goude, Y. (2021). Fast calibrated additive quantile regression. *JASA* 116(535), 1402–1412. doi:10.1080/01621459.2020.1725521 **[V]** (already in your bib; note it does *not* address crossing)
- Chernozhukov, V. & Fernández-Val, I. (2011). Inference for extremal conditional quantile models, with an application to market and birthweight risks. *Review of Economic Studies* 78(2), 559–589. **[V-bib]**
- Wang, H. J., Li, D. & He, X. (2012). Estimation of high conditional quantiles for heavy-tailed distributions. *JASA* 107(500), 1453–1464. doi:10.1080/01621459.2012.716382 **[V-bib]**
- Madrid Padilla, O. H. & Chatterjee, S. (2022). Risk bounds for quantile trend filtering. *Biometrika* 109(3), 751–768. doi:10.1093/biomet/asab045 **[V]** (already in your bib; single τ, no UQ)

### Scoring rules and metrics
- Gneiting, T. & Raftery, A. E. (2007). Strictly proper scoring rules, prediction, and estimation. *JASA* 102(477), 359–378. doi:10.1198/016214506000001437 **[V]**
- Laio, F. & Tamea, S. (2007). Verification tools for probabilistic forecasts of continuous hydrological variables. *Hydrology and Earth System Sciences* 11(4), 1267–1277. doi:10.5194/hess-11-1267-2007 **[V]** (CRPS = 2∫ρ_τ dτ)
- Gneiting, T. & Ranjan, R. (2011). Comparing density forecasts using threshold- and quantile-weighted scoring rules. *JBES* 29(3), 411–422. doi:10.1198/jbes.2010.08110 **[V]**
- Winkler, R. L. (1972). A decision-theoretic approach to interval estimation. *JASA* 67(337), 187–191. doi:10.1080/01621459.1972.10481224 **[V]**
- Bracher, J., Ray, E. L., Gneiting, T. & Reich, N. G. (2021). Evaluating epidemic forecasts in an interval format. *PLoS Computational Biology* 17(2), e1008618. doi:10.1371/journal.pcbi.1008618 **[V]**
- Panaretos, V. M. & Zemel, Y. (2019). Statistical aspects of Wasserstein distances. *Annual Review of Statistics and Its Application* 6, 405–431. doi:10.1146/annurev-statistics-030718-104938 **[V]**
- Gneiting, T., Balabdaoui, F. & Raftery, A. E. (2007). Probabilistic forecasts, calibration and sharpness. *JRSS-B* 69(2), 243–268. doi:10.1111/j.1467-9868.2007.00587.x **[V]**
- Kuleshov, V., Fenner, N. & Ermon, S. (2018). Accurate uncertainties for deep learning using calibrated regression. *ICML*, PMLR 80, 2796–2804. **[V]**
- Sangnier, M., Fercoq, O. & d'Alché-Buc, F. (2016). Joint quantile regression in vector-valued RKHSs. *NeurIPS 29*. **[V]** (crossing loss)
- Park, Y., Maddix, D. C., Aubet, F.-X., Kan, K., Gasthaus, J. & Wang, Y. (2022). Learning quantile functions without quantile crossing for distribution-free time series forecasting. *AISTATS*, PMLR 151, 8127–8150. **[V]** (percent adjacent crossing)
- Brando, A., Gimeno, J., Rodríguez-Serrano, J. & Vitrià, J. (2022). Deep non-crossing quantiles through the partial derivative. *AISTATS*, PMLR 151, 7902–7914. **[V]** (count of crossing pairs)
- Rodrigues, F. & Pereira, F. C. (2020). Beyond expectation: deep joint mean and quantile regression for spatiotemporal problems. *IEEE Trans. Neural Networks and Learning Systems* 31(12), 5377–5389 (arXiv:1808.08798). **[V-bib]** (crossing loss + number of crossing instances)
- Cannon, A. J. (2018). Non-crossing nonlinear regression quantiles by monotone composite quantile regression neural network, with application to rainfall extremes. *Stochastic Environmental Research and Risk Assessment* 32(11), 3207–3225. doi:10.1007/s00477-018-1573-6 **[V]**
- Fakoor, R., Kim, T., Mueller, J., Smola, A. J. & Tibshirani, R. J. (2023). Flexible model aggregation for quantile regression. *JMLR* 24(162), 1–45. **[V]** (sorting/isotonic correction never worsens WIS)
- Tagasovska, N. & Lopez-Paz, D. (2019). Single-model uncertainties for deep learning. *NeurIPS 32*. **[V]** (PICP/MPIW)

*Access note.* Web search was blocked for parts of this sweep and several publishers (Wiley, T&F, OUP, ScienceDirect, JSTOR) refused automated access, so discovery relied on arXiv, CrossRef, PMLR/NeurIPS proceedings, Springer, and the reference lists of the papers that could be read in full. Items marked [U] should be checked before citing; 2025–2026 coverage is probably incomplete.
