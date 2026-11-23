# Learning the difference-prior rate in Stage A

Internal research note, 23 November 2026. PROVED denotes a deduction below, subject to independent audit. The positive result invokes the prior lemmas of Theorem B. All priors on λ below use the **rate** convention. The three quadratic coefficients have Lebesgue prior in the orthonormal coordinates of L5.

## (d1) and (d2). PROVED — a fixed-scale counterexample for both hyperpriors

At some fixed positive σ, even iid uniform errors and the zero truth give inconsistency. For either rate schedule in the question there are fixed constants $0<a<A<\infty$ for which, with sampling probability tending to one, the posterior assigns probability tending to one to
$$
 a\le\lambda\le A,\qquad \|\theta-\theta^*\|_n>1/4.
$$
In particular no deterministic window with diverging lower endpoint can support a C1 argument in this generality. This refutes a universal constant-rate-hyperprior $n^{3/4}$ law, even with nonzero fixed local curvature. It leaves the behavior at the simulation scales, including the jointly learned scale, undecided.

**Proof.** Take $\tau=1/2$, $y_i$ iid uniform on $[-1,1]$, $\theta^*=0$, and $Q=\sum_i|y_i-\theta_i|/2$. Independence, full (A2) with local slope 1/2, and (A3) for every fixed positive V hold. Use the uncentered evidence $Z=\int e^{-Q/\sigma} dc\,P_\lambda(du)\,p_n(d\lambda)$, $u=D\theta$, $m=n-3$. At fixed σ all omitted likelihood factors cancel. Take $p_n=\mathrm{Gamma}(a_0,b_n)$ with fixed positive shape, and either fixed positive rate or $b_n=c n^{-5/2}$ with $0<c_-\le c\le c_+<\infty$.

1. **PROVED — interpolation evidence.** In trend coordinates $dc\,du=J_n\,d\theta$ with $1\le J_n=\sqrt{\det DD^T}\le8^m$. Indeed the inverse map is $\theta\mapsto(N^T(I-SD)\theta,D\theta)$. Adding multiples of the bottom rows to the top gives the stacked matrix with rows $N^T,D$, whose row Gram matrix is block diagonal. Cauchy–Binet gives the lower bound because the last $m$ columns of D have triangular determinant of absolute value one. Hadamard's inequality gives the upper bound from the stencil row norms. Set $q=1/256$, $h=q/4$. On the cube $\|\theta-y\|_\infty\le h$, $Q\le nh/2$, $\|D\theta\|_1\le 8n(1+h)$. For $1\le\lambda\le2$, the difference density there is at least $2^{-m}e^{-16n(1+h)}$. The hyperprior mass of [1,2] has negative log $O(\log n)$ by integrating its density (uniformly for the specified c). Multiplying by $J_n(2h)^n$ proves, for all sufficiently large n,
$$
 Z\ge \exp[-n(K+h/(2\sigma))],\qquad K=16(1+h)+\log(1/h)+1 .
$$

2. **PROVED — posterior fits the observations.** For any $u,y$, $Q\ge \|c-N^T(y-Su)\|_2/2$ by orthogonal projection. Thus $\int e^{-Q/(2\sigma)}dc\le C\sigma^3$ by polar integration. Reserving half the likelihood for this integral bounds the evidence on $Q\ge qn$ by $C\sigma^3e^{-qn/(2\sigma)}$. Choose once and for all $0<\sigma<(q-h)/(2(K+1))$. Dividing by the cube bound gives exponentially vanishing posterior mass there, uniformly in the data in the sampling support. The LLN gives $Q(0)/n>1/5$ with probability tending to one since its mean is $1/4$. As $|Q(0)-Q(\theta)|\le n\|\theta\|_n/2$, $Q<qn$ implies $\|\theta\|_n\ge2(1/5-q)>1/4$ on that event.

3. **PROVED — bounded posterior tuning.** With probability tending to one $\|Dy\|_1\ge n/4$. Each absolute stencil has expectation at least 1/2 by conditioning on all observations except one endpoint and minimizing $E|y_i-t|$ at zero. These bounded variables are 3-dependent, so their sum has variance $O(n)$ and Chebyshev applies. On $Q<qn$, the column sums of the absolute stencil give $\|u\|_1\ge n/4-16qn\ge n/8$. Given θ, $(b_n+\|u\|_1)\lambda$ has unit-rate Gamma law of shape $m+a_0$. The chance it exceeds $2n$ tends to zero by its mean and variance. Hence $A=16$ works. For a lower bound, on $0<\lambda<a$ the trend-coordinate prior density at fixed λ is at most $8^m(a/2)^m$, and $\int e^{-Q/\sigma}d\theta=(4\sigma)^n$. The numerator is at most $(4a)^m(4\sigma)^n$. Choose a fixed $0<a<1$ so small that $\log(16a\sigma)<-K-h/(2\sigma)-1$. The evidence bound then gives the claimed lower-tail limit. This completes the proof.

