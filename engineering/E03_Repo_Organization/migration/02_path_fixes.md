# E-03 path fixes (PREPARED, NOT APPLIED)

Applies after `01_moves.sh` and **before** the smoke tests, as separate commits, one per row group, reviewed by the Engineering head. Moves and edits stay in separate commits so `git log --follow` works.

Conventions
- "File" is the **new** path. Line numbers are the current ones (moves do not change them); they were taken from the tree of 2026-11-22. The E-02/E-04 files are still being edited by Engineering, so re-derive their line numbers at window time with the command in section F.
- `old` -> `new` is the exact text. Sections A to E are the rows of PROPOSAL §6b, in the same order, as amended by HQ (Applications kept as-is: only the Growth kernel path is fixed). Section G lists couplings that §6b does not cover.
- Frozen NOTS packages under `experiments/` are **never** edited (SHA256SUMS).

Suggested commits (after the `E-03:` prefix):
1. `joint include path` (A), 2. `individual/admm fallback strings` (B, G1), 3. `growth kernel path` (C), 4. `windows and old-layout paths` (D), 5. `tex evidence comment` (E), 6. `engineering default paths` (F), 7. `air-sim driver finds the sampler` (G2).

---

## A. Joint sampler -> `../Individual/` becomes `../individual/`

File: `method/joint/Joint_Sampler_PMALA_Augmented.R`

| Line | Old | New |
|---|---|---|
| 58 | `individual_dir <- file.path(dirname(script_dir), "Individual")` | `individual_dir <- file.path(dirname(script_dir), "individual")` |
| 49 | `rel <- file.path("Simulations", "Joint")` | `rel <- file.path("method", "joint")` |
| 55 | `Open this script from Simulations/Joint, or setwd() there.` | `Open this script from method/joint, or setwd() there.` |
| 36 (comment) | `../Individual/prox_admm_metric.cpp is #included` | `../individual/prox_admm_metric.cpp is #included` |
| 3 (comment) | `(Simulations/Individual/Individual_Sampler_PMALA_Augmented.R)` | `(method/individual/Individual_Sampler_PMALA_Augmented.R)` |

File: `method/joint/prox_box_metric.cpp`, line 40 (comment): `-I<Simulations/Individual>` -> `-I<method/individual>`. Line 41 `#include "prox_admm_metric.cpp"` is unchanged (resolved through `-I`).

Why line 58 matters: Linux paths are case sensitive. After the lower-case rename, `"Individual"` does not exist and line 575 (`readLines(file.path(individual_dir, "Individual_Sampler_PMALA_Augmented.R"))`) and `load_box_cpp` both fail. Leave line 575 unchanged (the file name keeps its capitals).

Verify: `grep -n 'Individual"' method/joint/Joint_Sampler_PMALA_Augmented.R` shows no folder-name use; `cd method/joint && Rscript Joint_Sampler_PMALA_Augmented.R test_prox` (needs `clarabel`) prints `all optimisation-kernel tests passed`.

## B. Individual sampler fallback strings

File: `method/individual/Individual_Sampler_PMALA_Augmented.R`

| Line | Old | New |
|---|---|---|
| 131 | `rel <- file.path("Simulations", "Individual")` | `rel <- file.path("method", "individual")` |
| 138 | `Open this script from Simulations/Individual, or setwd() there.` | `Open this script from method/individual, or setwd() there.` |

Line 135 (`"Quantile Regression", rel`) is the old project-root name; leave it (harmless: it is one of several search roots).

File: `method/individual/pmala_exact_methods_note.md`, line 3: `(Simulations/Individual; variants_cells.R ...` -> `(method/individual; variants_cells.R ...`.

Its own directory is found first (`--file=`), so the script already runs after the move; these fixes only update the fallback search.

Verify: `cd method/individual && OMP_NUM_THREADS=1 Rscript Individual_Sampler_PMALA_Augmented.R test` -> `all tests passed`. From a different working directory: `Rscript /abs/path/method/individual/Individual_Sampler_PMALA_Augmented.R test` also passes.

Separate labelled commit (already in `01_moves.sh` section 3, **not** a path fix): settings block := production defaults.

## C. Growth scripts -> kernel root and sub-folders

