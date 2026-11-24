# W-04 voice review: where the draft does not sound like its author

Reviewer inputs: `literature/SBSS_unblinded.pdf` (pp. 1–19, 27–28), `writing/W04_Paper/STYLE_GUIDE.md`, and `paper/main.tex` with the sections it inputs (proofs in `appendix_theory.tex` not read). Review date: 2026-11-24. The draft was being edited during the review; every `NOW:` quote was checked by script against the section files as they stood at 14:00 CT on that date (121 quotes written, 19 found stale and then corrected or withdrawn).

How to read an item. The heading gives `file:line` and what stands out. `NOW:` is the current sentence, verbatim (the anchor if lines shift). `NEW:` is a proposed rewrite in the SBSS voice. No rewrite changes a number, a table, a mathematical statement, a theorem, an assumption, a label, or a claim of which method is better. Items marked **CONTENT** flag a statement that looks wrong or inconsistent; they carry no rewrite. Where a rewrite adds a ratio or range, it was computed by the reviewer from the table named and is marked *(verify)*.

Item numbers have gaps where an item was withdrawn because the draft had already been changed (T-5, T-8, S-1, S-2, D-5, P-1, AP-1, AP-4). The review reflects the upper-bound-only theorem: the abstract, Introduction, Section 3, and Conclusions were re-read after that change (files dated 13:55 to 13:58 CT), no item is anchored on removed text, and no rewrite mentions a lower bound or an exact or sharp rate. Two checks requested by the author after the first pass (label-repeat openings, hand-typed citations) are in Part III.

Order: the three sections that carry the voice most (Introduction, Section 3, Conclusions), then the rest in paper order.

Overall: the draft has no em-dash (checked by search), no avoid-list adjective, and no rhetorical question. What remains is narrower: verdict words where SBSS gives numbers, a few refrains, several names for one object, and a development-log register in Appendix C and in the air-quality settings.

---

## Part I. Priority sections

### 1. Introduction (`introduction.tex`)

**I-1 · `introduction.tex:15` · λ is "the penalty" one sentence after "The ℓ1 penalty"**
```tex
NOW: Here $\lambda$, the penalty, sets the smoothness of the fit and must be chosen.
NEW: Here $\lambda$, the penalty parameter, sets the smoothness of the fit and must be chosen.
```
`methodology.tex:22` now fixes the name ("we refer to $\lambda$ as the penalty"), but line 23 of the Introduction calls λ "a global rate" and calls λσ "the penalty", and `theory.tex:76` calls λσ "tuning" (Global pattern 1).

**I-2 · `introduction.tex:15` · "exist" is stiff; three paragraphs follow, not two**
```tex
NOW: Two approaches to the problem exist, optimization and posterior sampling; we describe them next.
NEW: Optimization and posterior sampling have both been proposed for this problem; we describe them next.
```

**I-3 · `introduction.tex:17` · paragraph opens on a citation, not its subject**
```tex
NOW: \citet{brantley2020baseline} developed quantile trend filtering for baseline drift estimation.
NEW: Quantile trend filtering was developed by \citet{brantley2020baseline} for baseline drift estimation.
```

**I-4 · `introduction.tex:17` · limitation too clipped; "the optimizer" is a new actor**
```tex
NOW: The optimizer returns a point estimate at the selected penalty.
NEW: The result, however, is a point estimate at the selected penalty.
```
SBSS closes each strand this way: "Posterior sampling, however, must then move between spaces of different dimension." (p. 2).

**I-5 · `introduction.tex:19` · three chained clauses ending on a "which" tail**
```tex
NOW: \citet{onizuka2024fast} use horseshoe shrinkage on each difference, and their Gibbs sampler draws the trend from a Gaussian distribution whose precision matrix changes at every sweep, which is costly for long series.
NEW: \citet{onizuka2024fast} use horseshoe shrinkage on each difference. Their Gibbs sampler draws the trend from a Gaussian distribution whose precision matrix changes at every sweep; for long series this draw is costly.
```
**CONTENT:** this attributes the cost to the method, whereas `scalability.tex:58` says the gap "is a property of the implementation". The two should agree.

**I-6 · `introduction.tex:19` · orphan citation closes the paragraph instead of the limitation**
```tex
NOW: Calibrated loss-based alternatives include \citet{fasiolo2021fast}.
NEW: (attach to the paragraph's first sentence) ...; see also \citet{fasiolo2021fast} for a calibrated loss-based alternative.
```
The paragraph then ends on the cost sentence of I-5, as each SBSS strand ends on its limitation.

**I-7 · `introduction.tex:23` · "learned"; paragraph is twice the SBSS length**
```tex
NOW: This article develops a Bayesian counterpart of the ADMM quantile trend filtering estimator in which the penalty and the likelihood scale are learned with the trend.
NEW: This article develops a Bayesian counterpart of the ADMM quantile trend filtering estimator in which the penalty and the likelihood scale are sampled with the trend.
```
This contribution paragraph has 13 sentences and about 290 words; the SBSS one (p. 3) has 7 sentences and about 170. Items I-8 to I-10 shorten it.

**I-8 · `introduction.tex:23` · three stacked clauses; λ renamed "rate", penalty now λσ**
```tex
NOW: We take an asymmetric Laplace working likelihood with scale $\sigma$ and a Laplace prior with a global rate $\lambda$ on the differences, so that the conditional posterior mode at fixed $(\lambda, \sigma)$ is the solution of \eqref{eq:intro_qtf} with penalty $\lambda\sigma$, and we place priors on $\lambda$ and $\sigma$.
NEW: We take an asymmetric Laplace working likelihood with scale $\sigma$ and a Laplace prior with rate $\lambda$ on the differences, and we place priors on $\lambda$ and $\sigma$. At fixed $(\lambda, \sigma)$, the conditional posterior mode is the solution of \eqref{eq:intro_qtf} with penalty $\lambda\sigma$.
```

**I-9 · `introduction.tex:23` · five facts in one sentence; algorithm detail in a contribution list**
```tex
NOW: Its proximal map is a weighted trend filtering problem, solved by ADMM with banded factorizations, so P-MALA applies to the whole conditional without smoothing, and the cost per sweep grows linearly with $n$; the latent variables, $\lambda$, and $\sigma$ have conjugate updates.
NEW: Its proximal map is a weighted trend filtering problem, so P-MALA applies to the whole conditional without smoothing, and the cost per sweep grows linearly with $n$.
```
ADMM, the banded factorizations, and the conjugate updates are stated in Section 2; SBSS gives each contribution one sentence of elaboration.

**I-10 · `introduction.tex:23` · "neighbors" and "box" undefined here; "only … changes" closer**
```tex
NOW: Second, for several quantile levels we give a joint sampler whose draws never cross: given its neighbors, each trend has its single-level conditional restricted to a box, and only the proximal map changes.
NEW: Second, for several quantile levels we give a joint sampler whose draws never cross: each trend is drawn from its single-level conditional, restricted to lie between the trends at the adjacent levels.
```

**I-11 · `introduction.tex:23` · "inspired by" is soft; "and no moments" is a tail punch**
```tex
NOW: The data are not assumed to follow the asymmetric Laplace distribution; the result requires two conditions on their distribution functions near the quantile, inspired by \citet{madrid2022risk}, and no moments.
NEW: The data are not assumed to follow the asymmetric Laplace distribution; the result requires two conditions on their distribution functions near the quantile, adapted from \citet{madrid2022risk}, and no moment condition.
```
SBSS: "under prior-mass conditions adapted from Wei and Ghosal (2020)" (p. 3).

**I-12 · `introduction.tex:23` · "competitive" is a verdict; "while returning" sells**
```tex
NOW: In simulations, Bayesian-PMALA is competitive with the horseshoe sampler and with ADMM while returning posterior draws of the trend, the penalty, and the scale.
NEW: In simulations, Bayesian-PMALA is competitive with the horseshoe sampler and with ADMM.
```
The rewrite only removes the selling tail. SBSS's bridge states what was observed ("the observed error decay follows the sparsity of the fitted coefficients", p. 3). Replacing "competitive" by the observed fact is the author's call, since it touches the claim.

**I-13 · `introduction.tex:25` · "step by step" is informal**
```tex
NOW: Section~\ref{sec:methodology} presents the model and the two samplers step by step; computational details are in Appendix~\ref{app:pmala}.
NEW: Section~\ref{sec:methodology} presents the model and the two samplers; computational details are in Appendix~\ref{app:pmala}.
```

**I-14 · `introduction.tex:27` · sentence opens on a symbol**
```tex
NOW: $\mathrm{Gamma}(a, b)$ has shape $a$ and rate $b$, and $\mathrm{IG}(a, b)$ is the distribution of the reciprocal of a $\mathrm{Gamma}(a, b)$ variable.
NEW: We write $\mathrm{Gamma}(a, b)$ for the Gamma distribution with shape $a$ and rate $b$, and $\mathrm{IG}(a, b)$ for the distribution of the reciprocal of a $\mathrm{Gamma}(a, b)$ variable.
```

### 3. Theory (`theory.tex`)

Sections 3.1 and 3.2 up to the proof sketch follow SBSS pp. 6–9 closely and mostly read as the author. The items below are concentrated in the two remarks and in Section 3.3.

**T-1 · `theory.tex:13` · "rate" twice; the result is previewed inside the roadmap**
```tex
NOW: Section~\ref{sec:main-result} presents the posterior contraction theorem, which gives the rate at which the posterior concentrates around the true quantiles, and discusses the rate and the role of the working likelihood.
NEW: Section~\ref{sec:main-result} presents the posterior contraction theorem and discusses its rate and the role of the working likelihood.
```

**T-2 · `theory.tex:31` · "inspired by" where SBSS says "adapt"**
```tex
NOW: They are inspired by \citet{madrid2022risk}: Assumption~\ref{ass:A} is their condition, and Assumption~\ref{ass:B} is the corresponding upper bound.
NEW: They follow \citet{madrid2022risk}: Assumption~\ref{ass:A} is their condition, and Assumption~\ref{ass:B} is the corresponding upper bound.
```