**PROVED — radial explanation.** Integration of the normalized product-Laplace density against Gamma gives density proportional to $(b_n+\|u\|_1)^{-(m+a_0)}$. More precisely $R=\|u\|_1=b_n G_m/G_{a_0}$ in prior law with independent unit-rate gammas, since $\lambda R\mid\lambda\sim\mathrm{Gamma}(m,1)$ and $b_n\lambda\sim\mathrm{Gamma}(a_0,1)$. Thus for each fixed n its tail has order $x^{-a_0}$ as $x\to\infty$: condition on $G_m$, use $P(G_{a_0}<z)\le z^{a_0}/\Gamma(a_0+1)$, the matching small-z asymptote, and dominated convergence using $EG_m^{a_0}<\infty$. Its positive exponential moments are infinite, so the prior exponential-moment estimate in C1's TV cone cannot be integrated over this hyperprior. The evidence comparison above establishes failure of the conclusion itself.

## (d1) and (d2). PROVED — mixed-prior contraction under (EM)

At fixed σ satisfying Theorem B's uniform (EM), assume its (A1), upper (A2) and (A3) for fixed $V>0$. Write $H=\sum_i\min(\delta_i^2,|\delta_i|)$, $x_n=\varepsilon_n^2$. For sufficiently large fixed M the expected posterior mass of $H/n>M x_n$ tends to zero uniformly over this class, with
$$
 x_n=\begin{cases}
 n^{-5/6}(\log n)^{1/6} & b_n=c n^{-5/2},\\
 n^{-1/4}(\log n)^{1/8} & b_n=b_0>0 .
 \end{cases}
$$
Fixed scale and fixed class constants are understood throughout. At the scaled rate this also gives empirical **squared** loss $O(n^{-2/3}(\log n)^{1/3})$ in posterior probability. The second line is a slower theorem for the Huber-type loss. Its proof does not identify the typical λ.

**Proof of prior budget.** In the first case restrict λ to $[n^{5/2}/V,2n^{5/2}/V]$. Gamma rescaling gives a positive uniform lower bound on its probability by continuity on the compact c interval. Theorem B §§2.3–2.7 and join J7 give a deterministic mollified center with projected bias at most $\varepsilon/2$ and negative log shifted small-ball mass $O(nx_n)$ throughout this window (the center uses ε,V,n). In the second case take $[L_n,2L_n]$ with $L_n=nx_n$ and use the exact truth center. The negative log hyperprior mass is $O(L_n)$ by the Gamma density on this interval. L4 charges at most $2L_n V/n^2$. L3 at radius $\varepsilon/2$ charges at most
$$
 C n L_n^{-2/5}x_n^{-1/5}(\log n)^{1/5}+6=O(nx_n),
$$
since $x_n^{8/5}=n^{-2/5}(\log n)^{1/5}$. Both windows therefore give mixed good-set mass at least $V_3(\varepsilon\sqrt n/2)^3 e^{-Cnx_n}$ including L6's flat sections, where $V_3$ is the unit three-ball volume.

**Proof of denominator and numerator.** Center the likelihood at θ*. Normalize the mixed prior restricted to the preceding good set (including its λ window) to a deterministic probability g. Its support has $\|\delta\|_n\le 2\varepsilon$ by the projected bias, small ball and flat radius. The variable $T=\int\sum_i X_i(\delta_i)dg$ has mean at most $4 C_1 nx_n$ by L2. Independence across data indices and Jensen's inequality bound its variance by $\sum_i\int E X_i^2 dg\le4nx_n$. Chebyshev and Jensen thus lower bound the centered denominator by $e^{-C' nx_n}$ with failure probability at most $4/(nx_n)$, absorbing the flat volume. No simultaneous fixed-λ L6 event is used.

Put $v=b/\sigma>0$ from (EM). Tonelli and independence bound the expected centered numerator on $H>Mnx_n$ by $e^{-vMnx_n/2}\int e^{-vH/2}dc\,P_\lambda(du)p_n(d\lambda)$. For completeness, writing $g(t)=\min(t^2,t)$ for $t\ge0$, $H\ge g(\|\delta\|_2)$: each summand is at least $\delta_i^2/\max(1,\|\delta\|_2)$. Projection gives $\|\delta\|_2\ge\|c-N^T(\theta^*-Su)\|_2$. Polar integration of $e^{-vg(\|c\|_2)/2}$ gives a finite constant, and both remaining measures have unit mass. Division on the good denominator event proves the assertion for $M>2C'/v$. Finally $\sum_i\delta_i^2\le H+H^2$ by splitting at one. The first schedule gives the claimed squared rate by substitution. This conversion does not yield squared-loss consistency at the second schedule.

