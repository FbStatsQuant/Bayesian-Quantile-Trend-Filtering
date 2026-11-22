**Verdict — same target with caveat: the implemented latent-scale clamps break exactness.** With matched hyperparameters, integrating the two ideal mixtures gives exactly the paper's posterior. The shipped updates modify both mixtures. I found no structural error in the Gaussian draw, difference order, fixed-parameter scale or learned-parameter updates. The code review establishes where exactness fails. The magnitude of any change in the study's conclusions has not been established.

### Posterior and augmented joint

Let $q=\tau(1-\tau)$, $\psi=(1-2\tau)/q$, $t^2=2/q$, $e=y-\theta$, $v=D^{(3)}\theta$, and $m=n-3$. Write $h(\lambda,\sigma)$ for the independent Gamma(shape $a_0$, rate $b_0$) and inverse-gamma(shape $a_\sigma$, scale $b_\sigma$) prior densities. The latter has exponential factor $\exp(-b_\sigma/\sigma)$. With Lebesgue measure on the three quadratic null-space coordinates, the paper's joint posterior density is proportional to

$$
h(\lambda,\sigma)(q/\sigma)^n
\exp\{-\textstyle\sum_i\rho_\tau(e_i)/\sigma\}
(\lambda/2)^m\exp\{-\lambda\|v\|_1\}.
$$

The change of coordinates from $\theta$ to its null coordinates and $v$ contributes only a fixed Jacobian. Writing $N(x;\mu,V)$ for a normal density evaluated at $x$, the intended augmented joint is proportional to

$$
h(\lambda,\sigma)
\prod_i N(e_i;\psi z_i,t^2\sigma z_i)\,\sigma^{-1}e^{-z_i/\sigma}
\prod_j N(v_j;0,s_j)\,(\lambda^2/2)e^{-\lambda^2 s_j/2},\qquad z_i,s_j>0.
$$

Integrating each $z_i$ gives $(q/\sigma)\exp[-\rho_\tau(e_i)/\sigma]$. Integrating each $s_j$ gives $(\lambda/2)\exp[-\lambda|v_j|]$. These identities also establish the fixed-parameter posterior by conditioning on $(\lambda,\sigma)$. See Project_Paper/sections/methodology.tex:18 and Project_Paper/sections/appendix_pmala.tex:18.

### Findings

1. **CONFIRMED — Difference precisions are clipped.** Engineering/E02_Rate_Sims/e02_lib.R:234 floors $|v_j|$ at $1/(C\lambda)$ and caps the sampled precision at $C\lambda^2$, with default $C=10^6$. The correct reciprocal-scale conditional is inverse Gaussian with mean $\lambda/|v_j|$ and shape $\lambda^2$. Capping puts positive mass at the endpoint. At $\lambda=10^9$ the thresholds are $10^{-15}$ and $10^{24}$, respectively. In units of $\lambda v_j$ and $1/(\lambda^2s_j)$ they stay fixed, so large $\lambda$ alone does not imply increasing clipping bias. Engineering/E02_Rate_Sims/check_iwcap_penratio.R:5 varies the cap in two fixed-$\lambda$ sine cells, and its header reports stable penalty ratios. That check leaves the ALD clamps active. **Fix:** draw $\lambda^2s_j$ directly from its scale-free conditional, with the exact $\chi^2_1$ limit at $v_j=0$, then invert. Compare uncapped and production summaries at the largest penalties with Monte Carlo errors.

2. **CONFIRMED — Both samplers clip the ALD latent.** Engineering/E02_Rate_Sims/e02_lib.R:133 and Simulations/Individual/Individual_Sampler_PMALA_Augmented.R:215 use the correct inverse-Gaussian mean $1/(q|e_i|)$ and shape $1/(2q\sigma)$ for $1/z_i$, then replace $|e_i|<10^{-10}$ and force $z_i$ into $[10^{-8},10^4]$. This changes both the likelihood weight and, at asymmetric quantiles, its working response. The upper bound deserves a check in the Cauchy arm (run_grid.R:42). The exact conditional mean of $z_i$ is $q|e_i|+2q\sigma$, which can exceed the cap for a sufficiently large residual. **Fix:** use a stable positive-scale draw including the exact zero-residual law $z_i=2q\sigma\,\chi^2_1$. Measure bound hits and rerun representative Cauchy and extreme-penalty cells against the unclipped update.

