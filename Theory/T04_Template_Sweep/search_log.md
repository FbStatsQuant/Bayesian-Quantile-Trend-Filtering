# T-04 search log (audit trail)

Date: 2026-11-22. Planner, filter and verifier: Head of Theory (Claude Opus 5.5).

## Searchers

All five received the same brief: the target theorem, proof steps (a)–(e), criteria C1–C4, the exclusion list (`Papers/` plus T-01 entries), legitimate sources only, no proofs, and no repository writes.

| Searcher | Model | Direction |
|---|---|---|
| S1 | Claude Sonnet 5.5 | C1: Laplace / TV priors on increments |
| S2 | Claude Sonnet 5.5 | C2: check-loss Gibbs / quasi-posteriors in growing dimension |
| S3 | Claude Haiku 5.5 | C3: misspecified or non-Gaussian sequence models |
| S4 | Codex gpt-6.1-terra | C4: small-ball bounds for Laplace or integrated walks |
| S5 | Codex gpt-6-luna | Forward citations (OpenAlex) of ADH 2021, Agapiou & Wang, Giordano 2023, Syring & Martin, Madrid Padilla & Chatterjee |

## Head of Theory: personal verification

arXiv PDFs were converted with pdftotext.

- **Atchadé, arXiv 1508.07929v4.** Read H1–H3, the good-event definitions (2.5)–(2.7), Theorem 3 (2.8)–(2.9) and Remark 1.
- **Bach & Klein, arXiv 2109.04288v3.** Read the abstract, Assumptions A1–A7, Theorem 4.1 with its proof sketch (proper O-splines prior, Demmler–Reinsch basis, Hoffmann-Jørgensen shifted-ball inequality), and Corollary 4.2. The Supplement was not read.
- **Dolera, Favaro & Giordano, arXiv 2411.06981.** Front matter checked; S1's description of Theorem 2 and Lemma 5 relied on.

## Per-searcher reports (as reported)

### S1: Claude Sonnet 5.5, medium effort (Laplace / TV priors on increments, C1)

No strong hit.

**Candidates**
- Dolera, Favaro & Giordano, arXiv 2411.06981: Thm 2, Lemma 5. Score 2.
- Bach & Klein, arXiv 2109.04288: Thm 4.1, A1–A7. Score 2.
- Agapiou & Castillo, arXiv 2308.04916: Thms 1, 8, 9. Score 2.
- Dolera, Favaro & Mainini, arXiv 2203.10754. Score 1.
- Belomestny, van der Meulen & Spreij, arXiv 2305.07432. Score 1.

**Near misses**
- 2505.15543
- 2209.14995
- 2605.19610
- Aurzada & Dereich, arXiv 1008.0485
- Roualdes, arXiv 1505.07710
- 1512.06505
- Hosseini, arXiv 1609.07532
- Markkanen et al., arXiv 1603.06135

**Queries** (WebSearch, 18 total)
1. posterior contraction total variation prior Bayesian regression nonparametric rate Laplace increments
2. Bayesian fused lasso posterior concentration rate piecewise constant signal
3. posterior contraction Markov random field prior Laplace random walk Cauchy difference prior edge-preserving
4. posterior contraction rates Gaussian Markov random field integrated random walk prior P-spline small ball
5. arXiv Bayesian trend filtering posterior contraction rate theorem Laplace prior on differences
6. posterior consistency total variation prior Bayesian inverse problems contraction rate Lévy / Laplace random walk heavy-tailed increments
7. Agapiou Castillo heavy-tailed Bayesian nonparametric adaptation arXiv posterior contraction
8. Lévy adaptive regression kernels posterior contraction rate Besov
9. (extended) posterior contraction trend filtering Bayesian prior differences k-th order shrinkage horseshoe minimax rate bounded variation
10. Bayesian Laplace prior bounded variation functions posterior contraction regression 'total variation' prior rate n^{-2/3}
11. small ball probabilities integrated random walk iterated integrated Lévy process sup-norm small deviations Aurzada Simon
12. posterior contraction Laplace or Lévy process prior piecewise polynomial / locally adaptive ...
13. Bayesian P-splines posterior contraction rate random walk penalty prior theory
14. posterior contraction multiple change point piecewise constant mean prior on jumps increments
15. Bayesian trend filtering OR "Bayesian fused lasso" posterior consistency theorem Laplace prior differences
16. posterior concentration Laplace prior misspecified likelihood fixed design log-concave posterior without moment conditions Wasserstein
17. Dolera Favaro Mainini strong posterior contraction rates via Wasserstein dynamics arXiv
18. small deviations Riemann-Liouville / integrated random walk heavy-tailed or Laplace increments

**PDFs read:** 2308.04916, 2411.06981, 2109.04288. Headings or grep only: 2305.07432, 2209.14995, 2203.10754.

