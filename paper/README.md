# paper/

The manuscript "Bayesian Joint Quantile Trend Filtering via Proximal MCMC with Sequential Gibbs Sampling" (Bedoya, Li, Chi).

**Licence note.** The manuscript text (everything under `paper/`) is all rights reserved until publication. The MIT licence at the repo root covers the code only.

## Build

```sh
cd paper
latexmk -pdf main.tex        # uses ./latexmkrc;  or compile.bat on Windows (pdflatex, bibtex, pdflatex x2)
```

Needs `algpseudocode` (algorithmicx), `bbm`, `bbold` (a user texmf install is enough). `main.pdf` is tracked as the current build; the other LaTeX artifacts are git-ignored.

## Contents

| Path | What |
|---|---|
| `main.tex`, `sections/` | 11 section files (`\input`) |
| `references.bib` | the bibliography actually used (the stale `sections/references.bib` was removed after merging its 3 unique keys) |
| `figures/` | only the 15 figures that `main.tex` includes, and `make_spod_pmala_figure.R`, which draws `spod_detrended_pmala.png` and `spod_quantiles_pmala.png` from the E-18 export `engineering/E18_Air_Refit/results_a0_n/spod_curves.csv` |
| `history/` | dated edit-session notes (`*_2026MMDD/`), `noncrossing_review/`, `TODO_2026-03.txt`. Old-paper PDF snapshots were removed (they are in git history only if the history was not rewritten) |

Unreferenced figures moved: `munich_*` to `archive/munich_rent/figures/`, `cost_scaling.*`, `scal_speedup`, `scal_pmala_per_obs` to `experiments/scalability/figures_unused/`.

Where the numbers come from: `experiments/README.md` (table and figure index).
