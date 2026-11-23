# A joint evidence obstruction for the exact no-floor posterior

**PROVED, pending independent audit.** At the fixed level $\tau=0.05$, there is a bounded, absolutely continuous iid error law with unique quantile zero, full (A2), and zero truth for which the exact joint posterior assigns exponentially vanishing mass to a fixed neighborhood of the truth. This holds for every fixed positive Gamma rate $b_0$ and the stated IG(0.1,0.1) prior. The example has $0.19<\sigma_0/\bar\sigma<0.21$, above the proposed $1/6$ threshold. This is alternative B. The example is a separate noise design. Contraction on the paper's specific simulation laws remains open.

## PROVED — a data-dependent evidence comparison

Write $t=\tau(1-\tau)$, $k=\min(\tau,1-\tau)$, $R_n=\|Dy\|_1/n$, $Q_* = Q(\theta^*)$. Suppose that with probability tending to one $R_n\le r$ and $Q_*/n\ge s_*$, for fixed $r>0$ and $s_*>2tr$. For every $2tr<q<s_*$, some fixed $c>0$ satisfies, on these data events for all large $n$,
$$
 \Pi(Q(\theta)\ge nq\mid y)\le e^{-cn}.
$$
Consequently the posterior mass of $\|\theta-\theta^*\|_{1,n}\le s_*-q$ is at most $e^{-cn}$, where the norm is average absolute error. Indeed, $Q$ is 1-Lipschitz in unnormalized $\ell_1$. An empirical RMS ball of the same radius is contained in this ball. For $v=n^{-1}\sum_i\min(\delta_i^2,|\delta_i|)$, Cauchy–Schwarz on $|\delta_i|\le1$ gives $\|\delta\|_{1,n}\le\sqrt v+v$, so the result excludes contraction in that loss too.

**Proof of the numerator bound.** Use $u=D\theta$, $m=n-3$, and choose $N$ with orthonormal columns spanning the quadratic nullspace. Take $c_0=N^T\theta$, so $\theta=Nc_0+Su$ with $S=D^T(DD^T)^{-1}$. Switching from any other right inverse translates the flat coordinate at each $u$ and preserves its Lebesgue measure. Write $Z$ for the integral of $s^{-n}e^{-Q/s}$ against $dc_0$, the normalized product Laplace law of $u$ at rate $\ell$, and the two probability hyperpriors. On $Q\ge nq$, reserve $e^{-Q/(ns)}$ for integration in $c_0$. Since $Q\ge k\|y-\theta\|_2\ge k\|N^Ty-c_0\|_2$, the integral of this reserved factor is at most $C_k(ns)^3$ by change of variables in three dimensions. Both remaining priors and the conditional prior on $u$ have unit mass. The evidence restricted to $Q\ge nq$ thus satisfies
$$
 Z_{Q\ge nq}\le C_kn^3\sup_{s>0}s^{3-n}e^{-(n-1)q/s}
 =C_kn^3\bigl[(n-3)/(e(n-1)q)\bigr]^{n-3}.
$$
The equality follows by differentiating in $1/s$. The upper log evidence per observation is at most $-1-\log q+o(1)$, for all data.

**Proof of the denominator bound.** Under $\theta\mapsto(c_0,u)$ the absolute Jacobian is $J_n=\sqrt{\det(DD^T)}$ by the block-diagonal row Gram matrix. It is at least one by Cauchy–Binet, since the last $m$ columns of the third-difference matrix form a triangular minor with unit absolute determinant. At fixed $s,\ell$, change variables to $\theta=y-E$, where the integration kernel for each $E_i$ is normalized by its integral $\int s^{-1}e^{-\rho_\tau(x)/s}dx=1/t$. The fixed-parameter evidence equals
$$
 J_n(\ell/2)^m t^{-n}\, \mathbb E_s e^{-\ell\|D(y-E)\|_1}.
$$
Here the expectation uses independent normalized asymmetric Laplace variables, auxiliary to the sampling law. In particular this evidence is finite after mixing since the Gamma prior has a finite $m$th moment, and it is positive. The two exponential half-lines of the auxiliary density have conditional mean absolute sizes $s/\tau$ and $s/(1-\tau)$, so $E_s|E_i|\le s/k$. The stencil has absolute column sums at most eight. Jensen's inequality and the triangle inequality bound the expectation from below by $\exp[-n\ell(r+8s/k)]$ on $R_n\le r$.

At $(\ell,s)=(1/r,0)$, the continuous function
$$
 g(\ell,s)=\log(\ell/(2t))-\ell(r+8s/k)
$$
equals $-1-\log(2tr)>-1-\log q$. By continuity choose a **fixed closed rectangle inside the positive quadrant**, close enough to this point, such that its minimum exceeds $-1-\log q+2c$ for some $c>0$. Both hyperpriors assign it fixed positive joint mass. On this rectangle the correction from $m=n-3$ is the bounded log term $-3\log(\ell/2)$. Integration yields $n^{-1}\log Z\ge -1-\log q+2c-O(1/n)$. Division proves the claim. In particular, the IG's suppression near zero never has to be estimated on an interval shrinking with $n$.

