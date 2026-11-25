# Extreme-upper-quantile manuscript claims

Rankings and ties use the four displayed MSE decimals. The advantage is measured relative to the smallest competing MSE in the same cell. Crossing summaries use the displayed two decimals.

| Claim | Published | Recomputed |
| --- | --- | --- |
| VS Gaussian/mixed normal from τ = 0.93, joint MSE strictly smallest | 10/10 | Pending production build |
| VS Gaussian/mixed normal from τ = 0.93, nearest competitor MSE divided by joint MSE as τ increases | Normal 1.01× to 1.36× (strictly increasing). Mixed 1.03× to 1.71× (strictly increasing) | Pending production build |
| VS mixed normal at τ = 0.99, joint advantage and reference MSEs | Joint 0.1240, individual 0.2458, horseshoe 0.2123, ADMM 0.2980 | Pending production build |
| VS Gaussian/mixed normal at τ = 0.90, MSE winners | Mixed laplace. Normal laplace and horseshoe | Pending production build |
| VS Beta at τ = 0.90 through 0.98, horseshoe MSE strictly smallest | 5/5 | Pending production build |
| VS Beta at τ = 0.99, MSE winners | joint and individual smallest (joint 0.0132, individual 0.0132) | Pending production build |
| S Beta/Gaussian, ADMM MSE strictly smallest | 12/12 | Pending production build |
| S Beta/Gaussian, ADMM smallest and joint second | 12/12 | Pending production build |
| S mixed normal, MSE endpoints at τ = 0.90 and 0.99 | ADMM 0.0158 to 0.2911, joint 0.0280 to 0.0940, individual 0.0485 to 0.2324 | Pending production build |
| S mixed normal, levels where joint MSE is strictly smallest | 0.97, 0.98, 0.99 | Pending production build |
| Both signals, joint MSE strictly below individual MSE | 34/36 (exceptions: VS Normal 0.90, VS Beta 0.99) | Pending production build |
| VS Gaussian at τ = 0.90, joint and individual MSE | Joint 0.0135, individual 0.0134 | Pending production build |
| VS Beta at τ = 0.99, joint and individual MSE | Joint 0.0132, individual 0.0132 | Pending production build |
| Crossings among adjacent reported levels, individual versus joint | Positive in 6/6 individual, 6/6 Laplace, 6/6 horseshoe, and 6/6 ADMM signal/noise groups. Joint has zero in 24/24 neighboring cells | Pending production build |
| Appendix VS neighboring individual counts | 12/12 positive (mean counts 23.82–248.75) | Pending production build |
| Appendix VS total individual counts | 12/12 positive (mean counts 42.99–285.81) | Pending production build |
| Appendix S neighboring individual counts | 12/12 positive (mean counts 28.04–225.52) | Pending production build |
| Appendix S total individual counts | 12/12 positive (mean counts 49.51–274.88) | Pending production build |

The comparison covers the prose around the extreme MSE and crossing tables. The design still fits six levels separately for the individual sampler and counts crossings only among 0.96–0.99. The appendix counts index-level inversions, adds the specified pair counts, and averages over paired data seeds. All 48 joint crossing entries remain zero.

Appendix C.9 must extend the updated-sampler scope to the extreme individual runs and describe their run settings. Check the opening sentence at [appendix_pmala.tex](../../paper/sections/appendix_pmala.tex#L170).

[Extreme MSE prose](../../paper/sections/simulations.tex#L92) · [Crossing definition](../../paper/sections/appendix_simulations.tex#L144)
