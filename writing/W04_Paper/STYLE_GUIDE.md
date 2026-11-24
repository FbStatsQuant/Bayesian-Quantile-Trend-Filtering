# W-04 style guide: write like `literature/SBSS_unblinded.pdf`

Target voice: Felipe's Large Prior paper (SBSS, 30 pp.). Quotes below are verbatim from it, with page numbers.
Test for every sentence: could it sit on an SBSS page without standing out?

## The five rules that matter most

1. **Plain declaratives that carry a fact.** State what is done, what holds, or what a number is. No selling, no slogans, no meta-commentary.
2. **Say what a result means in words, before and after it.** One sentence before each assumption or theorem; a plain paragraph after it that begins with its name ("Assumption 1 is…", "Theorem 1 makes two assertions.").
3. **Semicolons and colons, never em-dashes.** A semicolon joins two related facts; a colon introduces the restatement or the reason. SBSS has no em-dash and no parenthetical aside longer than a few words.
4. **Report numbers first, then one sentence of interpretation.** Read the values off the table, give the range or ratio, and stop.
5. **One caveat, stated once, with its reason.** No stacked hedges and no defensive disclaimers.

## How sections and paragraphs open

- The Introduction opens on the object, then goes straight to the model: "Random series priors are among the most popular choices to construct nonparametric priors in Bayesian inference. Consider the regression model given by" (p. 2).
- A section with subsections opens with a roadmap, one clause per subsection: "Section 2.1 defines the prior. Section 2.2 introduces the sequences used by the main theorem and states three assumptions, each with a discussion of its role." (p. 4). The numerical section opens with its purpose and questions: "It addresses three questions: how … (Section 3.1), whether … (Section 3.2), and how … (Section 3.3)." (p. 13).
- Subsections open on the content, with no warm-up: "Throughout, a *dictionary* is a finite collection…" (p. 4); "We consider three periodic regression functions on [0, 1], built from rectified sines:" (p. 13); "We apply the large series prior to three publicly available series…" (p. 17).
- Paragraphs open with their subject ("The number of terms can be selected…", "Hierarchical Bayesian methods instead place a prior on J_n…") and often close with a short flat sentence: "This is the regime of all the examples below." (p. 6); "All constants are explicit." (p. 27).
- Main text uses `\section` and `\subsection` only. The one run-in head is "**Notation.**"; there are no "Data.", "Methods.", "Results." paragraph heads. Bold run-in heads appear only in the Appendix.

## Sentence length and rhythm

- Mostly 15 to 35 words, one idea each, mixed with short sentences of 6 to 12 words. Paragraphs of 4 to 8 sentences.
- Typical joints: "…; regularization is then delegated to the prior, which suppresses the terms not required…" (p. 4); "…the marginal density π_n: there is no prior on the number of terms, and hence no varying-dimensional computation." (p. 5).
- Connectives he uses: Here, Throughout, Consequently, In particular, Thus, Moreover, More generally, In short, For the same reason, that is, so, hence, whereas, while; "therefore", "instead" and "however" placed mid-sentence ("We therefore need…", "Our setting is instead nonparametric", "Posterior sampling, however, must then move…").
- Lists come in running prose with real counts ("one on the dictionary, one on the truth, and one on the prior"; "The first… The second… The third…"). Oxford comma always.

## Results, assumptions, theorems

- Lead-in in words: "We can now state the three assumptions: one on the dictionary, one on the truth, and one on the prior." (p. 6); "The main theorem states that, under the above assumptions, the posterior concentrates around f_0 at the rate ε_n and, at the same time, …" (p. 8).
- Assumptions are named and terse: "**Assumption 1** (Basis). There is a constant K > 0 such that, for every n," followed at once by "Assumption 1 is a normalization requirement: every dictionary element has empirical norm bounded by a fixed constant." (p. 6). Several conditions get "The three conditions play distinct roles. Condition (WG3) requires…" and a closing "In short, the prior must be…" (p. 7).
- Borrowed conditions are credited plainly: "The three conditions adapt conditions (3)–(5) of Wei and Ghosal (2020), stated there for high-dimensional logistic regression, with their dimension p replaced by J_n" (p. 7).
- Theorem form: "Suppose model (1), Assumptions 1–3, and the standing requirements (3) hold, and let M_n → ∞ be an arbitrary sequence. Then there exists…, depending only on (K, σ, μ, η, c_4, c_5), such that, for all sufficiently large n," display; "Consequently," display; "Moreover," display (p. 8).
- Follow-up: "Theorem 1 makes two assertions. The first, (8)–(9), concerns recovery of the function: … The second, (10), provides automatic complexity control: …" Then the proof pointer and the neighbours: "The proof, in the Appendix, follows the testing approach of…"; "Our setting is instead nonparametric: …" (pp. 8–9).
- Remarks are titled and practical: "*Remark* 2 (Practical guidance)." They admit gaps between theory and practice directly: "In our experience, scales much below 1/J_n² make the Gibbs sampler numerically unstable, so the numerical illustrations of Section 3 use larger, practical scales." (p. 12). Use this register for the λ and σ framing.