### S2: Claude Sonnet 5.5, medium effort (check-loss / Gibbs posteriors in growing dimension, C2)

No close blueprint.

**Candidates**
- Atchadé (2017, AoS), arXiv 1508.07929: Thm 3, good events (2.5)–(2.7), Lemmas 11–14. Score 2.
- Alquier, Li & Wintenberger (2013), arXiv 1202.4294: Thms 1–2, Lemma 2. Score 2.
- Mai (2024), arXiv 2409.01687: Thms 1–2. Score 2.
- Alquier & Ridgway (2020), arXiv 1706.09293: Thms 2.1, 2.6, 2.7. Score 2.
- Ho et al. (2021), arXiv 2111.10243: Thm 1. Score 1.

**Near misses**
- Martin & Syring, arXiv 2203.09381 (Thm 2)
- Bhattacharya & Martin, arXiv 2002.01052
- Steffen & Trabs, arXiv 2204.12392
- Jiang & Tanner, arXiv 0810.5655
- Alquier & Guedj (2018)
- Alquier (2021)
- Spokoiny, arXiv 2204.11038
- arXiv 2301.07782
- arXiv 2508.01738
- 1812.03652, 2111.00642, 1502.06481
- Survey arXiv 2605.05076, which states that contraction under non-intrinsic losses is open

**Queries** (WebSearch, 16 total)
1. Gibbs posterior convex Lipschitz loss high-dimensional concentration non-asymptotic
2. posterior contraction asymmetric Laplace quantile regression growing dimension misspecified
3. PAC-Bayes quantile regression high dimension Gibbs posterior oracle inequality check loss
4. generalized posterior absolute loss heavy tails no moment condition contraction nonparametric Gibbs
5. Alquier Ridgway Chopin tempered posterior concentration Lipschitz loss oracle inequality
6. quasi-posterior convex loss Laplace-type estimator increasing dimension finite sample concentration Spokoiny BvM
7. Bayesian lasso posterior contraction Laplace prior log-concave posterior convexity proof
8. Gibbs posterior quantile regression contraction nonparametric smoothing spline/basis, empirical process, no moment
9. Bernstein-von Mises quantile regression posterior high-dimensional misspecified ALD Gibbs growing covariates convex
10. Jiang Tanner Gibbs posterior variable selection high-dimensional classification
11. Alquier Guedj simpler PAC-Bayesian bounds hostile data heavy tails
12. (extended) Gibbs posterior contraction Lipschitz loss prior mass fractional posterior bounded increments
13. Alquier "Non-exponentially weighted aggregation"
14. Bayesian L1 trend filtering / TV prior Laplace likelihood median regression posterior contraction
15. posterior contraction nonparametric quantile regression ALD misspecified GP or splines
16. (extended) far-region control via convexity, Gibbs posterior log-concave, quantile/LAD, growing dimension

**PDFs read:** 1508.07929, 2409.01687, 2111.10243, 2203.09381, 1706.09293, 2204.12392, 1202.4294.

### S3: Claude Haiku 5.5, medium effort (misspecified sequence models, C3)

No candidate meets the strong-hit bar.

**Candidates**
1. Chakraborty & Ghosal, arXiv 2008.01244, monotone regression with fixed design. Thms 3.1 and 3.2 (summarizing fetch). Score 2.
2. Chatterjee & Bhattacharya, arXiv 1810.10495, misspecified GP / stochastic-process regression. Thms 5, 9 and 10. Score 2.
3. Castillo, Egels, Lazzarini & Szabó, arXiv 2611.11582, robust GP regression contraction under contamination with a weighted likelihood. Thms 1–3 and 6 (summarizing fetch, not verbatim). Score 2.

**Near misses**
- 2211.12595 (multivariate isotonic regression, Gaussian)
- 2203.09381 (direct Gibbs posterior with check loss; not read)
- 2603.28177
- 2505.15543 (heavy-tailed priors on coefficients, not noise)
- 2204.02299
- 1507.07412
- 2603.22468
- 2005.07844
- 2603.10924

**Queries** (WebSearch)
1. "posterior contraction Laplace errors sequence model nonparametric"
2. "Bayesian median regression nonparametric posterior contraction fixed design"
3. "misspecified Gaussian sequence model posterior contraction rate"
4. "Bayesian isotonic regression misspecified posterior contraction"
5. "robust Bayesian nonparametric regression Student t errors contraction rate"
6. "Bayesian trend filtering posterior contraction rate total variation prior sequence"
7. "Gibbs posterior quantile check loss nonparametric posterior contraction arXiv"
8. "posterior contraction heavy-tailed noise nonparametric regression Laplace likelihood misspecified rate theorem"
9. "Bayesian quantile regression posterior contraction asymmetric Laplace working likelihood nonparametric rates"

