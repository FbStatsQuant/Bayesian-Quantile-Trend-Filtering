# E-03 Repository organization: proposal (for HQ approval)

*Engineering, 2026-11-22. Based on the full read-only inventory (`INVENTORY.md`, next to this file). Nothing has been moved yet.*

## 1. Goals
- A referee or a new student understands the repo in 30 seconds: what the method is, where the paper is, where the code is, and how each table or figure was produced.
- One canonical copy of the method code. Frozen copies exist only where they document provenance.
- No heavy data in git. Heavy data goes to the PC archive through the E-01 pipeline, and every archived item has a pointer in the repo.
- Every result folder says which paper table or figure it feeds.

## 2. Proposed tree (top level plus 1–2 levels)
```
Bayesian-Quantile-Trend-Filtering/
├── README.md               project summary, paper status, quick start, repo map, reproduction table
├── .gitignore  .gitattributes
├── paper/                  the manuscript                          (was Project_Paper/)
│   ├── main.tex  references.bib  latexmkrc  compile.bat  main.pdf (current build, tracked)
│   ├── sections/           11 section files
│   ├── figures/            only figures \includegraphics'd by the paper
│   └── history/            dated edit-session notes, reviews, to-do (was notes/, noncrossing_review/, Notes.txt)
├── method/                 canonical sampler code: what a user runs
│   ├── README.md           entry points, dependencies, tests, defaults = paper defaults
│   ├── individual/         Individual_Sampler_PMALA_Augmented.R, prox_admm_metric.cpp, methods note
│   ├── joint/              Joint_Sampler_PMALA_Augmented.R, prox_box_metric.cpp
│   └── admm_qtf/           ADMM QTF baseline (ADMM_QTF_Individual.R)
├── experiments/            everything that produced numbers in the paper
│   ├── README.md           table/figure -> folder map (the provenance index)
│   ├── interior_quantiles/ VS and S interior-level campaigns (individual + joint NOTS packages)
│   ├── extreme_quantiles/  extreme-level campaigns + table builders
│   ├── joint_upper_levels/ 6-level joint 100-seed run
│   ├── air_simulation/     Brantley-style air simulation (PMALA, ADMM, Onizuka-Laplace)
│   ├── scalability/        time-per-sweep benchmark (from paper/notes/complexity_analysis)
│   └── pilots/             small local pilot runs
├── applications/           real-data analyses
│   ├── README.md
│   ├── air_quality_spod/   SPod data pointer + figure provenance
│   ├── growth/             Dutch growth data, joint fit, plots
│   └── nile/               figure provenance (code/data currently missing, see §6)
├── theory/                 Theory Department (T-xx task folders)            (was Theory/)
├── engineering/            Engineering Department (E-xx task folders)       (was Engineering/)
├── literature/             reading list (+ PDFs, see decision D3)           (was Papers/)
├── archive/                superseded material kept for the record (small files only)
│   ├── munich_rent/        dropped application: code and k=2 summaries (heavy results go to the PC)
│   ├── archived_campaigns.md   index of NOTS ~/projects/Quant_Reg, archived to the PC (E-01)
│   └── scratch_2026/       useful bits of Temp/
└── data/                   (only if needed) small raw data + DATA.md listing PC-archived data with SHA-256
```
Why this shape:
- **Method, experiments and applications are kept apart**, because they answer different questions: "what is the algorithm?", "where do the paper's numbers come from?", and "what does it do on real data?".
- **Departments get their own top-level folders**, so ownership is obvious. Theory commits only in `theory/`.
- **Dated run folders stay inside their experiment.** Nothing dated sits at the top level.

## 3. Where every existing item goes

