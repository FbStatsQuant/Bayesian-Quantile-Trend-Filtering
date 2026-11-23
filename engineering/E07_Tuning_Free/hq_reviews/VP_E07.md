# VP review: E-07 proposal and the σ question

*VP to HQ, for Felipe, 2026-11-23. Independent of Astra. Read: the brief, `PROPOSAL.md`, both advisor memos, `sampler/e07_sampler.R`, `e07_banded.cpp`, statements §3–§4.5, the E-05 report, and the paper's methodology and discussion. One local check (11 log-concave laws × 6 levels, seconds of CPU). Notation: σ₀ = the scale the IG update learns (mean check loss); σ̄ = τ(1−τ)/f_min = the smallest scale the proofs allow; R = σ̄/σ₀.*

## Verdicts
1. **Items 1, 3, 4 and 5 are correct. Adopt them**, with the fixes below.
2. **Item 2 is correct, but it is not P-MALA, and neither is the hybrid.** It is the standard Gibbs draw. Felipe should decide this on the substance, not on the label.
3. **σ: use Option F.** Fix σ at an estimate of σ̄ and learn λ. If Felipe wants to keep a σ | θ step, write F as a prior truncated below at that estimate; the results are the same.
4. **"Option P coherent with the proofs" does not exist as a smooth prior.** Coherence needs the prior's *support* to sit inside the proved range, and that needs an estimate of σ̄. That is Option F under another name.
5. **Keep the learned-σ fit as a second, clearly labelled arm.** It gives better point estimates on rough signals. It is outside the theorems, and its bands are too narrow at outer quantile levels, which the paper's discussion already admits.

## A. Items 1–5
| Item | Correct? | Right choice? | Risk or fix |
|---|---|---|---|
| **1. Collapsed (λ, θ) block** | Yes. I re-derived the density, including the λ^m factor and the log-scale Jacobian, and checked the code line against it. The sweep order is valid: every latent is redrawn before it is conditioned on | Yes | The log-determinant path is untested above n = 2k, where λ² reaches 10¹⁶–10²². Add one n = 8k cell to G0 |
| **2. Exact-metric θ move** | Yes. The midpoint Langevin step has r = (1 − h/2)/(1 + h/2) and innovation variance (1 − r²)P⁻¹, so it is reversible with acceptance 1, and h = 2 is an independent draw | Yes, as a sampler | See the label problem below |
| **3. λ ~ Gamma(2, s_y·n^(−5/2))** | Yes. Units and the √20 are right | Yes | At n = 500 the rate is about 5×10⁻⁸, against ‖Dθ‖₁ ≥ 6×10⁻⁴. So the prior is effectively flat, and the choice of c, a₀ or s_y (Fable against Astra) cannot matter. Its real content is the n^(−5/2) scaling |
| **4. The nats claim** | Yes: 46.3, 140.7 and 525.6 recomputed | — | The wording is too strong. A prior worth about n observations, such as IG(κn, κn·σ_ref), does move σ. But it needs σ̄ as input, so the conclusion stands |
| **5. Auto-stop** | The rule is sound | Yes | Four fixes below |

**Item 2, the label.**
- The paper defines P-MALA as Pereyra's *proximal* move: Moreau envelope, ADMM, accept/reject. Item 2 has none of these. It augments the Laplace prior, as the Bayesian lasso does, and draws θ from the resulting Gaussian. The Langevin reading is true and worth one remark; a referee will not accept it as P-MALA.
- **The hybrid does not rescue the label.** Item 1 must redraw θ exactly in every sweep, so the hybrid's P-MALA move is extra work on top of a Gibbs sampler.
- **The real conflict:** a sampler with no exact θ draw cannot run the theory's λ prior (E-05). So "P-MALA-like θ move" and "theory informs the algorithm" cannot both hold for the individual sampler.
- **My recommendation:** adopt items 1 and 2 for the individual sampler and call it an augmented Gibbs sampler. Keep P-MALA where it is needed: the non-crossing joint sampler, whose box-constrained conditional has no exact banded draw. The paper's sentence "U is not differentiable, so we sample this block by P-MALA" invites the question "why not augment the prior?", and E-02's 135–6400× answer is already in the repo.

