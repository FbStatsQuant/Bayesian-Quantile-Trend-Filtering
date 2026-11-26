# Lean formalization

*Theorem 1 · Theorem 2*

This folder contains machine-checked proofs, in Lean 4 with Mathlib, of the paper's two posterior-contraction theorems:

- **Theorem 1** (`thm:main`): posterior contraction of Bayesian quantile trend filtering at a single quantile level, at the unit scale and at any fixed scale σ₀.
- **Theorem 2** (`thm:joint`): joint contraction of the non-crossing posterior over a grid of quantile levels, again at unit and at general scales.

Everything is proved: there is no `sorry`, and the only axioms are Lean's standard three (`propext`, `Classical.choice`, `Quot.sound`). No classical result enters as a hypothesis. The Efron–Stein inequality (one-sided form), the Eckart–Young tail bound and the Prékopa–Leindler inequality are all proved here.

## Build and check

You need [elan](https://github.com/leanprover/elan). It installs the toolchain pinned in `lean-toolchain` (`leanprover/lean4:v4.35.0-rc2`). Mathlib is pinned in `lake-manifest.json`, at the same revision as the Large Prior formalization.

```sh
cd lean
lake exe cache get              # prebuilt Mathlib; without it Mathlib compiles for hours
lake build                      # ends with "Build completed successfully"
lake env lean AxiomCheck.lean   # prints the axioms each main theorem uses
```

[`AxiomCheck.lean`](AxiomCheck.lean) does two things:

- Lines like `example : MainStatement := main_theorem` compile only if the theorem has exactly the stated type.
- The `#print axioms` lines should all read `[propext, Classical.choice, Quot.sound]`.

`SHA256SUMS.txt` lists the hashes of the Lean sources, so you can confirm they are the ones we checked (`sha256sum -c SHA256SUMS.txt`).

## Where the statements are

| Paper | Lean statement | Proved by |
|---|---|---|
| Theorem 1, unit scale (σ = 1) | `MainStatement` | `main_theorem` (`BQTF/Main.lean`) |
| Theorem 1, general scale σ₀ | `MainStatementScale` | `main_theorem_scale` (`BQTF/Reduction.lean`) |
| Theorem 2, unit scales | `JointStatement` | `joint_theorem` (`BQTF/Joint/Main.lean`) |
| Theorem 2, general scales σ₀ₗ | `JointStatementScale` | `joint_theorem_scale` (`BQTF/Joint/Main.lean`) |

The statements are collected in [`BQTF/Spec.lean`](BQTF/Spec.lean). [`docs/statements.md`](docs/statements.md) explains each one in plain mathematics, so you can compare it with the paper without reading Lean.

## Differences from the paper

Both theorems have the paper's hypotheses and conclusions. [`docs/statements.md`](docs/statements.md) §4 lists every difference, D1–D12, with its direction. In short:

- **Equivalent reformulations.** Assumptions A and B are stated coordinatewise (D1). θ* is any τ-quantile, which is unique under A and B (D2). The posterior is written with its normalizer, and its properness is proved (D4). The joint posterior cancels the per-level normalizers (D5). "max_j" in the loss event is written "∃ j" (D9).
- **Safe additions to the conclusions.** Measurability of y ↦ Π(B | y) and of y ↦ Π_𝒞(B | y) is proved as part of the conclusion (D3, D8). Without it the expectations in the theorems would only be lower integrals.
- **Safe generalizations.** In Theorem 2, the dependence on the smallest level spacing is encoded as a lower bound gmin > 0 on the spacings (D6). The number of levels J ranges over all of ℕ (D7).
- **Intermediate lemmas.**
  - Some constants that the paper gives explicitly are existential in Lean: C_E in Lemma evid, C_pr in Proposition prior, and the quad-shift coefficient (D10).
  - Lemma gap is `level_gap_of_assB`, which needs Assumption B only, with the pairwise core `quantile_gap` (D11).
  - Lemma sup is proved on the paper's named event Ω_G ∩ Ω_E, as `supNorm_concentration_events`. The joint proof uses its existential-event wrapper, `supNorm_concentration` (D12).

  These do not affect the two theorems, whose constants are existential in the paper too.

  D10 makes the Lean coefficients of the appendix denominator and prior-mass bound weaker than the paper's standalone lemmas, which give them explicitly. They are still sufficient for Theorems 1 and 2, as the independent final audit confirms ([`notes/reviews/FINAL_AUDIT_astra.md`](notes/reviews/FINAL_AUDIT_astra.md)). The audit found the same for D12. Since then, the named-event version `supNorm_concentration_events` has been added, so Lemma sup now matches the paper.

Formalizing found eleven places where the paper's proofs needed a fix: missing cases, unstated side conditions, or a wrong intermediate claim. None changes a theorem statement or a rate. They are listed in [`notes/PAPER_CORRECTIONS.md`](notes/PAPER_CORRECTIONS.md), with the Lean declaration that settles each one.

## Files

```
lean/
├── BQTF/                  the development (Spec.lean holds the statements; Joint/ is Theorem 2)
├── BQTF.lean              imports every module
├── AxiomCheck.lean        type and axiom checks for the main results
├── docs/statements.md     the statements in plain mathematics, and the differences from the paper
├── notes/                 statement audits, per-module code reviews, paper corrections, work logs
├── PLAN.md                the module plan the formalization followed
├── lakefile.toml, lake-manifest.json, lean-toolchain
└── SHA256SUMS.txt
```
