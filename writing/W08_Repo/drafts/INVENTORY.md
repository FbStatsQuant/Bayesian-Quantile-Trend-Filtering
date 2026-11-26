# W-08 INVENTORY: mechanical pass over the tracked public repo

Read-only scan, tracked files only (`git ls-files`). Snapshot: HEAD `19be187`, 1,759 tracked files, 334.2 MB (apparent bytes). `.git` is 399 MB on this disk. Reference and privacy scans exclude `writing/W08_Repo/` (these drafts quote the patterns). Reference matches use `git grep -nI -F` for `<path>/`, then a boundary filter so that `lean/` does not match `clean/`. Values of personal strings are masked as `***` and column labels are generic. Counts "N (M)": N = all files, M = after dropping the one-shot E-03 migration scripts and their `03_new_files/` copies (`engineering/E03_Repo_Organization/migration/**`), which only mention old and new paths.

## 0. Ten-line summary

1. 1,759 tracked files, 334 MB. `applications/` is 254 MB (76%): 7 SPod CSVs of 19 MB each (134 MB) plus `Munich Rent/Others/` draws (115 MB). The 20 largest files are 67% of all bytes. 10 tracked files exceed the 5 MB limit of `.githooks/pre-commit` (allowlist empty), among them a 10.3 MB `monitor/history.jsonl` that `.gitignore` excludes.
2. Public-facing code is small: `method/` 7 files (244 KB); `lean/` 121 files (1.8 MB, 58 `.lean` modules); `paper/` 299 files, of which 263 are `paper/history/` (22 MB). Department folders (`engineering/` 455, `theory/` 174, `writing/` 26) are 655 files, 37% of the repo.
3. Reference graph: **`lean/` is referenced by nothing outside itself** (0 files; the root README map does not mention it). `archive/`, `literature/`, `theory/`, `writing/`, `paper/history/`, `.githooks/` are referenced only from markdown, comments, `.gitignore` or one-shot migration scripts: moving them breaks docs only.
4. A move **breaks code** for: `method/` (at least 37 live scripts in `engineering/`, `applications/Growth/`, `experiments/pilots/`), `experiments/` (12 live scripts, all in `engineering/E07/E08/E14/E15/E17/E18`), `paper/` (5 scripts read `paper/sections/*.tex`), `applications/` (`engineering/E18_Air_Refit/e18_prepare_spod.R`, `Growth` self-locator), `engineering/` (14 scripts hard-code `"engineering"` in `file.path`, 78 contain `engineering/`). `paper/figures/` breaks the LaTeX build (10 `\includegraphics{figures/...}` in 3 section files).
5. No checksum or manifest file references any candidate folder by repo-relative path. `lean/SHA256SUMS.txt` lists 58 `.lean` files by path relative to `lean/` (all 58 verify now); none of the 39 `lean/` files with personal strings is covered by it.
6. Privacy: 306 files carry at least one string from the brief's patterns (`/home/` 1,281 lines in 202 files; login-id 1,381 lines in 228 files; `/projects/` 168; lab-host 273; cluster-host 17; group-id 21; allocation 7; IPv4 2 in 1 file) and 37 more carry only a Windows user path `C:/Users/***` (1,904 lines in 44 files, 1,867 of them in 29 `paper/history/` build logs): 343 files in all. Classes of the 306 files: (a) docs 122, (b) code 129, (c) frozen records 55.
7. 81 of the 306 files have their current content hash listed in a checksum file: 75 in the PC-archive manifest `engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256` (47 of them only there), 34 in sibling `SHA256SUMS` of `experiments/interior_quantiles/individual_nots_20261003/` (+3 sub-packages), `experiments/joint_upper_levels/` (+ run `code/`, `metadata/`) and one Munich `SHA256SUMS.inputs`. Editing them breaks sealed provenance. Everything in `lean/`, `engineering/E02..E19` code and docs, `theory/`, `archive/`, root README is uncovered and easy to scrub.
8. Secrets: none found (no tokens, keys, passwords, `.netrc`, ssh config, `.env`; Slurm account is the public `commons`). Only the ssh host alias `nots` and one 2-IP login-node note. Author emails appear on the title page, in 6 frozen `paper/history/` snapshots and in `experiments/joint_upper_levels/paper_reference/main.txt`; 3 third-party emails (reviewed paper's authors) sit in `paper/history/simulation_revision_20260914/Brantley_2020.txt`.
9. Links: 7 relative markdown links in the 11 requested README/doc files, **0 broken**. The other READMEs use code spans, not links; of 150 code-span path tokens, 4 name things that no longer exist: `engineering/E03_Repo_Organization/hash_map.tsv` is not tracked (a real dead pointer), `Simulations/Individual/`, `Temp/NOTS_Exercise` and `paper/history/complexity_analysis` are old or deleted names, and the text says so (Part 4).
10. Existing defects worth fixing before publishing: 3 of 30 entries in `experiments/interior_quantiles/individual_nots_20261003/SHA256SUMS` fail (`audit/nots_readonly_probe.txt`, `audit/static_checks.json`, `paper_reference/simulations.tex`) although `experiments/README.md` says the seals stay valid; `engineering/E03_Repo_Organization/migration/01b_heavy_rm.sh` removes the SPod CSVs and Munich draws, which are still tracked, so it has not been applied.

## 1. Public footprint

### 1.1 Top-level folders (tracked files only)

Sizes: `git ls-files -z <dir> | xargs -0 du -ch | tail -1` (disk blocks) and apparent bytes.

| Folder | Files | `du -ch` | Bytes | What it holds |
|---|---:|---:|---:|---|
| (root) | 5 | n/a | 12.7 KB | `README.md`, `LICENSE`, `CITATION.cff`, `.gitignore`, `.gitattributes` |
| `.githooks/` | 2 | 8.0 K | 1.4 KB | pre-commit hook (refuses staged files over 5 MB) and its empty allowlist |
| `applications/` | 157 | 254 M | 253.0 MB | real-data analyses: Growth (fits, plots), Air Quality (raw SPod CSVs), Munich Rent (dropped application) |
| `archive/` | 17 | 3.0 M | 2.9 MB | superseded Munich figures, two scratch PNGs, `archived_campaigns.md` |
| `engineering/` | 455 | 20 M | 18.2 MB | Engineering task folders E02 to E19: rate sims, sampler checks, tuning-free study, air refit, prior studies, repo migration |
| `experiments/` | 493 | 26 M | 24.7 MB | campaigns behind the paper tables: frozen NOTS packages, summaries, pilots, scalability |
| `lean/` | 121 | 1.8 M | 1.5 MB | Lean 4 / Mathlib formalization: 58 `.lean` modules, `README.md`, `SHA256SUMS.txt`, notes and reviews |
| `literature/` | 3 | 1.3 M | 1.3 MB | reading list, README, our own `Large Prior.pdf` |
| `method/` | 7 | 244 K | 228.6 KB | canonical samplers: individual P-MALA, joint non-crossing, ADMM-QTF baseline, two `.cpp` prox kernels |
| `paper/` | 299 | 29 M | 28.2 MB | manuscript (`main.tex`, `sections/`, `figures/`, `main.pdf`) and `history/` of dated edit sessions |
| `theory/` | 174 | 3.0 M | 2.6 MB | Theory task folders T01 to T10, `THEOREM_INDEX.md` |
| `writing/` | 26 | 1.7 M | 1.6 MB | Writing task folders W01 to W08 (statements, theorems, paper sync, this proposal) |
| **Total** | **1,759** | | **334.2 MB** | |

### 1.2 Second level

Bytes are apparent sizes summed over tracked files (they differ from `du -ch` by block rounding only).

| Folder | Files | Size | What it holds |
|---|---:|---:|---|
| `experiments/air_simulation` | 22 | 2.3 MB | air simulation drivers (PMALA, ADMM) and the Onizuka-Laplace add-on (table `air_n500`) |
| `experiments/extreme_quantiles` | 90 | 864 KB | extreme upper levels: packages, tables 20261008/20261023, crossing tables |
| `experiments/interior_quantiles` | 192 | 2.2 MB | interior levels: individual NOTS package (VS/S sub-packages) and joint NOTS package |
| `experiments/joint_upper_levels` | 108 | 14.3 MB | six-level joint run (0.90 to 0.99); contains the 10.3 MB `monitor/history.jsonl` |
| `experiments/pilots` | 63 | 4.7 MB | pilot logs and runs (joint results, default prior, lambda mixing) |
| `experiments/scalability` | 17 | 316 KB | time-per-sweep benchmark, cost table, `figures_unused/` |
| `applications/Air Quality` | 8 | 133.7 MB | seven raw SPod CSVs (about 19 MB each) and `DATA.md` |
| `applications/Growth` | 23 | 2.4 MB | Dutch growth data, joint fit script, plots, `results_joint_k2/` |
| `applications/Munich Rent` | 125 | 116.9 MB | dropped Munich application; `Others/results*` draws (`.rds`, up to 23 MB) |
| `engineering/E02_Rate_Sims` | 34 | 388 KB | contraction-rate simulations, final report |
| `engineering/E03_Repo_Organization` | 31 | 161 KB | repo reorganization: inventory, proposal, `migration/` scripts |
| `engineering/E04_Sampler_Check` | 8 | 35 KB | sampler fitness check |
| `engineering/E05_PMALA_Fix` | 3 | 51 KB | P-MALA fix test |
| `engineering/E06_Rate_Validation` | 18 | 215 KB | rate validation, paper-section stub |
| `engineering/E07_Tuning_Free` | 143 | 10.0 MB | tuning-free sampler study (sampler copies, `joint_gibbs/`, `sigma_sprint/`, advisors) |
| `engineering/E08_Lambda_Prior` | 7 | 257 KB | lambda ~ Gamma(1, b0) quick look |
| `engineering/E09_NOTS_Cleanup` | 5 | 899 KB | NOTS cleanup; `quant_reg_archive/MANIFEST.sha256` (4,787 hashes) |
| `engineering/E10_Lambda_Mixing` | 21 | 4.3 MB | lambda mixing diagnostics |
| `engineering/E12_Disk_Reorg` | 1 | 9 KB | disk reorganization note |
| `engineering/E13_Joint_b0` | 25 | 154 KB | joint sampler, choice of b0 |
| `engineering/E14_Inner_Rerun` | 39 | 234 KB | interior-quantile rerun against the paper tables |
| `engineering/E15_Extreme_Individual` | 22 | 87 KB | extreme-level individual rerun |
| `engineering/E16_n2000_b0` | 8 | 24 KB | lambda-prior decision at n = 2000 |
| `engineering/E17_b0_1e5` | 40 | 115 KB | individual simulations at b0 = 1e-5, `ops/` scripts |
| `engineering/E18_Air_Refit` | 49 | 1.3 MB | air-quality refit, exports for Writing |
| `engineering/E19_Default_Prior` | 1 | 5 KB | default-prior pre-registration |
| `theory/T01..T10` (10 folders) | 2 / 1 / 41 / 2 / 28 / 62 / 12 / 4 / 15 / 3 | 37 KB / 8 KB / 198 KB / 20 KB / 191 KB / 954 KB / 928 KB / 15 KB / 280 KB / 5 KB | prior art, Syring-Martin, feasibility, template sweep, proofs, alignment, Bayes Thm 3, joint feasibility, joint theorem, g_r positivity |
| `writing/W01..W08` (7 folders) | 7 / 2 / 2 / 3 / 2 / 4 / 6 | 535 KB / 471 KB / 365 KB / 107 KB / 34 KB / 25 KB / 143 KB | statements, theorems, theorem, paper, E17 (not adopted), appendix, this repo proposal |
| `paper/figures` | 15 | 3.3 MB | 15 figures: 4 growth, 2 scal, 4 SPod, 5 `nile_*` (the 5 `nile_*` are not referenced by any `.tex`) |
| `paper/history` | 263 | 22.3 MB | dated edit-session snapshots, build logs, reviews |
| `paper/sections` | 15 | 175 KB | the 15 section `.tex` files |
| `lean/BQTF`, `lean/notes`, `lean/docs` | 56 / 55 / 1 (+ 9 root files) | | modules / notes (logs, reviews, audits) / statements |
| `method/individual`, `joint`, `admm_qtf` | 3 / 2 / 1 (+ README) | | individual P-MALA + prox kernel + note; joint sampler + box prox; ADMM baseline |

### 1.3 Twenty largest tracked files

| # | Size | File |
|---:|---:|---|
| 1 | 23.0 MB | `applications/Munich Rent/Others/results_onizuka_k2/all_quantile_fits.rds` |
| 2 | 19.2 MB | `applications/Air Quality/S08_2018-06-17.csv` |
| 3 | 19.2 MB | `applications/Air Quality/S08_2018-06-18.csv` |
| 4 | 19.2 MB | `applications/Air Quality/S08_2018-06-19.csv` |
| 5 | 19.1 MB | `applications/Air Quality/S08_2018-06-16.csv` |
| 6 | 19.1 MB | `applications/Air Quality/S08_2018-06-15.csv` |
| 7 | 19.0 MB | `applications/Air Quality/S08_2018-06-21.csv` |
| 8 | 19.0 MB | `applications/Air Quality/S08_2018-06-20.csv` |
| 9 | 11.9 MB | `applications/Munich Rent/Others/results/all_quantile_fits.rds` |
| 10 | 10.3 MB | `experiments/joint_upper_levels/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/metadata/monitor/history.jsonl` |
| 11 to 20 | 4.6 MB each | ten `fit_tau_{10,30,50,70,90}.rds` under `applications/Munich Rent/Others/results_onizuka_k2/` (5) and `.../results_onizuka/` (5) |

The first 20 files hold 224.8 MB (MiB, as everywhere in this file), 67% of all bytes. Files over 5 MB: 10 (rows 1 to 10). `paper/main.pdf` is 2.2 MB; the largest `paper/history` file is 2.7 MB.

## 2. Reference graph

Method: `git grep -nI -F -- '<path>/'` over tracked files, keeping lines where the match is not preceded by a letter, digit, `_` or `-`, and dropping files inside the folder itself. Because most scripts and TeX files use relative or split paths, two supplementary greps were added: quoted components (`file.path(..., "method", ...)`, `"experiments"`) and relative names (`figures/`, `history/`, `sections/`). Categories of the referring file: **MD** = `*.md`, README, `CITATION.cff`, LICENSE; **Script** = `.R .sh .slurm .py .cpp`, `.githooks/*`; **TeX** = `.tex .bib`; **lean SHA** = `lean/SHA256SUMS.txt`; **Run rec.** = `RUN_METADATA*`, `*.log`, `*.csv/.tsv/.json/.txt`, checksum and manifest files; **Other** = `.gitignore`, `.gitattributes`, `.lean`, `.patch`.

### 2.1 Summary table (files outside the folder that reference it; N (M) as defined above)

| Folder | Files | MD | Script | TeX | lean SHA | Run rec. | Other | A move breaks |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `applications/` | 15 (5) | 11 (5) | 4 (0) | 0 | 0 | 0 | 0 | **code** (1 live script by path; Growth self-locator; see 2.3) |
| `archive/` | 12 (5) | 10 (5) | 2 (0) | 0 | 0 | 0 | 0 | docs only |
| `engineering/` | 15 (15) | 13 (13) | 2 (2) | 0 | 0 | 0 | 0 | **code, internal** (14 scripts hard-code `"engineering"`, 78 contain `engineering/`); outside refs are docs and 2 comments |
| `experiments/` | 40 (28) | 27 (19) | 11 (7) | 1 (1) | 0 | 1 (1) | 0 | **code** (12 live scripts in `engineering/`) |
| `lean/` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **nothing** (no outside reference at all) |
| `literature/` | 17 (10) | 13 (9) | 2 (0) | 0 | 0 | 0 | 2 (1) | docs + `.gitignore` (2 lines) |
| `method/` | 64 (55) | 22 (17) | 40 (37) | 0 | 0 | 0 | 2 (1) | **code** (at least 37 live scripts) |
| `paper/` | 90 (79) | 74 (68) | 9 (6) | 2 (2) | 0 | 1 (0) | 4 (3) | **code** (5 scripts read `paper/sections/*.tex`), `.gitignore` (10 lines) |
| `theory/` | 21 (15) | 14 (10) | 4 (2) | 2 (2) | 0 | 0 | 1 (1) | docs and comments only |
| `writing/` | 8 (8) | 5 (5) | 1 (1) | 1 (1) | 0 | 1 (1) | 0 | docs and comments only |
| `.githooks/` | 6 (2) | 1 (1) | 3 (0) | 0 | 0 | 0 | 2 (1) | docs (clone-time `core.hooksPath` setting in README) |
| `paper/figures/` | 4 (2) | 3 (1) | 1 (0) | 0 | 0 | 0 | 0 | by prefix: docs only. By relative name `figures/`: **LaTeX build** (10 `\includegraphics` in 3 section files + `paper/README.md`) |
| `paper/history/` | 7 (3) | 5 (3) | 2 (0) | 0 | 0 | 0 | 0 | docs only (`.gitignore` has the glob `**/history/**/build/`) |

Checksum files: **no** checksum or manifest file contains a current repo-relative path to any of these folders. `lean/SHA256SUMS.txt` has 58 lines, paths relative to `lean/` (`AxiomCheck.lean`, `BQTF.lean`, `BQTF/...`), so moving `lean/` as a unit is safe for it. The package `SHA256SUMS` under `experiments/` use paths relative to their package, so a whole-folder move of `experiments/` is safe for them but moving a file in or out of a package is not. `paper/history/joint_sampler_rewrite_20261001/source_snapshot_sha256.json` lists 16 files by an old absolute Windows path (not the current one); it is already unusable as a verifier.

Not matched by any candidate path but live: `paper/main.tex` uses `\input{sections/...}` (14 lines), `\bibliography{references}`; `paper/sections/numerical.tex` `\input{sections/...}` (4 lines); 10 `\includegraphics{figures/...}` in `paper/sections/{data_application,appendix_data_application_plots,scalability}.tex`. No `\graphicspath`. `paper/latexmkrc` and `paper/compile.bat` are inside `paper/`. All of these are relative to `paper/`, so moving `paper/` as a unit is TeX-safe.

### 2.2 Referencing files by folder

MD files are aggregated by the folder they live in (count). All Script, TeX, Run rec. and Other files are listed. "E03 mig." = `engineering/E03_Repo_Organization/migration/{01_moves,01b_heavy_rm,04_smoke,05_history_rewrite}.sh` and `03_new_files/` copies.

**`applications/`**
- MD (11): `README.md`, `archive/README.md`, `experiments/README.md`, `engineering/E18_Air_Refit` ×1, `engineering/E03_Repo_Organization` ×7.
- Script: E03 mig. only (`01_moves.sh:153,168,204`, `01b_heavy_rm.sh:11,16,17,19`, `04_smoke.sh:56,61`, `05_history_rewrite.sh:10`). Quoted-path: `engineering/E18_Air_Refit/e18_prepare_spod.R:7` (`file.path("applications", "Air Quality", ...)`), `applications/Growth/Growth_Joint_PMALA_k2.R:50` (self-locator `file.path("applications", "Growth")`).

**`archive/`**
- MD (10): `README.md`, `applications/README.md`, `experiments/README.md`, `paper/README.md`, `engineering/E03_Repo_Organization` ×6. Script: E03 mig. only (`01_moves.sh:157..164`, `05_history_rewrite.sh:50`). No TeX, no run records.

**`engineering/`**
- MD (13): `README.md`, `archive/README.md`, `archive/archived_campaigns.md`, `theory/ALIGNMENT_MEMO.md`, `theory/T05_Proofs`, `theory/T06_Alignment` ×3, `theory/T07_Bayes_Thm3`, `writing/W06_E17`, `writing/W07_Appendix` ×3.
- Script (2, comments): `method/individual/Individual_Sampler_PMALA_Augmented.R:419,435`, `method/joint/Joint_Sampler_PMALA_Augmented.R:314,330` (point to `engineering/E10_Lambda_Mixing`).

**`experiments/`**
- MD (27): `README.md`, `archive/archived_campaigns.md`, `method/README.md`, `paper/README.md`, `engineering/E03_Repo_Organization` ×10, `E07_Tuning_Free` ×2, `E08_Lambda_Prior`, `E14_Inner_Rerun` ×3, `E15_Extreme_Individual` ×2, `E18_Air_Refit` ×2, `writing/W07_Appendix` ×3.
- Script (11; live 7): `engineering/E07_Tuning_Free/joint_gibbs/joint_gate.R:7-8`, `felipe_run_v3.R:1`; `engineering/E08_Lambda_Prior/e08_run.R:51`; `engineering/E17_b0_1e5/e17_snapshot.sh:20-21`; `engineering/E18_Air_Refit/e18_common.R:15`, `e18_snapshot.sh:11,17`, `e18_verify_data.R:4`; E03 mig. ×4. Quoted-path (`file.path(..., "experiments", ...)`): `engineering/E14_Inner_Rerun/e14_data.R:5`, `E15_Extreme_Individual/e15_data.R:3`, `e15_tables.R:126`, `e15_verify_data.R:9`, `E17_b0_1e5/e17_tables.R:5`, `E18_Air_Refit/e18_common.R:12,35`.
- TeX (1, comment): `paper/sections/scalability.tex:6`. Run rec. (1): `engineering/E15_Extreme_Individual/published_values.csv` (84 data lines each carry an `experiments/extreme_quantiles/tables...` source path; provenance of published values).

**`lean/`**: none (0 files). Lean sources mention `paper/sections/*.tex` in comments, i.e. `lean/` references the paper, not the reverse.

**`literature/`**
- MD (13): root `README.md`, `theory/T03_Feasibility` ×1, `theory/T04_Template_Sweep` ×2, `theory/T07_Bayes_Thm3` ×2, `writing/W04_Paper` ×2, `engineering/E03_Repo_Organization` ×5. Script: E03 mig. only (`01_moves.sh:185,209,210,217`, `05_history_rewrite.sh:14,32,43`). Other: `.gitignore:43-44` (`literature/*.pdf`, `!literature/Large Prior.pdf`) plus its E03 copy.

**`method/`**
- MD (22): `README.md`, `applications/README.md`, `theory/T06_Alignment`, `engineering/E03_Repo_Organization` ×6, `E04_Sampler_Check` ×2, `E07_Tuning_Free` ×4, `E08_Lambda_Prior`, `E10_Lambda_Mixing`, `E13_Joint_b0` ×3, `E14_Inner_Rerun` ×2.
- Script (37 live files mention the path; most load it via `file.path`/`readLines`/`setwd`/`source`, the rest cite it in comments or `stop()` text) by folder: `applications/Growth` 2 (`Growth_Joint_PMALA_k2.R:3,7,30,31,99`, `Growth_Joint_checks.R:7,15`); `engineering/E02_Rate_Sims` 2 (`e02_lib.R:22` and `free_check/run_free_check.R:3` hard-code an absolute `/home/***/...` path to `method/individual`); `E05_PMALA_Fix` 1; `E07_Tuning_Free` 13 (`joint_gibbs/common_v3.R:3`, `validate/common.R:3`, `validate/common2.R:3`, `smoke_scripts/common.R:10-11`, `e07_joint2.R:16`, `felipe_run*.R`, `joint_gate.R`, plus 4 sampler copies whose `stop()` message and header cite `method/individual`); `E08_Lambda_Prior` 2; `E10_Lambda_Mixing` 4 (`E10_CODE` default `"method/individual"`); `E13_Joint_b0` 7 (`file.path(ROOT, "method/joint")`); `E17_b0_1e5/e17_snapshot.sh:15-16` and `E18_Air_Refit/e18_snapshot.sh:12-13` (`git archive "$sampler" method/...`, a path inside a git ref); `E18_Air_Refit/diag/warm_probe.R:48`; `experiments/pilots` 3 (`default_prior_VS_normal_t075/run.R:7`, `lambda_mixing/run_variant.R:8`, `test_asis_general.R:3`, cwd = repo root); E03 mig. 3.
- Other: `.gitignore:27-29` (`method/**/results_*`) plus its E03 copy. Not affected: `experiments/**/source/` are frozen copies of the samplers and do not read `method/`. Samplers locate their own kernels relative to themselves (`method/joint` includes `../individual/prox_admm_metric.cpp`).

**`paper/`**
- MD (74): root `README.md`, `LICENSE`, `experiments/README.md`, `engineering/E03_Repo_Organization` ×7, `E06`, `E07` ×2, `E12`, `E14` ×2, `E15` ×3, `E18`; `lean/PLAN.md`, `lean/docs`, `lean/notes` ×35; `theory/T04`, `T07`, `T08` ×3, `T09` ×6, `T10`, `writing/W04_Paper` ×3, `W07_Appendix` ×2.
- Script (9; live 6): `engineering/E15_Extreme_Individual/e15_claims.R:124` (link text), `E18_Air_Refit/e18_verify_data.R:58`, `experiments/extreme_quantiles/tables_4lev_20261023/check_vs_existing_096_099_table.R:6`, `paper_tables_4lev_vs_6lev.R:47`, `writing/W01_Statements/simulation_laws.R:2` (comment), `.githooks/size_allowlist.txt:2` (comment); quoted: `engineering/E14_Inner_Rerun/e14_tables.R:12`, `E15_Extreme_Individual/e15_tables.R:9` (`file.path(root, "paper", "sections", ...)`).
- TeX (2, comments): `theory/T09_Joint_Theorem/T09.tex:11,24`, `engineering/E06_Rate_Validation/paper_section.tex:1`. Other (4): `.gitignore:1-10`, `lean/BQTF/Spec.lean:7-8`, `writing/W06_E17/E17_paper_NOT_ADOPTED.patch` (17 lines, a patch against `paper/sections/*.tex`).

**`theory/`**
- MD (14): `README.md`, `literature/READING_LIST.md`, `lean/PLAN.md`, `lean/notes` ×5, `engineering/E03_Repo_Organization` ×5, `E12_Disk_Reorg`.
- Script (2 comments): `engineering/E07_Tuning_Free/route_a/kappa_pilot.R:1`, `writing/W01_Statements/gap_ratios.R:4`. TeX (2): `writing/W01_Statements/statements.tex:407,441` and `W02_Theorems/theorems.tex:51` (`\source{\texttt{theory/...}}` typeset provenance text, not file loading). Other (1): `lean/BQTF/Gram.lean:9` (comment).

**`writing/`**: MD (5): `README.md`, `engineering/E07_Tuning_Free` ×3, `theory/ALIGNMENT_MEMO.md`. Script: `theory/T05_Proofs/checks/gap_ratio_check.py:1` (docstring). TeX: `paper/sections/theory.tex:2` (comment). Run rec.: `theory/T05_Proofs/checks/gap_ratio_check.out:1`.

**`.githooks/`**: MD (1) `engineering/E03_Repo_Organization`; Script: E03 mig. only; Other: `.gitattributes:19` and its E03 copy. The root README tells users to run `git config core.hooksPath .githooks` (code span).

**`paper/figures/`** (prefix match): MD (3): root `README.md` (via `paper/figures`), `engineering/E03_Repo_Organization` ×2; Script: E03 mig. (`01_moves.sh:144,161,163`). Relative-name match (`figures/` inside `paper/`): `paper/README.md`, `paper/sections/data_application.tex` (3), `appendix_data_application_plots.tex` (5), `scalability.tex` (2). 5 of 15 files (`nile_*`) are unreferenced.

**`paper/history/`**: MD (5): `README.md`, `paper/README.md`, `experiments/README.md`, `engineering/E03_Repo_Organization/PROPOSAL.md`, `engineering/E14_Inner_Rerun`; Script: E03 mig. (`01_moves.sh:76,77,79,141`, `05_history_rewrite.sh:12,51`).

### 2.3 Move verdicts (for Engineering sign-off)

| Candidate | Breaks code? | What to edit if it moves |
|---|---|---|
| `lean/` | no | nothing outside; add `lean/` to the root README map |
| `archive/`, `literature/` | no | docs (10 / 13 MD files); `.gitignore:43-44` for `literature/` |
| `theory/`, `writing/` | no | docs; 4 comments; 2 typeset `\source{}` strings |
| `paper/history/` | no | `README.md`, `paper/README.md`, `experiments/README.md`, 2 E-docs |
| `.githooks/` | no | `README.md` (`core.hooksPath` instruction), `.gitattributes:19` |
| `engineering/` | internal yes | 14 scripts with `file.path(..., "engineering", ...)`, 78 with `engineering/` (defaults, usage lines, slurm layout `e14.slurm`), 2 comments in `method/` |
| `experiments/` | yes | 12 engineering scripts (E07, E08, E14, E15, E17, E18) plus `published_values.csv` provenance text |
| `applications/` | yes | `e18_prepare_spod.R:7`, Growth self-locator (`Growth_Joint_PMALA_k2.R:50`), Growth `../../method` default (`:31,99`) |
| `paper/` | yes | `e18_verify_data.R:58`, 2 table scripts under `tables_4lev_20261023/`, `e14_tables.R:12`, `e15_tables.R:9`, `.gitignore` 10 lines, `lean/BQTF/Spec.lean` comments |
| `paper/figures/` | LaTeX | 10 `\includegraphics` in 3 section files (no `\graphicspath`) |
| `method/` | yes | at least 37 scripts (list in 2.2), `.gitignore:27-29`, README Quick start |

## 3. Privacy inventory

Patterns (as listed in the brief, plus Windows user paths found along the way): `/home/`, login-id, group-id, `/projects/`, cluster-host (the NOTS login-host domain), lab-host (the lab workstation's name, case-insensitive), `rice.edu`, allocation name, `user@host` strings, IPv4, and `C:/Users/***`. Excluded as not personal or not a hit: author emails on title pages (`paper/main.tex:54,56,58` and their frozen copies, see 3.5), `noreply@anthropic.com` trailers in 3 E03 scripts, and 16 lines where a 4-6 letter pattern appears inside a SHA-256 hex string (e.g. in `MANIFEST.sha256`). Slurm account `commons` and partition names are public NOTS defaults and are not counted.

### 3.1 Counts per folder: lines (files) per pattern, then files per folder

`.` = none. "`/projects/`" includes hits in lines that also contain other patterns, so one line can count in several columns. Total: 306 files with at least one hit; lines: `/home/` 1,281; login-id 1,381; group-id 21; allocation 7; cluster-host 17; univ-domain (non-author) 24; lab-host 273; `/projects/` 168; non-author `user@host` 3 (1 file, third-party); IPv4 2 (1 file).

| folder | `/home/` | `/projects/` | login-id | group-id | alloc-id | cluster-host | univ-domain | lab-host | user@host | IPv4 | files |
|---|---|---|---|---|---|---|---|---|---|---|---|
| (root) | . | 2 (1) | 1 (1) | 1 (1) | . | . | . | 1 (1) | . | . | 2 |
| applications/Munich Rent | 1 (1) | . | 1 (1) | . | . | . | 1 (1) | 2 (2) | . | . | 2 |
| archive | . | 3 (2) | 2 (2) | . | . | . | . | . | . | . | 2 |
| engineering/E02_Rate_Sims | 28 (15) | 2 (2) | 30 (16) | 2 (2) | . | . | . | 4 (3) | . | . | 16 |
| engineering/E03_Repo_Organization | 19 (11) | 18 (11) | 27 (13) | 4 (2) | . | . | . | 12 (5) | . | . | 15 |
| engineering/E04_Sampler_Check | 7 (5) | 1 (1) | 8 (6) | 1 (1) | . | . | . | . | . | . | 6 |
| engineering/E05_PMALA_Fix | 2 (1) | 1 (1) | 3 (2) | 1 (1) | . | . | . | . | . | . | 2 |
| engineering/E06_Rate_Validation | 9 (4) | . | 9 (4) | . | . | . | . | . | . | . | 4 |
| engineering/E07_Tuning_Free | 26 (23) | . | 28 (25) | . | . | . | . | 22 (17) | . | . | 40 |
| engineering/E08_Lambda_Prior | 2 (2) | . | 2 (2) | . | . | . | . | 2 (1) | . | . | 2 |
| engineering/E09_NOTS_Cleanup | 2 (2) | 3 (3) | 31 (3) | 2 (1) | 1 (1) | . | . | 2 (1) | . | . | 4 |
| engineering/E10_Lambda_Mixing | 4 (4) | 1 (1) | 5 (5) | 1 (1) | . | . | . | 1 (1) | . | . | 5 |
| engineering/E12_Disk_Reorg | 1 (1) | 3 (1) | 7 (1) | 3 (1) | . | . | . | 13 (1) | . | . | 1 |
| engineering/E13_Joint_b0 | 2 (2) | . | 2 (2) | . | . | . | . | 9 (3) | . | . | 5 |
| engineering/E14_Inner_Rerun | 6 (4) | 1 (1) | 6 (4) | . | . | . | . | 5 (3) | . | . | 5 |
| engineering/E15_Extreme_Individual | 2 (1) | . | 2 (1) | . | . | . | . | 2 (1) | . | . | 2 |
| engineering/E16_n2000_b0 | . | . | . | . | . | . | . | 20 (7) | . | . | 7 |
| engineering/E17_b0_1e5 | 3 (3) | . | 4 (4) | . | . | . | . | 5 (4) | . | . | 7 |
| engineering/E18_Air_Refit | 1 (1) | . | 3 (3) | . | . | . | . | 32 (8) | . | . | 11 |
| experiments | 1 (1) | 1 (1) | 1 (1) | . | . | . | . | . | . | . | 1 |
| experiments/air_simulation | 10 (4) | 10 (4) | 15 (4) | . | . | . | . | . | . | 2 (1) | 4 |
| experiments/extreme_quantiles | 13 (11) | 11 (9) | 17 (11) | . | . | 2 (2) | 4 (2) | . | . | . | 11 |
| experiments/interior_quantiles | 98 (63) | 85 (58) | 134 (69) | 5 (3) | 6 (6) | 12 (12) | 16 (12) | 1 (1) | . | . | 69 |
| experiments/joint_upper_levels | 28 (9) | 26 (7) | 34 (12) | 1 (1) | . | 3 (2) | 3 (2) | . | . | . | 13 |
| experiments/pilots | 1 (1) | . | 1 (1) | . | . | . | . | 5 (3) | . | . | 4 |
| lean | 1000 (27) | . | 991 (27) | . | . | . | . | 106 (36) | . | . | 39 |
| method | . | . | . | . | . | . | . | 1 (1) | . | . | 1 |
| paper/history | . | . | . | . | . | . | . | . | 3 (1) | . | 1 |
| theory/T03_Feasibility | 1 (1) | . | 1 (1) | . | . | . | . | 2 (2) | . | . | 3 |
| theory/T05_Proofs | 1 (1) | . | 2 (2) | . | . | . | . | 13 (8) | . | . | 9 |
| theory/T06_Alignment | . | . | . | . | . | . | . | 3 (2) | . | . | 2 |
| theory/T07_Bayes_Thm3 | 1 (1) | . | 2 (2) | . | . | . | . | 4 (3) | . | . | 4 |
| theory/T08_Joint_Feasibility | 5 (2) | . | 5 (2) | . | . | . | . | . | . | . | 2 |
| theory/T09_Joint_Theorem | 7 (1) | . | 7 (1) | . | . | . | . | 2 (2) | . | . | 3 |
| writing/W01_Statements | . | . | . | . | . | . | . | 1 (1) | . | . | 1 |
| writing/W07_Appendix | . | . | . | . | . | . | . | 3 (1) | . | . | 1 |
| TOTAL | 1281 | 168 | 1381 | 21 | 7 | 17 | 24 | 273 | 3 | 2 | 306 |

Windows user path `C:/Users/***` (not in the table above): 1,904 lines in 44 files: `paper/history/` 1,867 lines in 29 files (MiKTeX build logs `latex_pass*.txt`, `build-*.txt`, `build/main.log`, plus `source_snapshot_sha256.json` 16 lines, `revise.py`, `validate.py`); `experiments/interior_quantiles` 18 lines in 4 files (`audit/static_checks.json` 15, `deployment/cleanup_after_verified.py`, `finish_download_and_cleanup.py`, `deployment/upload_*/transfer.json`); `engineering/E03_Repo_Organization` 11 lines in 4 files; `experiments/pilots/joint_results_joint/*.txt` 3 lines in 3 files; `applications/Munich Rent` 2 lines in 1 file (`Munich_PMALA_checks.R:9,12`); `applications/Growth/Growth_Joint_checks.R:13`; `applications/README.md:18`; `engineering/E09_NOTS_Cleanup/README.md:34`. Home-relative `~/OneDrive/Documents` candidates (not personal) appear in 32 files (samplers, frozen `source/` copies, E07 variants) (`method/` and frozen `source/` copies).

### 3.2 Representative examples (file:line, value masked)

| Pattern | Example |
|---|---|
| `/home/` | `engineering/E02_Rate_Sims/analyze.R:4`: `E02 <- "/home/***/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims"` |
| `/home/` | `engineering/E02_Rate_Sims/e02_lib.R:22`: `KERNEL <- Sys.getenv("E02_KERNEL", "/home/***/Bayesian-Quantile-Trend-Filtering/method/individual/prox_admm_metric.cpp")` |
| `/home/` | `applications/Munich Rent/Others/results_pmala_k2/RUN_METADATA.txt:3`: `workdir: /home/***/.claude-science-scratch/...` |
| login-id | `README.md:28`: `... same layout on NOTS at ~/BQTF (= /projects/***/***/BQTF ...)` |
| login-id | `archive/archived_campaigns.md:3`: `the NOTS tree ~/projects/*** was archived to ...` |
| `/projects/` | `experiments/README.md:3`: `remote paths such as /home/***/projects/Quant_Reg/... inside them are historical` |
| group-id | `experiments/interior_quantiles/individual_nots_20261003/audit/nots_readonly_probe.txt:10`: `drwxr-xr-x 2 *** *** 4096 Oct 3 13:40 .` |
| group-id | `experiments/joint_upper_levels/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/metadata/comparison_slurm_record.txt:2`: `UserId=***(<uid>) GroupId=***(<gid>)` (numeric uid and gid also printed) |
| allocation | `engineering/E09_NOTS_Cleanup/README.md:14`: `/rhf/allocations/*** ... Not ours. This is a shared allocation` |
| allocation | `experiments/interior_quantiles/individual_nots_20261003/deployment/20261003T213032_677284Z_predeploy/output.txt:12` (and 4 sibling `output.txt`): `<host>:/rhf/allocations/***` |
| cluster-host | `experiments/*/environment.sh:5` (7 copies): `*.***|***) ;;` (login-host glob); `experiments/joint_upper_levels/runs/.../metadata/environment.txt:2-3`: login host and `uname -a` |
| cluster-host | `experiments/interior_quantiles/individual_nots_20261003/deployment/campaign.json:21`: `"monitor_login_host": "***"` |
| lab-host | `.gitattributes:4`: `# LF for scripts and sources (the NOTS cluster and the *** box are Linux)` |
| lab-host | `method/README.md:30`: `... pass with the default flags on ***` ; `engineering/E02_Rate_Sims/e02_lib.R:17` (`.libPaths` under `/home/***/...`) |
| IPv4 | `experiments/air_simulation/onizuka_laplace_20261023/BUILD_REPORT.md:92`: two login-node addresses `***` |
| `user@host` | none in code. Third-party: `paper/history/simulation_revision_20260914/Brantley_2020.txt:8,9` (3 addresses of the authors of a reviewed paper) |
| Windows path | `applications/Growth/Growth_Joint_checks.R:13`: `normalizePath("C:/Users/***/OneDrive/Documents/...")`; `experiments/interior_quantiles/individual_nots_20261003/audit/static_checks.json:14` |

### 3.3 Classification

(a) README/docs text, easy to scrub; (b) code defaults that need a path variable; (c) frozen run records/logs. Class is assigned per file by type and location (rule: `paper/history/**`, `deployment/`, `audit/`, `RUN_METADATA*`, `*.log`, `*.json`, `*.csv`, checksum files = (c); `.R .sh .slurm .py .cpp` = (b); rest = (a)).

| Class | Files | Lines | Where | Checksum-covered | Handling |
|---|---:|---:|---|---:|---|
| (a) docs | 122 | 2,484 | `lean/` 39 (`PLAN.md`, `notes/logs`, `notes/reviews`: 1,000 `/home/` lines, 106 lab-host); `engineering/` 42 docs (E03 11, E18 5, E07 6, E09 4, ...); `theory/` 18; `experiments/` 16 (package READMEs, `experiments/README.md`); `archive/` 2; `writing/` 2; root `README.md`, `.gitattributes`, `method/README.md` | 13 (E09 index/source files and READMEs inside sealed packages) | replace with `<repo>`, `$BQTF_ROOT`, "the cluster", "a Linux workstation". No sealing consequence for `lean/`, `theory/`, `engineering/`, `archive/`, root and `method/` |
| (b) code defaults | 129 | 386 | `engineering/` 90 scripts (E07 34, E02 14, E18 6, E16 6, E04 5, E17 5, E06 4, E03 4, E10 4, E13 3, ...); `experiments/` 38 (packages: `environment.sh`, `path_guard.sh`, `submit.sh`, `*.py`, frozen `source/` copies; `pilots` 3); `applications/Munich Rent/Others/Munich_PMALA_k2.R` | 34 (all in `experiments/` packages and the Munich script) | `Sys.getenv("BQTF_ROOT", ".")` / `.libPaths` from env for `engineering/`; for `experiments/` packages an edit changes sealed content (3.4) |
| (c) frozen records | 55 | 307 (+ 1,867 Windows-path lines in `paper/history/`) | `experiments/interior_quantiles/**/{deployment,audit}` 43; `joint_upper_levels/runs/**` 4; `air_simulation` 1; `applications/Munich Rent/Others/results_pmala_k2/RUN_METADATA.txt`; `theory/T03,T05,T06` `.out` files 5; `paper/history/**` | 34 | leave, or drop from the public view; any edit changes provenance |

Per folder (files):

| folder | (a) docs files | (b) code files | (c) frozen records files | checksum-covered files |
|---|---|---|---|---|
| (root) | 2 | 0 | 0 | 0 |
| applications/Munich Rent | 0 | 1 | 1 | 1 |
| archive | 2 | 0 | 0 | 0 |
| engineering/E02_Rate_Sims | 2 | 14 | 0 | 0 |
| engineering/E03_Repo_Organization | 11 | 4 | 0 | 0 |
| engineering/E04_Sampler_Check | 1 | 5 | 0 | 0 |
| engineering/E05_PMALA_Fix | 1 | 1 | 0 | 0 |
| engineering/E06_Rate_Validation | 0 | 4 | 0 | 0 |
| engineering/E07_Tuning_Free | 6 | 34 | 0 | 0 |
| engineering/E08_Lambda_Prior | 1 | 1 | 0 | 0 |
| engineering/E09_NOTS_Cleanup | 4 | 0 | 0 | 3 |
| engineering/E10_Lambda_Mixing | 1 | 4 | 0 | 0 |
| engineering/E12_Disk_Reorg | 1 | 0 | 0 | 0 |
| engineering/E13_Joint_b0 | 2 | 3 | 0 | 0 |
| engineering/E14_Inner_Rerun | 3 | 2 | 0 | 0 |
| engineering/E15_Extreme_Individual | 1 | 1 | 0 | 0 |
| engineering/E16_n2000_b0 | 1 | 6 | 0 | 0 |
| engineering/E17_b0_1e5 | 2 | 5 | 0 | 0 |
| engineering/E18_Air_Refit | 5 | 6 | 0 | 0 |
| experiments | 1 | 0 | 0 | 0 |
| experiments/air_simulation | 2 | 1 | 1 | 2 |
| experiments/extreme_quantiles | 2 | 9 | 0 | 11 |
| experiments/interior_quantiles | 5 | 21 | 43 | 58 |
| experiments/joint_upper_levels | 5 | 4 | 4 | 6 |
| experiments/pilots | 1 | 3 | 0 | 0 |
| lean | 39 | 0 | 0 | 0 |
| method | 1 | 0 | 0 | 0 |
| paper/history | 0 | 0 | 1 | 0 |
| theory/T03_Feasibility | 2 | 0 | 1 | 0 |
| theory/T05_Proofs | 7 | 0 | 2 | 0 |
| theory/T06_Alignment | 0 | 0 | 2 | 0 |
| theory/T07_Bayes_Thm3 | 4 | 0 | 0 | 0 |
| theory/T08_Joint_Feasibility | 2 | 0 | 0 | 0 |
| theory/T09_Joint_Theorem | 3 | 0 | 0 | 0 |
| writing/W01_Statements | 1 | 0 | 0 | 0 |
| writing/W07_Appendix | 1 | 0 | 0 | 0 |

### 3.4 Checksum and manifest coverage of the files with hits

81 of the 306 files have their **current** SHA-256 listed in some checksum file (content hash match), listed here by checksum file (files covered / of which by explicit relative path):

| Checksum file | Covered | By path | Verifies now |
|---|---:|---:|---|
| `engineering/E09_NOTS_Cleanup/quant_reg_archive/MANIFEST.sha256` (4,787 entries, manifest of the PC archive; the covered files are tracked copies of files in that archive) | 75 | 3 | n/a (hashes of archived copies; editing the tracked copy makes it differ from the archived one) |
| `experiments/interior_quantiles/individual_nots_20261003/SHA256SUMS` | 17 | 11 | 27 ok, **3 FAILED**: `audit/nots_readonly_probe.txt`, `audit/static_checks.json`, `paper_reference/simulations.tex` |
| same, `S_b00005/`, `S_b0001/`, `VS_b0001/` sub-packages | 7 each | 4 each | 16 ok each |
| `experiments/joint_upper_levels/SHA256SUMS` | 7 | 3 | 21 ok |
| `experiments/joint_upper_levels/runs/VS_upper6_..._20261002/code/SHA256SUMS` | 7 | 3 | 21 ok |
| `.../metadata/source_SHA256SUMS` | 7 | 0 | 0 ok, 42 missing (heavy files not tracked) |
| `applications/Munich Rent/Others/results_pmala_k2/SHA256SUMS.inputs` | 1 | 0 | 0 ok, 4 missing |

`lean/SHA256SUMS.txt`: lists 58 files (`AxiomCheck.lean`, `BQTF.lean`, 56 under `BQTF/`), `sha256sum -c` passes for all 58. **None of the 39 `lean/` files with personal strings is in it** (they are `PLAN.md` and `notes/**`), and none of the 58 `.lean` files contains any pattern. `lean/README.md`, `lean/AxiomCheck.lean`, `lean/lakefile.toml`, `lean/lake-manifest.json` are clean and also not listed. Scrubbing `lean/` therefore leaves the Lean seal intact.

Other seals: `paper/history/joint_sampler_rewrite_20261001/source_snapshot_sha256.json` (16 entries with old Windows paths, personal; sealed record of a snapshot, not verifiable here); `engineering/E18_Air_Refit/table2_data_sha256.csv` (101 rows, no hits); `engineering/E07_Tuning_Free/joint_gibbs/validate/inputs/SHA256SUMS` (no hits). Packages under `experiments/extreme_quantiles/packages/` have no local `SHA256SUMS`; their 11 files with hits match only the E09 manifest.

### 3.5 Emails and names

- Author emails (title page, excluded): `paper/main.tex:54,56,58` (3). The same three appear in frozen copies: `paper/history/{air_simulation_n500_update_20261008,joint_sampler_rewrite_20261001,simulation_revision_20260914}/before/main.tex`, `paper/history/simulation_revision_20260914/page_text.txt`, `paper/history/joint_extreme_results_20261002/compiled.txt`, `paper/history/writing_sync_20260914/main-text.txt`, `experiments/joint_upper_levels/paper_reference/main.txt`.
- `CITATION.cff` contains no email.
- Third-party personal data: `paper/history/simulation_revision_20260914/Brantley_2020.txt` is a text extraction of a third-party paper (3 author emails; copyright question as well).
- First names and a PC username appear inside Windows paths (3.1) and in prose such as "Felipe's PC" in `engineering/E09`, `E14`, `E07`, `theory/ALIGNMENT_MEMO.md`, `writing/W02_Theorems/theorems.tex` (author's own name; judgement call, not scrubbed by pattern).
- Git history: the history was rewritten once (E-03, `05_history_rewrite.sh` is in the tree); every string above that is removed from the working tree stays in older commits unless the history is rewritten again.

### 3.6 Secrets scan

Patterns searched over all tracked text: `ghp_`, `github_pat_`, `gho_`, `AKIA...`, `BEGIN ... PRIVATE KEY`, `xox[baprs]-`, `sk-...`, `AIza...`, `password|passwd|api_key|secret|bearer|authorization:|token|credential`; file names `.netrc`, `id_rsa*`, `*.pem`, `*.key`, `*.p12`, `.env`, `.ssh/*`, `ssh_config`, `known_hosts`, `*secret*`, `*credential*`.
**Result: no secrets.** The only `token` hit is the word "Forbidden-token scan" in `lean/notes/logs/neonC_progress.md:47`. SSH use: `engineering/E17_b0_1e5/ops/nots.sh:55,57` and `experiments/interior_quantiles/individual_nots_20261003/{upload_package.py:34,50, remote_admin.py:14}` call `ssh -o BatchMode=yes nots ...` (an alias from the user's own ssh config; no key, host or user in the repo); `deployment/upload_*/transfer.json:7,27` repeats the command lines. Slurm headers use `--account=commons` (10 files). No `.env`, key, or credential file is tracked.

## 4. Link check

Scope: `README.md`, `method/README.md`, `experiments/README.md`, `applications/**/README*` (only `applications/README.md` and `applications/Growth/data/README.txt` exist), `lean/README.md`, `lean/docs/*.md` (`statements.md`), `archive/README.md`, `literature/README.md`. Parsed: inline links `[t](path)`, images, reference definitions, `href=`/`src=`; skipped fenced code and code spans in this pass. Resolved against the tracked file and directory set (so a file that exists only on this disk counts as broken for the public); anchors in `.md` targets checked against headings.

### 4.1 Markdown links

| File | Relative links | External | Broken |
|---|---:|---:|---:|
| `README.md` | 0 | 0 | 0 |
| `method/README.md` | 0 | 0 | 0 |
| `experiments/README.md` | 0 | 0 | 0 |
| `applications/README.md`, `applications/Growth/data/README.txt` | 0 | 0 | 0 |
| `lean/README.md` | 6 | 1 | 0 |
| `lean/docs/statements.md` | 1 | 0 | 0 |
| `archive/README.md`, `literature/README.md` | 0 | 0 | 0 |
| **Total** | **7** | **1** | **0** |

**Broken relative links: none.** Most READMEs do not use markdown links at all; they cite paths in code spans, so GitHub shows them as unlinked text (a presentation gap for the public README: nothing in the root README is clickable).

### 4.2 Paths cited in code spans (second pass)

150 path-like tokens in the same files were resolved against all tracked paths (exact, relative to the file, or as a path suffix; globs matched against tracked names; `ops/`, `runs/`, `tmp/`, `~`, placeholders and URLs skipped). 139 resolve. The 11 that do not:

| File:line | Token | Verdict |
|---|---|---|
| `README.md:13` | `engineering/E03_Repo_Organization/hash_map.tsv` | **dead**: not tracked (the file maps old to new commit hashes after the history rewrite; either add it or drop the sentence) |
| `README.md:71` | `theory/T0x_*`, `engineering/E0x_*` | placeholders, fine |
| `applications/README.md:19` | `Simulations/Individual/` | old layout name, described as historical; reword before publishing |
| `applications/README.md:18` | `C:/Users/***/...` | a Windows path in prose (privacy item 3.1) |
| `applications/README.md:11` | `../../method/joint/`, `../../method/individual/` | correct relative to `applications/Growth/` (the scripts' location), not to the README; reads as broken from `applications/` |
| `archive/README.md:11` | `Temp/NOTS_Exercise` | deleted on purpose (the README says so) |
| `experiments/README.md:15` | `extreme_quantiles/tables_20261008/crossings_*.csv/.tex` | glob notation; the files exist (`crossings_all_S.csv` etc.) |
| `experiments/README.md:32` | `paper/history/complexity_analysis` | origin of `scalability/`; the folder was moved, no longer exists |
| `lean/README.md:14` | `leanprover/lean4:v4.35.0-rc2` | toolchain string, not a path |

Additional observations for the proposal: the root README has no reference to `lean/` (0 matches for `lean/` or "Lean" in `README.md`), its repository map omits `lean/`, and it says `literature/` PDFs are local only. `paper/figures` contains 5 `nile_*` files that no `.tex` includes; `experiments/README.md` and the root README state that frozen packages' `SHA256SUMS` stay valid, but 3 entries of `experiments/interior_quantiles/individual_nots_20261003/SHA256SUMS` fail (Part 3.4).