**Item 5, fixes.**
- The code's ESS is a sum of per-chain ESS values, not the multi-chain bulk ESS it cites. Use the `posterior` package.
- Add tail ESS ≥ 400 on the θ monitors, because the product is a 95% band.
- All four chains start at θ = y. Start two from the quadratic fit instead, since the E-05 trap is in θ, not in λ.
- G3's "every estimate within 0.1 posterior sd" will fail by chance (0.1 sd is about 2 Monte Carlo errors at ESS 400). Use a pass rate.
- Minor: on runs over 8k sweeps the stored θ draws cover a later, shorter window than the one the rule certified.

## B. σ
**Option F, my rule.**
- **Simulation:** σ = 1.1σ̄ from the known law, as proposed.
- **Data:** σ̂_F = 2·τ(1−τ)·maxᵤ ŝ(u), Engineering's estimator, with two additions. Both hold for log-concave noise, the same class P1 covers, and both passed in all 66 cases of my check.
  - **No abstention.** If level τ cannot be estimated, estimate at the nearest level p that can, and scale: σ̄(τ) ≤ (τ/p)·σ̄(p) above the median, and ((1−τ)/(1−p))·σ̄(p) below it. From p = 0.9 to τ = 0.99 this overshoots by 1.0–1.6× on seven unbounded laws. Falling back to learned σ, as proposed, silently leaves the proved range.
  - **A cap.** σ̄ ≤ √3·max(τ, 1−τ)·sd(noise). It needs only a noise scale, it bounds the noisy maximum, and it supplies the upper end of P2's interval. It is too loose to be the rule itself (up to 33× on the short side of skewed laws).

**What can be claimed.**
| Setting | Claim | Depends on |
|---|---|---|
| Simulation, σ = 1.1σ̄, λ fixed | Theorem B as proved | P1; without it only a much larger σ is covered |
| Same, λ learned | Rate n^(−5/6), V unknown | P1 and P3 |
| Data, plug-in σ̂_F, λ learned | Same rate | P1, plus P2 and P3 proved *jointly* (see below), plus σ̂_F landing in the interval |
| Learned σ, any smooth prior | Nothing | Targets 1 and 3, not started |

- **The plug-in needs no sample splitting.** If the bound is uniform over an interval I, then for any data-chosen σ̂: E Π_σ̂(bad) ≤ E sup over I of Π_σ(bad) + P(σ̂ ∉ I). The second term is a stated condition, supported by G2's hit rates.
- **Ask Theory now:** Tuesday's learned-λ theorem should carry the supremum over σ in I, and over the constant c in the λ prior, inside the expectation. The Tuesday list has P2 with λ fixed and P3 with σ fixed. The algorithm as run needs both at once, and s_y makes c data-dependent.
- **If P2 fails:** estimate σ̂ on odd points and fit on even points. Cost: half the data in the fit.
- **Heteroscedastic noise.** One σ must cover the worst location, so take the maximum over u. The cost is bands wider than needed where the noise is small (up to 2× in σ for the Gaussian design, 10× for Beta). A location-dependent σ is a different model with no theorem; leave it as future work.

**Option P.**
- **The only coherent form:** IG(0.1, 0.1·s_y) truncated to [σ̂_F, cap]. P2 covers it by the mixture argument. For log-concave noise the posterior sits within about 0.5% of σ̂_F.
- **Is piling up at the bound acceptable?** Yes. Desirable? Only slightly: it keeps the σ | θ step, and σ rises on its own if the data are more dispersed than σ̂_F implies. The paper must say plainly that σ acts as a fixed temperature.
- **Hyperparameters that depend on τ alone cannot do it.** R depends on the noise law: 1 for an asymmetric Laplace law, 1.57 for Gaussian at the median, 2 for uniform at every level, 14–21 at τ = 0.99.