**PROVED — one-sided λ control under (EM) for constant rate.** The same numerator calculation without the bad-H indicator bounds expected centered evidence on $\lambda>K L_n$ by a constant times its prior probability. Markov applied to $e^{b_0\lambda/2}$ under the hyperprior bounds this by $C2^{a_0}e^{-b_0K L_n/2}$. The same denominator gives posterior upper containment for sufficiently large fixed K. A matching lower bound would require evidence discrimination against smaller λ.

**CONJECTURE — benchmark fixed point.** The $n^{0.745}$ measurement and the curvature-based $n^{3/4}$ prediction may describe particular designs and scales. The gamma conditional alone controls $(b_n+\|D\theta\|_1)\lambda$ to relative order $n^{-1/2}$ around $m+a_0$ by Chebyshev. The $n^{3/4}$ claim would additionally require information on posterior roughness of order $n^{1/4}$ for fixed $b_0$. The counterexample gives order n roughness from below instead.

## (d3). PROVED — joint decomposition and the missing input

Let I and J be deterministic positive intervals, possibly depending on n, and let B be a bad trend event. Disintegrating the joint posterior on the rectangle and bounding its complement by a union gives
$$
 \Pi(B\mid y)\le
 \sup_{s\in I,\ell\in J}\Pi_{s,\ell}(B\mid y)
 +\Pi(\lambda\notin J\mid y)
 +\sup_{\ell\in J}\Pi(\sigma\notin I\mid y,\lambda=\ell).
$$
Indeed the integrated scale-tail term on $\lambda\in J$ is bounded by the displayed conditional supremum. Equivalently one may retain its posterior-weighted integral or the exact joint mass outside the rectangle. For the IG prior the finite-n joint posterior exists: at fixed λ its prior density in θ is bounded by $J_n(\lambda/2)^m$, the integral of the AL kernel cancels $s^{-n}$ up to a fixed n-dependent constant, and the hyperprior has finite mth moment.

**SKETCH — transfer requirements.** Prove containment of λ under the *joint* posterior or bound the joint tails directly. With J inside the deterministic C1 range, verify C1's sup-norm and denominator hypotheses over J and control the random supremum *inside* sampling expectation (a mixed good-set proof can bypass that supremum). For $\inf J/\log n\to\infty$, Lemma S §2 supplies the ingredients for conditional scale containment: its data events are common, the L3 bound at radius one and the roughness cost can both use the lower endpoint. Its moment and positive mean-loss conditions still apply. The missing joint λ containment does not follow from a Gamma pivot. Alternatively integrate λ first and prove fixed-s mixed localization on a scale range carrying joint posterior mass. The counterexample excludes such localization on arbitrary compact scale ranges. It does not address selection of σ by the IG marginal likelihood. Once joint trend contraction in average absolute error is available, Lemma S §1 gives scale consistency without new λ estimates, because the IG conditional given θ and the loss Lipschitz bound are unchanged.

**CONJECTURE — jointly learned benchmarks.** Neither the fixed-small-σ counterexample nor the (EM) theorem settles θ-contraction for the jointly learned default on the paper's designs. A proof must use where the joint evidence places its mass.

---

## Theory Department: verification and response to the audit (Opus, `reviews/AUDIT_opus_lambda.md`, 2026-11-23)

**Status: advisor-checked.**
- Theory re-derived the key steps before the audit: the cube evidence bound, the Q ≥ qn evidence bound and σ threshold, and the constant-b₀ budget balance at x_n = n^{−1/4}(log n)^{1/8}.
- Opus verdicts: (1) counterexample, (2) mixed (EM) contraction and (4) decomposition are ACCEPT WITH FIXES; (3) one-sided λ control is ACCEPT.
- No gap was found, and no rate, exponent or threshold changes. K = 23.947 and the σ threshold 5.87·10⁻⁵ are confirmed.

Rulings by Theory: every CONFIRMED item **HOLDS**, as follows.
1. **The pivot survives mixing.** λ‖u‖₁ | λ ~ Gamma(m, 1) for every λ. What fails under the hyperprior is a TV radius that does not depend on λ (C1's T₀ = Tn³/λ), not the moment estimate.
2. **(2):** cite joins J5 and J8 together with J7; state c ∈ [c₋, c₊] in the theorem; the threshold is explicit, M > 2C′/v.
3. **The counterexample lies outside (EM):** its ω = 1/σ ≈ 1.7·10⁴ ≫ 2 = f/(τ(1−τ)).
4. **(d3):** define Π(· | y, λ = ℓ) as the explicit ratio, and assume that the difference prior is not σ-scaled. This holds for BQTF's default; it would not hold for an Onizuka-type σ-scaled prior.

**Open item, marked PLAUSIBLE by Opus and agreed by Theory.** For (d3), Lemma S §2's containment must hold uniformly over λ in the window. Currently it is proved schedule by schedule; the uniform version is needed for the joint (both-learned) argument.
