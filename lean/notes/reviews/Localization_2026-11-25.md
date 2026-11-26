# Review of BQTF.Localization

**Verdict — PASS WITH FINDINGS.** 0 blockers, 0 major findings, 2 minor findings, and 2 nits. The build passed. All ten sources of `sorryAx` are frozen upstream declarations.

Reviewed detached commit `70b42f72b26f9ee9cba3c4eea2ae42a8436c576d` against `main` at `87bfe63f3983acc96d870133943ea64a6493b5dc`. The scoped three-dot diff covers Localization and its three Local helpers. `git diff --check` passed for those paths. Shells and Main edits were outside the review. I checked the Main call site only to verify how the denominator constant and thresholds are used.

## Findings

1. **Minor — The radial estimate repeats the existing logarithm bound.** The proof of `hsmallLog` repeats the little-o argument and the split of `log (2 * n)` already in `Asym.log_twice_eventually_le`. Instantiate that lemma at `d = 1 / (16 * r)` and use `Asym.mul_epsSq_le` to replace `n * epsSq r n` by `n`. The required sign and sample-size bounds are already available eventually. [LocalRates.lean:266](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:266), [ShellRates.lean:25](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/ShellRates.lean:25), [Rates.lean:33](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/Rates.lean:33)
2. **Minor — The absolute Laplace moment rederives normalization.** The proof splits the real line and repeats the half-line exponential integrals used in the imported Laplace file. Pointwise, multiplying the rate-`lam` density by `exp (s * |x|)` gives `lam / (lam - s)` times the rate-`(lam - s)` density. The existing `laplace_probability` applies since `s < lam`, so the proof can reuse it directly, including when `s < 0`. The product moment already reuses `lintegral_pi_ofReal_prod`. [LocalMass.lean:103](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalMass.lean:103), [Laplace.lean:23](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/Laplace.lean:23), [Laplace.lean:77](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/Laplace.lean:77), [LocalMass.lean:178](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalMass.lean:178)
3. **Nit — Several public helpers lack declaration-level docstrings.** The module headers describe their subject areas. Add short docstrings to the nontrivial interfaces, particularly the ray inequality, product-to-coordinate loss decomposition, and the eventual width and radial bounds. The two public integration formulas in LocalMass already have docstrings. [LocalGeometry.lean:77](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalGeometry.lean:77), [LocalGeometry.lean:110](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalGeometry.lean:110), [LocalRates.lean:98](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:98), [LocalRates.lean:245](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:245), [LocalMass.lean:70](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalMass.lean:70), [LocalMass.lean:157](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalMass.lean:157)
4. **Nit — A helper name and some parameters overstate what the proofs use.** `rpow_log_nonneg` proves nonnegativity of the logarithm itself and can be replaced by `Real.log_nonneg` with a cast. The `_hc` arguments in `Tn_eq` and `eventually_radial_bounds`, and `_hα` in `local_mass_tv`, are unused. [LocalRates.lean:11](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:11), [LocalRates.lean:25](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:25), [LocalRates.lean:245](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:245), [Localization.lean:338](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:338)

## Statement fidelity and proof

