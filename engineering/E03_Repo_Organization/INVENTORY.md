# E-03 step 1: read-only inventory of Bayesian-Quantile-Trend-Filtering

Repo: /home/fb31/Bayesian-Quantile-Trend-Filtering (branch main, 15 commits). Nothing in the repo was modified.
Total on disk 543 MB = .git 191 MB + working tree 353 MB. Working tree: 1009 files, 187 directories (excl. .git). Tracked: 995 files. Untracked: `Engineering/` (7 files) only; ignored: `Theory/T03_Feasibility/scratch/__pycache__/`.
Git: 363 loose objects (8.0 MiB) + one pack 181.67 MiB (958 objects). Pack size is about the sum of the big binary data blobs listed in section 2.

## 1. Tree with sizes

Tracking legend: T = fully tracked, U = untracked, P = partial. The only untracked top-level path is Engineering/. Everything else is tracked.

| Path | Size | Files | Status | Contents |
|---|---|---|---|---|
| `Data Applications/` | 254M | 154 | T | Real-data applications (Air Quality, Growth, Munich Rent) |
| `Data Applications/Air Quality/` | 134M | 7 | T | 7 raw SPod CSVs `S08_2018-06-15..21.csv`, about 20 MB each (input data) |
| `Data Applications/Growth/` | 2.5M | 23 | T | Dutch growth data (fdgs.csv + README), 3 scripts (Growth_Joint_PMALA_k2.R, Growth_Joint_checks.R, Growth_plots_k2.R) |
| `Growth/data/` | 472K | 2 | T | fdgs.csv, README.txt |
| `Growth/Others/` | 176K | 4 | T | LMS centile CSVs and sampler input CSVs |
| `Growth/results_joint_k2/` | 1.8M | 14 | T | boy/, girl/ (posterior_summary, crossings, diagnostics, traces, run.log, draws), figures/ (growth_joint_*.pdf/png) |
| `Data Applications/Munich Rent/` | 118M | 124 | T | Munich rent application; REMOVED from the paper 2026-10-28 |
| `Munich Rent/data/` | 52K | 2 | T | munich.rda, munich_processed.csv |
| `Munich Rent/Others/` | 115M | 98 | T | 7 older scripts + 5 result folders: results 30M, results_onizuka 24M, results_onizuka_k2 47M, results_pmala 15M, results_pmala_k2 416K (k=1 / earlier runs; large .rds) |
| `Munich Rent/results_k2/` | 2.5M | 19 | T | current k=2 summaries, figures/, per-method run.log |
| top-level in Munich Rent | small | 5 | T | Munich_PMALA_Individual_k2.R, Munich_plots_k2.R, Munich_PMALA_checks.R, prox_admm_metric_irregular.cpp, results_onizuka_k2_run.log |
| `Papers/` | 21M | 19 | T | 18 literature PDFs + READING_LIST.md (see section 7) |
| `Project_Paper/` | 53M | 340 | T | LaTeX manuscript (main.tex, sections/, figures/, references.bib), build artifacts, notes/ |
| `Project_Paper/figures/` | 6.0M | 32 | T | paper figures (+ `_superseded_k1_munich/` 432K, 4 files) |
| `Project_Paper/sections/` | 156K | 12 | T | 11 section .tex files + a stale `references.bib` |
| `Project_Paper/notes/` | 44M | 278 | T | 19 dated edit-session folders (see section 3) |
| `Project_Paper/noncrossing_review/` | 316K | 5 | T | review md files, plan .tex/.pdf, bib |
| `Simulations/` | 25M | 437 | T | ADMM, Air, Extreme, Individual, Joint |
| `Simulations/ADMM/` | 56K | 2 | T | admm_air_sim.R, ADMM_QTF_Individual.R |
| `Simulations/Air/lap_20261023/` | 2.3M | 14 | T | Onizuka-Laplace air-sim add-on results (attempt_*/ with results.rds 2.2 MB, oct8_partial/, rows.R) |
| `Simulations/Extreme/` | 1.1M | 89 | T | extreme-quantile NOTS packages + tables |
| `Extreme/Extreme_admm/` | 12K | 3 | T | worker_admm.R, qtf_lp_ebic.R, README |
| `Extreme/Extreme_Individual/` | 168K | 22 | T | NOTS package: workers, slurm, validate, `source/` snapshot |
| `Extreme/Extreme_Joint_Sampler/` | 208K | 21 | T | NOTS package, `source/Individual`, `source/Joint` snapshots |
| `Extreme/Extreme_Onizuka/` | 32K | 3 | T | worker_onizuka.R + `source/BQTF-function.R` |
| `Extreme/tables_20261008/` | 96K | 19 | T | crossings/mse tables csv+tex (+ draft_bodies/) |
| `Extreme/tables_20261023/` | 48K | 4 | T | consolidated Oct-7 MSE csv/md |
| `Extreme/tables_4lev_20261023/` | 528K | 16 | T | 4-level vs 6-level paper tables, scripts, inputs/, verify/ |
| `Simulations/Individual/` | 2.7M | 178 | T | individual sampler + NOTS package |
| top-level in Individual | small | 5 | T | Individual_Sampler_PMALA_Augmented.R (42 KB), individual_air_sim.R, prox_admm_metric.cpp, pmala_exact_methods_note.md, results_pmala_aug/ (52K, pilot output) |
| `Individual/NOTS/inner_individual/` | 2.6M | 171 | T | NOTS deployment package 2026-10-03: common/config/worker R, python deploy/monitor tools, slurm/, deployment/ (21 timestamped dirs + a 1.5 MB tarball), audit/, S_b00005/ S_b0001/ VS_b0001/ sub-packages each with `source/` + SHA256SUMS, 4 tracked `__pycache__/*.pyc` |
| `Simulations/Joint/` | 19M | 154 | T | joint sampler + NOTS package + runs |
| top-level in Joint | small | 2 | T | Joint_Sampler_PMALA_Augmented.R (58 KB), prox_box_metric.cpp |
| `Joint/inner_joint/` | 256K | 21 | T | NOTS package (interior-level joint), `source/Individual`, `source/Joint`, paper_reference/ |
| `Joint/NOTS/` | 15M | 107 | T | NOTS package for upper-6-level joint run: slurm/, analysis/, source/, paper_reference/, runs/VS_upper6_100seeds_Rdefaults_b001_20261002/ (15M, incl. 10.8 MB monitor history.jsonl) |
| `Joint/results_joint/` | 3.6M | 24 | T | local pilot outputs (n=500 seed 1; csv/png/rds, logs) |
| `Temp/` | 1.4M | 18 | T | scratch (section 6) |
| `Theory/` | 228K | 31 | T | see section 8 (27 tracked files) |
| `Engineering/` | 48K | 8 | **U** | E02_Rate_Sims (see section 8) |

