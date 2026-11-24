# T07 hard steps — Astra-1

Write $k=r-1$, $p=2r-1$, $m=n-r$, $V=\sup_n V_n^*<\infty$ (an eventual upper bound suffices), $f=\underline f$, and $\omega=1/\sigma_0$. Use the statement's radius exactly: $s=\varepsilon^2=n^{-p/(2r)}(\log n)^{1/(2r)}$ and $H=ns=(n\log n)^{1/(2r)}$. The constants in the evidence exponent and the final radius can depend on the stated parameters.

## 1. Bias and evidence — HOLDS (high confidence)

A convenient bandwidth avoiding division by the TV of the truth is $w=\lceil\lambda^{1/r}\rceil$, with $r\le w\le m/2$ eventually. Apply the degree-$k$ reproducing kernel of FABLE_B_general_k §2.2 to the difference atoms of $u^*=D^{(r)}\theta^*$, including at the endpoints. Each kernel has entries bounded by $C_r/w$. Reproduction leaves each integrated column error supported on at most $w$ rows of size at most $C_rw^{r-1}$. Minkowski therefore gives
$$
 \|S(u_h-u^*)\|_n^2\le C_rV^2(w/n)^p,\qquad
 \|u_h\|_2^2\le C_rV^2n^{-2r+2}/w.
$$
Keep the polynomial component of the truth when constructing the approximant. Since $\lambda^{1/r}\le w\le2\lambda^{1/r}$, the maximum of the squared approximation error and the quadratic charge per observation $\lambda^2\|u_h\|_2^2/n$ is bounded by
$$
 C'_r V^2\lambda^{p/r}n^{-p}
 = C'_r V^2 c^{p/r} n^{-p/(2r)}=o(s).
$$
This proves the half-radius approximation condition eventually, even at very large fixed $cV$. If $V=0$, the center is exactly zero in the difference coordinates and the polynomial component is unrestricted.

For $A=n^{-1/2}P_\perp S$, write $B_b=\{u:\|Au\|_2\le b\}$ and $\Phi(b)=-\log\Pi_1(B_b)$. The half-radius shift lemma requires **both** $\delta_A\le\lambda\varepsilon/4$ and $K'=8\delta_A\Phi(\lambda\varepsilon/8)/(\lambda\varepsilon)\le1$. Here $\delta_A=\max_j\|A(e_{j+1}-e_j)\|_2\le n^{r-2}$ by first differencing the binomial columns. The elementary R2 bound suffices: each column norm is at most $n^{r-1}$, and restricting every unit-rate coordinate to absolute value at most $1/n$ yields $\Phi(n^{r-1})\le m\log(2n)$. Indeed
$$
 \lambda\varepsilon/n^{r-1}=cH^{1/2}\gg 8\log(2n).
$$
Thus the quadratic cost multiplier is at most $e/(1-e^{-2})$. No factor of $\omega$ enters this prior calculation.

L3 at the actual half radius gives
$$
 -\log\Pi_\lambda(B_{\varepsilon/2})
 \le C_r[1+(2/c)^{2/p}\varepsilon^{-2/p}(\log n)^{1/p}]
 = C_r[1+(2/c)^{2/p}H].
$$
Together these give a common $C_{\rm pr}H$ budget on the negative log mass of the shifted ball. With the L5 measure $d\beta\,d\Pi_\lambda(u)$, L6 adds exactly the null-space volume $v_r(\sqrt H/2)^r$ and a likelihood factor at least $\exp[-\omega(1.44C_1+1)H]$, with failure probability at most $1.44/H$, where $C_1=\max(\bar f/2,1/L)$. This uses the global quadratic upper bound on expected excess check loss (local upper margin inside (L), Lipschitz outside) and variance bounded by squared displacement. All polynomial centers, including large ones, have the same section volume.

Sources: T05 L4q_quadratic_shift, “Half-radius form”, R2, Steps 1–7 and Corollary L4q-M; L3_small_ball, Steps 1–6; L5_normalization and L6_evidence_lower_bound, Steps 1–4. T06 FABLE_B_general_k §§1–3 gives the order-dependent column and kernel bounds. T07 PADILLA_THM3_BREAKDOWN §§3–5 identifies the linear penalty obstruction for truths of nonvanishing TV.

## 2. Every fixed c > 0 — HOLDS (high confidence)

The small-ball constant contains $c^{-2/p}$, the bias constant $V^2 c^{p/r}$. With fixed $T\ge4$, the C1 TV radius is $T_0=Tn^r/\lambda=(T/c)\sqrt n$, and $V/T_0\to0$. W′ gives squared localization radius $b^2=C_r'(T/c)^{2/(2r+1)}n^{-p/(2r+1)}(\log n)^{2r/(2r+1)}$, for a sufficiently large constant depending also on $f$. The power of $n$ in $(b^2)^k T_0$ is $1/2-k(2k+1)/(2k+3)<0$ for every $k\ge1$. Also $H=o(nb^2)$ and $nb^2=o(n)$. The cone integrations thus accept every fixed $c,\omega>0$.

