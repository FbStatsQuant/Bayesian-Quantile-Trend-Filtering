BQTF HQ -> advisor: independent review of Engineering's E-07 proposal and the σ question. Felipe (the owner) wants your own take before he decides. Repo: /home/fb31/Bayesian-Quantile-Trend-Filtering (Owls machine). Read-only except for your one output file.

CONTEXT
- Method: Bayesian quantile trend filtering. ALD working likelihood with scale σ; Laplace prior on D^(k+1)θ (paper default k=2, i.e. third differences); λ ~ Gamma; σ ~ IG. Gibbs structure: θ | rest by a P-MALA-like move, then λ | θ and σ | θ.
- Felipe's non-negotiables: keep the overall Gibbs structure, a P-MALA-like θ move, and λ|θ, σ|θ updates. The method should be as tuning-free as possible. k=2 is the default. σ hyperparameters may depend on τ. The theory should inform the algorithm.
- Theory status: Theorem B (light tails, condition EM) is proved for FIXED λ and FIXED σ, with σ above the threshold σ̄ = τ(1−τ)/f_min (f_min = smallest noise density at the true quantile). Rate n^(−5/6) at λ ≍ n^(5/2)/V.
  Tuesday's targets:
  - learned λ under Gamma(a0, c·n^(−5/2)) with σ fixed;
  - B uniform in σ over a compact interval (claim P2);
  - P1: log-concave noise ⇒ EM for all σ > σ̄;
  - Theorem A (moment-free) for general k;
  - stretch: any fixed σ (A+), and learned σ.
  See writing/W01_Statements/statements.tex / statements.pdf (§3 assumptions, §4 theorems, §4.5 σ, the P1–P7 box, the Targets box).
- Known fact: for log-concave noise (all three paper noise families), the learned σ₀ (≈ expected check loss) is always ≤ σ̄. So the IG-learned σ is never in the proved range.
- Empirics:
  - E-06 (engineering/E06_Rate_Validation/, tables/ and figs/) confirms the n^(−5/6) slope; the σ₀ arm gives the same slopes as 1.1σ̄.
  - E-05 (engineering/E05_PMALA_Fix/REPORT.md) shows P-MALA collapses λ when started at θ = y.

WHAT TO REVIEW: engineering/E07_Tuning_Free/PROPOSAL.md (commit 6fb245a), and its advisors/ memos for background. Its ranked proposals:
1. Collapsed (λ, θ) Gibbs block replacing ASIS: slice-sample log λ with θ integrated out.
2. θ move in the exact conditional metric W + D'diag(1/s)D (banded), preconditioned Langevin at h=2, accepted w.p. 1.
3. One scale-free λ prior Gamma(2, s_y·n^(−5/2)), s_y = MAD of D³y, replacing the per-signal b0.
4. σ, two options:
   - P: IG(0.1, 0.1·s_y). Engineering claims no smooth prior moves σ (the likelihood beats the prior by 46–525 nats), so P ≈ σ₀.
   - F: σ fixed; 1.1σ̄ in simulation, and for data the plug-in 2·τ(1−τ)·max ŝ(u), with abstention at sparse tails.
5. Auto-stop: 4 chains, split-R̂ ≤ 1.01, ESS ≥ 400.

QUESTIONS
(A) For each of items 1–5: is it correct, is it the right choice, and what are the risks? Check the math where you can: exactness of the collapsed block, the h=2 / acceptance-1 claim, the n^(−5/2) scaling and units of s_y, the 46–525 nats claim, and the auto-stop rule.
    Is item 2 still "P-MALA-like" in a sense Felipe can defend, or should the fallback be used (keep the paper's P-MALA move, replace only ASIS with item 1)?
(B) σ, the central question. Felipe accepts either option in the actual algorithm:
    - Option P: a σ prior, but COHERENT with the σ in the proofs;
    - Option F: σ fixed in harmony with the theory, λ learned. This is exactly the Tuesday theorem setting.
    For each option give:
    - your recommended concrete rule (prior family and hyperparameters, or fixed-σ constant and plug-in estimator), tuning-free and possibly τ-dependent;
    - exactly what can be CLAIMED theoretically, and what depends on P1/P2 or other pending results;
    - for a data-driven plug-in, what covers it when the theorem assumes a deterministic σ (P2 plus landing in the interval w.h.p., sample splitting, ...);
    - how heteroscedasticity is handled, given that σ̄ uses f_min;
    - whether a truncated prior (posterior piling at σ_lo) is acceptable or even desirable.
    If smooth priors really cannot move σ, say plainly what "coherent with the proofs" then requires.
(C) Referee question: "why is σ learned at all?" Give a two-paragraph answer a referee would accept, honest about the costs. Points to weigh:
    - the ALD is a working likelihood, so σ is a temperature, not a noise scale;
    - the IG update targets σ₀, the KL-optimal scale;
    - only Λ = λσ sets the mode;
    - Bayesian QR practice.
    Cite literature only if you are confident it exists (e.g. Sriram–Ramamoorthi–Ghosh 2013; Yang–Wang–He 2016; Syring–Martin 2019), and flag uncertainty.
(D) Your overall recommendation: which option(s) the paper and the software should adopt, ranked, and what E-07 must measure to settle it.

OUTPUT: write a concise memo (max ~2 pages) to the path given below. Lead with verdicts. Put every claim you could not verify under a "Not verified" heading. Do not edit any other file, do not commit, do not touch NOTS or run heavy compute (small local R/Python checks are fine). Reply with a 5–8 line summary when done.