(Correction on Theory: `git ls-files` lists `Theory/.gitignore`, T01 (2), T02 (1), T03 (21), T04 (2) = 27 tracked; Theory is NOT untracked despite the task note. Only `Engineering/` is untracked. Theory/T03_Feasibility/scratch/__pycache__ is ignored.)

### .gitignore files
There is NO root `.gitignore`. The only one is `Theory/.gitignore`:
```
__pycache__/
*.pyc
```
Consequence: LaTeX aux/log files, `__pycache__` in Individual/NOTS (4 .pyc tracked) and all outputs are tracked at the root level.

### File type counts among tracked files
png 147, txt 116, R 112, csv 102, tex 89, sh 85, pdf 71, rds 43, py 37, slurm 36, md 31, cpp 21, log 20, out 14, json 13.

## 2. Large files (> 1 MB), 52 files, all tracked

Regenerable = chains/.rds/raw draws/logs/monitor output; Source = input data or paper asset; Build = LaTeX output.

| Size | Path | Type | Class |
|---|---|---|---|
| 24.1M | Data Applications/Munich Rent/Others/results_onizuka_k2/all_quantile_fits.rds | rds draws | regenerable |
| 20.1M x7 (139M) | Data Applications/Air Quality/S08_2018-06-15..21.csv | raw SPod data | SOURCE DATA (not regenerable, but nothing in the repo reads it) |
| 12.5M | Munich Rent/Others/results/all_quantile_fits.rds | rds draws | regenerable |
| 10.8M | Simulations/Joint/NOTS/runs/VS_upper6_.../metadata/monitor/history.jsonl | monitor log | regenerable/log |
| 4.8M x5 | Munich Rent/Others/results_onizuka_k2/fit_tau_{10..90}.rds | draws | regenerable |
| 4.8M x5 | Munich Rent/Others/results_onizuka/fit_tau_*.rds | draws (k=1) | regenerable, superseded |
| 3.2/3.1/2.8/2.7/2.3M | Munich Rent/Others/results_pmala/fit_tau_*.rds (5) | draws | regenerable |
| 2.7/2.6/2.5/1.9M (+2.7M) | Munich Rent/Others/results/fit_tau_*.rds (5) | draws | regenerable |
| 4.4M | Papers/Kowal_Dynamic_Shrinkage.pdf | 3rd-party PDF | literature |
| 3.2M | Papers/Padilla_Risk Bounds for Quantile Trend Filtering.pdf | 3rd-party PDF | literature |
| 2.5M | Papers/Onizuka_2023.pdf | 3rd-party PDF | literature |
| 1.6M, 1.5M, 1.3M, 1.25M | Papers/Brantley_2020, Pereyra 2016, Large Prior, TF_2014 | PDFs | literature |
| 2.77M | Project_Paper/notes/joint_extreme_results_20261002/before/main.pdf | PDF snapshot | build artifact/history |
| 2.74M | Simulations/Joint/NOTS/runs/VS_upper6.../paper_reference/main.pdf | PDF snapshot | duplicate paper snapshot |
| 2.7M x7 | Project_Paper/notes/*/before/main.pdf and notes/simulation_revision_20260914/build/main.pdf | PDF snapshots of old paper | build artifact |
| 2.26M | Project_Paper/main.pdf | current compiled paper | build artifact (tracked) |
| 2.24M | Simulations/Air/lap_20261023/attempt_.../results.rds | summary rds | regenerable output (but only copy of the result) |
| 1.49M | Simulations/Individual/NOTS/inner_individual/deployment/validation_1785936.tar.gz | NOTS validation archive | regenerable/log |
| 1.38M, 1.37M | Simulations/Joint/results_joint/joint_summary_*.rds | pilot summary rds | regenerable |

Sizes of classes: Air Quality raw data 134M of tree; Munich Rent/Others results about 115M (all regenerable, project removed from paper); about 24M of repeated main.pdf snapshots in notes/.

### History
`git count-objects -vH`: count 363 (8.02 MiB loose), in-pack 958, packs 1, size-pack 181.67 MiB, garbage 0. 15 commits.
20 largest blobs in history (all still present in HEAD, so no purge-able dead weight in history; history size = the data files themselves):
```
4.78M Munich Rent/Others/results_onizuka/fit_tau_70.rds
4.78M Munich Rent/Others/results_onizuka/fit_tau_90.rds
4.79M .../results_onizuka_k2/fit_tau_90.rds
4.79M .../results_onizuka_k2/fit_tau_70.rds
4.81M .../results_onizuka/fit_tau_50.rds
4.82M .../results_onizuka_k2/fit_tau_50.rds
4.84M .../results_onizuka/fit_tau_10.rds
4.84M .../results_onizuka/fit_tau_30.rds   (4.84M results_onizuka_k2 fit_tau_30 too)
4.86M .../results_onizuka_k2/fit_tau_10.rds
10.8M Simulations/Joint/NOTS/runs/VS_upper6.../metadata/monitor/history.jsonl
12.5M Munich Rent/Others/results/all_quantile_fits.rds
19.9M, 19.9M, 20.0M, 20.1M x3, 20.1M  Data Applications/Air Quality/S08_*.csv (7)
24.1M Munich Rent/Others/results_onizuka_k2/all_quantile_fits.rds
```
(Full command output reproducible with the command in the task.) Moving files with `git mv` keeps blobs shared, so a reorganization commit adds no size; removing them does not shrink history unless it is rewritten.

## 3. Paper (`Project_Paper/`)

### TeX references (main.tex + sections/*.tex; no \graphicspath; no \include)
`\input` (all exist): sections/abstract, introduction, methodology, simulations, scalability, air_simulation, data_application, discussion, appendix_pmala, appendix_simulations, appendix_data_application_plots (11/11 exist).
`\bibliographystyle{apalike}` (apalike.bst present in TeX Live); `\bibliography{references}` -> Project_Paper/references.bib (exists; NOT sections/references.bib).
`\includegraphics` (15, all exist, paths relative to Project_Paper/, i.e. the compile directory): figures/growth_lms_boys, growth_lms_girls, growth_pmala_boys, growth_pmala_girls (.pdf), nile_diagnostic_summary, nile_running_mean_stability, nile_scale_trace_acf_diagnostics, nile_trace_acf_diagnostics (.png), nile_individual_sampler.pdf, scal_breakdown.pdf, scal_time.pdf, spod_detrended_admm, spod_detrended_pmala, spod_quantiles_admm, spod_quantiles_pmala (.png).
Packages used: geometry, amsmath, amssymb, amsthm, graphicx, booktabs, hyperref, natbib, algorithm, algpseudocode, xcolor, bm, bbm, caption, subcaption, lineno, bbold. No \input of tables: all tables (simulations 4, appendix_simulations 8, scalability 1, air 1, appendix_pmala 1) are inline tabulars, hand-copied from result files.

### figures/ referenced vs unreferenced (32 files)
Referenced (15): listed above.
UNREFERENCED (13 in figures/ + 4 in _superseded): cost_scaling.pdf/.png (only the label tab:cost_scaling appears; figure not included), scal_pmala_per_obs.pdf, scal_speedup.pdf, munich_* (9: diagnostic_summary.png, individual_sampler.pdf, onizuka_q10_q90.pdf, onizuka_q30_q50_q70.pdf, pmala_q10_q90.pdf, pmala_q30_q50_q70.pdf, running_mean_stability.png, scale_trace_acf_diagnostics.png, trace_acf_diagnostics.png) because Munich was removed 2026-10-28, and `_superseded_k1_munich/` (4 pdf). `munich_*` are inside an `\iffalse` block in appendix_data_application_plots.tex.
Note: no scripts in the repo generate the nile_*, spod_*, growth_lms_*, growth_pmala_* or scal_* figures (generators live outside the repo, e.g. the "Simulations/Scalability/" dir named in a TeX comment and notes/complexity_analysis). growth_joint_* figures exist in Data Applications/Growth/results_joint_k2/figures but the paper uses growth_pmala_* names.

### Other items
- `Notes.txt` (557 B): personal to-do list dated 3/5/26 (Brantley contrast, Pereyra transition, Gibbs/VB literature).
- `compile.bat`: Windows 4-pass build (pdflatex, bibtex, pdflatex x2). Latexmk is not required.
- `noncrossing_review/`: noncrossing_evaluation_review.md, joint_extreme_diagnosis.md, noncrossing_evaluation_plan.tex + .pdf, noncrossing_refs.bib (referenced by nothing in main.tex).
- `notes/` (44M, 278 files, 19 dated sub-folders): each is an edit session snapshot: `before/` copies of the old sections + main.pdf (15 `before/main.pdf` about 2.7 MB each, 24M total), build logs, python edit/validate scripts, audits. Folders: air_drop_se_20261027, air_lap_rows_20261027, air_simulation_20260915, air_simulation_n500_update_20261008, complexity_analysis (benchmark R/py, timings.csv, table bodies; real scalability provenance), extreme_six_levels_20261023, intro_abstract_rewrite_20261001, joint_extreme_results_20261002, joint_sampler_rewrite_20261001 (70 files: qa/ with kernel_check/prox_admm_metric.cpp copy, source_snapshot/), methodology_rewrite_20261001, munich_k2_update_20261013, remove_munich_20261028, s_baseline_b0001_update_20261008, scalability_rewrite_20261001, simulation_revision_20260914 (88 files, 16M), trim_intro_to_air_20261008, vs_s_bprior_update_20261012, writing_sync_20260914, plus loose mixture_gibbs.tex/.pdf. Only `complexity_analysis` and a few build_tables.py hold provenance; most is history already in git.
- LaTeX build artifacts TRACKED in Project_Paper/: main.aux, .bbl, .blg, .fdb_latexmk, .fls, .log, .out, .toc, main.pdf (all tracked). Plus 20 other .log/.aux in notes/.
- Duplicate references.bib: `Project_Paper/references.bib` (sha256 a9acf5f8...) vs `Project_Paper/sections/references.bib` (351b7385...). They DIFFER substantially: the root one is the one used (adds fahrmeir2013, schonbeck2013, vanbuuren2011, cole1992, rigby2005, heng2023, ramdas2016, kozumi2011, yu2011, roberts2007, neal2003, park2008, durmus2018, boyd2011, mehrotra1992, goulart2024, DOIs, braces fixes); the sections one is an older subset that additionally contains cobb1978nile, rue2005gaussian, faulkner2018locally absent from the root file. Check these 3 keys before deleting sections/references.bib (cobb1978nile in particular: the Nile figures are in the paper).

## 4. Code entry points and path coupling

### Main scripts
Simulations/Individual:
- `Individual_Sampler_PMALA_Augmented.R` (42 KB): individual exact augmented P-MALA sampler; `Rscript ... test` runs unit tests, no args = pilot writing `results_pmala_aug/`. Compiles `prox_admm_metric.cpp` found beside itself (via --file / sys.frame / known-roots search incl. `~/Quantile Regression/Simulations/Individual`).
- `individual_air_sim.R`, `Simulations/ADMM/admm_air_sim.R`, `ADMM_QTF_Individual.R`: Brantley air-quality-like simulation with PMALA / ADMM; comments mention `~/Quantile Regression`.
Simulations/Joint:
- `Joint_Sampler_PMALA_Augmented.R` (58 KB): joint non-crossing sampler; `test_prox` runs box-prox tests (needs `clarabel` R package); default pilot writes `results_joint/`. `prox_box_metric.cpp` does `#include "prox_admm_metric.cpp"`; the R script compiles both and requires `../Individual/prox_admm_metric.cpp` (CROSS-FOLDER dependency: Joint -> ../Individual).
Data Applications:
- Growth/`Growth_Joint_PMALA_k2.R`: joint sampler for growth data; `kernel_root` default `../../Simulations` (sourceCpp of Simulations/Joint/prox_box_metric.cpp and Simulations/Individual/prox_admm_metric.cpp; CROSS-FOLDER). `Growth_Joint_checks.R` sources Simulations/Joint/Joint_Sampler_PMALA_Augmented.R via `dirname(dirname(growth_dir))/Simulations/Joint` and has hard-coded `C:/Users/felip/OneDrive/Documents/Quantile Regression/Data Applications/Growth`. `Growth_plots_k2.R`: relative `data/`, `results_joint_k2/`.
- Munich Rent/`Munich_PMALA_Individual_k2.R` (own `prox_admm_metric_irregular.cpp`, a different file from the Simulations one), `Munich_plots_k2.R` (relative `data/munich.rda`, `results_k2/`; note: it expects results_k2/pmala and results_k2/onizuka), `Munich_PMALA_checks.R` (hard-coded `C:/Users/felip/OneDrive/Documents/Quantile Regression` and `C:/Users/felip/AppData/Local/Temp/munich_checks`; reads Simulations/Individual).
- Others/: 7 older Munich scripts (Munich_PMALA.R, _k2, Onizuka_HS(_k2), Individual_Sampler_Scale, Rent Data Application, plots_k2).
All sampler scripts also have a Windows fallback `gpp <- "C:/mingw64/bin/g++.exe"` (only reached if Rcpp::sourceCpp fails).
Simulations NOTS packages (self-contained snapshots run on the Rice NOTS cluster; each has config.R, common.R, worker.R, process_results.R, validate*/submit.sh, slurm/*.slurm, path_guard.sh, environment.sh, SHA256SUMS, `source/` copy of the samplers):
- Individual/NOTS/inner_individual (+ S_b00005, S_b0001, VS_b0001); Joint/inner_joint; Joint/NOTS; Extreme/Extreme_Individual, Extreme_Joint_Sampler, Extreme_Onizuka, Extreme_admm; Temp/air_lap_20261023/stage; Temp/NOTS_Exercise.
- `Simulations/Individual/NOTS/inner_individual/*.py` (download_campaign, download_verified, finish_download_and_cleanup, inspect_nots, monitor, prepare_package, remote_admin, status, upload_package, verify_downloads) are local-to-NOTS ssh/upload/monitor tools.

### Hard-coded paths (all families)
- NOTS remote absolute paths: `/home/fb31/projects/Quant_Reg/{Inner_Individual,Extreme_Individual,Extreme_Joint_Sampler,NOTS_Exercise,...}` in path_guard.sh (`readonly EXTREME_BASE=...`, `INNER_INDIVIDUAL_ROOT=...`, `S_B0001_ROOT`, `PACKAGE_ROOT`), submit.sh, slurm `--chdir`, monitor.py, status.py, upload_package.py, inspect_nots.py, finish_download_and_cleanup.py, Temp/NOTS_Exercise/run.slurm, Temp/air_lap.../edits.py; `R_LIBS_USER=/home/fb31/R/library` in all environment.sh (about 8 files). These are remote cluster paths: they must stay as is; moving the package locally does not break them, but SHA256SUMS cover the files so editing them invalidates the seal.
- Windows laptop paths (will not resolve on this Linux box): `C:/Users/felip/OneDrive/Documents/Quantile Regression/...` in Simulations/Air/lap_20261023/rows.R, Data Applications/Growth/Growth_Joint_checks.R, Munich Rent/Munich_PMALA_checks.R (+ `C:/Users/felip/AppData/Local/Temp/munich_checks`), Temp/extreme_tex_20261023/gen.R (reads Simulations/Extreme/tables_20261023/mse_consolidated_oct7.csv); `C:/Users/felip/OneDrive - Rice University/NOTS Data/Inner_Quant_Ind` in finish_download_and_cleanup.py; `C:/Program Files/R/R-4.4.1/...` and `C:/Program Files/Git/bin/bash.exe` in prepare_package.py.
- Relative-to-old-layout path: `Simulations/Extreme/tables_4lev_20261023/paper_tables_4lev_vs_6lev.R` reads `../../PMALA version Tex Project/sections/simulations.tex` (a folder that no longer exists; the paper is now Project_Paper/). NOTS/paper_reference and compare scripts also cite "PMALA version Tex Project" in provenance.txt.
- Folder-name assumptions: scripts search `Simulations/Individual`, `Simulations/Joint`, `Data Applications/Growth`, `Data Applications/Munich Rent` under `~`, `~/Documents`, `~/OneDrive/Documents` + `Quantile Regression` (that name is the old project root); `Growth_Joint_PMALA_k2.R` uses `dirname(dirname(script_dir))/Simulations`. Error messages say "Open this script from Simulations/Individual". Any rename of `Simulations/`, `Individual/`, `Joint/`, `Data Applications/Growth/` breaks the Growth scripts and the Joint -> Individual include unless updated.
- Extreme packages: `source(file.path(code_root, "Extreme_Individual", "config.R"))` and `Extreme_admm/worker_admm.R`, `Extreme_Onizuka/worker_onizuka.R` source `Extreme_Individual/config.R` and `common_extreme.R` (CROSS-FOLDER, sibling dirs on NOTS); validate_checks.R reads `${EXTREME_BASE_DIR:-/home/fb31/projects/Quant_Reg}/Extreme_Joint_Sampler/source/Joint`. Metadata via `../metadata/...` relative to the run folder.
- No `setwd` in the main samplers; `setwd(src)` appears in package common.R (to compile from `source/`), and `check_defaults.R` does `setwd(file.path(old,"source","Joint"))`.

### Duplicated files (sha256)
- `prox_admm_metric.cpp`: 13 byte-identical copies (ed607632e351...): Simulations/Individual (master), Individual/NOTS/inner_individual/{source,S_b00005/source,S_b0001/source,VS_b0001/source}, Joint/inner_joint/source/Individual, Joint/NOTS/source/Individual, Joint/NOTS/runs/VS_upper6.../code/source/Individual, Extreme_Individual/source, Extreme_Joint_Sampler/source/Individual, Temp/NOTS_Exercise, Project_Paper/notes/joint_sampler_rewrite_20261001/{qa/kernel_check,source_snapshot}.
- `prox_box_metric.cpp`: 5 identical copies (1f0d62dd740a): Simulations/Joint (master), Joint/NOTS/source/Joint, Joint/inner_joint/source/Joint, runs/.../code/source/Joint, Extreme_Joint_Sampler/source/Joint.
- `Joint_Sampler_PMALA_Augmented.R`: 5 identical copies (f6046f5e9963), same locations.
- `Individual_Sampler_PMALA_Augmented.R`: THREE different versions: the top-level master `Simulations/Individual/...` (5add385b2caf: seed 100, tau 0.5, order k=1, b0=0.001, 20000/5000 iterations, adapt_target 0.55, asis_lambda FALSE); the NOTS snapshots (300d2b667877 in Individual/NOTS (4 places), inner_joint, Joint/NOTS, runs/..: k=2, b0=0.01, 30000/10000, asis TRUE, VS, tau 0.1); and `Extreme_Individual/source` (2c91e64bec93: tau 0.9, baseline S, k=1, b0=0.001, 20000/5000). They differ only in the top-of-file default settings block (checked by diff), i.e. the sampler body is the same; the master copy is therefore NOT the code behind the NOTS results.
- `common_extreme.R`: identical in Extreme_Individual and Extreme_Joint_Sampler. `BQTF-function.R` (Onizuka) only in Extreme_Onizuka/source in this repo (the Air_sim copies live on NOTS).
- `prox_admm_metric_irregular.cpp` (Munich): unique, differs from the master.
- Paper main.pdf snapshots: 15 copies of old compiled papers in notes/, Joint/NOTS/runs/.../paper_reference/main.pdf, etc.
- references.bib: two different files (section 3).
- NOTS package scripts: config/common/worker/validate/submit are near-copies across Individual/Joint/Extreme/S_b*/VS_b* packages with small renames.