`Data Applications/Growth/` is now `applications/Growth/` (same depth, so `dirname(dirname(script_dir))` is still the repo root). Two things change: `Simulations` becomes `method`, **and** the sub-folder names become lower case (`Joint` -> `joint`, `Individual` -> `individual`). The second part is not in PROPOSAL §6b. The `kernels=DIR` option is also used with the frozen snapshots whose layout is capitalised (`source/Joint`, `source/Individual`), so the fix accepts both spellings.

File: `applications/Growth/Growth_Joint_PMALA_k2.R`

| Line | Old | New |
|---|---|---|
| 99 | `kernel_root <- kv$kernels %\|\|% file.path(dirname(dirname(script_dir)), "Simulations")` | `kernel_root <- kv$kernels %\|\|% file.path(dirname(dirname(script_dir)), "method")` |
| 100 | `joint_dir <- file.path(kernel_root, "Joint")` | `joint_dir <- if (dir.exists(file.path(kernel_root, "joint"))) file.path(kernel_root, "joint") else file.path(kernel_root, "Joint")` |
| 101 | `ind_dir   <- file.path(kernel_root, "Individual")` | `ind_dir   <- if (dir.exists(file.path(kernel_root, "individual"))) file.path(kernel_root, "individual") else file.path(kernel_root, "Individual")` |
| 50 | `rel <- file.path("Data Applications", "Growth")` | `rel <- file.path("applications", "Growth")` |
| 56 | `Open this script from Data Applications/Growth, or setwd() there.` | `Open this script from applications/Growth, or setwd() there.` |
| 3 (comment) | `COPY of Simulations/Joint/Joint_Sampler_PMALA_Augmented.R` | `COPY of method/joint/Joint_Sampler_PMALA_Augmented.R` |
| 7 (comment) | `(Simulations/Joint/prox_box_metric.cpp, which #includes Simulations/Individual/prox_admm_metric.cpp)` | `(method/joint/prox_box_metric.cpp, which #includes method/individual/prox_admm_metric.cpp)` |
| 29-31 (comment) | `... the layout of Simulations/ ...; default: ../../Simulations/Joint and ../../Simulations/Individual relative to this script.` | `... the layout of method/ (or of a frozen source/ snapshot) ...; default: ../../method/joint and ../../method/individual relative to this script.` |

File: `applications/Growth/Growth_Joint_checks.R`

| Line | Old | New |
|---|---|---|
| 15 | `orig_file <- file.path(dirname(dirname(growth_dir)), "Simulations", "Joint", "Joint_Sampler_PMALA_Augmented.R")` | `orig_file <- file.path(dirname(dirname(growth_dir)), "method", "joint", "Joint_Sampler_PMALA_Augmented.R")` |
| 7 (comment) | `# Simulations/Joint/Joint_Sampler_PMALA_Augmented.R is parsed` | `# method/joint/Joint_Sampler_PMALA_Augmented.R is parsed` |

File: `applications/Growth/Growth_plots_k2.R`, line 8 (comment): `(Data Applications/Growth)` -> `(applications/Growth)`.

Left alone on purpose (HQ: no per-application restructuring): `Growth_Joint_checks.R` line 13 (`C:/Users/felip/...`, reached only when the script is not run via `Rscript`), line 114 of `Growth_Joint_PMALA_k2.R` (`C:/mingw64/bin/g++.exe`, Windows fallback).

Verify (cheap): from the repo root
```sh
Rscript -e 'sd <- normalizePath("applications/Growth"); kr <- file.path(dirname(dirname(sd)), "method");
  stopifnot(file.exists(file.path(kr,"joint","prox_box_metric.cpp"), file.path(kr,"individual","prox_admm_metric.cpp"), file.path(kr,"joint","Joint_Sampler_PMALA_Augmented.R")))'
```
Verify (full, optional, minutes): `cd applications/Growth && Rscript Growth_Joint_checks.R` -> the G1-G6 checks pass as before the move (record the pre-move result first if the time allows).

## D. Windows and old-layout absolute paths (kept rows of §6b)

