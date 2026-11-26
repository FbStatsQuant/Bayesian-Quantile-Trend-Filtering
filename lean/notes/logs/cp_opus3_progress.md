# CP-Opus3 progress log — Eckart–Young tail (BQTF.Lin.EckartYoung)

## 2026-11-25
- Read owls POLICY.md; symlinked lean/.lake/packages -> main checkout packages (no cache get / update / clean).
- Statement frozen as briefed (`BQTF.Lin.eckartYoung_tail`); not changed. `#check` confirms the signature.
- Route (single file, no helper folder needed):
  1. `EckartYoung.frob_eq_adjoint`: Σ_i ‖S b_i‖² = Σ_j ‖S† c_j‖² (Parseval twice + adjoint swap).
  2. `EckartYoung.orthonormal_sum_le`: for any orthonormal family u, Σ_k ‖S u_k‖² ≤ Σ_i ‖S b_i‖²
     (pass to adjoint, Bessel `Orthonormal.sum_inner_products_le`).
  3. `EckartYoung.norm_sq_eq_sum_eigen`: ‖T x‖² = Σ_q λ_q ⟪v_q, x⟫², v = eigenvectorBasis of T†T.
  4. `EckartYoung.weighted_tail_le`: f antitone, ≥ 0, W ∈ [0,1], Σ W ≥ d − J ⇒ Σ_{Ico J d} f ≤ Σ_{range d} f·W
     (threshold c = f J).
  5. Main: u = ONB of ker H (stdOrthonormalBasis), (T−H)u_k = T u_k; weights w_q = Σ_k ⟪v_q,u_k⟫² ∈ [0,1],
     Σ w = dim ker H ≥ d − J by rank–nullity; λ_q = σ_q² via `sq_singularValues_fin`.
- Build: `owls_run -j 3 -- lake build BQTF.Lin.EckartYoung` ✔ (8931 jobs). No guard pause.
- Axioms (`lake env lean /tmp/cp_opus3_axioms.lean` via owls_run): [propext, Classical.choice, Quot.sound].
- Added `import BQTF.Lin.EckartYoung` to lean/BQTF.lean (full BQTF root not rebuilt).