## 5. Results provenance

The TeX files contain only ONE "% Evidence:" comment: sections/scalability.tex line 6, `Simulations/Scalability/ (rewritten 2026-10-01 ...)`, a folder that does NOT exist in the repo (its generators/results were not committed; closest is `Project_Paper/notes/complexity_analysis/` and `scalability_rewrite_20261001/`). No table is `\input` from a file; every table is typed into the TeX. Where numbers come from (inferred from folder content, comments, provenance.txt):
- Simulations tables (VS/S interior MSE/MAD/MCIW): produced from the Individual NOTS campaign (2026-10-03): `Simulations/Individual/NOTS/inner_individual/` (paper_mse_tables.py in deployment/, paper_reference/{simulations,appendix_pmala}.tex; raw task results are NOT in repo, they are on NOTS scratch and OneDrive). `Joint/inner_joint/paper_reference/{interior_tables_long.csv, provenance.txt}` lists the paper tables tab:vs_int_* and s_int_*.
- Extreme-quantile tables: `Simulations/Extreme/tables_20261008` (crossings and MSE csv+tex), `tables_20261023` (mse_consolidated_oct7.*, all levels, all methods), `tables_4lev_20261023` (paper_tables_4lev/6lev .tex/.md, comparison 4lev vs 6lev) from NOTS runs of Extreme_Individual / Extreme_Joint_Sampler / Extreme_Onizuka / Extreme_admm; raw runs not in repo.
- Joint upper-6-level 100-seed run: `Simulations/Joint/NOTS/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/` (summary/, analysis/, metadata, paper_reference/table2_mse.csv) + `Project_Paper/notes/joint_extreme_results_20261002/`.
- Air simulation (Brantley-style): `Simulations/Air/lap_20261023/attempt_.../{summary.csv, per_task_metrics.csv, results.rds, tables/}` (Onizuka-Laplace add-on) and `oct8_partial/`; code for these lived in Temp/air_lap_20261023/stage plus NOTS Air_sim (not in repo); notes: `Project_Paper/notes/air_*`.
- Scalability: `Project_Paper/notes/complexity_analysis/` (timings.csv, table_cost_scaling_body.tex, make_cost_figure.py) + figures/scal_*.pdf.
- Data applications: SPod air-quality (`Data Applications/Air Quality/S08_*.csv`, figures spod_*; no code in repo), Nile (figures nile_*; no code, no data in repo), Growth (`Data Applications/Growth/results_joint_k2/`, and figures/growth_pmala_*, growth_lms_*).
- Superseded/historical: all of `Data Applications/Munich Rent/` (Munich removed from paper; `Others/results*` are k=1 and earlier k=2 runs, 115M), `Project_Paper/figures/_superseded_k1_munich`, `Simulations/Joint/results_joint/` (local pilots n=500 seed 1; one at b0=0.01, one at b0=0.001), `Simulations/Individual/results_pmala_aug/` (pilot), `Simulations/Air/lap_20261023/oct8_partial`, `Simulations/Joint/inner_joint` (earlier joint package) vs `Joint/NOTS`, `Individual/NOTS/inner_individual/deployment/*` (campaign logs), `Project_Paper/notes/*/before/` (old paper versions), all `noncrossing_review`.