| File | Line | Old | New |
|---|---|---|---|
| `experiments/extreme_quantiles/tables_4lev_20261023/paper_tables_4lev_vs_6lev.R` | 47 | `paper <- readLines("../../PMALA version Tex Project/sections/simulations.tex")` | `paper <- readLines("../../paper/sections/simulations.tex")` |
| same | 5 (comment) | `# Run from Simulations/Extreme/.` | `# Run from experiments/extreme_quantiles/.` |
| `experiments/air_simulation/onizuka_laplace_20261023/rows.R` | 1 | `read.csv("C:/Users/felip/OneDrive/Documents/Quantile Regression/Simulations/Air/lap_20261023/attempt_20261023T171713_511660/summary.csv")` | `read.csv(file.path(dirname(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), "attempt_20261023T171713_511660", "summary.csv"))` |
| `experiments/extreme_quantiles/tables_20261023/gen_tex.R` | 2 | `read.csv("C:/Users/felip/OneDrive/Documents/Quantile Regression/Simulations/Extreme/tables_20261023/mse_consolidated_oct7.csv")` | `read.csv(file.path(dirname(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), "mse_consolidated_oct7.csv"))` |

Notes
- §6b writes the new `paper_tables_4lev_vs_6lev.R` path as `../../../paper/...`. That is right only if the script is run from its own folder. The script's own header says "Run from Simulations/Extreme/" and all its other paths (`tables_20261023/...`, `tables_4lev_20261023/...`, lines 6, 7, 39, 40, 52) are relative to that folder, whose new equivalent is `experiments/extreme_quantiles/` (also two levels below the root). Then `../../paper/sections/simulations.tex` is right. Pick one convention; the table above keeps the script's own (run from `experiments/extreme_quantiles/`). The three `tables_*` folder names are unchanged by the move, so every other relative path keeps working.
- `rows.R` and `gen_tex.R` use `Rscript`'s `--file=` to find their own folder (same idiom as the samplers). `gen_tex.R` also writes its tex next to the csv; check its remaining lines (3 to end) for `C:/` after the first edit (`grep -n "C:/" gen_tex.R`).
- `experiments/extreme_quantiles/tables_4lev_20261023/check_vs_existing_096_099_table.R` is **not in §6b**: see G3.

Verify: `grep -rn 'C:/Users\|PMALA version' experiments/air_simulation/onizuka_laplace_20261023/rows.R experiments/extreme_quantiles/tables_20261023/gen_tex.R experiments/extreme_quantiles/tables_4lev_20261023/*.R` returns nothing outside the files treated in G3; `cd experiments/extreme_quantiles && Rscript tables_4lev_20261023/paper_tables_4lev_vs_6lev.R` regenerates `paper_tables_{4lev,6lev}.{md,tex}` with no diff (`git diff --stat` empty); `Rscript experiments/extreme_quantiles/tables_20261023/gen_tex.R` runs.

## E. TeX evidence comment

File: `paper/sections/scalability.tex`, line 6

- Old: `% Evidence: Simulations/Scalability/ (rewritten 2026-10-01 for the exact augmented sampler).`
- New: `% Evidence: experiments/scalability/ (timings.csv, table_cost_scaling_body.tex, make_cost_figure.py; rewritten 2026-10-01 for the exact augmented sampler).`

Verify: `grep -rn "Simulations/" paper/main.tex paper/sections` returns nothing; `cd paper && latexmk -pdf main.tex` unchanged (comment only).

## F. Engineering E-02 / E-04 default paths

Defaults point at the old checkout. Two kinds of change: `Engineering/E02_Rate_Sims` -> `engineering/E02_Rate_Sims` (case), and the kernel path `Simulations/Individual/...` -> `method/individual/...`. The environment overrides (`E02_DIR`, `E02_KERNEL`, `E02_OUT`, `E02_CAL`) keep working, which is what the NOTS job uses.

Files and lines (state of 2026-11-22):