- Byte comparisons against `git show main:lean/BQTF/Localization.lean` matched the full `localization` docstring and declaration through `:= by`, and the complete `Kn` and `OmegaG` definitions and their docstrings. The intervening `s0` docstring and definition also matched. The paper labels the result `pf:prop:local`. Both probability bounds match exactly, namely $64/(\underline f^2 n\rho_n^2)$ and $r!(e^{-\underline f n\rho_n^2/16}+e^{-n/8})$. The frozen coordinatewise bound in part (a) gives the paper's loss identity since $s_0\le1$ implies $\min(|\delta_i|,\delta_i^2)=\delta_i^2$. The posterior event is about the translated parameter $\theta-\theta^*$. [Localization.lean:23](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:23), [Localization.lean:30](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:30), [Localization.lean:602](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:602), [Spec.lean:54](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Spec.lean:54), [appendix_theory.tex:244](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:244)
- The hypotheses have a common example for every $n>r$. Take $k\ge1$, $c=1$, $\tau=1/2$, each $\mu_i$ uniform on $[-1,1]$, $\theta^*=0$, $L=1/2$, $\underline f=\overline f=1/2$, and $\bar V=0$. The two CDF inequalities hold with equality and the signal variation is zero. In the general proof, applying both CDF bounds at $L$ to one coordinate gives $\overline f\ge\underline f>0$. The threshold is chosen before the data hypotheses are introduced using $\max(\underline f,\overline f)$ and is specialized to the actual $s_0$ after that comparison. [Spec.lean:97](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Spec.lean:97), [Spec.lean:118](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Spec.lean:118), [Localization.lean:621](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:621), [Localization.lean:638](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:638)
- Write $a=2/(2r+1)$, $X=n^a$, and $\ell=\sqrt{\log n}$. The chosen $J=\lceil X\rceil$ satisfies $1\le J\le n-r$ eventually because $X\le n/2$ and $n\ge2(r+1)$. Since $\sqrt n\rho_n=\sqrt X\ell$, the first width term is bounded by $\sqrt{2+r}\,X\ell$. For the second, $T_n=(4/c)\sqrt n$, $J^{-(r-1/2)}\le X^{-(r-1/2)}$, and $n X^{-(r-1/2)}=X$. Together with $\sqrt{\log(2n)}\le2\ell$, this gives width at most $C X\ell$ for a fixed $C$. Eventually $\ell\ge32C/\underline f$, giving width at most $(\underline f/32)n\rho_n^2$. Concentration yields a mean at most $(\underline f/8)n\rho_n^2$ and variance at most $n\rho_n^2$. The gap to the event cutoff is at least $(\underline f/8)n\rho_n^2$, so Chebyshev gives the factor $64$. [LocalRates.lean:110](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:110), [LocalRates.lean:135](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:135), [LocalRates.lean:185](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:185), [LocalRates.lean:219](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:219), [Localization.lean:100](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:100), [Localization.lean:124](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:124)
- The interpolation decay uses $4r(r-2)+1>0$ for $r\ge2$. The proof takes a common eventual threshold $N$ for interpolation, width, and the radial bounds, then chooses $n_2=\max(N,r+1)>k+1$. The witness is uniform in $\tau$, the laws, and the signal. Main takes a maximum with $n_1$ from the denominator lemma, giving the paper's bookkeeping. [LocalRates.lean:51](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:51), [Localization.lean:619](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:619), [Localization.lean:633](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:633), [Main.lean:242](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Main.lean:242), [Main.lean:281](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Main.lean:281)
- On a ray outside $K_n$, the gauge exceeds one, the rescaled vector belongs to $K_n$, and convexity propagates the boundary loss. When the empirical norm dominates, the rescaled norm equals $\rho_n$ and the expected quadratic lower bound supplies $2\alpha_n$ before subtracting the fluctuation $\alpha_n$. In the TV case the proof uses global nonnegativity of the expectation and $t\le\lambda\|u\|_1/(4n)+1/2$. The resulting two numerator bounds have exponential factors $e^{-\alpha_n/2}$ and $e^{-n/4}$, respectively. The radial integral uses the Euclidean norm through the volume-preserving coordinate identification. The TV integral uses a positive radius and a strict moment parameter below one. [Localization.lean:168](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:168), [Localization.lean:195](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:195), [Localization.lean:293](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:293), [LocalMass.lean:94](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalMass.lean:94), [Localization.lean:387](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:387), [Localization.lean:499](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:499), [Localization.lean:527](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:527), [Localization.lean:214](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:214)
- The argument `CE` fixes the denominator threshold in $\Omega_E$. Localization uses its lower bound directly as a set-membership hypothesis. It does not invoke the proof of the denominator lemma. For every fixed real $C_E$, the rate estimates absorb $C_E n\epsilon_n^2$ using $C_E n\epsilon_n^2\le\alpha_n/4$ in the first mass bound and absorb the second term's radius ratio together with that exponential using $e^{n/8}$. The denominator lower bound is strictly positive and finite, and the measurable complement of the translated $K_n$ is passed to the ratio lemma. Since $\alpha_n/4=\underline f n\rho_n^2/16$, the resulting constants are the frozen ones. In the intended application, the positive $C_E$ from the denominator lemma also gives a high-probability $\Omega_E$. Its complement bound and the $\Omega_G$ bound tend to zero, so their intersection has positive probability eventually. [Denominator.lean:19](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Denominator.lean:19), [Denominator.lean:30](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Denominator.lean:30), [LocalRates.lean:311](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:311), [LocalRates.lean:343](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:343), [Localization.lean:461](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:461), [Localization.lean:537](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:537), [Localization.lean:587](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:587)
- The upstream calls use admissible quantities. `width` receives $r\ge2$, $r<n$, positive radii and a valid projection index. `concentration` receives probability marginals and a compact, symmetric set containing zero. Compactness and the uniform bound on the centered loss keep the suprema in their bounded regimes. `interp` receives $r\ge2$ and $n>r$. `ell_props` receives an interior quantile level, and `mFun_props` receives the coordinate hypotheses, with $|\delta_i|\le L$ supplied for the quadratic bound. The coordinate lemmas have $1\le r<n$, and the volume and posterior calls have $\lambda>0$, along with their required measurability and radius conditions. The proof reaches none of these bounds through an out-of-domain value. [Localization.lean:100](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:100), [Localization.lean:117](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:117), [Localization.lean:185](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:185), [Localization.lean:279](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:279), [Localization.lean:388](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:388), [Localization.lean:594](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:594), [Localization.lean:621](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:621), [LocalGeometry.lean:127](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalGeometry.lean:127), [LocalMass.lean:71](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalMass.lean:71)