**T-3 · `theory.tex:49` · a third requirement buried mid-paragraph under Assumption B**
```tex
NOW: The last requirement concerns the signal: there is a constant $\Vb$ such that $V^{*}\le\Vb$ for all $n$.
NEW: (new paragraph) The theorem also requires a bound on the signal: there is a constant $\Vb$ such that $V^{*}\le\Vb$ for all $n$.
```

**T-4 · `theory.tex:49` · passive pointer with an insert; "more complete" hedges**
```tex
NOW: A more complete analysis of the assumptions, including their verification for the noise distributions and signals of Section~\ref{sec:numerical}, is given in Appendix~\ref{app:assumptions}.
NEW: Appendix~\ref{app:assumptions} analyzes the assumptions and verifies them for the noise distributions and signals of Section~\ref{sec:numerical}.
```

**T-6 · `theory.tex:69` · four nested clauses in the proof sketch**
```tex
NOW: The numerator is bounded above on shells around $\thetas$, after a localization step that confines the posterior to a set on which $\|\theta-\thetas\|_\infty\to0$, so that Assumptions~\ref{ass:A} and~\ref{ass:B} apply to every coordinate.
NEW: The numerator is bounded above on shells around $\thetas$. A localization step first confines the posterior to a set on which $\|\theta-\thetas\|_\infty\to0$, so that Assumptions~\ref{ass:A} and~\ref{ass:B} apply to every coordinate.
```

**T-7 · `theory.tex:72` · present tense for a proved result**
```tex
NOW: \citet{madrid2022risk} obtain the rate $n^{-(2k+2)/(2k+3)}$, up to a logarithmic factor, for the quantile trend filtering estimator.
NEW: \citet{madrid2022risk} obtained the rate $n^{-(2k+2)/(2k+3)}$, up to a logarithmic factor, for the quantile trend filtering estimator.
```
`introduction.tex:17` already uses the past ("established") for the same paper.

**T-9 · `theory.tex:76` · a new result packed into one sentence; "tuning" for penalty**
```tex
NOW: The posterior mode is the quantile trend filtering estimator with tuning $\sigma_0\lamtv$, and at $\lamtv=c\,(n\log n)^{1/(2k+3)}$ every mode attains $\Delta_n^2\le C\,n^{-(2k+2)/(2k+3)}(\log n)^{1/(2k+3)}$ with probability at least $1-C(n\log n)^{-1/(2k+3)}$, by the localization argument of Appendix~\ref{app:proofs}.
NEW: The posterior mode is the quantile trend filtering estimator with penalty $\sigma_0\lamtv$. At $\lamtv=c\,(n\log n)^{1/(2k+3)}$, the localization argument of Appendix~\ref{app:proofs} shows that every mode attains $\Delta_n^2\le C\,n^{-(2k+2)/(2k+3)}(\log n)^{1/(2k+3)}$ with probability at least $1-C(n\log n)^{-1/(2k+3)}$.
```

**T-10 · `theory.tex:80` · second statement of one disclaimer in this section (line 17)**
```tex
NOW: The asymmetric Laplace density is a working likelihood: we do not assume that the data follow it, and every probability statement in Theorem~\ref{thm:main} is under the true distribution of the data.
NEW: Every probability statement in Theorem~\ref{thm:main} is under the true distribution of the data, which need not be asymmetric Laplace.
```

**T-11 · `theory.tex:80` · double "X, not Y" punchline**
```tex
NOW: Misspecification changes the spread of the posterior and not its center, so the theorem describes where the posterior concentrates and how fast, not the frequentist coverage of its credible sets \citep{yang2016posterior}.
NEW: Misspecification affects the spread of the posterior but leaves its center at the true quantile. The theorem therefore describes where the posterior concentrates and how fast; it makes no statement about the frequentist coverage of its credible sets \citep{yang2016posterior}.
```

**T-12 · `theory.tex:85` · rhetorical setup ("fixes … fixes … fixes neither")**
```tex
NOW: The sampler of Section~\ref{sec:methodology} fixes neither: both have the priors \eqref{eq:hyperpriors} and are updated with the trend.
NEW: (merge with the sentence before it) The contraction result holds for a deterministic $\lambda$ of a given order and a fixed $\sigma$, whereas the sampler of Section~\ref{sec:methodology} places the priors \eqref{eq:hyperpriors} on both and updates them with the trend.
```

**T-13 · `theory.tex:87` · "guard" is a metaphor; "unrealistically" is editorial**
```tex
NOW: Its role is to guard this unrealistically smooth case, in which the conditional mean of $\lambda$ would otherwise be unbounded.
NEW: Without it, the conditional mean of $\lambda$ would be unbounded for such trends.
```
**CONTENT:** `data_application.tex:16` reports that the prior rate sets the posterior of λ in the air-quality fit (λ near 864 under Gamma(1, 10)), so in the paper's own application this case is not unrealistic.

**T-14 · `theory.tex:89` · which / when / semicolon chain with a trailing caveat**
```tex
NOW: Hence $\sigma$ concentrates near $S(\theta)/n$, which is close to the average check loss $\bar\sigma_n=n^{-1}\sum_{i=1}^n\E\,\rho_\tau(y_i-\thetas_i)$ when this average is finite and bounded away from zero; this excludes Cauchy noise.
NEW: Hence $\sigma$ concentrates near $S(\theta)/n$. This is close to the average check loss $\bar\sigma_n=n^{-1}\sum_{i=1}^n\E\,\rho_\tau(y_i-\thetas_i)$ when that average is finite and bounded away from zero, which excludes Cauchy noise.
```

**T-15 · `theory.tex:89` · "data driven" is a catchphrase**
```tex
NOW: The scale is thus data driven, and Theorem~\ref{thm:main} with $\sigma_0=\bar\sigma_n$ describes the posterior at that scale.
NEW: Theorem~\ref{thm:main} with $\sigma_0=\bar\sigma_n$ describes the posterior at that scale.
```

**T-16 · `theory.tex:91` · defensive disclaimer ("we do not claim")**
```tex
NOW: A posterior with random $\lambda$ and $\sigma$ differs from the posterior \eqref{eq:post-fixed} of the proof, and we do not claim a contraction result for it.
NEW: The posterior with random $\lambda$ and $\sigma$ is not covered by Theorem~\ref{thm:main}.
```
SBSS states the same kind of gap flatly: "scales much below 1/J_n² make the Gibbs sampler numerically unstable, so the numerical illustrations of Section 3 use larger, practical scales" (p. 12).

**T-17 · `theory.tex:91` · labels its own choice; "free of tuning" is a slogan**
```tex
NOW: The choice is pragmatic: it keeps the method free of tuning, since no penalty is selected by cross-validation or by an information criterion.
NEW: We sample both in practice so that no penalty has to be selected by cross-validation or by an information criterion.
```
**CONTENT:** the prior rate $b_0$ is set differently for each signal and data set ($10^{-3}$ and $5\times10^{-4}$ in Section 4.1, $10$ and $\sqrt{G}$ in Section 4.4), so "free of tuning" would not survive a referee.

**T-18 · `theory.tex:76` · CONTENT: the only remaining mention of a lower bound**
```tex
NOW: The two balance at $\lambda\asymp n^{(2k+1)/2}$, which gives $n^{-(2k+1)/(2k+2)}$, the exponent of the lower bound for linear estimators over this class \citetext{\citealp{donoho1998minimax}; \citealp[Section~5.1]{tibshirani2014adaptive}}.
```
This cites a known lower bound for linear estimators from the literature; it is not the removed part (b) and does not say the posterior rate is exact. A reader may still take it as an optimality claim, so the author should confirm it stays now that the theorem is an upper bound only. No rewrite.

### 5. Conclusions (`discussion.tex`)

Two paragraphs, about 250 words, proposal with a colon, theorem, one sentence per experiment, one next step: the SBSS shape is there.

**C-1 · `discussion.tex:3` · SBSS heads this section "Conclusion"**
```tex
NOW: \section{Conclusions}
NEW: \section{Conclusion}
```

**C-2 · `discussion.tex:6` · "with … learned" tail; SBSS closes on "combined with"**
```tex
NOW: This paper proposes a Bayesian counterpart of the ADMM quantile trend filtering estimator: an asymmetric Laplace working likelihood and a Laplace prior with a global rate on the differences of the trend, with the penalty and the likelihood scale learned from the data.
NEW: This paper proposes a Bayesian counterpart of the ADMM quantile trend filtering estimator: an asymmetric Laplace working likelihood, combined with a Laplace prior on the differences of the trend and with priors on the penalty and the likelihood scale.
```

**C-3 · `discussion.tex:6` · "sampled by a … sampler"; three-item mechanism list**
```tex
NOW: The posterior is sampled by a Gibbs sampler whose trend update is a P-MALA step on the whole conditional of the trend; its proximal map is a weighted trend filtering problem, every linear system is banded, and the cost per sweep grows linearly with $n$.
NEW: A Gibbs sampler updates the trend by a P-MALA step on its whole conditional, whose proximal map is a weighted trend filtering problem, and the cost per sweep grows linearly with $n$.
```

**C-4 · `discussion.tex:6` · imprecise: it is the data that are not assumed**
```tex
NOW: The result holds under two conditions on the distribution functions of the data near the quantile and does not assume the working likelihood.
NEW: The result holds under two conditions on the distribution functions of the data near the quantile, and the data need not follow the working likelihood.
```

**C-5 · `discussion.tex:8` · borrowed SBSS line; results cannot "support a method"**
```tex
NOW: The numerical results support the method.
NEW: The numerical results illustrate the two samplers.
```
In SBSS the line is "The numerical results support this picture" (p. 19), where the picture is the theorem. Here the numerics do not test Theorem 1, so the borrowed sentence has lost its object.