### Paper
| Now | Goes to | Note |
|---|---|---|
| `Project_Paper/main.tex`, `references.bib`, `sections/` | `paper/` | |
| `Project_Paper/compile.bat`, new `latexmkrc` | `paper/` | |
| `Project_Paper/figures/` (15 referenced) | `paper/figures/` | |
| `Project_Paper/figures/` (13 unreferenced: munich_*, cost_scaling.*, scal_speedup, scal_pmala_per_obs) and `_superseded_k1_munich/` | `archive/munich_rent/figures/` and `experiments/scalability/figures_unused/` | |
| `Project_Paper/sections/references.bib` (stale, differs) | deleted | First its 3 unique keys (cobb1978nile, rue2005gaussian, faulkner2018locally) are merged into `paper/references.bib`. |
| LaTeX artifacts (`main.aux/.bbl/.blg/.fdb_latexmk/.fls/.log/.out/.toc`) | untracked, ignored | `main.pdf` stays tracked as the current build (2.2 MB). |
| `Project_Paper/notes/` (19 session folders) | `paper/history/` | Their 15 `before/main.pdf` snapshots (24 MB) are removed; they stay in git history. `complexity_analysis/` goes to `experiments/scalability/`. |
| `Project_Paper/noncrossing_review/`, `Notes.txt` | `paper/history/noncrossing_review/`, `paper/history/TODO_2026-03.txt` | |

### Method
| Now | Goes to | Note |
|---|---|---|
| `Simulations/Individual/{Individual_Sampler_PMALA_Augmented.R, prox_admm_metric.cpp, pmala_exact_methods_note.md}` | `method/individual/` | Its settings block is reset to the paper defaults (it has `order <- 1L`), in a separate, clearly labelled commit. |
| `Simulations/Joint/{Joint_Sampler_PMALA_Augmented.R, prox_box_metric.cpp}` | `method/joint/` | The `../Individual/` include becomes `../individual/`. |
| `Simulations/ADMM/ADMM_QTF_Individual.R` | `method/admm_qtf/` | |

### Experiments (frozen NOTS packages move as-is)
Content is untouched, so their `SHA256SUMS` stay valid.

| Now | Goes to |
|---|---|
| `Simulations/Individual/NOTS/inner_individual/` (+ S_b00005, S_b0001, VS_b0001) | `experiments/interior_quantiles/individual_nots_20261003/` |
| `Simulations/Joint/inner_joint/` | `experiments/interior_quantiles/joint_nots/` |
| `Simulations/Individual/individual_air_sim.R`, `Simulations/ADMM/admm_air_sim.R` | `experiments/air_simulation/drivers/` |
| `Simulations/Air/lap_20261023/` + `Temp/air_lap_20261023/{stage/, BUILD_REPORT.md}` | `experiments/air_simulation/onizuka_laplace_20261023/` (results + `package_stage/`) |
| `Simulations/Extreme/*` (4 packages, 3 table folders, DEPLOYMENT_NOTES.md) | `experiments/extreme_quantiles/` (`packages/`, `tables_20261008/`, `tables_20261023/`, `tables_4lev_20261023/`) |
| `Temp/extreme_tex_20261023/gen.R` | `experiments/extreme_quantiles/tables_20261023/gen_tex.R` (Windows path fixed) |
| `Simulations/Joint/NOTS/` (incl. `runs/VS_upper6_…_20261002`) | `experiments/joint_upper_levels/` |
| `Project_Paper/notes/complexity_analysis/` | `experiments/scalability/` |
| `Simulations/Individual/results_pmala_aug/`, `Simulations/Joint/results_joint/` | `experiments/pilots/` |

The 10.8 MB `history.jsonl` monitor log in `joint_upper_levels` goes to the PC archive; a pointer stays in the repo.

### Applications
| Now | Goes to | Note |
|---|---|---|
| `Data Applications/Growth/` | `applications/growth/` (`data/`, `scripts/`, `results_joint_k2/`) | Its `../../Simulations` kernel paths are re-pointed to `../../method`; Windows paths become relative. |
| `Data Applications/Air Quality/S08_*.csv` (7 × 20 MB raw data; nothing in the repo reads them) | PC archive via E-01; `applications/air_quality_spod/DATA.md` | DATA.md gives the source, SHA-256 and PC location. |
| figures `spod_*`, `nile_*` | stay in `paper/figures/` | Each application folder's README says which figures it owns and that the generator is missing (§6). |

### Archive
| Now | Goes to | Note |
|---|---|---|
| `Data Applications/Munich Rent/` (code, data 52K, `results_k2/` 2.5M) | `archive/munich_rent/` | |
| `Data Applications/Munich Rent/Others/results*` (115 MB of superseded .rds) | PC archive via E-01 | Pointer in `archive/munich_rent/README.md`. |
| `Temp/NOTS_Exercise/` | deleted | Throwaway exercise; the cpp is a duplicate. Its array pattern is noted in `engineering/`. |
| `Temp/extreme_tex_20261023/*.png` (5 previews) | deleted | |
| `~/projects/Quant_Reg` (NOTS, archived 2026-11-22) | `archive/archived_campaigns.md` | One line per campaign plus the PC location. |