## Axiom provenance

The audit printed axioms for all 31 public declarations in the four files, including the three frozen definitions and `localization`. Seven declarations inherit `sorryAx`. The kernel dependency walk followed types and stored bodies, including private declarations. The following ten declarations directly contain `sorryAx` on paths from `BQTF.localization`. The public helpers with `sorryAx` use a subset of these sources.

| File | Direct sources |
| --- | --- |
| Width | `BQTF.width` [Width.lean:17](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Width.lean:17) |
| Concentration | `BQTF.concentration` [Concentration.lean:25](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Concentration.lean:25) |
| Interp | `BQTF.interp` [Interp.lean:16](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Interp.lean:16) |
| CheckLoss | `BQTF.ell_props` [CheckLoss.lean:62](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/CheckLoss.lean:62), `BQTF.mFun_props` [CheckLoss.lean:81](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/CheckLoss.lean:81) |
| Coord | `BQTF.coordMap_bijective` [Coord.lean:49](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Coord.lean:49), `BQTF.posterior_eq_ratio` [Coord.lean:56](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Coord.lean:56), `BQTF.pythagoras` [Coord.lean:72](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Coord.lean:72), `BQTF.sub_cbar_eq` [Coord.lean:79](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Coord.lean:79), `BQTF.vol_formula` [Coord.lean:86](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Coord.lean:86) |

The reviewed source contains no holes, axiom declarations, `native_decide`, `implemented_by`, `unsafe`, heartbeat overrides, or debug escapes. The build replays warnings for additional upstream declarations outside the reachable proof graph.

## Candidate paper corrections

- Use the simpler $J_n=\lceil n^{2/(2r+1)}\rceil$ or retain the paper's balancing choice and explicitly give $1\le J_n\le n-r$ eventually. In either case, state the $O(n^{2/(2r+1)}\sqrt{\log n})$ width bound and the mean-to-cutoff gap $(\underline f/8)n\rho_n^2$ used in Chebyshev. [appendix_theory.tex:260](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:260), [LocalRates.lean:135](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:135), [Localization.lean:124](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:124)
- In the concentration proof used by localization, specify a nonempty $K$. For the variance step use one-sided Efron–Stein: $(G(Y)-G(Y^{(i)}))_+\le |\hat\delta_i(Y)|$ for a maximizer at the original sample. Sum the squared positive parts before taking expectations to obtain $\sup_K\|\delta\|_2^2$. An unsigned bound requires using the maximizer at whichever sample gives the larger value. [appendix_theory.tex:225](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:225), [appendix_theory.tex:235](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:235)
- In the TV-dominated case, write $t\le\Gamma/(4n)+c\bar V/(4\sqrt n)\le\Gamma/(4n)+1/2$ and integrate with the last majorant. Include the mgf domain $b<1$ and an exponent bound. With $\alpha_n+1\le n/32$, the exponential tilt gives $b=1/2+(\alpha_n+1)/(4n)\le 51/100$ and prefactor $e^{-n+(\alpha_n+1)/2}$. Using $(1-b)^{-1}\le e^{23/32}$ and $m\le n$ gives an exponent at most $-17n/64\le-n/4$. [appendix_theory.tex:266](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:266), [Localization.lean:214](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:214), [Localization.lean:229](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:229), [Localization.lean:272](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Localization.lean:272)
- In the final display use $\Pi_\lambda(\theta-\theta^*\notin K_n\mid y)$ as in the proposition. Spell out that $n\rho_n\epsilon_n\to\infty$, $C_E n\epsilon_n^2=o(n\rho_n^2)$, and $r\log(2\rho_n/\epsilon_n)+C_E n\epsilon_n^2=o(n)$. These give the two exponent absorptions. If $C_E$ is presented as a free fixed parameter, state that $n_2$ may depend on it. For the evidence lemma's choice, it is already determined by the stated constants. [appendix_theory.tex:193](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:193), [appendix_theory.tex:245](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:245), [appendix_theory.tex:269](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/paper/sections/appendix_theory.tex:269), [LocalRates.lean:329](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:329), [LocalRates.lean:343](/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/review-solW1-70b42f7/lean/BQTF/Asym/LocalRates.lean:343)

## Verbatim build output

From the detached worktree's `lean` directory, `~/.config/bvs-hq/owls/owls_run -j 2 -- lake build BQTF.Localization` exited 0.