**C-6 · `discussion.tex:8` · "competitive" for the third time; no observed fact**
```tex
NOW: On the two benchmark signals, Bayesian-PMALA is competitive with the horseshoe sampler of \citet{onizuka2024fast} and with the ADMM estimator of \citet{brantley2020baseline}, and at extreme upper quantiles the fits of the joint sampler never cross.
NEW: On the two benchmark signals, Bayesian-PMALA is competitive with the horseshoe sampler of \citet{onizuka2024fast} and with the ADMM estimator of \citet{brantley2020baseline}. At extreme upper quantiles the fits of the joint sampler never cross.
```
The rewrite only separates two unrelated facts. SBSS's conclusion gives the observation itself ("has a lower error … in every comparison", p. 19); see I-12.

**C-7 · `discussion.tex:8` · two unrelated results joined; linear cost already stated in paragraph one**
```tex
NOW: In the peak-detection design it performs close to ADMM, and its time per sweep grows linearly with $n$.
NEW: In the peak-detection design its baseline error and detection accuracy are close to those of ADMM. In the timing experiment the time per sweep grows linearly with $n$.
```

**C-8 · `discussion.tex:8` · CONTENT**
```tex
NOW: In the two data applications, the same sampler estimates the baseline of an air-quality series with $n = 8{,}640$ observations and the growth centiles of Dutch children.
```
"The same sampler" echoes SBSS's "one rule … yields smooth fits" (p. 19), but the two applications use different priors on λ (Gamma(1, 10) and Gamma(1, √G)) and the air-quality settings name a smoothing parameter (D-3). No rewrite.

---

## Part II. Remaining sections, in paper order

### Abstract (`abstract.tex`)

One paragraph, about 165 words, in the SBSS order. Five small items.

**A-1 · `abstract.tex:2` · "the optimizer" has no antecedent**
```tex
NOW: The penalty must be selected, and the optimizer returns a point estimate.
NEW: The penalty must be selected, and the estimator is a point estimate at the selected value.
```

**A-2 · `abstract.tex:2` · "learns"; the model sits in a participial tail**
```tex
NOW: We propose a Bayesian counterpart that learns the penalty and the likelihood scale with the trend, using an asymmetric Laplace working likelihood and a Laplace prior on the differences.
NEW: We propose a Bayesian counterpart: an asymmetric Laplace working likelihood and a Laplace prior on the differences, with priors on the penalty and the likelihood scale.
```
SBSS: "We propose a large series prior: a deterministic number of basis functions …, combined with a shrinkage prior on the coefficients." (p. 1).

**A-3 · `abstract.tex:2` · "at a cost" tail**
```tex
NOW: The trend is updated by a proximal Metropolis-adjusted Langevin step whose proximal map is a weighted trend filtering problem, at a cost per sweep linear in the sample size $n$.
NEW: The trend is updated by a proximal Metropolis-adjusted Langevin step whose proximal map is a weighted trend filtering problem, and the cost per sweep is linear in the sample size $n$.
```

**A-4 · `abstract.tex:2` · SBSS marks the theory sentence with "We establish"**
```tex
NOW: For a fixed scale and a fixed penalty of order $n^{(2k+1)/2}$, the posterior contracts around the true quantiles at the rate $n^{-(2k+1)/(2k+2)}$; the data need not follow the working likelihood.
NEW: We establish that, for a fixed scale and a fixed penalty of order $n^{(2k+1)/2}$, the posterior contracts around the true quantiles at the rate $n^{-(2k+1)/(2k+2)}$; the data need not follow the working likelihood.
```

**A-5 · `abstract.tex:2` · "competitive" is a verdict where SBSS states an observation**
```tex
NOW: In simulations, the sampler is competitive with ADMM-based quantile trend filtering and with a horseshoe Gibbs sampler.
```
SBSS: "In simulations, the Horseshoe error is insensitive to the dictionary size, unlike ridge regression" (p. 1). No rewrite, since the replacement is a claim; see I-12.

### 2. The model and the algorithm (`methodology.tex`)

The roadmap, Sections 2.1–2.4, and Section 2.6 read as the author. The step lists were asked for and are not flagged.

**M-1 · `methodology.tex:15` · model (1) displayed and described a second time**
```tex
NOW: with independent errors, where for a level $\tau \in (0,1)$ the trend entry $\theta_i$ is the conditional $\tau$-quantile of $y_i$.
```
SBSS displays the model once and then writes "model (1)". No rewrite, since removing the display would remove a label.

**M-2 · `methodology.tex:22` · "single global" and "overall" pad the sentence**
```tex
NOW: The prior is flat on the null space of $D$, the polynomials of degree at most $k$, and the single global rate $\lambda$ controls the overall smoothing; we refer to $\lambda$ as the penalty.
NEW: The prior is flat on the null space of $D$, the polynomials of degree at most $k$, and the rate $\lambda$ controls the smoothness of the trend; we refer to $\lambda$ as the penalty.
```
The next sentence then opens "The rate and the likelihood scale": the name changes back within one line.

**M-3 · `methodology.tex:22` · parameterization already fixed in Notation**
```tex
NOW: The rate and the likelihood scale $\sigma$ receive conjugate priors, in the shape and rate parameterizations,
NEW: The rate and the likelihood scale $\sigma$ receive the conjugate priors
```
The check function is likewise defined twice (`introduction.tex:27` and `methodology.tex:38`).

**M-4 · `methodology.tex:27` · CONTENT**
```tex
NOW: Following \citet{brantley2020baseline}, we use $k = 2$, so the fitted trends are piecewise quadratic.
```
The conditional mode is piecewise quadratic; a posterior mean is not. `data_application.tex:16` has the accurate wording ("the prior favors piecewise quadratic trends").

**M-5 · `methodology.tex:43` · "unchanged … gains" contrast survives from the old punchline**
```tex
NOW: Integrating out $z_i$ returns \eqref{eq:ald} exactly, so the model is unchanged and the sampler gains the latent variables $z = (z_1,\ldots,z_n)^\top$.
NEW: Integrating out $z_i$ returns \eqref{eq:ald}, so the representation leaves the model unchanged; the latent variables $z = (z_1,\ldots,z_n)^\top$ are sampled with the other parameters.
```

**M-6 · `methodology.tex:62` · dangling participle**
```tex
NOW: Integrating out $z$, the conditional posterior of $\theta$ at fixed $(\lambda, \sigma)$ is proportional to
NEW: With $z$ integrated out, the conditional posterior of $\theta$ at fixed $(\lambda, \sigma)$ is proportional to
```

**M-7 · `methodology.tex:71` · sampler personified; third verb for one idea**
```tex
NOW: The sampler infers $\lambda$ and $\sigma$ together with $\theta$ and reports posterior means and pointwise intervals.
NEW: We sample $\lambda$ and $\sigma$ together with $\theta$ and report posterior means and pointwise intervals.
```
The paper says "learned" (Introduction), "infers" (here), and "sampled" (`numerical.tex:2`) for the same thing.

**M-8 · `methodology.tex:76` · "four-block", then five steps (line 204 says "the five steps")**
```tex
NOW: We sample \eqref{eq:posterior} by a four-block Gibbs sampler, Bayesian-PMALA.
NEW: We sample \eqref{eq:posterior} by a Gibbs sampler with four blocks, which we call Bayesian-PMALA.
```
and, two sentences later,
```tex
NOW: The steps of one sweep are the following.
NEW: One sweep has five steps: the four block updates and an update of the P-MALA step size.
```
SBSS counts are exact ("one on the dictionary, one on the truth, and one on the prior", p. 6).

**M-9 · `methodology.tex:95` · slogan; "learns"**
```tex
NOW: This step learns the amount of smoothing from the data.
NEW: Through this step the roughness $\norm{D\theta}_1$ of the current trend sets the amount of smoothing.
```
This matches the wording of `theory.tex:87`.

**M-10 · `methodology.tex:95` · "draws … the draw … redraw"; "the rough part" undefined**
```tex
NOW: Because posterior draws satisfy $\norm{D\theta}_1 \approx m/\lambda$, the draw moves $\lambda$ slowly; it is therefore followed by an interweaving redraw \citep{yu2011center} that moves $\lambda$ and the rough part of $\theta$ together (Appendix~\ref{app:pmala:asis}).
NEW: Because posterior draws of the trend satisfy $\norm{D\theta}_1 \approx m/\lambda$, this update moves $\lambda$ slowly. It is therefore followed by an interweaving step \citep{yu2011center}, which rescales the component of $\theta$ outside the null space of $D$ together with $\lambda$ (Appendix~\ref{app:pmala:asis}).
```

**M-11 · `methodology.tex:128` · appended fragment for emphasis**
```tex
NOW: We apply it to the whole conditional \eqref{eq:Utheta}, likelihood and penalty together.
NEW: We apply it to the whole conditional \eqref{eq:Utheta}, which contains both the likelihood and the penalty.
```

**M-12 · `methodology.tex:156` · triad after a colon; "the stated posterior"**
```tex
NOW: The update is exact for the stated posterior: $U$ is the exact conditional, the proposal density is an explicit Gaussian, and $T$ enters only as a deterministic map of its input.
NEW: The move leaves the conditional \eqref{eq:Utheta} invariant: the acceptance ratio \eqref{eq:pmala_accept} uses $U$ itself and the Gaussian proposal density \eqref{eq:pmala_proposal}, and $T$ enters both only as a deterministic function of its input.
```

**M-13 · `methodology.tex:156` · the old "efficiency, not invariance" punchline reworded**
```tex
NOW: An approximate proximal solve therefore changes the efficiency of the move and leaves its invariant distribution unchanged.
NEW: The accuracy of the proximal solve therefore affects only the efficiency of the move.
```
**CONTENT:** `appendix_pmala.tex:160` says that safeguard (i) alters the conditional of $z$ and that the implementation as a whole is not exact. The main text says "exact" five times in Section 2 without that qualification.