### Departments and literature
| Now | Goes to |
|---|---|
| `Theory/` (already tracked: T01–T04) | `theory/`, same subfolders. Theory owns its contents. |
| `Engineering/` (untracked) | `engineering/` (`E01_Transfer_Pipeline/` docs, `E02_Rate_Sims/`, `E03_Repo_Organization/`), committed |
| `Papers/` | `literature/` (READING_LIST.md + PDFs; see D3) |

## 4. Naming conventions
- **Folders:** lower-case `snake_case`, with no spaces or parentheses. Dated work folders end in `_YYYYMMDD`.
- **Files:**
  - Scripts are `snake_case` verbs (`run_grid.R`, `make_tables.R`).
  - Kept historical names are fine inside frozen packages, which must not be renamed.
  - Reports are `UPPERCASE.md` (`README.md`, `REPORT.md`, `MEMO.md`).
- **Task IDs:** `T-xx` for Theory and `E-xx` for Engineering, used in messages and commit prefixes. Task folders are named `T03_Feasibility/` or `E02_Rate_Sims/` (ID, then a short CamelCase or snake title).
- **Commits:** `E-03: move simulations into experiments/` or `T-03: memo v2`. Small and logical; moves are kept separate from edits so `git log --follow` works.
- **Results:** each experiment has a `results/` folder (small summaries, tables, figures) and a `README.md` whose first section is "Feeds paper: Table X, Figure Y".

## 5. `.gitignore` and data policy
Policy:
- Git holds code, reports, small summaries (≤ ~1 MB each), tables, figures and the paper.
- Chains, raw draws, per-task `.rds`, monitor logs and raw data larger than 5 MB go to the PC through E-01: sealed manifest, SHA-256, signed receipt.
- Any file over 5 MB needs HQ's OK. A pre-commit hook in `.githooks/` will refuse staged files over 5 MB, unless they're listed in `.gitattributes` as approved.

Draft `.gitignore`:
```
# LaTeX build
paper/*.aux paper/*.bbl paper/*.blg paper/*.fdb_latexmk paper/*.fls paper/*.log paper/*.out paper/*.toc paper/*.synctex.gz
**/history/**/build/
# R / Python / OS
.Rhistory .RData .Rproj.user/ __pycache__/ *.pyc .DS_Store Thumbs.db
# heavy outputs: never in git (go to the PC via E-01)
**/raw/  **/chains/  **/draws/  *.npz  *.feather  *.parquet
**/runs/**/tasks/  **/runs/**/logs/  **/monitor/history.jsonl
# Rcpp build cache
**/.rcpp_cache/
```
(`.rds` and `.csv` are not ignored globally, because small summaries are legitimate; the size hook enforces the limit.)

## 6. Gaps found (to fix or document; not blocking)
1. The `% Evidence: Simulations/Scalability/` comment in `scalability.tex` points to a folder that is not in the repo. The closest material is `notes/complexity_analysis/`.
2. There are no generator scripts in the repo for the `nile_*`, `spod_*`, `growth_lms_*`, `growth_pmala_*` and `scal_*` figures, and no Nile data. **Felipe: do you have these on the PC?**
3. Every paper table is typed by hand into the TeX. Later, the table builders should write `paper/tables/*.tex` to be `\input`ed. That's not part of E-03.
4. `paper_tables_4lev_vs_6lev.R` reads `../../PMALA version Tex Project/…`; it becomes `../../../paper/sections/simulations.tex`.
5. Smoke tests need tools that are not in the repo:
   - LaTeX packages `algpseudocode`, `bbm` and `bbold`, installed in a user texmf on Owls;
   - the R package `clarabel` for the joint tests, installed in a user library.

## 6b. What breaks when files move, and the fix for each
Every item below is fixed in the path-fix commits of step 3 of §8 and covered by the smoke tests in step 6.

