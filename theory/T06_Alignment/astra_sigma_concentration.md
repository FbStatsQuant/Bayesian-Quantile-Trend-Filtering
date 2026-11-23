# Lemma S. Learning the scale at deterministic roughness tuning

## 1. PROVED — conditional scale consistency

Fix an interior quantile level \(\tau\). Write $Z_i=y_i-\theta_i^*$, $W_i=\rho_\tau(Z_i)$, $s_n=n^{-1}\sum_i E W_i$, $Q_*=Q(\theta^*)$, and $k=\min(\tau,1-\tau)>0$. For clarity, the law and truth may vary by row. In every limit below, uniformity means a supremum over the specified row class, with all class constants fixed. A single triangular sequence is also allowed. Assume (A1) independence, $s_n\ge d>0$, and the row-average uniform integrability condition
\[
 u(K)=\sup_{n,P}n^{-1}\sum_i E[W_i\mathbf1_{W_i>K}]\longrightarrow0.
\]
In particular $s_n\le B<\infty$ uniformly, since $s_n\le K+u(K)$. Since $k|Z_i|\le W_i\le |Z_i|$, the analogous condition on absolute centered errors is equivalent. Uniformly bounded $1+\gamma$ moments for any common $\gamma>0$ suffice by truncation. This covers bounded Beta errors and Gaussian or finite Gaussian mixture errors with uniformly bounded centered component locations and scales, including the heteroscedastic paper designs at each fixed level.

Use the flat quadratic prior, normalized independent Laplace differences at fixed deterministic $\lambda>0$, and IG shape and scale $a=b=0.1$ (any fixed positive values work). Let $\Pi^\theta$ denote the trend marginal **after mixing over the learned scale**. The exact scalar preliminary hypothesis needed is, for every $t>0$,
\[
 \tag{H} \sup_P E_P\Pi^\theta(|Q(\theta)-Q_*|>nt\mid y)\to0.
\]
Then, for every fixed $\eta>0$,
\[
 \sup_P E_P\Pi(|\sigma/s_n-1|>\eta\mid y)\to0.
\]

**Proof, including the conditional tail.** The posterior is proper for finite data. Indeed the penalty factor is bounded by one in Lebesgue trend coordinates, and integration of $e^{-Q/\sigma}$ there gives $[\sigma/\{\tau(1-\tau)\}]^n$ by separate one-dimensional integration. The remaining IG integral is finite, and the evidence is positive. Constant coordinate Jacobians and prior normalization constants at fixed $n,\lambda$ do not affect propriety.

Clip each $W_i$ at $K$. The mean absolute deviation of the clipped average about its expectation is at most $K/\sqrt n$ by independence and Cauchy–Schwarz. Removing the clipping costs at most $2u(K)$ in mean absolute deviation. Taking $n\to\infty$ then $K\to\infty$ proves $Q_*/n-s_n\to0$ uniformly in mean absolute value. No second moment or root-$n$ rate for the original losses is required.

Conditionally on $\theta,y$, $G=(b+Q(\theta))/\sigma\sim\mathrm{Gamma}(n+a,1)$, with unit rate, by change of variables in the stated IG conditional. For each fixed $0<h<1$ and $n$ with $a/n<h/2$, Chebyshev gives
\[
 \Pi(|G/n-1|>h\mid\theta,y)\le 4(n+a)/(n^2h^2).
\]
Put $A=(b+Q(\theta))/(ns_n)$. By the preceding LLN, (H), $s_n\ge d$, and $b/n\to0$, the expected posterior mass of $|A-1|>h$ vanishes uniformly (split the three additive errors at $dh/3$). On the two good events, $\sigma/s_n=A/(G/n)$ differs from one by at most $2h/(1-h)$. Choose $h$ so that this is below $\eta$ and integrate the conditional bound. This proves the claim.

**PROVED — sharpness of (H) and trend-based sufficient conditions.** Conversely, scale consistency plus the conditional gamma bound imply concentration of $A=(\sigma/s_n)(G/n)$ at one under the joint posterior: when both factors are within $h$ of one the product error is at most $2h+h^2$. As $s_n\le B$, the LLN and $b/n\to0$ then give (H) by the triangle inequality. Thus (H) is an equivalent scalar localization under these assumptions. For a geometric sufficient condition, the check loss is 1-Lipschitz by its two slopes, so $|Q-Q_*|/n\le\|\theta-\theta^*\|_{1,n}$, the average absolute error. With $v=\Delta_n^2(\theta-\theta^*)=n^{-1}\sum_i\min(\delta_i^2,|\delta_i|)$, this average is at most $\sqrt v+v$ by Cauchy–Schwarz on $|\delta_i|\le1$ and direct summation elsewhere. Either loss converging to zero in posterior probability suffices. Convergence in sampling probability of posterior bad mass is equivalent to convergence in expectation, uniformly: for $0\le X\le1$, $EX\le t+P(X>t)$ and $P(X>t)\le EX/t$.