**M-14 · `methodology.tex:165` · two consecutive "X, Y, so Z" sentences**
```tex
NOW: Problem \eqref{eq:prox} is a weighted trend filtering problem, solved by ADMM with a fixed number of iterations and a cold start, so $T$ is deterministic (Appendix~\ref{app:pmala:admm}).
NEW: Problem \eqref{eq:prox} is a weighted trend filtering problem. We solve it by ADMM with a fixed number of iterations and a cold start, which makes $T$ a deterministic function of its input (Appendix~\ref{app:pmala:admm}).
```
```tex
NOW: Every linear system is banded with half-bandwidth $k+1$, and one factorization serves the forward and reverse maps, so the work per sweep is linear in $n$.
NEW: Every linear system is banded with half-bandwidth $k+1$, and one factorization serves the forward and reverse maps; the work per sweep is therefore linear in $n$.
```

**M-15 · `methodology.tex:212` · "draw for draw" idiom; a software test in the main text**
```tex
NOW: For $J=1$ the joint sampler reproduces the individual sampler draw for draw (Appendix~\ref{app:pmala:tests}).
NEW: For $J=1$ the joint sampler reduces to the individual sampler.
```

**M-16 · `methodology.tex:241` · sentence wraps a display and trails a list without a serial comma**
```tex
NOW: The negative log-density $U_j + \iota_{B_j}$, with $\iota_{B_j}$ the indicator function of $B_j$ in the convex-analysis sense, is convex, so P-MALA applies as in Section~\ref{subsec:pmala} with the box-constrained proximal map
NEW: Let $\iota_{B_j}$ be the indicator function of $B_j$ in the convex-analysis sense. The negative log-density $U_j + \iota_{B_j}$ is convex, so P-MALA applies as in Section~\ref{subsec:pmala}, with the metric $M_j$ of \eqref{eq:metric} at level $j$, a step size $\delta_j$ per level, and the box-constrained proximal map
```
The trailing text after the display (`methodology.tex:248`, "the metric $M_j$ … and a step size $\delta_j$ per level.") is then dropped, and the display ends the sentence.

### 4. Simulations and data applications, opening (`numerical.tex`)

Purpose, four questions with section pointers, two flat closing sentences: this is SBSS p. 13.

**N-1 · `numerical.tex:2` · first question runs 45 words; competitors listed again at `simulations.tex:19`**
```tex
NOW: It addresses four questions: how the individual and joint samplers compare with the Laplace and horseshoe Gibbs samplers of \citet{onizuka2024fast} and with the ADMM estimator of \citet{brantley2020baseline} on two benchmark signals, at interior and at extreme quantile levels (Section~\ref{sec:simulations}); how the time per sweep grows with the sample size (Section~\ref{sec:scalability}); how well the method recovers a baseline contaminated by transient peaks (Section~\ref{sec:air_simulation}); and how it performs on an air-quality series and on growth data (Section~\ref{sec:applications}).
NEW: It addresses four questions: how the individual and joint samplers compare with existing Bayesian and optimization-based methods on two benchmark signals (Section~\ref{sec:simulations}); how the time per sweep grows with the sample size (Section~\ref{sec:scalability}); how well the method recovers a baseline contaminated by transient peaks (Section~\ref{sec:air_simulation}); and how it performs on an air-quality series and on growth data (Section~\ref{sec:applications}).
```

### 4.1 Simulations on two benchmark signals (`simulations.tex`)

The design paragraphs and the extreme-quantile paragraph on the VS signal read as the author. The two interior-quantile result paragraphs give counts of wins but no values or ratios before the reading.

**S-3 · `simulations.tex:19` · CONTENT (design)**
```tex
NOW: For the VS signal, $\lambda\sim\mathrm{Gamma}(1,10^{-3})$, the interweaving step is used, and the chain has $30000$ sweeps of which the first $10000$ are discarded; for the S signal, $\lambda\sim\mathrm{Gamma}(1,5\times10^{-4})$, no interweaving step is used, and the chain has $20000$ sweeps of which the first $5000$ are discarded.
```
The prior, the interweaving step, and the chain length all differ by signal, with no reason given; SBSS attaches the reason to each setting in a clause. The number of replications is not stated anywhere in Section 4.1, and Section 4.1.2 gives no priors or chain lengths for the joint sampler.

**S-4 · `simulations.tex:19` · methods named by first author's surname (53 uses in the main text)**
```tex
NOW: The Onizuka samplers use $8000$ sweeps with $2000$ burn-in and an $\mathrm{IG}(1,1)$ prior on $\sigma^2$.
NEW: The two Gibbs samplers of \citet{onizuka2024fast} use $8000$ sweeps with $2000$ burn-in and an $\mathrm{IG}(1,1)$ prior on $\sigma^2$.
```
SBSS names methods, not people ("the Horseshoe", "ridge regression"). The table row labels "Onizuka (…)" are the author's call.

**S-5 · `simulations.tex:23` · no values before the reading; "slightly ahead"**
```tex
NOW: The three Bayesian samplers have similar MSE in every configuration, and the horseshoe is slightly ahead under Beta noise, so a single global penalty matches local shrinkage on this signal.
NEW: In every configuration the MSE values of the three Bayesian samplers are within a factor of $1.22$ of one another, and the horseshoe has the smallest at all five levels under Beta noise. A single global penalty therefore gives nearly the same error as local shrinkage on this signal.
```
*(verify)* Factor from Table `tab:vs_int_mse`: the largest ratio of largest to smallest among the three is $0.007911/0.006493 = 1.22$ (Beta, $\tau = 0.95$).

**S-6 · `simulations.tex:23` · "heavy"/"lighter" metaphors; "learn"; explanation not shown**
```tex
NOW: This is consistent with extended BIC selecting a penalty too heavy for the localized bump, whereas the samplers learn a lighter one from the data.
NEW: These results suggest that extended BIC selects a penalty too large for the localized bump, whereas the samplers settle on a smaller one.
```

**S-7 · `simulations.tex:56` · no magnitude; "designed for" reads as an excuse (again at `air_simulation.tex:42`)**
```tex
NOW: ADMM has the smallest MSE in every configuration, as expected for the smooth-baseline setting it was designed for.
NEW: ADMM has the smallest MSE in every configuration; the MSE of Bayesian-PMALA is between $1.4$ and $3.1$ times as large. This is the smooth-baseline setting for which ADMM was developed.
```
*(verify)* Ratios from Table `tab:s_int_mse`: smallest $0.000251/0.000183 = 1.37$ (Beta, $0.05$); largest $0.072843/0.023342 = 3.12$ (mixed normal, $0.95$).

**S-8 · `simulations.tex:56` · "slightly" with no number; "a … one"**
```tex
NOW: Bayesian-PMALA has a smaller MSE than both Onizuka samplers at $\tau=0.25$, $0.50$, and $0.75$ under every noise family, and a slightly larger one at five of the six outer-level configurations; the exception is Beta noise at $\tau=0.05$.
NEW: Bayesian-PMALA has a smaller MSE than both samplers of \citet{onizuka2024fast} at $\tau=0.25$, $0.50$, and $0.75$ under every noise family, by $15\%$ to $23\%$ relative to the better of the two. At $\tau=0.05$ and $0.95$ its MSE is larger than both in five of the six configurations, by $8\%$ to $18\%$ relative to the better of the two; the exception is Beta noise at $\tau=0.05$.
```
*(verify)* From Table `tab:s_int_mse`: interior ratios to the better competitor run from $0.767$ to $0.848$; the five outer ratios run from $1.084$ to $1.181$.

**S-9 · `simulations.tex:56` · explanation asserted, not hedged; "exploit"**
```tex
NOW: This signal has no localized feature for local shrinkage scales to exploit.
NEW: These results suggest that local shrinkage scales bring no gain on a signal without a localized feature.
```

**S-10 · `simulations.tex:92` · the paper's own sampler listed as a "competitor"; appositive list**
```tex
NOW: The competitors, Bayesian-PMALA, the two Onizuka samplers, and ADMM, are fitted one level at a time to the same data.
NEW: The individual sampler, the two samplers of \citet{onizuka2024fast}, and ADMM are fitted one level at a time to the same data.
```

**S-11 · `simulations.tex:94` · "ahead" is a race metaphor**
```tex
NOW: At $\tau=0.90$ under these two noise families the Onizuka samplers are ahead.
NEW: At $\tau=0.90$ under these two noise families the samplers of \citet{onizuka2024fast} have the smaller MSE.
```

**S-12 · `simulations.tex:96` · "much faster" beside the numbers; nested "which" tail**
```tex
NOW: Under mixed-normal noise the ADMM error grows from $0.0158$ at $\tau=0.90$ to $0.2911$ at $\tau=0.99$, much faster than that of the joint sampler, which grows from $0.0280$ to $0.0940$ and has the smallest MSE from $\tau=0.97$ upward.
NEW: Under mixed-normal noise the ADMM error grows from $0.0158$ at $\tau=0.90$ to $0.2911$ at $\tau=0.99$, whereas that of the joint sampler grows from $0.0280$ to $0.0940$; the joint sampler has the smallest MSE from $\tau=0.97$ upward.
```

**S-13 · `simulations.tex:96` · paragraph opened "On the S signal"; the subject changes here**
```tex
NOW: On both signals the joint sampler has a smaller MSE than individual Bayesian-PMALA in every configuration but two, both for the VS signal: with Gaussian noise at $\tau=0.90$ the two values are $0.0135$ and $0.0134$, and with Beta noise at $\tau=0.99$ both are $0.0132$.
NEW: (new paragraph) On both signals the joint sampler has a smaller MSE than the individual sampler in every configuration but two, both for the VS signal: with Gaussian noise at $\tau=0.90$ the two values are $0.0135$ and $0.0134$, and with Beta noise at $\tau=0.99$ both are $0.0132$.
```