3. **CONFIRMED — The Gaussian draw has the required mean and covariance.** Engineering/E02_Rate_Sims/e02_lib.R:235 and Engineering/E02_Rate_Sims/banded_ls.cpp:39 stack $A=[W^{1/2};S^{-1/2}D]$ and use right-hand side $[W^{1/2}r+\xi_1;\xi_2]$, where $W_{ii}=1/(t^2\sigma z_i)$, $r=y-\psi z$, $S=\mathrm{diag}(s)$ and the noises are fresh independent standard normals. Thus $Q=A^TA$ and the normal-equation right-hand side has mean $Wr$ and covariance $Q$. Solving gives covariance $Q^{-1}$. Each of the $n-3$ prior rows uses $(-1,3,-3,1)$ once. When row $j$ enters, no earlier row extends beyond $j+3$, so the bounded Givens loop at banded_ls.cpp:15 discards no fill. Positive data weights give full rank without a ridge. **Action:** retain this block. Its exactness is conditional on the supplied weights and exact arithmetic.

4. **CONFIRMED — Fixed and learned updates have the paper's parametrization.** Engineering/E02_Rate_Sims/run_grid.R:87 converts the MAP penalty $\Lambda$ to $\lambda=\Lambda/\sigma$. Both learning flags default to false. Engineering/E02_Rate_Sims/e02_lib.R:238 updates only enabled parameters. Integrating out $s$ gives $\lambda\mid\theta\sim\mathrm{Gamma}(a_0+m,b_0+\|v\|_1)$. In the optional interweaving step at e02_lib.R:203 the rough-coordinate Jacobian cancels $\lambda^m$ and the log-scale Jacobian leaves $a_0\log\lambda$. Old $s$ is discarded before its next use. The scale update has shape $a_\sigma+3n/2$ and scale $b_\sigma+\sum_i[z_i+(e_i-\psi z_i)^2/(2t^2z_i)]$. These agree with the reference unscaled-prior branch at Individual_Sampler_PMALA_Augmented.R:369. **Action:** retain these updates and match prior rates when comparing studies. The benchmark rates at pmala_vs_gibbs.R:36 differ from the interior-quantile simulation rates at Project_Paper/sections/simulations.tex:25.

5. **CONFIRMED — Validation can detect some wrong targets, but agreement cannot certify exactness.** Engineering/E02_Rate_Sims/validate_samplers.R:20 compares fixed-mode trends, spread, interval widths and mean loss, with a batch-means difference statistic only for mean loss. Its four cells cover neither the Cauchy arm nor raw $\lambda=10^9$. Both chains use the same ALD routine. Engineering/E02_Rate_Sims/pmala_vs_gibbs.R:60 records learned-parameter and trend summaries as well as ESS, but includes only median regression and gives no uncertainty-calibrated target comparison. **Fix:** add a small independent reference integrating the original ALD and Laplace densities, and compare trend contrasts, roughness, interval spread and learned hyperparameters against Monte Carlo or integration error. Include at least one asymmetric quantile. Compare high-penalty cells to the unclipped sampler separately.

6. **CONFIRMED — The reported midpoint ESS is mis-scaled.** Engineering/E02_Rate_Sims/e02_lib.R:266 (also :180) multiplies the ESS of the thinned midpoint series by the thinning interval. For independent draws this reports the full sweep count although only one in every five or ten midpoint draws entered the estimate. In general this multiplication cannot recover full-trace ESS. **Fix:** report the thinned-series ESS directly, or compute ESS on the unthinned midpoint trace. The comparison at pmala_vs_gibbs.R:61 already uses unthinned coordinate traces.

This was a source and algebra review. No chains were run and no existing simulation outputs were re-estimated.