## 2. PROVED — independent compact containment at oracle tuning

For this section add the paper's (A3), $\|D\theta^*\|_1\le V/n^2$, with fixed $V$, and suppose $\lambda_n/\log n\to\infty$ uniformly over the allowed deterministic schedules. This includes the oracle and polynomial windows with lower endpoint $c n^p$, $p>0$. Use the unscaled third forward difference as in Theorem B. There exist fixed $0<l<d\le B<H_0<\infty$ such that the expected posterior mass outside $I=[l,H_0]$ tends to zero uniformly. This statement uses no trend contraction assumption.

**Proof of a data roughness bound.** For $1\le j\le n-3$ let $T_j=|(Dy)_j|$. Conditional on all observations except $y_j$, this is $|Z_j-t|$ for a shift independent of $Z_j$ since the endpoint coefficient has magnitude one. For every shift, $E|Z_j-t|\ge E\rho_\tau(Z_j-t)\ge EW_j$. The last inequality holds because zero is a quantile: the difference of expected check losses is the oriented integral of $F_{Z_j}(v)-\tau$ from zero to $t$, by integrating the piecewise-linear loss and applying Fubini on the finite interval. The last three omitted means divided by $n$ sum to at most $3K/n+u(K)=o(1)$ in the iterated limit. Thus $n^{-1}\sum_j ET_j\ge d-o(1)$.

The $T_j$ have row-average uniformly integrable tails. Indeed, $T_j\le V/n^2+8\max_{j\le i\le j+3}|Z_i|$ by (A3) and the stencil coefficients. For $K>2V$, on $T_j>K$ that maximum exceeds $K/16$ and $T_j\le16\max|Z_i|$. Bound the truncated maximum by the sum of the four $|Z_i|\mathbf1_{|Z_i|>K/16}$, then sum in $j$, counting each coordinate at most four times. The resulting average tends to zero by the moment condition. After clipping at $K$, terms separated by more than three indices are independent, so the variance of the sum divided by $n^2$ is at most $7K^2/n$ by counting overlapping pairs. The clipping argument in §1 gives $P(\|Dy\|_1<nd/2)\to0$ uniformly. On the complementary event, for every $\theta$ with $Q(\theta)<qn$, where $q=kd/32$,
\[
 \|D\theta\|_1\ge \|Dy\|_1-8\|y-\theta\|_1
 \ge nd/2-8Q(\theta)/k\ge nd/4 .
\]
Here the factor eight is the maximum absolute column sum bound for $D$.

**Proof of an evidence lower bound.** Use L5 coordinates $\theta=Nc+Su$, with normalized difference prior $P_\lambda$ and three-dimensional Lebesgue measure $dc$. Write $P_N=NN^T$, $P_\perp=1-P_N$, and $\|z\|_n=\|z\|_2/\sqrt n$. The uncentered joint evidence integrates $s^{-n}e^{-Q/s}$ against $dc\,dP_\lambda\,d\mathrm{IG}(s)$. We need only a lower bound $e^{-Cn}$ on a high-probability event. L6 gives a finer centered evidence bound under its margin and prior-mass hypotheses. The following coarser bound avoids the margin entirely.

By L3 of the complete Theorem B package at radius one, $P_\lambda(\|P_\perp Su\|_n\le1)\ge\exp[-30(n^{5/2}/\lambda)^{2/5}(\log n)^{1/5}-6]\ge e^{-n}$ eventually. We use L3 here as the cited proved prior lemma. Each entry of its triple cumulative-sum right inverse $S$ is at most $n(n+1)/2\le n^2$ in absolute value (the third cumulative sum of a unit impulse is a sequence of triangular numbers). Thus $\|P_\perp\theta^*\|_n\le\|Su^*\|_n\le V$. For each such $u$ integrate over the unit Euclidean ball centered at $N^T(\theta^*-Su)$ in $c$. The polynomial component of the error has Euclidean norm at most one, so $\|\theta-\theta^*\|_n\le 2+V$. On $Q_*/n\le B+1$, an event of uniformly tending-to-one probability by §1, Lipschitzness gives $Q/n\le B+3+V$ throughout this set. Integrate over $1\le s\le2$, whose IG probability is a positive constant. The integrand there is at least $2^{-n}\exp[-n(B+3+V)]$. Multiplication by the constant ball volume and prior mass proves the asserted evidence bound for a common finite $C$.

