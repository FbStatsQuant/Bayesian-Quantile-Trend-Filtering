# W-07: record sources for the App C settings table (C.6)

This file is internal; it is not cited in the paper. It records Engineering's answers from 2026-11-26, as routed by HQ.

Short names:
- **EQ** = experiments/extreme_quantiles/packages
- **MAN** = engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256

| Result | Settings | Record |
|---|---|---|
| Interior, §4.1 and App D.1 | later version (E-14, 63f2a56). b0 = 1e-3 VS, 5e-4 S. 30000/10000 sweeps. Spline-held interweaving. Target 0.5. ADMM in increment form | engineering/E14_Inner_Rerun/README.md; prox_admm_metric.cpp:123/172 at 63f2a56 |
| Extreme individual, §4.2 (τ 0.96–0.99) | Oct-7 legacy run. 10000/3000 sweeps. Target 0.55. No interweaving. b0 = 0.01 VS, 0.001 S. Increment form | EQ/Extreme_Individual/config.R:13–14; Individual_Sampler_PMALA_Augmented.R:87, 111; kernel ed607632 at MAN:1100/1152; engineering/E15_Extreme_Individual/PROVENANCE.md |
| Extreme individual, τ 0.90 and 0.93 | Oct-21 run with the same sampler and kernel hashes (run tag _10k3k_). **Its config record is missing**, so nothing more is inferred | MAN:1100/1152; E15 PROVENANCE |
| Extreme joint, §4.2 | Oct-7 run (VS and S), the table source (DEPLOYMENT_NOTES.md:13). b0 = 0.01 VS, 0.001 S. 30000/10000 sweeps. asis = TRUE. Target 0.5. Increment form. No git hash; file hashes at MAN:3929–3930 | EQ/Extreme_Joint_Sampler/config.R:12,16; EQ/Extreme_Joint_Sampler/source/Joint/prox_box_metric.cpp:23,273 |
| Extreme joint, Oct-2 run | VS only, b0 = 0.01, same code and data. **Not the table source** | experiments/joint_upper_levels/README.md |
| Growth, §4.4.2 and App E.2 | **Felipe 11-26: no refit and no script hunt.** C.6 shows only what §4.4.2 states (independent levels, Gamma(1,√G), 6000/1000); every other column gets an em dash. Nothing is taken from the joint Growth run | none |
| Scalability, §4.2 | **Felipe 11-26: no re-timing.** C.6 shows only what scalability.tex states; every other column gets an em dash. Nothing is taken from experiments/scalability/ | none |
| Air simulation (§4.3) and SPod (§4.4.1, App E.1) | being refit in E-18. **TBC** | engineering E-18 |

## Main-text alignment edits (HQ ruling 3)
- simulations.tex:19: "All other results in the paper use the sampler as described in Section 2 and Appendix C" is false: the extreme individual runs used target 0.55, no interweaving, and 10000/3000 sweeps. It is replaced by a pointer to the C.6 settings table at integration.
- No other main-text statement of the extreme-run priors or sweeps exists (checked by grep, 2026-11-26).
- data_application.tex (Growth) and scalability.tex stay as they are, apart from any pointer fixes (Felipe 11-26).
