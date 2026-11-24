# Feasibility of the non-crossing extension

**Yes for fixed, distinct levels and fixed tuning and scale at each level.** Every ordered-posterior marginal inherits both sides of the T-07 annulus: squared radius of order $n^{-(2r-1)/(2r)}$ and expected mass $O_J(n^{-1/(2r)})$ in each excluded tail. The single-level radius constants still work. The probability prefactor and the threshold for $n$ may depend on the finite collection of levels. A union bound also gives simultaneous contraction.

**Separation is already implied by B and the common data law.** Write $q_{ij}$ for the true quantile and $F_i$ for the CDF of observation $i$. B gives continuity at each $q_{ij}$, hence $F_i(q_{ij})=\tau_j$. If an adjacent gap is at most the local radius $L_j$, applying B at its left endpoint gives $\tau_{j+1}-\tau_j\le\bar f_j(q_{i,j+1}-q_{ij})$. Thus every gap is at least $g=\min_{j<J}\min\{L_j,(\tau_{j+1}-\tau_j)/\bar f_j\}>0$, uniformly over $i,n$. Exact touching and gaps tending to zero are excluded. Small fixed gaps can increase the threshold for $n$ considerably, particularly for $r=2$.

**Evidence cost.** For the observed $y$, let $Q_y$ be the product of the normalized one-level posteriors. The ordered-to-product evidence ratio is exactly $Q_y(C)$. Proposition 2 gives deterministic error sets $K_{n,j}$ with sup-norm radii $s_{n,j}\to0$. Eventually $s_{n,j}+s_{n,j+1}\le g$ for every adjacent pair, so the product of the translated sets lies inside $C$. On the intersection of the levelwise evidence and localization events,

$$
1-Q_y(C)\le\sum_j\Pi_j(K_{n,j}^{c}\mid y)
\le O_J(\exp[-a n\rho_n^2]),\qquad
\rho_n^2=n^{-(2r-1)/(2r+1)}\log n ,
$$

where the sets in the probability refer to centered errors and $a>0$ depends on the fixed parameters. The intersection has true probability $1-O_J(n^{-1/(2r)})$ by a union bound even though all levels use the same observations. On this event the additive loss in the log evidence, $-\log Q_y(C)$, is itself $O_J(\exp[-a n\rho_n^2])$. This is a high-probability statement. For coalescing levels outside the question, the same argument would suffice if each actual gap eventually dominates the sum of its two localization radii and the levelwise bounds are uniform. T-07 alone gives no truncation exponent for smaller gaps or for touching under weakened assumptions.

**Work required.** The ordered target is $Q_y(\cdot\mid C)$. Its total variation distance from $Q_y$ equals $1-Q_y(C)$, which also bounds the change in every marginal event probability. Charging the exceptional data event once gives the stated expected-mass bounds. All one-level evidence, localization, shell and small-ball estimates carry over through this comparison. Anderson applies in its original single-level symmetric ball. There is no need to analyze a new shell integral over the cone or to multiply expectations over the data. My estimate is **1–2 manuscript pages, low risk, high confidence** for the fixed-parameter target. The argument concerns the statistical target and does not address sampler mixing or a posterior with learned scales and penalties. [Joint target](/home/fb31/Bayesian-Quantile-Trend-Filtering/paper/sections/methodology.tex:170) · [T-07 localization](/home/fb31/Bayesian-Quantile-Trend-Filtering/theory/T07_Bayes_Thm3/T07c_proof.tex:511)