## Citations (natbib)

- `\citet` when the authors are subject or object: "van der Pas et al. (2014) established…"; "adapted from Wei and Ghosal (2020)"; "the Horseshoe of Carvalho et al. (2009)".
- `\citep` at the end of the clause it supports, lists joined by semicolons: "(Arbel et al., 2013; Shen and Ghosal, 2015)". Extras go in "see also X (year) for … and Y (year) for …".
- Pinpoints: "Shen and Ghosal (2015, Lemma 2)"; "Theorem 3.3 of Wei and Ghosal (2020)". Software: "the `horseshoe` package in `R` (van der Pas et al., 2019)".
- Past tense for what others proved ("established", "obtained", "derived", "analyzed"); present for what a method does.
- The literature is three compact paragraphs, one per strand, each ending on the limitation that motivates the paper.

## Notation

- A "**Notation.**" paragraph closes the Introduction: "We write c_n ≲ d_n, or c_n = O(d_n), if…".
- Verbs: let, write, set, put, define, denote. New terms are italicized once and then used by name ("The *effective sparsity* a_n…").
- Truth carries subscript 0 (f_0, P_0, E_0). Constants come with their dependence. "for all sufficiently large n".
- Displays are part of the sentence and punctuated. References are bare: "By (31) and (29)", "Under (2) and (3)"; never "Equation (2)". Capitalize Section, Theorem, Table, Figure, Appendix. American spelling ("behavior", "neighborhood").

## Person and tense

- "We" for the authors' choices and actions ("We take", "We use", "we call the result a large series prior"). Present tense for the paper and its results ("Figure 1 shows", "The Horseshoe has the lower error"). Passive for data generation and settings ("observations are generated on an equally spaced grid"; "The noise variance is treated as known."). "This article" in the Introduction, "This paper" in the Conclusion.

## Words and constructions

- Uses: "rather than", "whereas", "the same … throughout", "is governed by", "is driven by", "which is why", "which is what makes … possible", "need not", "as the theory predicts". Single calibrated qualifiers: "roughly", "essentially flat", "nearly the same", "These results suggest that…".
- Avoids: em-dashes; "crucially, notably, importantly, interestingly"; "novel, powerful, robust, leverage, state-of-the-art"; "It is worth noting", "Note that"; rhetorical questions; metaphors; "not only … but also"; development history ("we tried", "was examined and rejected"). Intensifiers are rare (one "sharply", one "markedly", one "greatly" in 30 pages).

## How the Introduction builds its case

1. Object and model in two sentences, then the quantity everything depends on, then a hand-off: "Several strategies for selecting J_n have been proposed; we describe them next." (p. 2).
2. One paragraph per existing strategy, ending on its cost: "Posterior sampling, however, must then move between spaces of different dimension." (p. 2); "These results motivate a large fixed set of basis functions with shrinkage on the coefficients." (p. 3).
3. Contribution paragraph: "This article combines the simplicity of … with the adaptivity of …. We take … ; we call the result a large series prior. The contributions are twofold. First, we establish … Second, we show that …" and a bridge to the numerics: "our simulations show the same dependence empirically: …" (p. 3).
4. Roadmap: "Section 2 introduces …, presents …, and derives …; the proofs are in the Appendix. Section 3 reports simulations and three real-data applications, and Section 4 concludes." Then the code link and **Notation.**
5. No results table preview and no list of numerical wins in the Introduction.

## Simulations and data results

- Design: display the test functions, one sentence on why they are what they are, then exact settings in prose: "The comparison uses n = 1000 and J_n = ⌊n^0.7⌋ = 125"; "computed from 5,000 draws after 1,000 burn-in iterations" (p. 14).
- Competitor with the reason it is the right one, and what the comparison isolates: "Both methods use the same dictionary, so the comparison isolates the effect of the prior" (p. 14).
- Results: "Figure 1 shows one realization." Then the numbers and one reading: "…the Horseshoe and ridge MSE values, multiplied by 10³, are 0.274 and 3.311 for f_1, …, so the Horseshoe error is roughly six to twelve times smaller." (p. 14). "The ridge error grows steadily with J_n, roughly doubling between J_n = 140 and J_n = 300, whereas the Horseshoe error stays essentially flat… The Horseshoe has the lower error in all 27 comparisons." (p. 15).
- Caveats are numbered and brief: "The slopes need not match the minimax exponents of Corollary 1, even for the cosine basis. First, … Second, …" (p. 17).
- Captions describe every mark and the settings and make no claims: "Gray points are the data, curves are posterior means of the mean function, and shaded bands are pointwise 95% credible bands for it." (p. 18).
- Data: "The first is … The second is … The third is …", each with source, n, and transformation. Then "Figure 2 shows the three fits. In each case the posterior mean is smooth and follows the systematic part of the series rather than its scatter: …", closing on the method: "No series required its own choice of the number of terms: …" (p. 18).

