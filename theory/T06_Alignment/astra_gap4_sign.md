# G4 and G5 • The sign of the learned-scale evidence slope

**Status — open.** The signed scaling integrand takes negative values of order the conjectured slope even inside the Huber body, with probability tending to one on the Gaussian design. A posterior-averaged estimate is essential. Below is an exact Gaussian integration formula for its score term at learned scale. Neither that formula nor comparison with the upper endpoint currently gives the sign.

Write $g_i=1\{\theta_i>y_i\}-\tau$, $Z_i=y_i-\theta_i^*$, $\delta_i=\theta_i-\theta_i^*$, $\psi_i=\tau-1\{Z_i<0\}$, and $\omega=1/\sigma$. Brackets denote the joint posterior at fixed $\ell,y$. Use independent Gaussian errors centered at their respective $\tau$-quantiles, with the scale function in Fable B. Put $k=n\ell^{-1/3}$. Constants below can depend on a fixed interior quantile.

## 1. PROVED • A signed obstruction inside the localization body

Take any deterministic sequence $1\le\ell\le C n^{99/43}(\log n)^C$. With probability tending to one, there exists a data-dependent vector satisfying
$$
 \|\delta\|_\infty\le c\ell^{-1/6},\qquad
 \sum h_L(\delta_i)\le C_1 k,\qquad
 \|D\delta\|_1\le T n/\ell,\qquad
 R'(\delta)-\langle\psi,\delta\rangle\le -c_1 k.
$$
Here $c_1>0$; the statement concerns a point of the body, not its posterior probability. It applies already to a quadratic truth. In particular even improving the Huber radius to a sufficiently small constant times $k$ in summed loss cannot by itself give a pointwise sign.

**Proof.** Set $h=\max(8,\lceil\ell^{1/3}\rceil)$, partition into $B=\lfloor n/h\rfloor\asymp k$ disjoint complete blocks, and leave the remainder at zero. Sample a fixed nonnegative smooth bump supported in $(0,1)$, bounded by one and equal to one on the middle half, on the grid $j/h$ of each block. Write its values as $w_j$. Its zero extension has summed absolute third differences at most $C/h^2$, by integrating the bounded third derivative three times. For block $b$ put $S_b=\sum w_j\psi_i$ and choose $\delta_i=d w_j\operatorname{sign}(S_b)$, where $d=\alpha/\sqrt h$. Uniformly in the block, $E S_b^2\asymp h$ and $E S_b^4\le Ch^2$ by independence and centering. Applying Paley–Zygmund to $S_b^2$ gives $E|S_b|\ge c\sqrt h$.

The score contribution is exactly $d|S_b|$. The crossing contribution is at most $d\sum 1\{|Z_i|\le d\}$, without any independence assumption between the chosen direction and the crossings. The uniform density upper bound makes its expectation at most $C h d^2=C\alpha^2$. Thus the expected signed contribution is at most $C\alpha^2-c\alpha$. Its second moment is bounded uniformly, since $d^2 E S_b^2=O(1)$ and the independent crossing indicators in the upper bound have total mean at most $Chd$ and variance at most $Chd$. Choose a sufficiently small fixed $\alpha>0$. Independence across blocks and Chebyshev give the claimed negative sum with exceptional probability $O(1/B)$. Finally the Huber loss is at most $nd^2/2$ and the summed third differences at most $CBd/h^2\le C\alpha n h^{-7/2}\le Tn/\ell$. Decreasing $\alpha$ allows any prescribed positive constant in the Huber upper bound, with a corresponding smaller sign margin.

**PROVED • Scope of H.** Taking its mixing law to be the point mass at the floor gives window mass one. The stated contracting regime requires $K_n^6(\log n)^3=o(\ell)$ and $\ell\le n^2$. Where applicable its summed radius $nr^2$ exceeds $k$ by a factor proportional to $K_n^{12/7}\ell^{1/21}(\log(2n))^{6/7}$ for fixed $T$. The constructed points are inside that body. At bounded tuning there is no shrinking radius from H. The construction also works there with $B\asymp n$.

## 2. PROVED • An exact population formula for the adaptive score

Let $p_i,F_i$ be the true error density and distribution and set
$$
 W_i(z)=\begin{cases}(1-\tau)F_i(z)/p_i(z),&z<0,\\
 \tau(1-F_i(z))/p_i(z),&z\ge0.\end{cases}
$$
Conditional on all the other observations, for the actual learned-scale posterior,
$$
 E_{Z_i}\{\psi_i[\omega\delta_i]\}
 =E_{Z_i}\{W_i(Z_i)\operatorname{Cov}_{\ell,y}
                   (\omega\delta_i,\omega g_i)\}.
$$
In particular $0<W_i(z)\le \tau(1-\tau)/p_i(0)$. For the normal law the right-tail ratio decreases and the left-tail ratio increases. This follows by writing the right-tail ratio as the integral over $v>0$ of $p_i(z+v)/p_i(z)$, decreasing in $z$, and using the reflected argument on the left.

**Proof.** For $H(z)=[\omega\delta_i]$ with $y_i=\theta_i^*+z$, differentiation of the normalized posterior gives $H'(z)=\operatorname{Cov}(\omega\delta_i,\omega g_i)$ almost everywhere, since the derivative of the log likelihood factor with respect to $y_i$ is $\omega g_i$. The product $W_i p_i$ is continuous at zero and has derivative $-\psi_i p_i$ off zero. Integration by parts gives the formula. For integrability, after scale integration each inserted power $\omega^j$ contributes a fixed constant times $(b+Q)^{-j}$, with $b=0.1$; moreover $|\delta_i|\le |z|+Q/\min(\tau,1-\tau)$. These bounds justify local differentiation by domination because compact changes in $z$ leave the ratios of $b+Q$ bounded. They bound $H,H'$ by $C_n(1+|z|)$, and kill the boundary terms.