### 4.2 Computational cost (`scalability.tex`)

Setup, exact settings, numbers first, short flat sentences ("The two Onizuka priors cost about the same."): this section reads as the author.

**SC-1 · `scalability.tex:18` · "both" of three samplers; "clock reads" is lab shorthand**
```tex
NOW: The Onizuka code is used unmodified, with \texttt{sparse = TRUE}, and both samplers are timed by clock reads around their updates.
NEW: The code of \citet{onizuka2024fast} is used unmodified, with \texttt{sparse = TRUE}, and each update of each sampler is timed separately.
```

**SC-2 · `scalability.tex:56` · "a sweep grows"; surname used as an adjective**
```tex
NOW: An Onizuka sweep grows roughly cubically, so the ratio to Bayesian-PMALA increases with every doubling of $n$: from $25$ (Laplace) and $24$ (horseshoe) at $n=250$ to $7\,035$ and $6\,593$ at $n=4000$.
NEW: For the two samplers of \citet{onizuka2024fast} it grows roughly cubically, so the ratio to Bayesian-PMALA increases with every doubling of $n$: from $25$ (Laplace) and $24$ (horseshoe) at $n=250$ to $7\,035$ and $6\,593$ at $n=4000$.
```

**SC-3 · `scalability.tex:58` · two caveats run together; the second is a disclaimer**
```tex
NOW: The experiment times single sweeps; the autocorrelation of the chains is not measured, and the cost per effective draw also depends on it.
NEW: (whole paragraph) Two points qualify this comparison. First, the cubic cost belongs to the implementation rather than to the model: the precision matrix of the horseshoe hierarchy is banded and admits a banded Cholesky draw. Second, the times are per sweep, and the cost per effective draw depends also on the autocorrelation of the chains, which we do not compare.
```
SBSS: "The slopes need not match the minimax exponents … First, … Second, …" (p. 17).

### 4.3 Baseline recovery and peak detection (`air_simulation.tex`)

Design in the passive, exact settings, numbers and then one reading ("This is consistent with fits that follow the peaks rather than the baseline beneath them."): reads as the author.

**AS-1 · `air_simulation.tex:6` · table labels dropped into the sentence as an appositive**
```tex
NOW: We compare Bayesian-PMALA with the horseshoe and Laplace samplers of \citet{onizuka2024fast}, Onizuka (HS) and Onizuka (Laplace), and with ADMM \citep{brantley2020baseline}.
NEW: We compare Bayesian-PMALA with the horseshoe and Laplace samplers of \citet{onizuka2024fast}, labeled Onizuka (HS) and Onizuka (Laplace) in Table~\ref{tab:air_n500}, and with ADMM \citep{brantley2020baseline}.
```
The sampler settings for this experiment (priors, sweeps) are not stated.

**AS-2 · `air_simulation.tex:42` · "the method designed for this problem" reads as an excuse**
```tex
NOW: At $\tau=0.05$ and $0.10$ the MSE of Bayesian-PMALA is $0.0138$ and $0.0131$, against $0.0127$ and $0.0114$ for ADMM, the method designed for this problem; at $\tau=0.01$ the values are $0.0461$ and $0.0302$.
NEW: At $\tau=0.05$ and $0.10$ the MSE of Bayesian-PMALA is $0.0138$ and $0.0131$, against $0.0127$ and $0.0114$ for ADMM; at $\tau=0.01$ the values are $0.0461$ and $0.0302$.
```

**AS-3 · `air_simulation.tex:42` · "close" without the number**
```tex
NOW: The CAA values of the two methods are close at $\tau=0.05$ and $0.10$ for every threshold, and at $\tau=0.01$ ADMM is higher by about $0.07$ at $h=0.5$ and $0.75$.
NEW: At $\tau=0.05$ and $0.10$ the CAA values of the two methods differ by at most $0.031$ at every threshold, and at $\tau=0.01$ ADMM is higher by about $0.07$ at $h=0.5$ and $0.75$.
```
*(verify)* Largest difference in Table `tab:air_n500`: $0.789 - 0.758 = 0.031$ ($\tau = 0.10$, $h = 1$).

**AS-4 · `air_simulation.tex:42` · 45 words, three results, two nested comparisons**
```tex
NOW: The Onizuka fits have the smallest check losses but the largest MSE, between $0.065$ and $0.107$ at $\tau=0.05$ and $0.10$ against at most $0.0138$ for Bayesian-PMALA and ADMM, and their CAA is lower than that of Bayesian-PMALA in all cases except $h=0.5$ at $\tau=0.01$.
NEW: The fits of the two samplers of \citet{onizuka2024fast} have the smallest check losses but the largest MSE: between $0.065$ and $0.107$ at $\tau=0.05$ and $0.10$, against at most $0.0138$ for Bayesian-PMALA and ADMM. Their CAA is lower than that of Bayesian-PMALA in all cases except $h=0.5$ at $\tau=0.01$.
```

**AS-5 · `air_simulation.tex:42` · side comparison placed after the reading; paragraph ends off its subject**
```tex
NOW: Between the two Onizuka priors, the Laplace prior has the smaller MSE at $\tau=0.05$ and $0.10$ and the horseshoe at $\tau=0.01$.
NEW: (move before "This is consistent with …", so that the paragraph closes on the reading) Between the two priors of \citet{onizuka2024fast}, the Laplace prior has the smaller MSE at $\tau=0.05$ and $0.10$ and the horseshoe at $\tau=0.01$.
```

### 4.4 Data applications (`data_application.tex`)

The opening paragraph ("The first is … The second is …") and the growth figure paragraph mirror SBSS pp. 17–18. The air-quality settings and diagnostics do not: they describe a sampler with a smoothing parameter and read as a run log. Five CONTENT flags sit in this section.

**D-1 · `data_application.tex:10` · about 280 words of instrument background before the analysis**
```tex
NOW: The first application revisits the fenceline air-quality monitoring problem that motivated quantile trend filtering in \citet{brantley2020baseline}.
NEW: (one paragraph for lines 10 and 12) The first application is the fenceline air-quality monitoring problem that motivated quantile trend filtering in \citet{brantley2020baseline}. Low-cost SPod sensors on the perimeter of industrial facilities record, once per second, the signal of a photoionization detector in uncalibrated counts. Emission plumes produce one-sided spikes lasting seconds to a few minutes, on a baseline that drifts over hours with temperature, humidity, and lamp condition. The baseline is therefore a low conditional quantile of the series, and it must be removed before events can be flagged or compared across sensors.
```
SBSS gives each data set its source, $n$, and transformation in one sentence (p. 17).

**D-2 · `data_application.tex:12` · tidy closer; remnant of the "nuisance / signal" slogan**
```tex
NOW: This is a quantile trend filtering problem in which the trend is removed and the residual is analyzed.
NEW: (delete; the last sentence of D-1 says it)
```

**D-3 · `data_application.tex:16` · CONTENT; also a six-item settings list**
```tex
NOW: The sampler is run for $6{,}000$ sweeps with a burn-in of $1{,}000$, proximal parameter $\gamma = 0.1$, smoothing parameter $\epsilon = 0.01$, priors $\lambda \sim \mathrm{Gamma}(1, 10)$ and $\sigma \sim \mathrm{IG}(0.01, 0.01)$, and a step size adapted during burn-in toward acceptance rate $0.5$.
```
Section 2 has $\gamma = \delta/2$ and no smoothing parameter; "adapted during burn-in" contradicts `appendix_pmala.tex:153` ("The adaptation continues after burn-in"). This sentence and "the smoothed check-loss gradient" (line 26) describe a different sampler from the one in the paper. No rewrite.

**D-4 · `data_application.tex:16` · "effectively pins" is a metaphor with a hedge**
```tex
NOW: Because $\norm{D\theta}_1$ is small for the smooth baselines supported by these data, the rate parameter of the Gamma prior effectively pins the posterior of $\lambda$ near $(n - k - 1)/10 \approx 864$.
NEW: Because $\norm{D\theta}_1$ is small for the smooth baselines supported by these data, the rate of the Gamma prior dominates the full conditional \eqref{eq:lambdaupdate}, and the posterior of $\lambda$ concentrates near $(n - k - 1)/10 \approx 864$.
```
**CONTENT:** the sentence says the prior, not the data, sets λ here, against `theory.tex:87` and `:91` (T-13, T-17).

**D-6 · `data_application.tex:18` · dangling "Following"; 50 words with a colon and a "so that" tail**
```tex
NOW: Following \citet{brantley2020baseline}, event detection after baseline removal is a threshold rule on the detrended series $\by - \widehat{\theta}$: a point is classified as signal when it exceeds the empirical 90th, 95th, or 99th percentile of the detrended data themselves, so that no absolute calibration of the counts is required.
NEW: Following \citet{brantley2020baseline}, we detect events by a threshold rule on the detrended series $\by - \widehat{\theta}$: a point is classified as signal when it exceeds the empirical 90th, 95th, or 99th percentile of the detrended data. The rule requires no absolute calibration of the counts.
```

**D-7 · `data_application.tex:22` · verdict stated before the evidence**
```tex
NOW: The comparison at $\tau = 0.01$ favors the Bayesian fit.
NEW: (open the paragraph with) At $\tau = 0.01$ the two fits differ. (and close it with) At this level the comparison favors the Bayesian fit.
```
**CONTENT:** line 26 reports a median effective sample size of $3.5$ at this level and "substantial Monte Carlo error"; a referee will set that beside this verdict. The fits here are posterior medians, whereas `methodology.tex:104` and the growth application report posterior means.

