# Writing notes for the common λ-prior rate

The updated individual simulation fits use `b0 = 1e-3` for both VS and S.
The interior VS entries come from E-14. The interior S entries come from
E-14b. Both extreme individual rows come from E-15. The extreme joint
and competitor rows retain their published provenance.

| Manuscript location | Update after the reruns |
| --- | --- |
| [Section 4.1, interior methods](../../paper/sections/simulations.tex#L19) | Replace the signal-specific rates with λ ∼ Gamma(1, 10⁻³) for both signals. Extend the scope of the sampler updates to the extreme individual fits. |
| [Extreme quantiles, methods](../../paper/sections/simulations.tex#L92) | State the same individual prior for both signals, 30,000 sweeps and 10,000 burn-in, and cite Appendix C.9. |
| [Appendix C.9 heading](../../paper/sections/appendix_pmala.tex#L167) and [opening scope](../../paper/sections/appendix_pmala.tex#L170) | Include the interior and extreme individual simulations. Keep acceptance, ESS, safeguard and warm-up counts tied to their measured run groups. |
| [Appendix C, Rate of the Gamma prior](../../paper/sections/appendix_pmala.tex#L191) | State the updated default as b0 = 10⁻³. Replace the obsolete interior signal-specific rates. Label the b0 = 10⁻⁴ sensitivity as an old-sampler comparison against its 10⁻² default, or omit it. If retaining the probability illustration for the new default, Gamma(1, 10⁻³) gives P(λ > 100) = exp(−0.1) ≈ 0.90. |

The E-13a phase-2 screen used one VS Gaussian dataset at n = 500 with
four quantiles and two chains per setting. The corrected sampler showed
no collapse at any tested rate in {10⁻⁵, 10⁻⁴, 10⁻³}. For the individual
references using the fixed spline move, raising b0 from 10⁻⁵ to 10⁻³
lowered λ by 5–11% with no observed MSE change in the screen.
[E-13a design](../E13_Joint_b0/e13b_run.R#L2) ·
[Screen rows](../E13_Joint_b0/README.md#L43) ·
[Prior pull](../E13_Joint_b0/README.md#L59) ·
[Stability conclusion](../E13_Joint_b0/README.md#L64)

Refresh the numerical claims after GO using the generated claim lists.
The interior result prose is at [simulations.tex line 56](../../paper/sections/simulations.tex#L56)
and [appendix_simulations.tex line 78](../../paper/sections/appendix_simulations.tex#L78).
The extreme rankings and crossing sentence start at
[simulations.tex line 94](../../paper/sections/simulations.tex#L94).