| File (new path) | Line | Old | New |
|---|---|---|---|
| `engineering/E02_Rate_Sims/e02_lib.R` | 21 | `.../Bayesian-Quantile-Trend-Filtering/Engineering/E02_Rate_Sims` | `.../Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims` |
| same | 22 | `.../Bayesian-Quantile-Trend-Filtering/Simulations/Individual/prox_admm_metric.cpp` | `.../Bayesian-Quantile-Trend-Filtering/method/individual/prox_admm_metric.cpp` |
| same | 8 (comment) | `(Simulations/Individual/prox_admm_metric.cpp, unchanged)` | `(method/individual/prox_admm_metric.cpp, unchanged)` |
| `engineering/E02_Rate_Sims/free_check/run_free_check.R` | 3 | `root <- ".../Simulations/Individual"` | `root <- ".../method/individual"` |
| `engineering/E02_Rate_Sims/analyze.R` | 4 | `.../Engineering/E02_Rate_Sims` | `.../engineering/E02_Rate_Sims` |
| `engineering/E02_Rate_Sims/calibrate_c.R` | 3 | `source(".../Engineering/E02_Rate_Sims/e02_lib.R")` | `source(".../engineering/E02_Rate_Sims/e02_lib.R")` |
| `engineering/E02_Rate_Sims/check_iwcap_penratio.R` | 4 | `source(".../Engineering/E02_Rate_Sims/e02_lib.R")` | `source(".../engineering/E02_Rate_Sims/e02_lib.R")` |
| `engineering/E02_Rate_Sims/validate_samplers.R` | 3 | `Sys.getenv("E02_DIR", ".../Engineering/E02_Rate_Sims")` | `... ".../engineering/E02_Rate_Sims")` |
| `engineering/E02_Rate_Sims/pmala_vs_gibbs.R` | 9 | same pattern | same pattern, lower case |
| `engineering/E02_Rate_Sims/run_grid.R` | 22 (was 20 an hour ago) | same pattern | same pattern, lower case |
| `engineering/E02_Rate_Sims/free_check/aggregate.R` | 10 | `.../Engineering/E02_Rate_Sims/free_check/free_check_table.csv` | `.../engineering/E02_Rate_Sims/free_check/free_check_table.csv` |
| `engineering/E04_Sampler_Check/e04_checks.R` | 9 | `Sys.getenv("E02_DIR", ".../Engineering/E02_Rate_Sims")` | lower case |
| `engineering/E04_Sampler_Check/CHANGES.md` | 3, 5, 6, 7 | prose paths `Simulations/Individual/*`, `Engineering/E02_Rate_Sims/...` | `method/individual/*`, `engineering/E02_Rate_Sims/...`; line 7 (PLANNED reset) -> mark DONE with the E-03 commit hash |
| `engineering/E04_Sampler_Check/REVIEW_ASTRA.md` | 25-35 | prose `Engineering/E02_Rate_Sims/...`, `Simulations/Individual/...:215` | lower case / `method/individual/...:215`; **review text, change only with the Engineering head's OK** (line numbers inside it refer to the file *before* the sampler-defaults commit, which changes no line count) |

One-liner for the code files (run in `engineering/`, after review):
```sh
grep -rlE 'Bayesian-Quantile-Trend-Filtering/(Engineering|Simulations/Individual)' --include=*.R . \
 | xargs sed -i -e 's#Bayesian-Quantile-Trend-Filtering/Engineering/#Bayesian-Quantile-Trend-Filtering/engineering/#g' \
                -e 's#Bayesian-Quantile-Trend-Filtering/Simulations/Individual#Bayesian-Quantile-Trend-Filtering/method/individual#g'
```
Re-derive the exact lines at window time (E-02 is still being edited):
`grep -rnE 'Engineering/|Simulations/' engineering --include=*.R --include=*.slurm --include=*.sh --include=*.py`

NOTS side: the E-02/E-04 jobs run from code snapshots (`$RUN/code`, `E02_KERNEL="$CODE/prox_admm_metric.cpp"`). Whoever builds a snapshot must copy `method/individual/prox_admm_metric.cpp` (it was `Simulations/Individual/prox_admm_metric.cpp`). Nothing in `engineering/E02_Rate_Sims/nots/e02_job.slurm` needs a change.

Verify: `grep -rn 'Engineering/E0\|Simulations/Individual' engineering | grep -v E03_Repo_Organization` is empty (except prose that is deliberately historical); `Rscript -e 'source("engineering/E02_Rate_Sims/e02_lib.R"); load_kernel()'` compiles the kernel from `method/individual/` (about 1 minute). `Rscript engineering/E02_Rate_Sims/validate_samplers.R` is the full check (the Engineering head decides).