**D-8 · `data_application.tex:22` · "twenty-fold smaller" is awkward**
```tex
NOW: Extended BIC selects a twenty-fold smaller penalty at this level than at the other two, and the resulting ADMM curve bends upward into the 05:00 plume and crosses the $\tau = 0.05$ and $\tau = 0.1$ curves.
NEW: Extended BIC selects a penalty twenty times smaller at this level than at the other two, and the resulting ADMM curve bends upward into the 05:00 plume and crosses the $\tau = 0.05$ and $\tau = 0.1$ curves.
```

**D-9 · `data_application.tex:24` · "sits at", "noise floor"; three clauses and a parenthesis**
```tex
NOW: With the $\tau = 0.05$ baseline removed, the 95\% threshold sits at $109$ counts for Bayesian-PMALA ($92$ for ADMM), while the largest plumes exceed $400$ counts, so the events of interest separate from the noise floor under either baseline.
NEW: With the $\tau = 0.05$ baseline removed, the 95\% threshold is $109$ counts for Bayesian-PMALA and $92$ for ADMM, whereas the largest plumes exceed $400$ counts. The events of interest are therefore separated from the noise under either baseline.
```

**D-10 · `data_application.tex:26` · past tense among present-tense results; dash range in prose**
```tex
NOW: Each level required $44$--$53$ minutes of computation at $n = 8{,}640$ ($6{,}000$ sweeps), against roughly four minutes for the ADMM fit including the extended BIC grid search.
NEW: Each level takes between $44$ and $53$ minutes for $6{,}000$ sweeps at $n = 8{,}640$, against roughly four minutes for the ADMM fit with its grid search.
```
The next sentence ("The acceptance rates were …") has the same tense shift.

**D-11 · `data_application.tex:26` · CONTENT**
```tex
NOW: At that level fewer than one observation in a hundred lies below the trend and the smoothed check-loss gradient is nearly flat, so pointwise credible statements at $\tau = 0.01$ carry substantial Monte Carlo error at this chain length.
```
There is no smoothed check loss in the sampler of Section 2 (see D-3). No rewrite.

**D-12 · `data_application.tex:47` · "slots" is informal (seven uses); the caption says "age grid"**
```tex
NOW: We round age to the nearest tenth of a year, which gives $G = 220$ equally spaced age slots for boys and $G = 221$ for girls, and index the trend $\theta \in \R^{G}$ by slot.
NEW: We round age to the nearest tenth of a year, which gives a grid of $G = 220$ equally spaced ages for boys and $G = 221$ for girls, and index the trend $\theta \in \R^{G}$ by grid point.
```

**D-13 · `data_application.tex:49` · CONTENT; development-log register**
```tex
NOW: With some twenty children per slot the likelihood is much more concentrated, and a prior centered near $2G$ leaves the P-MALA step unable to move, so we use the $\sqrt{n}$ rule instead.
```
Neither "the linear-in-$n$ prior of Section 2.4" (previous sentence) nor "the $\sqrt{n}$ rule" is defined in the paper, and a Gamma$(1, \sqrt{G})$ prior is not centered near $2G$. "Unable to move, so we use … instead" is tried-and-replaced history. Once the rule is defined, the SBSS form is "In our experience, …, so …" (p. 12). No rewrite.

**D-14 · `data_application.tex:51` · "at the price of" is an idiom hung on a tail**
```tex
NOW: All centiles are read off this one fitted distribution, so they cannot cross by construction, at the price of a parametric shape assumption at every age.
NEW: All centiles are read off this one fitted distribution, so they cannot cross; the method assumes a parametric shape at every age.
```

**D-15 · `data_application.tex:55` · setup and payoff ("nothing … nevertheless never"); long parenthesis**
```tex
NOW: The posterior-mean curves for girls nevertheless never cross, and those for boys cross at a single grid point (age $0.1$ years, where the $0.5$ and $0.7$ curves invert by $0.6$~cm), out of $880$ adjacent comparisons.
NEW: (with the sentence before it) The five fits are independent, so non-crossing is not enforced. The posterior-mean curves for girls do not cross. Those for boys cross in one of $880$ adjacent comparisons: at age $0.1$ years the $0.5$ curve lies $0.6$~cm above the $0.7$ curve.
```

**D-16 · `data_application.tex:57` · "closely" and "roughly" stacked**
```tex
NOW: The two methods agree closely between roughly one and eighteen years of age and differ at the ends of the age range, where few children are observed.
NEW: The two methods agree between about one and eighteen years of age and differ at the ends of the age range, where few children are observed.
```

**D-17 · `data_application.tex:57` · participial tail ("sitting … and bending")**
```tex
NOW: The LMS centiles follow the local data more closely, whereas the trend-filtering curves extrapolate the piecewise-quadratic trend, sitting slightly above the newborn measurements and bending at the oldest ages.
NEW: The LMS centiles follow the local data more closely. The trend filtering curves extrapolate the piecewise-quadratic trend: they lie slightly above the newborn measurements and bend at the oldest ages.
```

### Appendix B. Analysis of the assumptions (`appendix_assumptions.tex`)

Reads as the author: named assumptions, "This is why …", "Two features need a remark. First, … Second, …", counts ("in all 33 combinations").

**B-1 · `appendix_assumptions.tex:5` · clause-style heads; SBSS heads are noun phrases**
```tex
NOW: \paragraph{What the assumptions say.}
NEW: \paragraph{Meaning of the assumptions.}
```
Likewise `:12`, "Where they enter the proof." to "Role in the proof."

**B-2 · `appendix_assumptions.tex:79` · "invisible" is colloquial**
```tex
NOW: For Beta noise it is between $9.5$ and $45.1$, which moves $V^*$ by about $-10\%$ to $+13\%$ for S and is invisible for VS.
NEW: For Beta noise it is between $9.5$ and $45.1$, which moves $V^*$ by about $-10\%$ to $+13\%$ for S and is negligible for VS.
```

**B-3 · `appendix_assumptions.tex:81` · CONTENT**
```tex
NOW: The constants of the theorem also degrade where $\underline f$ is small, at $\tau\ge0.96$ and for Beta noise at $\tau=0.05$.
```
In Table `tab:ass:margins`, Beta noise at $\tau = 0.05$ has $\underline f = 0.500$, which is not small; the extreme value there is $\bar f = 10.74$.

### Appendix C. Computational details (`appendix_pmala.tex`)

C.1 (conditionals), the algorithm statements in C.2 and C.3, and C.4 read as the author. The verification text in C.3, and C.8 and C.9 as a whole, are a development and test log, which the guide lists under "avoid". Lighter pass; representative items only. The headings are now in sentence case.

**P-2 · `appendix_pmala.tex:5` · a 70-word enumeration as the opening sentence**
```tex
NOW: This appendix gives the derivations of the full conditional distributions of Section~\ref{subsec:individual}, the algorithms that solve the two proximal problems, the unconstrained map \eqref{eq:prox} of the individual sampler and the box-constrained map \eqref{eq:joint_prox} of the joint sampler, the interweaving step for $\lambda$ and its constrained version, the initialization, warm-up and step-size adaptation, and the numerical safeguards, followed by the choices behind the default settings and the exactness checks.
NEW: This appendix is organized as follows. Appendix~\ref{app:pmala:conditionals} derives the full conditional distributions of Section~\ref{subsec:individual}. Appendices~\ref{app:pmala:admm} and~\ref{app:pmala:boxsolver} give the algorithms for the unconstrained proximal map \eqref{eq:prox} and the box-constrained map \eqref{eq:joint_prox}. Appendix~\ref{app:pmala:asis} describes the interweaving step for $\lambda$ and its constrained version. Appendices~\ref{app:pmala:init}--\ref{app:pmala:safeguards} give the initialization, the warm-up, the step-size adaptation, and the numerical safeguards, and Appendices~\ref{app:pmala:runlength}--\ref{app:pmala:tests} the run length, the default settings, and the checks of the implementation.
```
SBSS: "The Appendix is organized as follows."

**P-3 · `appendix_pmala.tex:33` · a discarded alternative reported**
```tex
NOW: An early exit on the relative primal and dual residuals would also depend only on the iterates; it is not used, because it saved no time at this budget (Appendix~\ref{app:pmala:changes}).
NEW: (delete; the fixed budget is stated in the sentence before)
```

**P-4 · `appendix_pmala.tex:39` · version history of the code**
```tex
NOW: The simulations of Section~\ref{sec:simulations} use the original form; rerunning replications $1$--$10$ of every configuration with the increment form reproduces them, with no configuration differing significantly (all paired $|t| < 2$, geometric mean of the MSE ratios $1.01$).
NEW: The simulations of Section~\ref{sec:simulations} use the original form. In ten replications of every configuration, the MSE under the increment form does not differ significantly (all paired $|t| < 2$; geometric mean of the MSE ratios $1.01$).
```

**P-5 · `appendix_pmala.tex:58` · log of alternatives tried and dropped**
```tex
NOW: An active-set scheme that pins violating coordinates at their bounds and re-solves cycled on the same problems.
NEW: (whole paragraph "ADMM with a box splitting.") We do not split the box inside ADMM: under the metric \eqref{eq:metric}, $c/\gamma$ is large, and the dual ascent of the box multiplier converges very slowly whenever a bound is active.
```

**P-6 · `appendix_pmala.tex:94` · about 900 words of test report in the past tense**
```tex
NOW: The solver was checked by eight tests.
NEW: (for the two "Verification" paragraphs) We check the solver against the closed form available at $\lambda = 0$ and $c = 0$, against the interior-point solver Clarabel \citep{goulart2024clarabel} applied to \eqref{eq:box_qp}, and against a longer run of the same method. On $72$ problems that reproduce the conditions of the sampler, the output agrees with the longer run to $5.0\times10^{-10}$, and its objective is above Clarabel's in $3$ problems, by at most $1.9\times10^{-9}$ in relative terms.
```
SBSS appendices state a property once ("All constants are explicit.", p. 27). The remaining test counts belong with the code.