## 6. Temp/ (1.4M, 18 files, all tracked)

| Item | What | Referenced by | Suggestion |
|---|---|---|---|
| `Temp/air_lap_20261023/` (556K): BUILD_REPORT.md, p17-17.png, p17nose-17.png, stage/{config.R, edits.py, README.md, validate_checks.R, worker_onizuka_lap.R} | staging copy of the Onizuka-Laplace air-sim NOTS package (the actual package lives on NOTS: `/home/fb31/projects/Quant_Reg/Air_sim_Lap`) and its build report (SHA, validation record) | nothing in repo; Simulations/Air/lap_20261023 holds its results | ARCHIVE (move to `Simulations/Air/lap_20261023/package_stage/`; it is the only repo record of the code that produced those results). Do not delete. |
| `Temp/extreme_tex_20261023/` (780K): gen.R + p-10..q-14.png | script that regenerates the 6-level extreme MSE TeX tables from `Simulations/Extreme/tables_20261023/mse_consolidated_oct7.csv` + rendered page PNGs (visual checks) | nothing; gen.R has a Windows absolute path | ARCHIVE gen.R next to tables_20261023 (fix path); the 5 PNG page renders can be deleted (pure previews). |
| `Temp/NOTS_Exercise/` (64K): worker.R, sampler.R, prox_admm_metric.cpp, run.slurm | 3000-task Slurm array exercise (seeds x tau x noise x VS/S) running the individual sampler; a copy-pasted tutorial/test package | nothing | DELETE or ARCHIVE (it is a throwaway exercise; sampler.R is a copy of Individual sampler, cpp is a duplicate of the master). Keep only if run.slurm documents the array pattern. |