## G. Couplings NOT in PROPOSAL §6b

### G1. `ADMM_QTF_Individual.R` searches `Simulations/ADMM`

File: `method/admm_qtf/ADMM_QTF_Individual.R`

| Line | Old | New |
|---|---|---|
| 150 | `cand <- c(.norm("~/Quantile Regression/Simulations/ADMM"), .norm("~/OneDrive/Documents/Quantile Regression/Simulations/ADMM"),` | `cand <- c(.norm("~/Quantile Regression/method/admm_qtf"), .norm("~/OneDrive/Documents/Quantile Regression/method/admm_qtf"),` |
| 151 | `.norm(file.path(getwd(), "Simulations", "ADMM")), .norm(getwd()))` | `.norm(file.path(getwd(), "method", "admm_qtf")), .norm(getwd()))` |
| 58 (comment) | `below "~/Quantile Regression"` | unchanged |

(Only reached when the script is not run via `Rscript --file=`, e.g. RStudio "select all, Run".) Verify: `Rscript -e 'invisible(parse("method/admm_qtf/ADMM_QTF_Individual.R"))'`.

### G2. `individual_air_sim.R` loads the sampler from *its own* folder (BREAKS after the move)

File: `experiments/air_simulation/drivers/individual_air_sim.R`. The script was beside `Individual_Sampler_PMALA_Augmented.R`; in `drivers/` it no longer is. Moreover the sampler's own `.script_dir()` is evaluated inside the driver (line 123) with `--file=` pointing at the driver, so it fails to find `prox_admm_metric.cpp` unless the working directory is the sampler's folder.

| Line | Old | New |
|---|---|---|
| 119 | `sampler_file <- file.path(.this_dir(), "Individual_Sampler_PMALA_Augmented.R")` | `sampler_file <- file.path(dirname(dirname(dirname(.this_dir()))), "method", "individual", "Individual_Sampler_PMALA_Augmented.R")` |
| 123 | `eval(parse(text = src[seq_len(grep("^# ---- Main", src)[1L] - 1L)]), envir = smp)` | `local({ old <- setwd(dirname(sampler_file)); on.exit(setwd(old)); eval(parse(text = src[seq_len(grep("^# ---- Main", src)[1L] - 1L)]), envir = smp) })` |

(`drivers/` -> `air_simulation/` -> `experiments/` -> repo root, hence three `dirname`.) Verify: `Rscript -e 'invisible(parse("experiments/air_simulation/drivers/individual_air_sim.R"))'` (syntax), then a functional check in a scratch copy of the repo: run the driver with a small `n` and one `tau` (its settings are at the top of the file) and confirm it reaches the fit instead of stopping at `Could not find prox_admm_metric.cpp` or `file.exists(sampler_file)`. The Engineering head runs this; it is not in `04_smoke.sh` because of its runtime.

`admm_air_sim.R` does not source `ADMM_QTF_Individual.R` and has no path to `Simulations` (checked by grep): no change.

### G3. `check_vs_existing_096_099_table.R` (reads the old layout from the repo root)

File: `experiments/extreme_quantiles/tables_4lev_20261023/check_vs_existing_096_099_table.R`

| Line | Old | New |
|---|---|---|
| 1 | `read.csv("Simulations/Extreme/tables_4lev_20261023/comparison_4lev_6lev_individual.csv")` | `read.csv("experiments/extreme_quantiles/tables_4lev_20261023/comparison_4lev_6lev_individual.csv")` |
| 3 | `sprintf("Simulations/Extreme/tables_20261008/mse_%s.csv", b)` | `sprintf("experiments/extreme_quantiles/tables_20261008/mse_%s.csv", b)` |
| 6 | `readLines("PMALA version Tex Project/sections/simulations.tex")` | `readLines("paper/sections/simulations.tex")` |