**P-7 · `appendix_pmala.tex:96` · "well within the resolution that matters" is vague emphasis**
```tex
NOW: Both methods therefore approach the same minimizer, and the interior-point output attains it to well within the resolution that matters for the proposal.
NEW: Both methods therefore approach the same minimizer.
```

**P-8 · `appendix_pmala.tex:130` · answers an objection nobody has raised**
```tex
NOW: The chain starts at $\by$ rather than at a smooth preliminary fit, because a chain started near a good smooth estimate can report a small error without having explored the posterior.
NEW: The chain starts at $\by$ rather than at a smooth preliminary fit, so that the reported errors do not depend on a starting estimate.
```

**P-9 · `appendix_pmala.tex:160` · "X, not a claim that Y": audit register**
```tex
NOW: The exactness of the trend update is therefore a property of that block, not a claim that the whole guarded implementation samples \eqref{eq:posterior} or \eqref{eq:joint_target} exactly.
NEW: With safeguard (i) in place, the sampler targets \eqref{eq:posterior} or \eqref{eq:joint_target} up to the clipping of the latent draws; the trend update itself remains exact.
```
The same paragraph has "which change the proposal and not the target"; "which change only the proposal" is enough. See the CONTENT note under M-13.

**P-10 · `appendix_pmala.tex:165` · CONTENT**
```tex
NOW: The application of Section~\ref{sec:app:spod}, with $n = 8640$, therefore uses longer chains.
```
`data_application.tex:16` reports $6{,}000$ iterations for that application, shorter than the $30000$ sweeps stated here. "Each run uses $30000$ sweeps" also omits the $20000$-sweep runs of the S signal (`simulations.tex:19`).

**P-11 · `appendix_pmala.tex:176` · development history: "pilot", "sensitivity run", "keep … as the default"**
```tex
NOW: We therefore keep $b_0 = 10^{-2}$ as the default.
NEW: (for the paragraph) We use $b_0 = 10^{-2}$. The prior rate must be small relative to $\norm{D\theta}_1$ for the data to determine $\lambda$, and $\mathrm{Gamma}(1, 10^{-2})$ gives $P(\lambda > 100) = e^{-1} \approx 0.37$.
```
The whole of C.8 is in this register ("performed worse in preliminary experiments", "on a pilot configuration", "is not used: in one configuration …"), and Table `tab:pmala_variants` has a "Previous default" row and an "Adopted" column. **CONTENT:** the same paragraph says that Section 4.1 does not use the default ($10^{-3}$ and $5\times10^{-4}$), and Section 4.4 uses $10$ and $\sqrt{G}$.

**P-12 · `appendix_pmala.tex:180` · a paragraph that only points elsewhere**
```tex
NOW: The start $\theta^{(0)} = \by$ and the warm-up are explained in Appendix~\ref{app:pmala:init}.
NEW: (delete the paragraph; likewise "Numerical safeguards." at line 208, which repeats C.6)
```

**P-13 · `appendix_pmala.tex:216` · a debugging anecdote closes the appendix**
```tex
NOW: A grid with nodes at the box edges overweights the edges of a truncated density; the midpoint grid avoids that bias, which amounted to about $1\%$ of the standard deviations here.
NEW: (delete; "on an $80^4$ midpoint grid" is already in the second test)
```
C.9 opens with a nine-item test list in one sentence (`:214`); a single sentence on what was compared with what would match C.1 to C.4.

### Appendices D and E (`appendix_simulations.tex`, `appendix_data_application_plots.tex`)

Mostly tables, figures, and definitions; the crossing-count paragraph reads as the author. The captions and headings flagged in an earlier pass are already corrected.

**AP-2 · `appendix_simulations.tex:78` · repeats the settings of Section 4.1.1 word for word**
```tex
NOW: For the smooth signal, Bayesian-PMALA uses $\lambda\sim\mathrm{Gamma}(1,5\times10^{-4})$, no interweaving step, and $20000$ sweeps of which the first $5000$ are discarded; all other settings are those of Section~\ref{sec:sim:individual}.
NEW: (delete; these settings are stated in Section~\ref{sec:sim:individual})
```

**AP-3 · `appendix_simulations.tex:78` · "extreme levels" means 0.05 and 0.95 here; main text says "outer"**
```tex
NOW: The MAD comparison (Table~\ref{tab:s_int_mad}) agrees with the MSE comparison of Section~\ref{sec:sim:ind:smooth} (Table~\ref{tab:s_int_mse}): Bayesian-PMALA is more accurate than both Onizuka samplers at $\tau=0.25$, $0.50$, and $0.75$ under every noise family and under Beta noise at $\tau=0.05$, and less accurate than both at the other extreme levels.
NEW: The MAD comparison (Table~\ref{tab:s_int_mad}) agrees with the MSE comparison of Section~\ref{sec:sim:ind:smooth} (Table~\ref{tab:s_int_mse}): Bayesian-PMALA is more accurate than both samplers of \citet{onizuka2024fast} at $\tau=0.25$, $0.50$, and $0.75$ under every noise family and under Beta noise at $\tau=0.05$, and less accurate than both at the other outer levels.
```
The main text keeps "extreme" for the levels $0.90$ to $0.99$; the next sentence of the same paragraph repeats "the other extreme levels".

---

## Part III. Two checks added at the author's request

Both checks were run by search over `main.tex` and every section file in scope, on the files as they stood at 14:00 CT (unchanged since the first pass). The proofs appendix (`appendix_theory.tex`) is outside this review and was not checked for either.

### Check 1. Paragraphs that open by repeating the label of the display they follow

**Result: no violation.** The draft displays two assumptions, one theorem, two remarks, and two algorithms (all in `theory.tex` and `methodology.tex`). The paragraph after each one opens as follows.

| Display | Next paragraph opens | Status |
|---|---|---|
| Assumption A (`theory.tex:33–38`) | "This condition requires each distribution function …" (`:40`) | clean |
| Assumption B (`theory.tex:42–47`) | "This second condition is the matching upper bound …" (`:49`) | clean |
| Theorem 1 (`theory.tex:55–65`) | "Posterior draws lie within …" (`:67`) | clean |
| Remarks 1 and 2 (`theory.tex:71–81`) | a remark, then a subsection heading | clean |
| Algorithm 1 (`methodology.tex:106–123`) | a subsection heading | see L-1 |
| Algorithm 2 (`methodology.tex:214–236`) | a subsection heading | clean |

Three paragraphs open on a label without directly following its display. They do not break the rule as stated; they are listed so the author can decide.

**L-1 · `methodology.tex:104` · opens on "Algorithm 1" and sits next to the Algorithm 1 float**
```tex
NOW: Algorithm~\ref{alg:pmala} states one run.
NEW: One run is stated in Algorithm~\ref{alg:pmala}.
```
In the source this paragraph comes before the float (`[h!]`). If LaTeX places the float above it, the page will read as a label repeat. The joint sampler's version (`methodology.tex:212`) already avoids this: its paragraph opens "During the first $H$ sweeps …" and names Algorithm 2 in the second sentence.

**L-2 · `theory.tex:85` · Section 3.3 opens on "Theorem 1"; the theorem is one page back**
```tex
NOW: Theorem~\ref{thm:main} fixes $\lambda$ at a given order and fixes $\sigma$.
```
Two remarks and a heading separate it from the theorem, so the rule is not broken. The rewrite proposed in T-12 opens on "The contraction result holds for …" and removes the label from the opening; the rewrite in T-16 was also changed so that it does not open on the label.

**L-3 · `appendix_assumptions.tex:6` · four paragraphs of Appendix B open "Assumption A …" or "Assumption B …"**
```tex
NOW: Assumption~\ref{ass:A} is a lower margin: the distribution function of $y_i$ grows at least linearly in a fixed neighborhood of the quantile, uniformly in $i$ and $n$.
```
Also `:17` and `:25` ("Assumption~\ref{ass:B} gives …") and `:19` ("Assumption~\ref{ass:A} gives the curvature …"). None follows a displayed assumption (the assumptions are displayed only in Section 3), so the rule is not broken; the appendix is about the assumptions and names its subject. No rewrite.

### Check 2. Citations typed by hand instead of `\citet` / `\citep`

**Result: no hand-typed author–year citation of a reference.** The draft has 62 citation commands, all natbib: 35 `\citet`, 24 `\citep`, and one `\citetext` holding two `\citealp` (`theory.tex:76`). `main.tex` loads `natbib` with the `apalike` style. The items below are the places where a source or an author is named by hand.

**R-1 · `data_application.tex:62` · source and year typed by hand in four figure captions**
```tex
NOW: Bayesian-PMALA fits for the height of 4{,}817 Dutch boys (Fifth Dutch Growth Study, 2009) at $\tau \in \{0.1, 0.3, 0.5, 0.7, 0.9\}$, $k = 2$.
NEW: Bayesian-PMALA fits for the height of 4{,}817 Dutch boys from the Fifth Dutch Growth Study \citep{schonbeck2013tallest} at $\tau \in \{0.1, 0.3, 0.5, 0.7, 0.9\}$, $k = 2$.
```
The same parenthesis "(Fifth Dutch Growth Study, 2009)" is in `appendix_data_application_plots.tex:83`, `:90`, and `:97`. The text cites the study correctly at `data_application.tex:45`. Note that 2009 is the collection year and the reference is dated 2013, so the hand-typed form also looks like a different source.

**R-2 · `simulations.tex:19` · an author's surname used as a method name, without a citation command**
```tex
NOW: The Onizuka samplers use $8000$ sweeps with $2000$ burn-in and an $\mathrm{IG}(1,1)$ prior on $\sigma^2$.
```
This is not an author–year citation, but it is a hand-typed author name. Outside citation commands "Onizuka" appears 17 times in prose and captions: `simulations.tex:19`, `:56`, `:92`, `:94`; `scalability.tex:18`, `:56` (three times), and the captions at `:23` and `:63`; `air_simulation.tex:6` and `:42` (twice each); `appendix_simulations.tex:14` and `:78`. It also labels 78 table rows, as "Onizuka (Horseshoe)" in Section 4.1 and Appendix D but "Onizuka (HS)" in Section 4.3. Rewrites for the prose are in S-4, S-8, S-10, S-11, SC-1, SC-2, AS-1, AS-4, AS-5, and AP-3; the row labels are the author's call.