## PROVED — an explicit counterexample at a paper quantile level

Take $\theta_i^*=0$, $\tau=.05$, and independent identically distributed $Y_i$ with these uniform mixture components.

| Weight | Support |
|---:|---:|
| .049 | $[-.02,-.01]$ |
| .002 | $[-.005,.005]$ |
| .949 | $[1,1.001]$ |

**Proof of assumptions and scale ratio.** The weights sum to one. On $|x|<.005$, $F(x)=.05+.2x$, so zero is the unique quantile and full (A2) holds, for instance with $L=.004$ and both slope constants .2. Independence gives (A1), the zero third difference gives (A3), and bounded support gives row-average uniform integrability. With $\sigma_0=E\rho_\tau(Y)$, the third component alone contributes at least $.949\cdot.05=.04745$. An upper bound summing component maxima is $.049(.95)(.02)+.002(.95)(.005)+.949(.05)(1.001)<.049$. Thus $d=.047$ works, and $\bar\sigma=t/f(0)=.2375$ gives the claimed ratio.

**Proof of the strict evidence gap.** Since $D\mathbf1=0$, $R_n\le 8n^{-1}\sum_i |Y_i-1|$. The expectation of $|Y_i-1|$ is at most $.049(1.02)+.002(1.005)+.949(.001)<.053$. The weak law therefore gives $R_n\le .424$ with probability tending to one. The same law gives $Q_*/n\ge .047$ with probability tending to one. Take $r=.424,\ s_*=.047,\ q=.043$. Then $2tr=.095(.424)<.043<.047$. The comparison proves exponentially vanishing posterior mass in the fixed average absolute error ball of radius .004 on events of sampling probability tending to one.

**PROVED — consequence for the learned scale.** In the same example the posterior probability of $\sigma>.045$ tends to zero in sampling probability, although $\sigma_0\ge.04745$. Indeed, given $\theta,y$, $G=(.1+Q)/\sigma$ is unit-rate Gamma of shape $n+.1$, by substitution in the conditional density. Its mean and variance are $n+.1$, so Chebyshev gives conditional probability $o(1)$ for $G<.97n$, uniformly in $\theta,y$. On $G\ge.97n$ and $Q<.043n$ we have $\sigma\le(.1+.043n)/(.97n)<.045$ eventually. The evidence bound controls the remaining event. Thus the paper's observed scale concentration is additional information about those designs. It cannot be deduced under the stated assumptions alone.

## PROVED — necessary diagnostic for a design-specific theorem

When $R_n\to R>0$ and $Q_*/n\to\sigma_0$ in sampling probability for constant limits, consistency requires $\sigma_0\le2\tau(1-\tau)R$. If the inequality were strictly reversed, choose $r>R$, $s_*<\sigma_0$ with $2tr<s_*$ and apply the comparison. This is a necessary condition only. Neither the comparison nor the scale ratio establishes contraction on the other side of this inequality. The comparison above integrates both hyperparameters in the same uncentered evidence, so it applies directly to the learned posterior without invoking fixed-scale containment.

---

## Theory Department: verification and design check (2026-11-23)

**Verified by Theory, step by step:**
- the numerator bound on {Q ≥ nq} (reserve e^{−Q/(ns)} for the flat integral; the supremum over s at s = (n−1)q/(n−3) gives −1 − log q per observation);
- the denominator identity at fixed (s, ℓ) through θ = y − E with the normalized ALD kernel (mass 1/t), followed by Jensen, giving g(ℓ, s) = log(ℓ/(2t)) − ℓ(r + 8s/k), which equals −1 − log(2tr) at ℓ = 1/r, s → 0;
- the counterexample's numbers.

**Interpretation.** If σ₀ > 2τ(1−τ)R, configurations that nearly interpolate the data (small σ, λ ≈ 1/R) carry more evidence than the truth. That is why a general theorem for the no-floor method is impossible. **The V0T floor (λ ≥ κ₋n^{5/2}) excludes exactly these configurations.**

**The paper's designs satisfy the necessary condition, with margin** (`noFloor_necessary.py` / `.out`, MC for R, quadrature for σ₀). The ratio σ₀/(2τ(1−τ)R) is:
- Gaussian: 0.22–0.38 (R = 1.189);
- Beta: 0.18–0.47 (R = 0.494);
- Mixed: 0.22–0.38 (R = 2.590);

at τ ∈ {0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99}.

So the obstruction does not apply to the paper's designs. **Whether the condition, with margin, is also SUFFICIENT is OPEN** (Tuesday).

**Audit status:** Theory-verified. The cross-family audit by Fable is pending (Tuesday's first slot).