~~~text
⚠ [8934/8954] Replayed BQTF.CheckLoss
warning: BQTF/CheckLoss.lean:62:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:70:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:75:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:81:8: declaration uses `sorry`
warning: BQTF/CheckLoss.lean:91:8: declaration uses `sorry`
⚠ [8940/8954] Replayed BQTF.Falling
warning: BQTF/Falling.lean:13:8: declaration uses `sorry`
warning: BQTF/Falling.lean:18:8: declaration uses `sorry`
⚠ [8941/8954] Replayed BQTF.Coord
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
⚠ [8942/8954] Replayed BQTF.SplineApprox
warning: BQTF/SplineApprox.lean:26:8: declaration uses `sorry`
warning: BQTF/SplineApprox.lean:32:8: declaration uses `sorry`
warning: BQTF/SplineApprox.lean:38:8: declaration uses `sorry`
⚠ [8945/8954] Replayed BQTF.SmallBall
warning: BQTF/SmallBall.lean:31:8: declaration uses `sorry`
⚠ [8946/8954] Replayed BQTF.QuadShift
warning: BQTF/QuadShift.lean:33:8: declaration uses `sorry`
⚠ [8947/8954] Replayed BQTF.Gram
warning: BQTF/Gram.lean:35:8: declaration uses `sorry`
warning: BQTF/Gram.lean:39:8: declaration uses `sorry`
⚠ [8948/8954] Replayed BQTF.Smooth
warning: BQTF/Smooth.lean:17:8: declaration uses `sorry`
⚠ [8949/8954] Replayed BQTF.PriorMass
warning: BQTF/PriorMass.lean:22:8: declaration uses `sorry`
⚠ [8950/8954] Replayed BQTF.Denominator
warning: BQTF/Denominator.lean:30:8: declaration uses `sorry`
⚠ [8951/8954] Replayed BQTF.Width
warning: BQTF/Width.lean:17:8: declaration uses `sorry`
⚠ [8952/8954] Replayed BQTF.Interp
warning: BQTF/Interp.lean:16:8: declaration uses `sorry`
⚠ [8953/8954] Replayed BQTF.Concentration
warning: BQTF/Concentration.lean:25:8: declaration uses `sorry`
Build completed successfully (8954 jobs).
~~~

## Verbatim axiom and provenance output

From the same directory, `~/.config/bvs-hq/owls/owls_run -j 2 -- lake env lean /tmp/sol-loc-review-70b42f7/Audit.lean` exited 0.

~~~text
'BQTF.Kn' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.s0' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.OmegaG' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.localization' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.l2sq_nonneg' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.sq_empNorm' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.empNorm_nonneg' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.TVr_nonneg' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.l2sq_le_of_empNorm_le' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.continuous_TVr' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.continuous_empNorm' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.isClosed_Kset' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.isCompact_Kset' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.diffOp_smul' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.TVr_smul' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.empNorm_smul' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.lossHat_ray' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.integrable_ell' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.lossExp_eq_sum' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.lossExp_nonneg' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.lossExp_quadratic_lower' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.continuous_coordMap' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.continuous_NT' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.continuous_l2norm' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.nu_lintegral_exp_NT' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'BQTF.Qlam_lintegral_exp_l1' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Asym.Tn_eq' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Asym.rhoSq_tendsto_zero' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Asym.interpolation_factor_tendsto_zero' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Asym.eventually_width_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
'BQTF.Asym.eventually_radial_bounds' depends on axioms: [propext, Classical.choice, Quot.sound]
reachable constants seen: 48263
direct sorryAx source: BQTF.concentration
direct sorryAx source: BQTF.coordMap_bijective
direct sorryAx source: BQTF.ell_props
direct sorryAx source: BQTF.interp
direct sorryAx source: BQTF.mFun_props
direct sorryAx source: BQTF.posterior_eq_ratio
direct sorryAx source: BQTF.pythagoras
direct sorryAx source: BQTF.sub_cbar_eq
direct sorryAx source: BQTF.vol_formula
direct sorryAx source: BQTF.width
width direct source check: [BQTF.width]
~~~

## Head rulings (Lean head, 2026-11-25)

- **F1, F2 (minor), reuse:** deferred to the polish pass. These are non-blocking, with no correctness impact.
- **F3, F4 (nits):** deferred to the polish pass.
- **Paper candidates:** (i) The J_n choice and range is exposition, since Lean used a different but equivalent J. (ii) The concentration variance step is already C-06. (iii) The A_2 mgf domain is exposition: ϑ=1/2+(α_n+1)/(4n)<1 holds for n ≥ n_2, which the paper's "for n ≥ n_2" covers. This differs from C-08, where the domain condition is used before it is established. (iv) The final-display notation and the absorptions are exposition. None is a new correction.
- **Verdict upheld: PASS.** The merge waits for Sol-W1's rebased branch, which merges together with Shells.