**Proof of the tail bounds.** For any $s>0,u,y$,
\[
 \int e^{-Q/(2s)}dc\le \int_{\mathbb R^3}e^{-k\|c-N^T(y-Su)\|_2/(2s)}dc=C_k s^3,
\]
since absolute loss dominates Euclidean norm after projection and $Q\ge k\|y-\theta\|_1$. For $s>H_0>1$, the numerator is therefore at most $C_k H_0^{3-n}$ for $n>3$. Take $\log H_0>C+1$ and $H_0>B$.

For $s<l$ split the numerator at $Q=qn$. On $Q\ge qn$ reserve half the likelihood for the flat integral above. The contribution is at most $C_k\sup_{0<s<l}s^{3-n}e^{-qn/(2s)}$, using unit total mass of both proper priors. Take $l<\min(1,d)$ sufficiently small that $\sup_{0<s<l}[-\log s-q/(2s)]<-C-1$, possible by the limit at zero. This contribution is at most $C_k e^{-(C+1)n}$.

On $Q<qn$, the data roughness event forces $\|u\|_1\ge nd/4$. Under $P_\lambda$, the absolute differences are independent exponentials of rate $\lambda$. Markov at $\lambda/2$ gives prior probability at most $2^{n-3}e^{-\lambda nd/8}$. Discard the restriction on $c$ and integrate using the flat bound. Even integrated over **all** scales, this part is at most
\[
 C_k 2^{n-3} e^{-\lambda nd/8} b^{3-n}\Gamma(n+a-3)/\Gamma(a).
\]
The last factor is the IG negative moment obtained by substituting $b/s$. For integer $n\ge4$, the gamma ratio is a product of $n-3$ terms bounded by $n+a$. Its log cost, including $b^{3-n}$, is $O(n\log n)$. Hence the roughness penalty dominates this cost and $Cn$. On the intersection of the evidence and roughness events division by the evidence makes all three tails vanish. Outside that intersection posterior mass is at most one, proving the uniform expectation claim. In particular this calculation also controls the joint posterior of $Q<qn$ itself.

## 3. PROVED — transfer from a fixed-scale theorem

**Hypothesis U (assumed).** On the *entire* deterministic interval $I$ supplied by independent compact containment, for every fixed $t>0$,
\[
 \sup_P E_P\sup_{s\in I}\Pi_s(|Q-Q_*|>nt\mid y)\to0.
\]
Here $\Pi_s$ is the conditional trend posterior with the same deterministic tuning. A bound of this form for average absolute error, or for $\Delta_n^2$ at any vanishing radius and common multiplier, implies U by §1. Measurability of the scale supremum follows from continuity: at fixed data the fixed-scale numerator and denominator are continuous in $s\in I$ by domination by $e^{-Q/H_0}$, integrable by the flat bound. The denominator is positive and a countable dense scale set suffices.

**Proof.** For $E_y=\{|Q-Q_*|>nt\}$, disintegration gives
\[
 \Pi^\theta(E_y\mid y)\le \sup_{s\in I}\Pi_s(E_y\mid y)+\Pi(s\notin I\mid y).
\]
Take expectations and suprema over laws. U and §2 give (H), hence §1 gives Lemma S. The same implication holds whenever some other independent compact-containment argument gives the second term on the very interval for which U holds. The random mixing weights explain the order of expectation and scale supremum. No optimal rate is needed.

**CONJECTURE — outstanding fixed-scale input.** For the smooth benchmark truths and noise families, U at oracle tuning over the full coarse interval in §2 remains to be established. Theorem B's EM-based numerator bound covers only eligible scales. A result on a narrower neighborhood of $s_n$ would need containment on that narrower neighborhood or another argument for its complement. The IG update alone uses (H) to reach that neighborhood and cannot supply the missing independent premise. Section 1 itself needs neither (A3) nor a tuning window. Section 2 uses both the truth restriction and growing tuning for the noncircular route. No conclusion here mixes over a learned roughness parameter.