## 7. Papers/ (21M, 19 files, tracked)

READING_LIST.md says every PDF is a "legitimate open copy" (arXiv/author page) or a file the user added himself; copyright-sensitive third-party items for a public repo: any publisher-version PDF. Sizes:
Kowal_Dynamic_Shrinkage 4.38M; Padilla_Risk Bounds for Quantile Trend Filtering 3.23M; Onizuka_2023 2.50M; Brantley_2020 1.60M; Pereyra 2016 1.54M; Large Prior (Bedoya & Li, own work) 1.33M; TF_2014 (Tibshirani) 1.25M; Bach_Klein_2022 0.95M; Syring_Martin 2023 0.79M; Agapiou_2024 0.55M; Agapiou_2021 0.54M; Wang_2014 0.50M; Giordano_2023 0.49M; Atchade_2017 0.42M; Ghosal_2007 0.39M; Castillo_2015 0.40M; Sriram_2013 0.38M; Fill_2004 0.33M; READING_LIST.md 7 KB.
Third-party (copyright-sensitive if the repo is made public or shared): all except `Large Prior.pdf` (own manuscript). Journal-typeset ones most at risk: Pereyra 2016, Onizuka_2023, Brantley_2020, Kowal, Padilla, TF_2014, Ghosal_2007, Castillo_2015, Sriram_2013, Fill_2004, Syring_Martin 2023, Wang_2014, Giordano_2023, Agapiou_2021/2024 (some may be arXiv versions; not verified). Recommendation: keep in repo only if private; otherwise git-ignore Papers/*.pdf and keep READING_LIST.md. Filenames with spaces: `Large Prior.pdf`, `Pereyra 2016.pdf`, `Syring_Martin 2023.pdf`, `Padilla_Risk Bounds for Quantile Trend Filtering.pdf`.

## 8. Theory/ and Engineering/

Theory/ (228K, 31 files; tracked, with ignore for __pycache__; the department owns it):
- T01_Prior_Art: REPORT.md, search_log.md
- T02_Syring_Martin: ASSESSMENT.md
- T03_Feasibility: MEMO.md (40 KB), STATEMENT_DRAFT.md, reviews/ (1 file), scratch/ (25 files incl. .out logs, scripts, ignored __pycache__)
- T04_Template_Sweep: search_log.md, SHORTLIST.md
- `Theory/.gitignore`
Engineering/ (48K, 8 files, UNTRACKED, owned by the engineering department; includes this E-03 work's neighbours):
- E02_Rate_Sims: analyze.R, banded_ls.cpp, calibrate_c.R, e02_lib.R (17 KB), run_grid.R, validate_samplers.R, free_check/{aggregate.R, run_free_check.R}
(mtime Nov 22 15:36-16:07: still being edited, so do not move.)

## 9. Smoke tests (run in /tmp, repo untouched)

Machine: latexmk /home/fb31/.local/bin/latexmk, pdflatex /usr/bin/pdflatex, bibtex present; biber absent (not needed, natbib+bibtex). R, Rscript, g++, python3 present. R packages found: Rcpp, RcppArmadillo, glmgen, Matrix, ggplot2, MASS. Missing: clarabel, mvtnorm, statmod, quantreg.

(a) Paper build. Copied main.tex, references.bib, sections/, figures/ to /tmp/claude-71711/paper_build_test and ran `latexmk -pdf -interaction=nonstopmode main.tex`: FAILED in 0.6 s with `LaTeX Error: File 'algpseudocode.sty' not found` (algorithmicx not installed). Also missing per `kpsewhich`: `bbm.sty` and `bbold.sty`. All other packages (geometry, amsmath/symb/thm, graphicx, booktabs, hyperref, natbib, algorithm, xcolor, bm, caption, subcaption, lineno) and apalike.bst are present. Fix needs `tlmgr` (algorithmicx, bbm-macros, bbold) or a user-level texmf install; the repo itself is complete (11/11 sections, 15/15 figures, references.bib present). The tracked main.log shows the authors' machine used TeX Live 2026 and built fine (28 Oct 2026). Smoke command once packages exist: `cd Project_Paper && latexmk -pdf main.tex` (or compile.bat sequence).

(b) Individual sampler tests: copied Simulations/Individual (without NOTS) to /tmp/claude-71711/smoke/Simulations/Individual, ran `OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 Rscript Individual_Sampler_PMALA_Augmented.R test`: PASS, "all tests passed", exit 0, 98 s (tests 1-7 incl. ALD augmentation, GIG, prox vs glmgen, P-MALA vs grid integration, ASIS). Writes nothing (the test branch quits before output); sourceCpp cache in tempdir. Runnable in the repo.

(c) Joint sampler tests: copied Joint_Sampler_PMALA_Augmented.R + prox_box_metric.cpp to smoke/Simulations/Joint and the Individual folder to smoke/Simulations/Individual; ran `Rscript Joint_Sampler_PMALA_Augmented.R test_prox`: FAIL at test P3 after 25 s with `Error in loadNamespace(x): there is no package called 'clarabel'`. P1 (free box bitwise unbounded) and P2 (closed form, max err 8.5e-12) passed before the failure. Cause: missing R package `clarabel` on this machine (used as reference solver in the tests), not a code or layout problem. Install `install.packages("clarabel")` to complete; not installed since the task is read-only. The test also needs the Individual folder at `../Individual/`.

## Summary of problems relevant to reorganization
1. Size: 543 MB (191 MB .git); 139 MB Air Quality CSVs and about 115 MB Munich Rent/Others results account for most of the working tree weight; 24 MB of repeated paper PDFs in notes/.
2. No root .gitignore; LaTeX artifacts, pyc, logs tracked.
3. Heavy duplication of samplers (13 copies of one cpp) inside NOTS packages and notes; these are deliberate frozen snapshots with SHA256SUMS, do not dedupe in place; the top-level Individual sampler differs from the snapshots in its settings block.
4. Path coupling: Joint->../Individual cpp include; Growth scripts -> ../../Simulations; Extreme workers -> sibling Extreme_Individual; Windows absolute paths in 5 scripts; a stale reference to "PMALA version Tex Project"; `Quantile Regression` old-root name embedded in search logic.
5. Paper TeX evidence comment points at nonexistent Simulations/Scalability; no scripts for nile/spod/growth_lms figures; stale sections/references.bib that differs from the real one.
6. Smoke: Individual tests PASS (98 s); Joint prox tests FAIL on missing `clarabel` package (after P1 and P2 pass); paper build FAILS on missing LaTeX packages algpseudocode, bbm, bbold.