**R-3 · `theory.tex:76` · `\citetext` with `\citealp`: natbib, but not `\citet` / `\citep`**
```tex
NOW: The two balance at $\lambda\asymp n^{(2k+1)/2}$, which gives $n^{-(2k+1)/(2k+2)}$, the exponent of the lower bound for linear estimators over this class \citetext{\citealp{donoho1998minimax}; \citealp[Section~5.1]{tibshirani2014adaptive}}.
```
Nothing is typed by hand here, and the output is a correct parenthetical citation with a section pointer for the second reference. It is flagged only because the rule names two commands. If the rule is meant literally, the plain form is `\citep{donoho1998minimax,tibshirani2014adaptive}`, at the cost of the pointer to Section 5.1. No rewrite proposed.

---

## Global patterns

1. **Several names for one object.** `methodology.tex:22` now says "we refer to λ as the penalty", yet λ is still "a global rate" or "the rate" (Introduction, Section 2.1, Conclusions), and λσ is "the penalty" in `introduction.tex:23` and "tuning" in `theory.tex:76`. The competitor is "the Onizuka samplers / fits / priors / code" (the surname appears 53 times in the main text). The paper's own single-level method is "Bayesian-PMALA", "the individual sampler", and "individual Bayesian-PMALA". "ALD" and "asymmetric Laplace" are each used 10 times in the main text; the levels 0.05 and 0.95 are "outer" in Section 4.1 and "extreme" in Appendix D. SBSS italicizes a term once and keeps it.
2. **Verdict words where SBSS gives numbers.** "Competitive" (abstract, Introduction, Conclusions), "similar", "close", "slightly", "performs close to". SBSS reads the values off the table, gives the ratio, and stops.
3. **Refrains.** "The data need not follow the working likelihood" is said 5 times (abstract, Introduction, twice in Section 3, Conclusions). "The cost per sweep grows linearly with n" is said 6 times (abstract, Introduction, Section 2.5, Section 4.2, and twice in the Conclusions). The list of competitors is given 4 times. Once per section is the SBSS rate.
4. **Residual "X, not Y" contrasts.** `theory.tex:80` (twice in one sentence), `methodology.tex:43` and `:156`, `appendix_pmala.tex:160`. Each is the old punchline in new words ("changes the efficiency … and leaves its invariant distribution unchanged").
5. **"…, so …" as the default joint, with "which" and "whereas" tails.** 33 uses in the main text, often two in consecutive sentences. SBSS breaks at a semicolon or opens the next sentence with "Consequently" or a mid-sentence "therefore".
6. **"Learn" and personified algorithms.** "learns the penalty" (abstract), "learned with the trend" (Introduction), "This step learns" (Section 2.4), "the samplers learn a lighter one" (Section 4.1), "learned from the data" (Conclusions); also "the sampler infers … and reports" and "the optimizer returns". SBSS writes "we take", "we place", "is selected".
7. **Development and test-log register, with settings the paper does not define.** Appendix C.3 (verification), C.8, and C.9, and the air-quality settings: alternatives tried and dropped, "previous default", test counts, "pins", "unable to move". The same passages name a smoothing parameter ε, a "√n rule", a "linear-in-n prior", and "longer chains" of 6,000 sweeps, none of which matches Section 2 or Appendix C.
8. **Mechanics.** Serial comma missing in `appendix_pmala.tex` (lines 5, 94, 96) and `methodology.tex:248` (and in the constants list of Theorem 1, which is the author's call); three thousands styles (`30000` in Section 4.1, `8{,}640` in Section 4.4, `7\,035` in Section 4.2); the level 0.1 is written "0.10" in Section 4.3 and "0.1" in Section 4.4; past tense for the paper's own runs in Section 4.4.1 and Appendix C.

## Verdict per section

| Section | File | Verdict |
|---|---|---|
| Abstract | `abstract.tex` | close |
| 1 Introduction | `introduction.tex` | close (contribution paragraph overloaded) |
| 2 The model and the algorithm | `methodology.tex` | close (2.1–2.4 and 2.6 read as the author; the exactness paragraph of 2.5 does not) |
| 3 Theory | `theory.tex` | close (3.1–3.2 read as the author; the two remarks and 3.3 are the gap) |
| 4 opening | `numerical.tex` | reads as the author |
| 4.1 Simulations on two benchmark signals | `simulations.tex` | close (interior results lack values before the reading) |
| 4.2 Computational cost | `scalability.tex` | reads as the author |
| 4.3 Baseline recovery and peak detection | `air_simulation.tex` | reads as the author |
| 4.4 Data applications | `data_application.tex` | not yet for air quality (run-log settings, five content flags); close for growth |
| 5 Conclusions | `discussion.tex` | close |
| Appendix B | `appendix_assumptions.tex` | reads as the author |
| Appendix C | `appendix_pmala.tex` | not yet (C.1, C.2, C.4 read as the author; C.3 verification, C.8, C.9 are logs) |
| Appendices D, E | `appendix_simulations.tex`, `appendix_data_application_plots.tex` | reads as the author (two small items) |

---

## Applied / declined (lead writer, 2026-11-24)

Each item was judged against the files; numbers were checked against the tables before use. No table, number, label, or statement of Section 3 was changed (the Theorem 1 constants list gained a serial comma). Content flags are logged in `INCONSISTENCIES.md`.

**Applied as proposed:** I-2, I-3, I-9, I-10, I-11, I-13, I-14; T-1, T-3, T-4, T-6, T-7, T-11, T-12 (also settles L-2), T-13, T-14, T-15, T-16, T-17; C-1, C-2, C-3, C-4, C-5; A-2, A-3, A-4; M-5, M-6, M-7, M-8, M-9, M-10, M-11, M-12, M-13, M-14, M-15, M-16, L-1; N-1; S-4, S-5, S-7, S-8, S-10, S-11, S-12, S-13; SC-1, SC-2, SC-3; AS-1, AS-2, AS-3, AS-4; D-4, D-6, D-8, D-9, D-10, D-12, D-14, D-15, D-16, D-17; B-1, B-2; P-2, P-3, P-4, P-7, P-8, P-9, P-13 (number kept); R-1 (four captions).

**Applied with a change:**
- I-1, I-8, M-2, M-3, T-9 (one name per object): $\lambda$ is "the penalty" (Introduction: "which we call the penalty"); $\lambda\sigma$ is "the effective penalty" in the Introduction, Sections 2.3 and 2.4, and Remark 1. "Penalty parameter" and "rate $\lambda$" were not used.
- I-4, A-1: "The method, however, returns a point estimate at the selected penalty" and "the result is a point estimate"; "The result" after the risk-bound sentence read as the risk bound.
- I-5: split as proposed, with "in their implementation this draw is costly", to agree with Section 4.2.
- I-6: attached to the first sentence of the paragraph.
- I-7, A-2, S-6, P-11 ("learn"): "estimated with the trend", "priors on the penalty and the likelihood scale", "the samplers estimate a smaller one", "for the data to determine $\lambda$".
- I-12, A-5, C-6, C-7 ("competitive", "close"): replaced by the observed facts with table numbers, scoped to the levels $0.05$ to $0.95$ (factor $1.22$ on the VS signal; ADMM smallest on the S signal; peak-detection MSE values; sweep-time ratios $25$ and $7\,000$). This changes how the comparison is stated in the abstract, Introduction, and Conclusion; the author should confirm.
- T-2: "adapted from", the same words as the Introduction (and as SBSS), instead of "follow".
- T-10: applied; the working-likelihood statement now appears once in Section 3.1 and once, in six words, in Remark 2.
- C-8, M-4: one phrase changed each ("Bayesian-PMALA estimates", "the prior favors piecewise quadratic trends") and logged.
- S-9: "no localized feature to which local shrinkage scales could adapt"; the proposed "bring no gain" claims more than the table shows at $\tau = 0.05$ and $0.95$.
- AS-5: moved before the reading, and the reading now names its subject ("Small check losses with a large MSE are consistent with ...").
- D-1, D-2: condensed to one paragraph; the EPA and VOC sentence is kept, and the removed instrument background is parked as a comment in the file.
- D-7: opening and closing sentences as proposed; the flag about the effective sample size is logged.
- D-13: register only ("In our experience ..."); undefined terms logged.
- AP-2, AP-3: the repeated settings are replaced by a pointer; the levels $0.05$ and $0.95$ are named by value, so "extreme" is used only for $0.90$ to $0.99$ and "outer" is not used.
- P-5: present tense; the numbers and the active-set remark are kept.
- P-12: the pointer paragraph on the start and warm-up is deleted; the "Numerical safeguards" paragraph is kept because it reports a result.
- Global pattern 5: three ", so" joints varied in Sections 2 and 3 in addition to the item rewrites. "Interweaving redraw" is now "interweaving step" throughout Section 2.

**Declined:**
- M-1 (model displayed twice): removing the display would remove a label.
- P-6 and the C.9 and C.10 test lists: condensing them deletes reported results; the past tense is left for completed test runs.
- P-10, D-3, D-11, S-3, B-3, T-13 and T-17 content notes: logged, not fixed (settings and results are outside this pass).
- R-2 table row labels and R-3 (`\citetext`): left as they are; `\citetext` is natbib and keeps the section pointer.
- L-3 (Appendix B paragraphs opening on "Assumption A"): they do not follow a displayed assumption.
- T-18: kept, as instructed (cited literature fact).
- Global pattern 8 (thousands separators, "0.10" vs "0.1"): left, as instructed.
