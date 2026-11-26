# CP-Opus1 progress

- 2026-11-25: read POLICY.md; symlinked .lake/packages; drafted BQTF/Prob/EfronStein.lean (induction via Fin.cons split, law of total variance, 1-d identity, Jensen, resampling null-set lemma via lmarginal).
- 2026-11-25: fixed first-build errors (lemma names, Pi.sub coercions, explicit measurability via F).
  `owls_run -j 3 -- lake build BQTF.Prob.EfronStein`: Build completed successfully, no warnings.
  `#print axioms BQTF.Prob.efronStein_oneSided`: [propext, Classical.choice, Quot.sound].
  Frozen statement unchanged. Added `import BQTF.Prob.EfronStein` to BQTF.lean.
  Exposed helper lemmas (namespace BQTF.Prob): lintegral_sq_sub_const, evariance_le_lintegral_posPart_sq,
  ofReal_posPart_sq_integral_le, evariance_comp_measurePreserving, evariance_prod_eq (law of total
  variance on ν.prod π), lintegral_lintegral_update, ae_ae_update, efronStein_oneSided_aux.
  Two-sided form NOT exposed (optional per brief; the one-sided proof does not go through it).