## Conclusion

Two or three paragraphs, about 250 words, no subsections, no limitations list. It restates the proposal with a colon ("This paper proposes a large series prior for Bayesian nonparametric regression: a deterministic number of basis functions growing as n^b, combined with a shrinkage prior on the coefficients."), the theorem in one or two sentences, then "The numerical results support this picture." with one sentence per experiment, and ends on one concrete next step: "A natural next step is a sampler that remains stable at the very small global scales the theory calls for, which would bring the simulations closer to the regime of Theorem 1." (p. 19).

## Abstract and Appendix

- Abstract: one paragraph, about 170 words: context, the trade-off, "We propose…", "We establish…", computation, "In simulations, …", "Three real-data applications illustrate the method."
- Appendix: opens "The Appendix is organized as follows." Each proof opens with its approach and the list of supporting lemmas. Unnumbered bold heads ("Preliminaries", "The four estimates", "Proof of the theorem from the four estimates"); named lemmas ("**Lemma 1** (Local prior mass)."); terse proof prose ("By (31) and (29), the first two terms are at most…", "which is (8).").

## AI-isms in the current BQTF paper to remove

Phrases are quoted from `paper/sections/*.tex` at commit `b19ed3c`.

- **"X, not Y" punchlines.** "so the representation changes the sampler, not the model" and "affects efficiency, not invariance" (`methodology.tex`); "nothing is smoothed, and the chain targets the stated posterior" (`introduction.tex`). SBSS uses this contrast rarely and only for a real distinction. State the fact once.
- **Slogans and metaphors.** "shows what the global penalty buys", "local adaptivity is a liability" (`discussion.tex`); "the prior acts as a smoothness dial", "rides on top of both", "the trend is the nuisance and the residual carries the signal", "Growth charts are the canonical use of quantile curves" (`data_application.tex`); "each competitor excels on the benchmark that suits it" (`introduction.tex`, repeated in `discussion.tex`).
- **Intensifiers.** "far more accurately" (`abstract.tex`); "markedly less accurate" (`simulations.tex`); "clearly outperforms", "clearly ahead", "by far the largest" (`air_simulation.tex`); "exclusively", "strictly", "cleanly", "idiosyncratically" (`data_application.tex`). Give the ratio or the numbers instead.
- **Announcing significance.** "Treating the ALD scale σ as unknown is a substantive modeling choice.", "A single global penalty is a deliberate simplification", "The computational structure is the second difference from…" (`discussion.tex`); "Bayesian-PMALA brings exact posterior sampling to quantile trend filtering while keeping…" (`discussion.tex`).
- **Defensive disclaimers.** "The comparison concerns time per sweep, not the efficiency of the chains per sweep." (`scalability.tex`); "the widths describe different posterior constructions and are not by themselves a measure of calibration" (`appendix_simulations.tex`); "the experiments do not establish a universally preferred prior or difference order" (`discussion.tex`); "although the two runs also differ in length and tuning" (`simulations.tex`). Keep one caveat with its reason, in the SBSS "First, … Second, …" form.
- **Generic discussion closer.** "Several extensions follow from the present work." followed by three items and "Finally," (`discussion.tex`). Replace with one concrete next step.
- **Overloaded sentences and paragraphs.** The "Data." and "Results." paragraphs of `data_application.tex` run 300 to 350 words with participial tails (", making this a natural quantile trend filtering problem in which, in contrast to the usual convention, …"). Split into SBSS-size paragraphs.
- **Run-in paragraph heads in the main text.** "Data.", "Methods.", "Performance measures.", "Protocol.", "Results.", "Data generation.", "Evaluation.", "Model and settings." Replace with topic sentences.
- **Development-log register.** "Why each component was needed", "was also examined and rejected", "The default was kept.", "All tests pass.", "the supplied implementation" (`appendix_pmala.tex`, `scalability.tex`, `discussion.tex`). Describe the method as it is.
- **Results preview in the Introduction and a mechanism-by-mechanism abstract.** The Introduction's sixth paragraph lists numerical wins, and the abstract is two paragraphs (about 330 words) of algorithmic detail. SBSS does neither.
- **Mixed spelling.** "neighbours", "centre", "favours", "analysed" next to "center", "analyze". Use American throughout.
