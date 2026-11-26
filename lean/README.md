# Lean formalization (in progress)

This folder holds the Lean 4 + Mathlib formalization of the paper's two posterior-contraction theorems:
- **Theorem 1**, `thm:main`: a single quantile level.
- **Theorem 2**, `thm:joint`: non-crossing quantile levels jointly.

The work is under way. **Theorem 1 comes first.** [`PLAN.md`](PLAN.md) has the module plan, the risks, and the list of classical inputs that are still hypotheses.

All Lean work lives in this folder and nowhere else in the repository.

## Build

You need [elan](https://github.com/leanprover/elan). It installs the toolchain pinned in `lean-toolchain`, `leanprover/lean4:v4.35.0-rc2`. Mathlib is pinned in `lake-manifest.json` to the same revision as the Large Prior formalization.

```sh
cd lean
lake exe cache get   # prebuilt Mathlib (never build Mathlib from source)
lake build
```

On Owls, every build goes through `~/.config/bvs-hq/owls/owls_run`. See `~/.config/bvs-hq/owls/POLICY.md`.

## Layout

```
lean/
├── README.md            this map
├── PLAN.md              module plan, lemma → module map, risks, classical inputs still assumed, estimates
├── BQTF.lean            imports every module
├── BQTF/
│   └── Spec.lean        definitions and the main statements (MainStatement, MainStatementScale)
├── docs/
│   └── statements.md    the statements in plain mathematics, and the differences from the paper
├── notes/
│   ├── audits/          Astra statement-fidelity audits (spec_<thm>_astra_r<k>.md)
│   ├── reviews/         Sol code reviews, one per module merge (<module>_<date>.md)
│   └── logs/            build logs and status lines worth keeping
├── lakefile.toml, lake-manifest.json, lean-toolchain
└── .gitignore           .lake/ and build output
```

These will be added when they exist:
- `AxiomCheck.lean`, which pins each main theorem to its `Spec` type and prints its axioms;
- `SHA256SUMS.txt`;
- the proof modules listed in `PLAN.md`.
