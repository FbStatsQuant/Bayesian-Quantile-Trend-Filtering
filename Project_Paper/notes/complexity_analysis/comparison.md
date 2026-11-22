# Per-Gibbs-iteration complexity: Gaussian S signal, n=500, k=2

This note analyzes the individual-quantile algorithm in the PMALA draft and its matching `Simulations/NOTS_n500/R/individual_core.R` implementation. It compares both Onizuka MCMC priors in `Simulations/Onizuka/NOTS_n500/src/BQTF-function.R`. It does not substitute a differently named corrected or augmented PMALA variant for the draft algorithm.

## Setting

One fixed data set, seed 1, one quantile tau=0.5, x_i=i:

    y_i = sin(2*pi*i/500) + s_i*epsilon_i,
    s_i = (1+(i/500)^2)/4, epsilon_i ~ N(0,1).

Gaussian describes the data-generating noise. Both quantile methods still use an asymmetric-Laplace working likelihood. No data generation or true-quantile calculation is needed inside Gibbs. Other quantiles have the same structural operation counts, although timings and proximal convergence can change.

The draft's k=2 means THIRD differences, D3 of dimension 497 by 500. Each row has four nonzeros, so nnz(D3)=1988. The posterior log-density involves L(theta)=sum rho_tau(y_i-theta_i) and V(theta)=||D3 theta||_1.

## Draft PMALA: one complete outer iteration

The actual call graph is:

1. Evaluate the smoothed likelihood gradient at the current theta; draw 500 normals; compute the noisy input; run trendfilter once to form the proposed theta.
2. Evaluate two target log-densities, one at the current theta and one at the proposal.
3. Re-evaluate the current gradient and run trendfilter a second time to construct the forward mean used in the MH ratio.
4. Evaluate the proposal gradient and run trendfilter a third time for the reverse mean.
5. Compute two squared Euclidean distances and make one uniform accept/reject draw.
6. Recompute V(theta) at the accepted/current state and draw lambda from Gamma(a0+497,b0+V).
7. Recompute L(theta) and draw sigma from IG(500+a_sigma,b_sigma+L).

Counts per iteration: 3 trendfilter calls; 3 vector gradients (1500 scalar exponential evaluations); 3 target-penalty D3 products; 3 check-loss sums; 2 squared-distance reductions; 500 standard-normal draws, 1 uniform draw, and 2 Gamma-family draws (one reciprocated). Distribution draws are not identical-cost primitive operations: Gamma and GIG generators can have data-dependent rejection work.

The stored D in this implementation is DENSE. A conventional dense matrix-vector count for one D3 product is 497*(2*500-1)=496503 additions/multiplications, or 1489509 for the three calls. That count excludes absolute values and reductions. The same mathematical product can use a four-coefficient stencil in 5*497=2485 arithmetic operations, or successive first differences in 1494 subtractions. This is a removable O(n^2) term outside trendfilter.

## What happens inside each trendfilter call

Checked against the installed glmgen commit 9e6061503d6dd103712a0c07f6be7293c1c58aaf, Gaussian family, k=2, default tridiag=0, one supplied lambda, max_iter=800, objective tolerance 1e-5. Its Gaussian family refers to the quadratic proximal objective, not the quantile working likelihood.

Each ordinary call constructs sparse difference operators and performs THREE sparse QR factorizations: weighted D3 transpose (500 by 497), modified D2 transpose (500 by 498), and the 500 by 500 ADMM kernel. It also computes the maximum-lambda and initialization quantities even though one lambda is supplied. The wrapper is called afresh, without cached factors or previous-call ADMM state.

The specialized split uses alpha=D2 beta, with alpha of length 498 and the first-difference penalty on alpha. The kernel is pentadiagonal, H=I+rho_eff*(D2)'D2. In this implementation rho_eff also scales with the supplied proximal penalty. Each inner ADMM sweep performs:

- A D2-transpose operation and construction of a length-500 right-hand side.
- One sparse-QR system solve using the already computed kernel factorization (Householder transformations plus a triangular solve).
- A forward D2 operation.
- One exact one-dimensional fused-lasso dynamic-programming solve on 498 entries.
- A length-498 dual update.
- A full quadratic-plus-third-difference objective evaluation and a stopping check.

Thus, if J1,J2,J3 are the actual inner sweep counts in the three calls,

    T_draft = 3*T_TF_setup(500,2)
              + (J1+J2+J3)*T_ADMM_sweep(500,2)
              + T_remaining_R_updates.

Each fixed-order sweep is O(n), not O(1). Setup is also linear under the usual sparse/banded implementation assumptions; a call is O(n*(1+J)). The implementation's dense D3 products give the full draft code cost O(n^2 + n*(J1+J2+J3)). Replacing those products by differences gives O(n*(1+J1+J2+J3)). A bounded iteration limit is not a guarantee of a fixed proximal accuracy as n changes.