For C2 take $J=\lfloor(f^2/128)MH\rfloor$ and fix $M$ before letting $n\to\infty$. On the score event of FABLE_lemmaF_C2 §§3.3–3.4, the coarse score costs at most $faH/8$ on the shell $aH<\|\delta\|_2^2\le2aH$, $a\ge M$. Rank is $J+r$, so Chebyshev gives failure probability $O(1/J)$. The fine coordinates $t=S^\top(I-P_J)\psi$ satisfy $\|t\|_\infty\le C_r(n/J)^{p/2}\sqrt{2\log(2m)}$ by Lemma F and Hoeffding; the score has range length one. Therefore
$$
 2\omega\|t\|_\infty/\lambda
 \lesssim_{r,f}(\omega/c)M^{-p/2}
 n^{-p/(4r)}(\log n)^{1/(4r)}\to0 .
$$
The exact Laplace log-MGF at $2\omega t$ is bounded by $8\omega^2 m\|t\|_\infty^2/\lambda^2\lesssim_{r,f}(\omega/c)^2H/M^p$, using $H^{p+1}=n\log n$. Separately, $2\omega|\langle t,u^*\rangle|\lesssim_{r,f}\omega V M^{-p/2}\sqrt H=o(H)$. The latter uses the actual truth in the numerator; mollification is only needed in the denominator.

For $0<\eta<f/8$ choose $M$ so that
$$
 \omega(f/8-\eta)M>
 \omega(1.44C_1+1)+C_{\rm pr}+C_{r,f}(\omega/c)^2 M^{-p}.
$$
The null-space volume ratio is at most $(8a)^{r/2}$. Dyadic summation on the good event, plus its vanishing failure probability and C1, gives convergence in expected posterior mass. There is no lower bound on $cV^*$. As a translation of older oracle-window statements one can also use a fixed positive TV upper bound $V_0=\max(1,V)$ and take $a_1<cV_0<a_2$. Constants and starting sample sizes need not be uniform as $c\downarrow0$ or $c\uparrow\infty$.

**Roadmap correction.** Use Cauchy–Schwarz over the prior and bound the score factor on its good event. Apply Tonelli and Markov to the Knight remainder factor on deterministic shells, with sup-norm cutoff $\min(L,3f/(4\omega\bar f))$. This proves a high-probability numerator inequality. Roadmap Step 4's unconditional expected-numerator inequality is stronger and is not supplied by C2. The bounded posterior ratio gives exactly the expectation in the theorem. Sources: T06 C1_any_sigma, Steps 5–8; FABLE_B_general_k §§6–7; FABLE_lemmaF_C2 §§3.1–3.5.

## 3. Localization at r = 2 — HOLDS with W′ (high confidence)

For $D=D^{(2)}$, the null space is affine, $T_0=(T/c)\sqrt n$, and the width projector is onto piecewise affine discrete splines. Lemma F gives a uniform residual column bound $C(n/J)^{3/2}$, including the two ends. With independent Rademacher coordinates, the head is bounded by $\sqrt n b\sqrt{J+2}$ and the tail by $C\sqrt n T_0 J^{-3/2}\sqrt{\log n}$. Choosing $J\asymp(T_0/b)^{1/2}$ gives W′. Symmetrization and contraction of the check loss then make the mean empirical fluctuation at most $fn b^2/8$ for
$$
 b^2=C(T/c)^{2/5} n^{-3/5}(\log n)^{4/5}.
$$
On the gauge body $\|\delta\|_n\le b,\ n\|D\delta\|_1\le T_0$, affine L10-I (Christoffel constant 4) gives $\|\delta\|_\infty\le4b+C(b^2T_0)^{1/3}$.
Here $b^2T_0=C(T/c)^{7/5} n^{-1/10}(\log n)^{4/5}\to0$. Thus the body eventually satisfies the C1 lower-margin cutoff and the C2 remainder cutoff at every fixed $\omega$. The old W radius instead gives $b^2T_0$ growing as $n^{1/10}$ up to logs.

Remaining inputs for C1:

- Independence, bounded excess-loss increments and Bousquet at $x=\log n$, with variance proxy $nb^2\asymp n^{2/5}(\log n)^{4/5}\gg\log n$. This yields the event $G\le fnb^2/4$.
- Convexity along rays and Assumption A's local quadratic margin on the norm face. L5 integration over the two affine coefficients gives an exponentially small norm-face numerator.
- On the TV face the gauge is bounded by $\Gamma/(Tn)+V/T_0$, with $\Gamma=\lambda\|u\|_1\sim\mathrm{Gamma}(m,1)$. Its MGF at $1/2$ is $2^m$; $T\ge4$, $V/T_0=o(1)$, and $\omega nb^2=o(n)$ give exponential decay in $n$, including the two-dimensional section volume.
- The L6 denominator from point 1, using B, L3 and half-radius L4q. Here $H=(n\log n)^{1/4}=o(nb^2)$ and $n\varepsilon b=\sqrt{Hnb^2}\to\infty$. These control both cone ratios. Localization alone yields the coarser radius $b$; C2 of point 2 gives the target radius. Finally $\Delta_n^2(\delta)\le\|\delta\|_n^2$ pointwise.

Sources: T06 FABLE_B_general_k §§4, 5.1–5.2, 6.1–6.2 (general-order substitutions); C1_any_sigma, Steps 0–8 and audit response; FABLE_lemmaF_C2 §§2.1–2.3 (projector replacing the Frobenius estimate of W_width_lemma). The general-order audit is recorded at the end of FABLE_B_general_k.