## C. Referee answer: "why is σ learned at all?"
The asymmetric Laplace density is a working likelihood, so σ is not a noise scale. It is the temperature of the posterior exp{−Q(θ)/σ}, in the sense of general Bayesian updating (Bissiri, Holmes and Walker, 2016). Learning it has three uses. The procedure becomes scale-free, with no temperature for the user to set. The conjugate update targets σ₀, the expected check loss, which is the scale that best fits the working family. And because the conditional mode depends only on λσ, point estimates are nearly insensitive to how the pair is split. This is common practice (Kozumi and Kobayashi, 2011), and posterior consistency under this misspecification is known for linear quantile regression (Sriram, Ramamoorthi and Ghosh, 2013).

The cost is that σ₀ is not the scale at which the posterior's spread is right. The spread grows with σ, while the sampling variability of the centre is τ(1−τ)/f, and the two agree at σ̄ = τ(1−τ)/f (compare the variance correction of Yang, Wang and He, 2016, and the calibrated learning rates of Syring and Martin, 2019). For log-concave noise σ₀ ≤ σ̄, with equality only when the working family is true; in our designs the ratio is 1.6–6.7, and it reaches about 20 at τ = 0.99. So the learned scale gives intervals that are too narrow, increasingly at outer levels, and it lies outside our theorems. We therefore fix σ at an estimate of σ̄ and learn only λ, which is the setting of the theorem, and we report the learned-σ fit beside it: the same contraction slopes, better point estimates on rough signals, lower coverage in the tails.

## D. Recommendation
1. **Paper and software default: Option F**, items 1–3 and 5, plug-in with extrapolation and cap. Use the truncated-prior form only if Felipe wants the σ | θ step kept.
2. **Second arm in every table, and a software option: learned σ**, labelled as above.
3. **Rejected:** informative smooth priors and τ-only rules.
4. **Re-run the paper's tables under the new λ default once G1 passes.** Engineering suggests keeping the old runs. I disagree: the statements file calls the per-signal b₀ "tuning by hand", and Felipe's rule is that the method must match the theorem.
5. **Joint sampler at extreme levels:** no theorem covers it under either option. Decide from G1's τ = 0.95 and 0.99 cells.

**What E-07 must measure.**
- F against learned σ on the same data, 10 seeds: MSE of the posterior mean, band coverage and width, by τ. Report λσ per arm.
- Whether F's loss equals the predicted constant (σ_F/σ₀)^(5/6).
- G2 with the real pilot, including the extrapolation and the cap: P(σ̂_F ≥ 1.1σ̄), σ̂_F/σ̄, and plug-in against oracle accuracy.
- One cell showing that the truncated prior and fixed σ give the same fit.

**Main risk.** F costs point accuracy by design. The model reads the larger σ as more noise and smooths more: on VS, λσ rose 4–35× and MSE 2.4–2.7× on one seed. The cost grows with R, so it is largest at the outer levels the paper cares about.

**What would change my mind.**
- G1 showing F more than 2× worse in MSE in most cells, or losing to the paper's competitors. Then make learned σ the default, state the gap, and offer F as the calibrated mode.
- P1 failing on Tuesday. Then even the oracle 1.1σ̄ is uncovered, and F loses its main reason.

## Not verified
- **Rate constant under F.** The (σ_F/σ₀)^(5/6) prediction and the statement that the best λ does not depend on σ come from the Target 1 formula, which is a target, not a theorem. It predicts 2.2× at VS, τ = 0.5 (measured 2.4×) and 5.3× at τ = 0.95 (measured 2.7×).
- **The two bounds in B.** Checked numerically (script: `/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/74e5bc3d-f2c3-4e8f-b7f6-5eb4ee37e444/scratchpad/vp_check.py`, temporary) and derived from the concavity Engineering already verified. The cap also uses Bobkov's inequality f(median)²·Var ≥ 1/12 for log-concave laws, quoted from memory. Theory should confirm both.
- **All Engineering numbers:** the speed gains, the one-seed accuracy table, the plug-in hit rates and c = 2. I re-ran none of them.
- **The joint sampler has no exact banded draw:** my judgment, not tested.
- **Literature.** I am confident the five cited papers exist. I am not certain how Sriram et al. treat σ, nor of the exact form of the Yang–Wang–He correction.
- **P1, P2, P3** are pending with Theory. Every claim in B's table rests on them as marked.