**Fetches:** abs pages for 2611.11582 and 2008.01244; HTML for 2611.11582v1, 2008.01244v1 and 1810.10495.

### S4: Codex gpt-6.1-terra, medium effort (small-ball bounds, C4)

No checked theorem gives step (a) for the projected, thrice-summed Laplace walk. Key observation: rotating to the singular basis destroys the independence of the Laplace coordinates, so weighted-iid small-deviation results do not apply directly.

**Candidates**
1. Agapiou & Savva (2024, Bernoulli), arXiv 2209.06045 (full text). Lemma 3.2 and Lemma D.1 give −log Π(εB_ℓ2) ≍ (ε/τ)^{−1/α}, including p = 1. Theorem 2.2 gives white-noise contraction. Score 3/5. Already in T-01 row 9.
2. Dolmeta & Giordano (2026), hierarchical Besov-Laplace priors for binary classification. Theorem 1. Its small-ball step cites Giordano (2023). Score 2/5.

**Near misses**
- Dunker, Lifshits & Linde (1998); full text not accessed.
- Lifshits (1997); not checked.
- Gao, Hannig & Torcaso (2003); inaccessible.
- Aurzada (2008), arXiv 0711.2576: exponential weights only.
- Vysotsky (2014): positivity (persistence) of integrated walks, not small balls.

**Queries** (16, web search)
1. "small deviations integrated random walk non Gaussian increments L2 small ball probability"
2. "small deviations weighted sums iid Lifshits regularly varying small ball random series"
3. "p exponential prior small ball probability Besov posterior contraction Laplace"
4. "small ball integrated Laplace process random walk small deviation"
5. "Comparison Theorems for Small Deviations of Random Series" Gao pdf
6. "Lifshits small deviations random series independent identically distributed summands regularly varying weights 1997"
7. "\"integrated random walk\" \"small deviations\" probability"
8. "\"small deviations\" integrated random walks Laplace increments"
9. "\"Dunker\" \"Lifshits\" \"Linde\" 1998 small deviations sums independent random variables pdf"
10. "\"Comparison Theorems for Small Deviations of Random Series\" Gao Hannig Torcaso pdf journal"
11. "small deviations Laplace random walk integrated non gaussian Gaussian comparison small ball"
12. "Bayesian total variation prior contraction random walk Laplace prior posterior rates small ball"
13. "\"small deviations\" \"integrated\" \"Laplace\" random walks small ball"
14. "\"small deviation probabilities of sums of independent random variables\" Dunker Lifshits Linde pdf"
15. "\"Comparison Theorems for Small Deviations of Random Series\" site:projecteuclid.org"
16. "\"Adaptive inference over Besov spaces\" Agapiou Randrianarisoa authors"

### S5: Codex gpt-6-luna, medium effort (forward citations via OpenAlex)

**Citing records returned per seed**

| Seed | OpenAlex ID | Records |
|---|---|---:|
| Agapiou, Dashti & Helin | W2903107951 | 34 |
| Agapiou & Wang | W4226083423 | 25 |
| Giordano | W4387317067 | 12 |
| Syring & Martin | W3113099064 | 50 |
| Madrid Padilla & Chatterjee | W3109802576 | 37 |

**Candidates** (proposed by S5 despite the exclusion list)
1. Agapiou & Wang: excluded, already in Papers/. Thm 2.4, Lemma 6.3 (small ball), Lemma 6.5 (two-level concentration). S5 score 5/5.
2. Agapiou & Savva (2024): T-01 row 9. Thm 2.5, Lemma 3.3. S5 score 4/5.
3. Bhattacharya & Martin (2022, JSPI), arXiv 2002.01052: Thm 1 (root-n concentration), Thm 2 (BvM); fixed dimension. S5 score 3/5. Screened in T-01.

**Near misses**
- Tang & Yang (2022, JRSSB), exponentially tilted empirical likelihood for risk minimization
- Quantile additive trend filtering, arXiv 2310.11711 (frequentist)
- Agapiou & Castillo (2024, AoS), heavy-tailed Bayesian nonparametric adaptation

**Calls**
- OpenAlex: works?search=<title>&per-page=3 (×5); works?filter=cites:<ID>&per-page=100 (×5).
- Web queries: "OpenAlex API works filter cites documentation"; "site:api.semanticscholar.org/graph/v1/paper/arXiv 1811.12244 citations"; theorem-discovery queries for Agapiou–Savva, Tang–Yang, Bhattacharya–Martin and Agapiou–Castillo; "Laplace priors and spatial inhomogeneity ... pdf theorem"; "Rates of contraction ... p-exponential priors arxiv theorem small ball".