(Script is run from the repo root, unlike `paper_tables_4lev_vs_6lev.R`.) `.../tables_4lev_20261023/verify/verify_compare.py` line 4: `D = r"C:\Users\felip\OneDrive\Documents\Quantile Regression\Simulations\Extreme\tables_4lev_20261023"` -> `D = os.path.dirname(os.path.abspath(__file__)) + "/.."` (add `import os` if absent). Verify: `python3 -c "import ast,sys;ast.parse(open('experiments/extreme_quantiles/tables_4lev_20261023/verify/verify_compare.py').read())"`.

### G4. Prose that cites old paths (no code effect; list for the owner)

- **Theory** (owns its files; send this list after the window): `Papers/` -> `literature/` at `theory/T01_Prior_Art/search_log.md:28`, `theory/T02_Syring_Martin/ASSESSMENT.md:3`, `theory/T03_Feasibility/MEMO.md:270,305`, `theory/T04_Template_Sweep/SHORTLIST.md:16,18,67`, `theory/T04_Template_Sweep/search_log.md:7,193`. One-liner for Theory: ``sed -i 's#`Papers/#`literature/#g;s# Papers/# literature/#g' theory/T0*/*.md``. `literature/READING_LIST.md` (new draft) already says `theory/T03_Feasibility/MEMO.md`. The one absolute path inside `theory/T03_Feasibility/scratch/vp_bias_check.out:16` is a log line; leave.
- `experiments/extreme_quantiles/DEPLOYMENT_NOTES.md:15`: `(local copy Simulations/Extreme/tables_20261008)` -> `experiments/extreme_quantiles/tables_20261008`.
- READMEs inside frozen packages (`Local package: Simulations/Individual/NOTS/inner_individual`, `Production destination: /home/fb31/projects/Quant_Reg/...`) are provenance; leave unchanged.
- `paper/history/*` and `experiments/scalability/comparison.md` mention `Simulations/...`, `Project_Paper`: history; leave.

### G5. Output folders the samplers write next to themselves

`method/individual/results_pmala_aug/`, `method/joint/results_joint/`, `method/admm_qtf/results_admm_qtf/` are created by a no-argument run. The draft `.gitignore` ignores them; the old tracked pilot results are in `experiments/pilots/` (not at those paths), so no tracked file is shadowed.

### G6. Frozen package copies of the canonical scripts differ from the canonical ones

`method/joint/Joint_Sampler_PMALA_Augmented.R` after fix A differs from its 5 frozen copies (`source/Joint/` in the packages, byte-identical `f6046f5e9963` before) by the path strings only, and `method/individual/...` after the settings reset differs from the NOTS snapshot only in the `tau` line. Both are intended; record in `method/README.md` (done in the draft) that the frozen copies are what the campaigns ran.

---

## The 3 bib keys to merge (do before `git rm paper/sections/references.bib`)

Absent from `paper/references.bib` (0 matches each), present at lines 84, 95 and 103 of the stale `paper/sections/references.bib`. Cited in the TeX? Run `grep -rn "cobb1978nile\|rue2005gaussian\|faulkner2018locally" paper/sections paper/main.tex` (Nile figures are in the paper, so `cobb1978nile` matters). Entries (also in `03_new_files/paper/bib_merge_3keys.bib`, appended by `01_moves.sh` section 10):

```bibtex
@article{cobb1978nile,
  title={The problem of the {N}ile: conditional solution to a changepoint problem},
  author={Cobb, George W},
  journal={Biometrika},
  volume={65},
  number={2},
  pages={243--251},
  year={1978},
  publisher={Oxford University Press}
}

@book{rue2005gaussian,
  title={Gaussian Markov Random Fields: Theory and Applications},
  author={Rue, H{\aa}vard and Held, Leonhard},
  year={2005},
  publisher={Chapman \& Hall/CRC},
  address={Boca Raton}
}

@article{faulkner2018locally,
  title={Locally adaptive smoothing with Markov random fields and shrinkage priors},
  author={Faulkner, James R and Minin, Vladimir N},
  journal={Bayesian Analysis},
  volume={13},
  number={1},
  pages={225--252},
  year={2018}
}
```

Verify: `for k in cobb1978nile rue2005gaussian faulkner2018locally; do grep -c "{$k," paper/references.bib; done` prints `1 1 1`; `cd paper && latexmk -pdf main.tex` completes with no new "undefined" warnings (a key that is not cited produces no warning with bibtex; that is fine).