There are normally 9 sparse QR factorizations per outer draft step (3 per call), plus J1+J2+J3 kernel solves and the same number of fused-lasso subproblems. These are included in the measured trendfilter time. This count does not include additional setup solves used for initialization. No refactorization occurs on every ADMM sweep.

The native C loop reports its zero-based terminating counter in fit$iter. For ordinary converged calls the actual number of sweeps is fit$iter+1; at the 800-sweep limit it is 800. The timing script records min(fit$iter+1,800). It records reaching the cap separately; status=0 alone is not a convergence certificate.

## Onizuka: conditional Gaussian draw and remaining Gibbs blocks

Let Dbar stack the first three coordinate-selector rows over the third-difference operator. It is a 500 by 500 invertible operator; the boundary rows encode proper priors and do not increase its bandwidth. Write s=Onizuka's sigma^2 (an ALD scale), t2=2/[tau*(1-tau)], psi=(1-2*tau)/[tau*(1-tau)]. For one observation at every location,

    A = Dbar' W^(-1) Dbar + diag(1/(t2*z_i)),
    B_i = (y_i/z_i-psi)/t2,
    theta | rest ~ N(A^(-1)B, s*A^(-1)).

A has half-bandwidth 3: seven diagonals, at most 3488 nonzeros, or 1994 stored entries in its lower triangle. The inverse is generally dense. A and its numeric factor change when the augmentation and shrinkage variables change.

