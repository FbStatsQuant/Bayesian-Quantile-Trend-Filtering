# CP-Opus2 progress: Ledoux–Talagrand contraction (`BQTF.Prob.contraction_abs`)

## 2026-11-25
- Setup: `.lake/packages` symlinked to the main checkout; `.lake/build` copied with `cp -a`.
- `BQTF/Prob/Contraction/Cube.lean`: `signCube n = {−1,1}ⁿ`;
  `rademacher_eq_sum_dirac` (via `Measure.pi_eq` + `Finset.prod_univ_sum`);
  `integral_rademacher`: `∫ g ∂(rademacher n) = 2^{−n} ∑_{ε ∈ cube} g ε` for EVERY `g`
  (finite sum of Diracs, `integrable_dirac`; no measurability hypothesis).
- `BQTF/Prob/Contraction/Compare.lean`: two-point inequality `sup'_add_sup'_sub_le`;
  coordinate flip `flipAt` (an involution of the cube); one step `cubeSup_le_update`
  (replace a 1-Lipschitz `ψ_k` by `id`); `cubeSup_comparison` (all coordinates, by
  `Finset.induction_on`). One-sided version needs no `φ(0) = 0`.
- `BQTF/Prob/Contraction.lean`: `contraction_abs`, frozen statement unchanged. Route:
  `T₀ = insert 0 T`; `max_T |X| ≤ max_{T₀} X + max_{T₀}(−X)`; `ε ↦ −ε` on the cube;
  comparison; `max_{T₀}⟨ε,·⟩ = max_T⟨ε,·⟩` by symmetry of `T`.
- Build: `owls_run -j 3 -- lake build BQTF.Prob.Contraction` passes, no warnings.
- Axioms: `[propext, Classical.choice, Quot.sound]`. No sorry/admit/axiom/native_decide.
- `BQTF.lean`: added `import BQTF.Prob.Contraction`.
