# Bayesian Joint Quantile Trend Filtering via Proximal MCMC with Sequential Gibbs Sampling

Felipe Bedoya, Meng Li, Eric C. Chi.

Quantile trend filtering combines the check loss with an $\ell_1$ penalty on discrete differences of the trend. We develop Bayesian-PMALA, a posterior sampler for quantile trend filtering that learns the regularization strength and the likelihood scale jointly with the trend. Augmenting the asymmetric Laplace likelihood with its normal-exponential representation makes the likelihood Gaussian in the trend. Under a global Laplace prior on trend differences, the whole negative log-conditional of the trend is then a weighted quadratic plus an $\ell_1$ difference penalty. The trend can therefore be updated by an exact proximal Metropolis-adjusted Langevin (P-MALA) step. The Moreau-Yosida envelope is built on the entire conditional posterior, through a weighted trend filtering problem, rather than on a smoothed check loss, and the Metropolis-Hastings correction uses the exact density. The latent variables, the penalty and the scale have conjugate updates. Every linear system is banded, and the proximal map is computed by ADMM with a factorization shared by the forward and reverse maps, so the work per sweep grows linearly with the sample size for a fixed inner iteration budget. For several quantile levels, a joint version samples each trend between its neighbours. Only the proximal map changes, becoming a box-constrained problem solved with banded interior-point steps, and no retained draw crosses.

In simulations with varying-smoothness and smooth signals under Gaussian, Beta, and mixed-normal noise, Bayesian-PMALA attains accuracy comparable to a locally adaptive horseshoe Gibbs sampler with a simpler hierarchy and banded computations, and accuracy comparable to ADMM-based quantile trend filtering while providing posterior inference on the trend, the penalty and the scale. In a peak-detection design for air-quality sensors, it recovers the peak-free baseline far more accurately than the horseshoe sampler and comes close to the ADMM benchmark in baseline recovery and detection, and an application to fenceline sensor data illustrates the method at $n = 8{,}640$.

## Status

- Manuscript: `paper/main.tex` (current build `paper/main.pdf`). Manuscript text: all rights reserved until publication.
- Current work: posterior-contraction theory for the sampler's target (Theory Department, tasks T-xx in `theory/`) and rate simulations (Engineering, tasks E-xx in `engineering/`).
- Repository reorganized in task E-03 (2026-11): see the map below. History before that commit uses the old folder names (`Project_Paper/`, `Simulations/`, ...); `engineering/E03_Repo_Organization/hash_map.tsv` maps old to new commit hashes after the history rewrite.

## Repository map

| Folder | What is in it |
|---|---|
| `paper/` | The manuscript: `main.tex`, `references.bib`, `sections/`, `figures/`, `history/` (dated edit-session notes, reviews, to-do). |
| `method/` | Canonical sampler code, the thing a user runs: `individual/` (single-quantile P-MALA), `joint/` (non-crossing joint sampler), `admm_qtf/` (ADMM quantile trend filtering baseline). |
| `experiments/` | Everything that produced numbers in the paper. `experiments/README.md` maps each table and figure to its folder. |
| `applications/` | Real-data analyses (`Growth/`, `Air Quality/`, `Munich Rent/`). Open items are listed in its README. |
| `theory/` | Theory Department task folders (T-01 ...). Theory commits only here. |
| `engineering/` | Engineering Department task folders (E-01 ...), including `E03_Repo_Organization/`. |
| `writing/` | Writing Department task folders (W-01 ...: statement drafts, reviews). The Writing Department commits only here. |
| `literature/` | Reading list with DOI/arXiv links. PDFs are local only (git-ignored), except our own `Large Prior.pdf`. |
| `archive/` | Superseded material kept for the record (small files only) and `archived_campaigns.md`, the index of the NOTS campaigns archived to the PC. |
| `ops/` `runs/` `tmp/` | **Not in git** (git-ignored, local to each machine). `ops/` = the E-01 operations pipeline (ops scripts, receipt ledger, PC puller, ssh lock shim, R library `ops/Rlib`); `runs/` = run outputs and sealed `archive-*` runs headed for the PC; `tmp/` = scratch. Same layout on NOTS at `~/BQTF` (= `/projects/ml75/fb31/BQTF`, the NOTS checkout). See `engineering/E12_Disk_Reorg/`. |

**Committing (all departments share one working tree and git index):**
- Commit with explicit paths, staging and committing in ONE command: `git add <your paths> && git commit -m "..."`.
- Never use `git commit -a`, `git add -A` or `git add .`, and never commit an index you did not stage yourself in that same command. A commit picks up whatever any department has staged.

## Quick start