A banded implementation need not calculate any inverse. With A=L L', compute

    v = solve(L,B),
    theta = solve(L', v + sqrt(s)*xi),  xi ~ N(0,I_500).

This needs one banded Cholesky factorization and TWO triangular solves, plus 500 normals. Equivalently, separately calculating the mean and noise uses three triangular solves; the expression above combines the last two. For fixed half-bandwidth 3, matrix assembly, factorization, and solves are O(n), with O(n) working memory.

For perspective, elementary row-oriented banded Cholesky arithmetic gives about 15n additions/multiplications/divisions plus n square roots, and each triangular solve about 7n arithmetic operations. At n=500, a boundary-adjusted count is 14442 arithmetic operations plus 500 square roots for factorization and the two solves, before matrix assembly, random generation, and combining/scaling vectors. This is an illustrative algorithm count, not a measured LAPACK flop count or the cost of a whole sweep.

The remaining scalar update counts per Gibbs sweep are:

| Draw type | Onizuka Laplace | Onizuka horseshoe |
|---|---:|---:|
| Standard normals for theta | 500 | 500 |
| ALD latent-variable GIG draws | 500 | 500 |
| Interior local-scale draws | 497 GIG | 497 inverse-Gamma |
| Boundary-scale draws | 3 inverse-Gamma | 3 inverse-Gamma |
| Local auxiliary draws | None | 497 inverse-Gamma |
| ALD-scale draw | 1 inverse-Gamma | 1 inverse-Gamma |
| Global-scale draw | 1 GIG | 1 inverse-Gamma |
| Global auxiliary draw | 1 inverse-Gamma | 1 inverse-Gamma |

Totals excluding normals: Laplace 998 GIG + 5 inverse-Gamma; horseshoe 500 GIG + 1000 inverse-Gamma. Preparing these parameters and sums is O(n) with sparse/stencil difference operations. Both optimized complete sweeps therefore have O(n) expected cost under the conventional bounded-expected-cost scalar-generator assumption.

## What the supplied Onizuka R code actually does

Both variants call solve(A) without a right-hand side, explicitly construct and symmetrize the dense covariance, then call MASS::mvrnorm. The installed mvrnorm computes a dense symmetric eigendecomposition each call. The configured comparison has sparse=FALSE. Consequently the current Onizuka implementations have O(n^3) runtime and O(n^2) working memory per sweep; this does not describe the best banded implementation of the same Gaussian conditional.

| Implementation | Complete outer-step cost, fixed k=2 |
|---|---|
| Draft PMALA code, including trendfilter and dense D3 products | O(n^2 + n*(J1+J2+J3)) |
| PMALA computational design with sparse/stencil D3 products | O(n*(1+J1+J2+J3)) |
| Supplied Onizuka R code | O(n^3) |
| Onizuka with banded precision sampling | O(n) |

Thus the actual dense-code comparison can favor PMALA strongly, but proximal mappings do not automatically improve asymptotic complexity over a properly banded Gaussian sampler. They exchange latent-variable updates and a direct factorization for several iterative optimization solves.

## Interpretation and proposal discrepancy

The draft and matching code put Gaussian noise INSIDE a nonlinear proximal map, yet evaluate Gaussian proposal densities centered at separately constructed means. A nonlinear proximal transform of a Gaussian generally does not have that Gaussian proposal density. The supplied acceptance ratio therefore does not establish invariance of the claimed posterior. Timings here deliberately retain that code and measure its computational work, not valid posterior efficiency.

The existing `Simulations/My Samplers/Others/Individual_Sampler_Scale_PMALA_Corrected.R` instead adds Gaussian noise after forming a deterministic proximal mean and evaluates matching forward/reverse Gaussian densities. That implementation uses TWO proximal calls per proposal. It is a different algorithm from the draft and was not silently substituted into this benchmark.

Even with a correct MH kernel, one PMALA transition is a Metropolis-within-Gibbs update, whereas Onizuka draws theta directly from its augmented full conditional. Equal iteration counts do not imply equal effective sample sizes. These models also differ in boundary treatment and scale/shrinkage priors. Per-effective-sample comparisons require valid kernels, suitable burn-in, and ESS measurements; the small timing audit below is not such a comparison.

## Sources

- Local draft: `PMALA version Tex Project/sections/methodology.tex`, individual sampler; `sections/simulations.tex`, S/Gaussian specification.
- Matching original individual code: `Simulations/NOTS_n500/R/individual_core.R`, lines 37-80 and 157-163.
- Onizuka local PDF: `Papers/Onizuka_2023.pdf`, Section 2.3, pp. 7-9. Public version: https://arxiv.org/abs/2211.04666.
- Supplied Onizuka code: `Simulations/Onizuka/NOTS_n500/src/BQTF-function.R`, lines 106-109 and 248-251; campaign config specifies sparse=FALSE.
- Exact installed glmgen source: https://github.com/glmgen/glmgen/blob/9e6061503d6dd103712a0c07f6be7293c1c58aaf/R_pkg/glmgen/src/tf_admm.c. Saved reference copy accompanies this note.
- Specialized ADMM analysis: Ramdas and Tibshirani (2016), Section 2: https://www.stat.cmu.edu/~ryantibs/papers/fasttf-jcgs.pdf.

Timing results are in `timings.csv`, proximal diagnostics in `prox_iterations.csv`, environment and settings in `timing_environment.txt`, and the reproducible driver in `benchmark_existing.R`. The driver is run from the workspace root. Sampling time excludes package loading, data generation, matrix setup before Gibbs, burn-in timing, plotting, summaries, and file output; it includes all three trendfilter calls and their internal setup and sweeps. The two original implementations have slightly different surrounding storage overhead; this is a short computational audit, not a controlled steady-state MCMC study.

## Measured n=500 results

These are short early-chain timing windows: three repetitions on the same seed-1 data, each with five untimed warm iterations and thirty measured iterations. This warm-up is for timing, not a claim of MCMC convergence. PMALA uses gamma=0.1, delta=0.02, eps=0.01, a0=500, b0=1, a_sigma=b_sigma=0.1, lambda_init=20. Onizuka uses its supplied sig.init=c(1,1). Exact settings and R/package versions accompany the outputs.

| Method | Median ms/full iteration | Range of repetition means, ms |
|---|---:|---:|
| Draft PMALA, including all three trendfilter calls | 30.33 | 30.00-85.33 |
| Onizuka Laplace, supplied dense code | 435.67 | 418.67-1126.33 |
| Onizuka horseshoe, supplied dense code | 649.00 | 424.00-1001.00 |
| Hypothetical banded Onizuka implementation | Not timed | Not timed |

| PMALA repetition | Whole step, ms | All trendfilter calls, ms | Mean ADMM sweeps/call | Mean ADMM sweeps/Gibbs step |
|---|---:|---:|---:|---:|
| 1 | 30.33 | 30.33 | 329.46 | 988.37 |
| 2 | 30.00 | 28.33 | 305.34 | 916.03 |
| 3 | 85.33 | 82.67 | 334.10 | 1002.30 |

Across 90 measured PMALA steps there were 270 trendfilter calls and 87201 inner ADMM sweeps: 322.97 sweeps/call, or 968.9 sweeps/Gibbs step. Thus the typical observed step solved roughly 969 banded-kernel systems and roughly 969 length-498 fused-lasso subproblems, plus the nine QR factorizations in the three setups. All 270 calls had status 0 and none reached the 800-sweep cap; the largest observed count was 581. This only checks the solver's own stopping rule, not independently certified proximal accuracy.

The three trendfilter calls took approximately 97% of aggregate timed PMALA work. Millisecond timer quantization means the first repetition's displayed 100% should not be read literally as zero cost for everything else. Per-call timing instrumentation and diagnostic recording add a small overhead. Runtime varied markedly across repetitions, so these values should be treated as local short-run timings rather than precise or stationary benchmarks.

The ratio of median timings is about 14.4 for dense Onizuka Laplace versus draft PMALA and 21.4 for dense Onizuka horseshoe versus draft PMALA. These are neither ESS gains nor predicted speedups over banded Onizuka. No wall-clock result for a banded implementation was measured.