| Breaks | Why | Fix |
|---|---|---|
| Paper build | `paper/` is a rename only. `\input{sections/...}` and `figures/...` are relative to the compile dir, so they keep working. | None needed. Verified by `latexmk -pdf` in `paper/`, after installing algpseudocode, bbm and bbold in a user texmf. |
| Joint sampler | `prox_box_metric.cpp` `#include`s, and the R script loads, `../Individual/prox_admm_metric.cpp`. | Re-point to `../individual/`. Verified by the joint `test_prox`, after installing `clarabel` in a user library. |
| Individual sampler | Its `.script_dir()` fallback searches for `Simulations/Individual` under `~/Quantile Regression`. | Its own directory is found first, so it still runs. The fallback strings are updated to `method/individual`. Verified by `Rscript ... test`. |
| Growth scripts | `kernel_root = ../../Simulations`; `Growth_Joint_checks.R` has `C:/Users/felip/...` | `../../method`; Windows paths replaced by script-relative paths. |
| Munich checks | `C:/Users/felip/...` | Archived. A header note says the paths are historical; not run. |
| `paper_tables_4lev_vs_6lev.R` | Reads `../../PMALA version Tex Project/...` | `../../../paper/sections/simulations.tex` |
| `Simulations/Air/lap_20261023/rows.R`, `gen.R` | Windows absolute paths | Script-relative paths. |
| Frozen NOTS packages | Remote paths (`/home/fb31/projects/Quant_Reg/...`) under SHA256SUMS | Left unchanged on purpose: they document where the runs happened. Their SHA256SUMS stay valid because the content is untouched. |
| `scalability.tex` evidence comment | Points at the nonexistent `Simulations/Scalability/` | Comment updated to `experiments/scalability/`. |
| Engineering E-02 scripts | Default paths point into `Engineering/E02_Rate_Sims`. | Paths are env-configurable; defaults updated to `engineering/E02_Rate_Sims`. |

## 7. Decisions needed from HQ / Felipe
- **D1. Heavy data in history.** `git rm` of the SPod CSVs (139 MB) and Munich `.rds` files (115 MB) clears the working tree but not `.git` (191 MB). A one-time history rewrite (`git filter-repo`) would bring `.git` to about 15 MB. It needs a force-push and a fresh clone on NOTS and the PC. Recommendation: yes, once, right after the migration, with HQ pushing.
- **D2. Is `paper/main.pdf` kept tracked?** Recommendation: yes. It's the current build, and a referee can open it without LaTeX.
- **D3. Third-party PDFs in `literature/`.** If the repo stays private, keep them. If it might become public, git-ignore `literature/*.pdf` and keep `READING_LIST.md` with links. `Large Prior.pdf` is Felipe's own paper.
- **D4. Licence file and `CITATION.cff`** for the final repo: Felipe's call.

## 8. Migration plan (after approval)
1. **Freeze window.** Agree a window of about 2 hours with Theory in which nobody edits moved paths.
2. **Folder moves.** One commit per area, by a Sonnet agent with `git mv` only: paper, method, experiments, applications, archive, departments, literature.
3. **Path fixes.** Separate commits by a Sonnet agent, reviewed by me: the Joint include, the Growth kernel root, the Windows paths, the "PMALA version Tex Project" path, and the TeX evidence comment.
4. **Heavy data.** Seal it on NOTS or Owls, send it through E-01 to the PC, then `git rm` it with pointer READMEs.
5. **New files.** `.gitignore`, the size hook, `README.md` and the per-folder READMEs.
6. **Smoke tests.** `latexmk -pdf` in `paper/`, the individual sampler `test`, and the joint `test_prox`. All must pass before I tell HQ the batch is ready to push.
7. **Optional history rewrite (D1).**

## 9. Top-level README outline
1. **Title and one-paragraph abstract.** What BQTF is, and the paper title and authors.
2. **Status.** The paper version and the current work (theory, under T-xx).
3. **Repository map.** The tree above, one line per folder.
4. **Quick start.** Requirements (R ≥ 4.4, Rcpp, glmgen; a C++17 compiler); fitting one quantile in five lines; running the tests.
5. **Reproducing the paper.** A table of paper item → folder → command → expected runtime and cluster.
6. **Data.** What is in the repo, what is archived (PC) and how to obtain it.
7. **Departments and task IDs.** T-xx / E-xx, and where reports live.
8. **Citation and licence.**