Requirements: R >= 4.4 with `Rcpp`, `RcppArmadillo`, `glmgen`, `Matrix`; a C++17 compiler. The joint tests also need `clarabel`. Building the paper needs TeX Live with `algorithmicx` (algpseudocode), `bbm` and `bbold`.

```sh
# Individual sampler: edit the "Settings" block at the top of the file (defaults = production), then
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R          # pilot fit on simulated data; writes results_pmala_aug/ (git-ignored)
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test     # unit tests, about 100 s, must print "all tests passed"
Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox          # box-prox kernel tests (needs clarabel)
cd paper && latexmk -pdf main.tex                                       # build the manuscript
```

Enable the size hook once per clone: `git config core.hooksPath .githooks` (refuses staged files over 5 MB).

## Reproducing the paper

All campaigns ran on the Rice NOTS cluster (Slurm) from frozen, SHA-256-sealed packages. The raw per-task outputs are archived on the PC (see `archive/archived_campaigns.md`); the repo keeps packages, summaries and tables. Every table in the TeX is typed in by hand from the listed result files.

| Paper item | Folder | Command (run on NOTS from the package folder) | Cost |
|---|---|---|---|
| Tables `vs_int_mse`, `s_int_mse` and appendix MAD/MCIW tables (interior levels, individual sampler) | `experiments/interior_quantiles/individual_nots_20261003/` (`paper_reference/`, `deployment/paper_mse_tables.py`) | `bash submit.sh RUN_NAME` | 3,000 tasks (VS and S x 3 noises x 5 levels x 100 seeds), 1 CPU each; NOTS `commons` |
| Interior joint-sampler comparison, `provenance.txt` | `experiments/interior_quantiles/joint_nots/` (`paper_reference/`) | `bash submit.sh RUN_NAME` | NOTS |
| Tables `vs_ext_upper_mse`, `s_ext_upper_mse` and the crossing tables (extreme upper levels) | `experiments/extreme_quantiles/` (`tables_20261008/`, `tables_20261023/`, `tables_4lev_20261023/`; packages in `packages/`) | `bash submit.sh RUN_NAME` in each package, then `make_tables.R` / `paper_tables_4lev_vs_6lev.R` | 100 seeds x 3 noises; joint run 30,000 sweeps, 10,000 burn-in; NOTS |
| Joint six-level run (0.90 to 0.99), `table2_mse.csv` | `experiments/joint_upper_levels/` | `bash submit.sh RUN_NAME` | 300 tasks, 1 CPU and 8 GB each, up to 24 h; NOTS `commons` |
| Air simulation, table `air_n500` (PMALA, ADMM, Onizuka-Laplace) | `experiments/air_simulation/` (`drivers/`, `onizuka_laplace_20261023/`) | `Rscript drivers/individual_air_sim.R`, `drivers/admm_air_sim.R`; add-on on NOTS | hours; Onizuka-Laplace add-on on NOTS |
| Scalability: table `cost_scaling`, figures `scal_time`, `scal_breakdown` | `experiments/scalability/` | `Rscript benchmark_existing.R`; `python3 build_tables.py` | minutes on one machine; the `scal_*` figure generators are not in the repo (open item) |
| Real-data figures: Growth (`growth_pmala_*`) | `applications/Growth/` | `Rscript Growth_Joint_PMALA_k2.R sex=boy` (and `girl`), then `Growth_plots_k2.R` | minutes to hours, local |
| Real-data figures: SPod (`spod_*`), Nile (`nile_*`), `growth_lms_*`, `scal_*` | `paper/figures/` | generators and the Nile data are not in the repo | open items, see `applications/README.md` |

## Data

- In the repo: small summaries (each at most about 1 MB), tables, figures, the Growth data (`applications/Growth/data/`).
- Archived on the PC through the E-01 pipeline (sealed manifest, SHA-256, signed receipt): the raw SPod air-quality CSVs, the Munich `Others/results*` draws, the joint-run monitor log and the whole NOTS `~/projects/Quant_Reg` tree. Each has a `DATA.md` pointer or an entry in `archive/archived_campaigns.md`. Ask Felipe for the PC path.
- Policy: anything larger than 5 MB needs HQ's OK; the pre-commit hook enforces it.

## Departments and task IDs

Work is tracked as `T-xx` (Theory, folders `theory/T0x_*`) and `E-xx` (Engineering, folders `engineering/E0x_*`). Commit messages start with the task ID (`T-03: ...`, `E-03: ...`). Reports are `MEMO.md`, `REPORT.md`, `README.md` in the task folder.

## Citation and licence

Cite the paper (`CITATION.cff`). Code is MIT-licensed (`LICENSE`). The manuscript text in `paper/` is all rights reserved until publication.