**PROVED • Remaining comparison.** For a quadratic truth, I3 now gives $E_0\kappa+3=\sum_i E_0\{[\omega R'_i]-W_i\operatorname{Cov}(\omega\delta_i,\omega g_i)\}$. The two terms are at the same data vector. This removes the raw sign correlation in population without freezing the inverse scale or treating posterior draws as independent of the data. To obtain a uniform realized sign by this route one still needs a positive lower bound for this difference exceeding 3 and control of downward fluctuations relative to the resulting margin, uniformly in tuning. H bounds neither the covariance nor the posterior mass on score-aligned directions. For a general truth, translating the posterior integral in the direction $v=\theta^*-q$ gives the extra term $[\omega\langle g,v\rangle]=-\ell[\langle\operatorname{sign}(D\theta),D\theta^*\rangle]$ for quadratic $q$ by differentiation of the likelihood and penalty along the translation. Its absolute upper bound $\ell\|D\theta^*\|_1$ alone need not be small relative to $k$ above $n^{9/4}$ under the usual $n^2\|D\theta^*\|_1\le V$.

## 3. PROVED • Endpoint comparison has no deterministic monotonicity principle

Let $x=Dy$ and let $G$ be the density of $De$ for independent working asymmetric Laplace residuals conditional on their common IG scale, mixed over that scale. Up to a constant independent of $x,\ell$, the evidence equals $G*L_\ell(x)$, where $L_\ell$ is the product of $m=n-3$ centered Laplace densities of rate $\ell$. Indeed, integrating the flat quadratic coordinates projects the residual density onto its $D$-image with a constant Jacobian, and the prior innovations have density $L_\ell$. The density $G$ is positive, bounded and continuous. At scale one, condition on the three coordinates outside an invertible column minor of $D$; the remaining product density transformed by the minor is continuous and bounded. Scaling and mixing preserve these properties since the inverse scale has all positive moments.

For every fixed $n>3,\ell>0$, the continuous function $G*\partial_\ell L_\ell$ has integral zero and is not identically zero. Its Fourier transform is $\widehat G(t)\partial_\ell\prod_j(1+t_j^2/\ell^2)^{-1}$, nonzero for sufficiently small nonzero $t$ since $\widehat G(0)=1$. Thus there are open sets of both slope signs, both with positive probability under the full-support Gaussian data law.

For every fixed $x$, the slope tends to $m$ at zero and to zero at infinity. At zero use the virial formula with density proportional to $G(x-u)e^{-\ell\|u\|_1}$ and dominated convergence for $\ell\|u\|_1e^{-\ell\|u\|_1}$. At infinity substitute $u=v/\ell$ in the signed numerator and use continuity, boundedness and $\int (m-\|v\|_1)L_1(v)dv=0$. Consequently a data vector with negative slope at an interior tuning has a slope curve that is neither monotone nor globally convex or concave, also in log tuning. Convexity on a right half-line with a finite limit forces a nonincreasing function, and concavity forces a nondecreasing one. This does not bound the probability of a negative slope as $n$ grows. LO gives a fixed-pair upper bound on an evidence value; even a positive endpoint slope would require an additional probabilistic comparison to propagate it downwards.

**CONJECTURE • Verdict.** For the median Gaussian design and quadratic truth the conjectured uniform G4 sign remains consistent with these results. The posterior weight assigned to score-aligned perturbations, relative to the positive crossing contribution, is the unresolved quantity. G5 does not yield to this argument either. The same obstruction is then extensive, and no shrinking-local-error approximation follows. Neither the sign on either full interval nor A-rule containment is established here.

---

## Theory response (2026-11-23)

**Status: G4 and G5 remain OPEN.** This is a negative result with three proved obstructions. They are unaudited; Fable is the cross-family auditor on Tuesday. Theory checked the arguments' logic.

**§1, the point obstruction.** Block bumps aligned with sign(S_b) at amplitude α/√h. The score gain is ≍ α per block and the crossing cost is O(α²), so the gain wins for small α. They have k-order negative signed integrand inside the Huber body. Consequence: no pointwise (sup-over-body) argument can give the sign; any proof must be posterior-averaged. **Ruling: HOLDS.**

**§2, the integration-by-parts identity.** E[ψᵢ·ωδᵢ] = E[Wᵢ·Cov(ωδᵢ, ωgᵢ)], with the learned scale kept. This is a new and potentially useful tool for Tuesday's H4. The remaining quantity is the posterior covariance on score-aligned directions against the crossing term. **Ruling: HOLDS** (Stein-type identity; boundary terms killed by the stated domination).

**§3, no monotonicity principle.** For fixed n, the slope has both signs on open data sets, and it is neither monotone nor convex in ℓ. So the endpoint sign from LO cannot be propagated downwards deterministically. **Ruling: HOLDS.** Note that this is a fixed-n statement; it says nothing about probabilities as n → ∞.

**For the plan.** H4 is reframed: bound the posterior covariance in §2 against the crossing term, uniformly in ℓ. The fallback stays the conditional theorem F3 with the sign on [ℓ₀, n^{2.30}] as a named assumption, supported by κ̂ data (75ad1a4).
