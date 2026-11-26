# W-08 draft (FABLE): arrangement of the public repo

Proposal only. Nothing was moved, renamed, edited or committed to write it. Engineering is repo steward: every move in Section 5 needs Engineering's sign-off and is run by Engineering, not by Writing.

Square brackets mark values that are not final, e.g. `[E-18: MSE]`. All other statements were checked against the tracked files on 2026-11-26 (`git ls-files`, 1,753 files); Section 6 says what was checked and where.

Summary of the proposal:

- One new front page (README) in the Large Prior pattern, selling four things: the two Lean-verified theorems, the exact sampler, the non-crossing joint sampler, the air-quality result.
- A dedicated Lean section for the README, drafted in its own file, [`LEAN_SECTION.md`](LEAN_SECTION.md), with the source line of every claim in comments for the Lean head.
- A hero figure built on the owner's idea: the band between the joint sampler's 0.1 and 0.9 quantile curves, which never cross (Section 2). Writing draws it from Engineering's saved curves.
- One new folder, `examples/`, holding the quick start and the published README figure with the curves it is drawn from. New files only.
- One recommended move (the dropped Munich application), one optional move (`paper/history/`), and no move of the department folders: they stay where they are and are listed last. Moving them is costed in Section 5 and marked risky.
- Eleven privacy items already in the public repo (Section 7), with the owner's ruling on scrubbing applied to each, and the open items left for the owner (Section 8).
- What we take from the Large Prior repo, and what does not fit (Section 9).

---

## 1. README outline

Order of sections (each is one screen or less):

1. Title, badges, one-sentence statement with authors
2. The main idea behind this project (3 paragraphs: method, theory, computing)
3. Hero figure and one-line italic caption (Section 2)
4. Quick start (Section 4 of this draft)
5. Our work (table: paper item, folder, command, time)
6. Formal verification in Lean: a full section, not a line. Its complete draft is [`LEAN_SECTION.md`](LEAN_SECTION.md); the Lean head fact-checks it before it is final.
7. Requirements
8. Data
9. Repository structure (public folders first, project records last)
10. Citation and license

What leaves the front page: the "Status" section, the committing rules, "Departments and task IDs", the `ops/ runs/ tmp/` row with the cluster path, and "Ask Felipe for the PC path". The working rules go to a new `engineering/README.md` (Section 3); the README keeps one line pointing there.

### 1.1 Title, badges, authors (full draft)

```markdown
# Bayesian quantile trend filtering

[![R >= 4.4](https://img.shields.io/badge/R-%E2%89%A5%204.4-276DC3)](https://www.r-project.org/)
[![Lean 4](https://img.shields.io/badge/Lean-v4.35.0--rc2-0f4c81)](https://lean-lang.org/)
[![Lean proofs: no sorry, standard axioms](https://img.shields.io/badge/Theorems%201%E2%80%932-verified%20in%20Lean-2e7d32)](lean/README.md)
[![License: MIT (code)](https://img.shields.io/badge/license-MIT%20%28code%29-lightgrey)](#citation-and-license)

This repository has the code, the paper and the Lean proofs for
**Bayesian Joint Quantile Trend Filtering via Proximal MCMC with Sequential Gibbs Sampling**,
by Felipe Bedoya, Meng Li (Department of Statistics, Rice University) and
Eric C. Chi (School of Statistics, University of Minnesota).
```

Notes for the editor:

- The H1 is short on purpose; the full paper title is in the sentence below it. If the owner prefers the full title as H1, only the first line changes.
- No e-mail addresses. Contact is "open an issue".
- The Lean badge is static. It is true today (Section 6). If a CI job is added later, replace it with the live status badge.
- The licence badge says "code" because `LICENSE` excludes the manuscript text.

### 1.2 The main idea behind this project (full draft)

```markdown
## The main idea behind this project

Quantile trend filtering estimates a conditional quantile along an ordered domain by combining
the check loss with an ℓ1 penalty on the differences of order k+1 of the trend. The penalty has to
be selected, and the result is a point estimate. We give it a Bayesian counterpart: an asymmetric
Laplace working likelihood, a Laplace prior on the differences, and priors on the penalty and on the
likelihood scale. The output is a posterior for the trend, the penalty and the scale, so every fit
comes with credible bands and no penalty is chosen by cross-validation. A joint version fits several
quantile levels together, and its draws never cross: the area between two of its curves, such as
the 0.1 and 0.9 quantiles in the figure below, is always a valid band for the data.

On the theory side, Theorem 1 shows that for a fixed scale and a penalty of order n^((2k+1)/2) the
posterior contracts around the true quantiles at the rate n^(-(2k+1)/(2k+2)), which is n^(-5/6) for
the default k = 2, with no logarithmic factor. The data need not follow the working likelihood and
no moment is assumed, so heavy-tailed noise is allowed. Theorem 2 gives the same rate at every level
of the non-crossing joint posterior at once. Both theorems are machine-checked in Lean 4 with
Mathlib: [`lean/`](lean) has no `sorry`, uses only Lean's three standard axioms, and takes no
classical result as a hypothesis. An independent final audit compared the Lean statements with the
paper's and found that they imply them. The theorems hold the penalty and the scale fixed; the
samplers place priors on both, and that case is not covered.

On the computing side, the normal-exponential representation of the asymmetric Laplace likelihood
makes the conditional of the trend a weighted quadratic plus the ℓ1 difference penalty. We update
the trend by a proximal Metropolis-adjusted Langevin step whose proximal map is a weighted trend
filtering problem on this whole conditional, not on a smoothed check loss, and the accept-reject
step uses the exact density, so the sampler targets the posterior exactly. Every linear system is
banded, and the cost of a sweep grows linearly with n: 9.2 ms at n = 1,000 in our timings, against
about 3 s for the two Gibbs samplers we compare with. In the joint sampler only the proximal map
changes: it becomes a box-constrained problem solved with banded interior-point steps.
[`method/`](method) has both samplers and the ADMM baseline.
```

Then, after the figure, one short paragraph for the air-quality result (placeholders until E-18 closes):

```markdown
In the peak-detection design of Brantley et al. (2020) for air-quality sensors, the sampler recovers
the peak-free baseline about as well as ADMM quantile trend filtering at τ = 0.05 and 0.10
([E-18: MSE PMALA] against [E-18: MSE ADMM]) and better at τ = 0.01 ([E-18: MSE PMALA] against
[E-18: MSE ADMM]), without selecting a penalty.
```

Notes for the editor:

- The three paragraphs follow the reference repo's order (method, theory, computing) and its length.
- "9.2 ms" and "about 3 s" are Table `tab:cost_scaling` of the paper at n = 1,000 (PMALA 9.2 ms; Laplace 3,650 ms; horseshoe 2,918 ms). Re-check at paper freeze.
- The sentence "The theorems hold the penalty and the scale fixed ..." is in the paper (Section 3.4). I keep it on the front page: a reader who finds the limit later, after reading "verified in Lean", trusts the rest less.
- The air paragraph must not say more than E-18 supports. The pre-refit paper table has ADMM ahead at τ = 0.01 (0.0461 against 0.0302), so the claim "better at τ = 0.01" exists only in the E-18 refit. In the tracked E-18 table for that refit, the 95% pointwise coverage of the selected fits is far below 0.95. The README should therefore claim accuracy of the baseline estimate and say nothing about the calibration of the bands in this design, unless E-18 ends otherwise.
- The theory paragraph gives the Lean result in three sentences only. The full account (what is formalized, the trust story, the classical results proved from scratch, the eleven corrections C-01 to C-11, the differences D1 to D12, build and check, module map) is the README's own Lean section, drafted in `LEAN_SECTION.md`.
- The figure sentence at the end of the method paragraph ("always a valid band") refers to the hero figure of Section 2. If the figure ships later than the README, drop the clause after the colon.

### 1.3 "Our work" table (draft; times to be filled by Engineering)

```markdown
## Our work

| In the paper | Folder | How to run | Time |
|---|---|---|---|
| Section 2: the two samplers | [`method/`](method) | `Rscript Individual_Sampler_PMALA_Augmented.R test` in `method/individual/`; `Rscript Joint_Sampler_PMALA_Augmented.R test_prox` in `method/joint/` | about 100 s; [Eng] |
| Theorems 1 and 2 | [`lean/`](lean) | `lake exe cache get`, `lake build`, `lake env lean AxiomCheck.lean` | [Lean: build time with the Mathlib cache] |
| Simulations at interior levels (Tables 1 and 2, appendix tables) | [`experiments/interior_quantiles/`](experiments/interior_quantiles) | from the shipped results: [Eng: one command]; full run: 3,000 cluster tasks | seconds; [Eng: core-hours] |
| Joint estimation of extreme upper levels, crossing tables | [`experiments/extreme_quantiles/`](experiments/extreme_quantiles), [`experiments/joint_upper_levels/`](experiments/joint_upper_levels) | from the shipped results: [Eng]; full run on a cluster | [Eng] |
| Air-quality simulation (Table `air_n500`) | [`experiments/air_simulation/`](experiments/air_simulation) | [E-18: final command] | [E-18] |
| Cost per sweep (table and two figures) | [`experiments/scalability/`](experiments/scalability) | `Rscript benchmark_existing.R`, then `python3 build_tables.py` | minutes |
| Growth centiles | [`applications/Growth/`](applications/Growth) | `Rscript Growth_Joint_PMALA_k2.R sex=boy`, then `Rscript Growth_plots_k2.R` | [Eng] |
| Air-quality sensor data | [`applications/Air Quality/`](applications/Air%20Quality) | [E-18: command] | [E-18] |
| The figure above | [`examples/`](examples) | `Rscript make_readme_figures.R` (from the shipped curves) | seconds |
| The paper | [`paper/`](paper) | read `main.pdf`, or `latexmk -pdf main.tex` | |
```

Notes:

- Table numbers ("Tables 1 and 2") must be read off the compiled `paper/main.pdf` at freeze; the current README uses labels (`vs_int_mse`), which mean nothing to an outside reader.
- The current README lists open items (no generator in the repo for `spod_*`, `nile_*`, `growth_lms_*`, `growth_pmala_*`, `scal_*`; Nile data missing). A sentence "Every figure and table of the paper comes from a script in this repository" is false today, so the draft does not say it. Either the generators arrive (E-18 covers `spod_*`), or the README says in one line which figures have no script here. I recommend the line; it costs little and it is true.
- The Growth row needs care. The tracked run `applications/Growth/results_joint_k2/` is a joint-sampler fit (b0 = 0.01, 30,000 sweeps with 10,000 burn-in) and is not the run behind the paper's growth figure (owner's ruling). The row must say which run the command reproduces, and must not attach the paper's figure number to it until Engineering confirms a command that reproduces that figure.
- A "from the shipped results" command per experiment (as in the reference repo) is what makes the table usable without a cluster. Where no such command exists, the cell says "full run only" rather than a command that needs Slurm.

---

## 2. Figure plan

This section follows the owner's clarification of the hero figure, the final E-20 spec (BRIEF, owner additions, item C) and the owner's ruling on who draws it:

- Engineering fits and saves the curves (the VS fit is task E-20; the SPod curves come from E-18).
- Writing draws the README figures from those saved curves. A separate Writing worker is writing the script, `writing/W08_Repo/figures/make_readme_figures.R`.
- This section therefore specifies the panels and the captions. Section 2.5 lists what the script needs from each panel; it is input for that worker, not a second script.

What the owner fixed is marked FIXED.

### 2.1 The idea

The hero is not a curve with a credible band. It is a **band made of two quantile curves**: the joint sampler's estimates at τ = 0.1 and τ = 0.9, with the area between them shaded. About 80% of the observations should fall inside it, so the band is to the whole series what an interval is to a single number. The joint sampler's curves never cross, so the band is valid at every point: its lower edge is never above its upper edge. That is the selling line.

Per-curve credible bands are not drawn. A faint version of them is an optional variant (Section 2.5), not the default.

### 2.2 Panels

```
+---------------------------------------------------------------+
| (a) VS signal, n = 1,000: band between tau = 0.1 and 0.9      |   row 1: full width; ships first, alone
+-------------------------------+-------------------------------+
| (b) Air-quality sensor        | (c) Height of Dutch boys      |   row 2: added when ready
+-------------------------------+-------------------------------+
```

**(a) Simulated signal. FIXED.** VS signal with Normal errors, n = 1,000, one seed, fitted by the joint sampler at τ = (0.1, 0.9). Light-blue band between the two estimated curves; dark-blue points on top; the true noiseless signal as a dotted line; a note with the fraction of points inside the band (nominal 0.80). Source: Engineering's saved curves from E-20.

**(b) Air-quality sensor.** One day of SPod readings (n = 8,640). Fits exist at τ = 0.01, 0.05 and 0.10 only; there is no upper level, so this panel is not an "80% band" and must not be captioned as one. It shows the low baseline under the plumes, with the spikes above it. Two versions; the choice is made on the saved curves:

- *Version 1, preferred:* the band between the τ = 0.01 and τ = 0.10 curves in light blue, the τ = 0.05 curve as a line inside it, points on top. Use it only if the three saved curves are ordered at every time point. These are fits of the individual sampler, one level at a time, so nothing guarantees the order; the script should check it and stop if it fails.
- *Version 2, fallback:* the τ = 0.05 curve alone as a dark line under the points.

In both versions the y axis must let the reader see the baseline and the spikes: either the full range with the baseline near the bottom, or a clipped range with the clipping stated in the caption. No fraction note in this panel. Source: E-18's saved curves.

**(c) Height of Dutch boys.** Height against age with the band between the outer fitted centiles (τ = 0.1 and 0.9) in light blue, a darker inner band (τ = 0.3 to 0.7), and the median as a line; a note with the fraction of children inside the outer band (nominal 0.80). Source: the tracked run `applications/Growth/results_joint_k2/boy/` (`posterior_summary.csv` with columns `age, tau, estimate, lower, upper` at the five levels; `crossings.csv`, all counts 0) and the data `applications/Growth/data/fdgs.csv`.

Two facts about panel (c) that the caption and the README text must respect (owner's ruling):

- That run is a joint-sampler fit (b0 = 0.01, 30,000 sweeps with 10,000 burn-in). Caption it as a joint-sampler fit whose curves cannot cross.
- It is **not** the run behind the paper's growth figure. Never call the panel "Figure 5 of the paper" or "as in the paper", and do not put it in the "Our work" row for the paper's growth figure.

Order of shipping: (a) alone is complete. Add (c) next (its inputs are tracked today), then (b) when E-18's curves are saved.

### 2.3 Captions

One italic line under the image, as in the reference repo.

- (a) alone: *The band between the estimated 0.1 and 0.9 quantile trends of a simulated signal (n = 1,000) contains [E-20: fraction] of the observations. The two curves are sampled jointly and never cross. Dotted: the noiseless signal.*
- (a) + (c): *Bands between jointly sampled quantile trends, which cannot cross. (a) Simulated signal, n = 1,000: the 0.1 to 0.9 band contains [E-20: fraction] of the points; dotted, the noiseless signal. (c) Height of Dutch boys, joint fit of five centiles: [W: fraction] of the children lie between the 0.1 and 0.9 curves.*
- (a) + (b) + (c): the line above, with (b) inserted. Version 1: *(b) One day of fenceline sensor readings: the band between the 0.01 and 0.10 quantile trends, each fitted separately, follows the baseline under the plumes.* Version 2: *(b) One day of fenceline sensor readings: the 0.05 quantile trend follows the baseline under the plumes.*

Alt text: "A shaded band between two estimated quantile curves that contains about 80% of the data points".

Rules that keep the captions true:

1. **The fraction.** Print the fraction the script computes, to two decimals, next to the nominal value: "0.xx of the points inside (nominal 0.80)". Do not round a 0.77 or a 0.84 to "about 0.80".
2. **What the band is.** It is an in-sample fraction on the data the curves were fitted to. Do not call it coverage, a confidence interval or a credible interval. The owner's phrase "its own CI so to speak" is the right intuition, but the object is a band between two quantile curves, and the README uses those words.
3. **"Never cross"** is said only of joint-sampler fits: panels (a) and (c). Panel (b) is three separate fits; its caption says "each fitted separately" and makes no crossing claim.
4. **Panel (c) is not the paper's figure** (above).
5. Next to the saved curves of (a), Engineering should save the number of retained draws and the number with any crossing (expected 0), as `applications/Growth/results_joint_k2/boy/crossings.csv` does. The caption's "never cross" then has a file behind it.

### 2.4 Where the figure lives

The script is being written in `writing/W08_Repo/figures/`. For the public repo I propose that the published image, the script and the small curve files it reads sit together in `examples/` (Section 3): `examples/make_readme_figures.R`, `examples/reference_outputs/readme_fig.png`, `examples/reference_outputs/*.csv`. A reader can then redraw the figure with one command, as in the reference repo. If Writing prefers to keep them under `writing/`, only the image path in the README changes; but then the front page's figure comes from a folder the README describes as a working record, which reads oddly. Engineering signs off the location either way.

README embed line:

```markdown
![A shaded band between two estimated quantile curves that contains about 80% of the data points](examples/reference_outputs/readme_fig.png)
```

### 2.5 What the script needs for each panel (input for the figure worker)

Colours marked FIXED are the owner's; hex values and sizes are suggestions.

| Item | Value |
|---|---|
| Saved curves, panel (a) | One row per observation: `x, y, signal, q10, q90` (posterior means of the two trends). A summary file with n, seed, sampler settings, retained draws, draws with any crossing. No posterior draws. |
| Saved curves, panel (b) | One row per observation: time, reading, `q01, q05, q10`; the unit of the readings for the axis label |
| Saved curves, panel (c) | Tracked: `posterior_summary.csv` and `fdgs.csv` (above) |
| Band (FIXED: light blue) | Fill `#CFE2F3`, no border, drawn first. Inner band of (c): `#A9C8E6`. |
| Band edges | The estimated curves, `#5B8DB8`, line width 1.0 |
| Points (FIXED: dark blue, on top) | `#12355B`, small filled circles, drawn after the band; same colour inside and outside. In (b) and (c), with thousands of points, smaller and partly transparent. |
| True signal, panel (a) (FIXED: dotted) | The noiseless VS signal, black, dotted, drawn last so that it shows over the points |
| Fraction note | Inside panels (a) and (c), computed by the script from the saved curves, never typed by hand |
| Size | 8 in wide, 300 dpi; about 3.4 in high for (a) alone and 6 in with a second row. At GitHub's README width (about 830 px), 10 pt text then displays at about 14 px. |
| Background | White and opaque. A transparent PNG is unreadable in GitHub's dark theme. |
| Text in the image | Panel titles only when there is more than one panel. No main title, no MSE, no file names. |
| Labels | Direct labels at the right end of the edges ("τ = 0.9", "τ = 0.1"); no legend box |
| Size on disk | PNG under 1 MB (the pre-commit hook refuses files over 5 MB) |

Checks before the figure is published:

1. The dotted signal is readable over 1,000 dark points. If not, thicken it or put a thin white line under it; the points stay on top of the band.
2. The points outside the band are visible against white. This is the reason they are dark and not grey.
3. In (b), the order check of Version 1 passed, or Version 2 was used.
4. The note and the labels are legible at 830 px.

Why the noiseless signal and not the true quantile curves in (a): it is the owner's spec, and it is the simpler picture. With Normal errors the true 0.1 and 0.9 quantiles are the signal shifted down and up, so the signal runs through the middle of the band.

Optional faint variant, not the default: the 95% pointwise credible band of each edge, under the edge lines. It belongs in `examples/README.md` or the paper, not on the front page.

---

## 3. Folder arrangement

### 3.1 Proposed top level

```
Bayesian-Quantile-Trend-Filtering/
├── README.md                 front page (Section 1)
├── LICENSE, CITATION.cff
│
│   -- what a reader uses --
├── paper/                    main.pdf, main.tex, sections/, figures/, references.bib
├── method/                   individual/, joint/, admm_qtf/        the samplers
├── lean/                     Lean 4 proofs of Theorems 1 and 2
├── experiments/              simulations of the paper, with frozen packages and results
├── applications/             Growth/, Air Quality/                 real data
├── examples/                 NEW: quick-start fit and the README figure
│
│   -- project records (kept, listed last in the README) --
├── engineering/              task folders E-02 ... E-19, working rules (new README.md)
├── theory/                   task folders T-01 ... T-10, proof development
├── writing/                  task folders W-01 ... W-08
├── literature/               reading list
└── archive/                  superseded material: munich_rent/, [paper/history/], scratch_2026/
```

Six public folders, five record folders. Nothing is deleted.

### 3.2 Public and internal

| Folder | Role | In the README |
|---|---|---|
| `paper/`, `method/`, `lean/`, `experiments/`, `applications/`, `examples/` | Public face. Each has a README with settings, commands, outputs. | "Our work" table and the structure section |
| `engineering/`, `theory/`, `writing/` | Records of how the work was done: task memos, pilots, audits, run ledgers. Public, not advertised. | One paragraph at the end of the structure section: "The folders `engineering/`, `theory/` and `writing/` hold the project's working records (task notes, pilot runs, reviews). They are not needed to use the method or to reproduce the paper." |
| `literature/`, `archive/` | Reading list; superseded material. | Same paragraph, one clause each |
| `experiments/pilots/` | Small local pilots. Stays in place (8 files reference it, 5 of them code). | Last row of `experiments/README.md`, as now |
| `lean/notes/` | Audits, reviews, logs of the formalization. Stays: `lean/README.md` links into it (the final audit and the corrections list are selling points). | Via `lean/README.md` only |
| `ops/`, `runs/`, `tmp/` | Git-ignored, not public. | Not mentioned on the front page; described in `engineering/README.md` without machine paths |

### 3.3 Why the department folders stay at the top level

The brief allows "moved under one folder or just listed last". I recommend listed last, for now:

- `engineering/` is referenced by path in 117 tracked files, 83 of them code (R, shell, Slurm), for example `engineering/E18_Air_Refit/e18_common.R:114`, which loads `engineering/E14_Inner_Rerun/e14_run.R`. Tasks E-18 and E-19 are running from these paths today, and the cluster checkout mirrors the layout. Untracked run folders under `runs/` reference the same paths (39 files on this machine).
- `theory/` is referenced by 36 files (7 under `lean/`), `literature/` by 18 files and by two rules in `.gitignore`.
- The gain is cosmetic: GitHub sorts folders alphabetically, so the records sit among the public folders in the file list. The README's structure section fixes the reading order, and the file list is below the fold of what a visitor reads first.

If the owner wants a cleaner file list, the move is M3 in Section 5: one scripted commit by Engineering after E-18 and E-19 close, under a single folder `records/`. It is marked risky.

### 3.4 New files (no move, no reference to update)

| New file | Content | Owner |
|---|---|---|
| `examples/README.md` | What the two scripts do, settings, outputs, time | Writing drafts, Engineering checks |
| `examples/make_readme_figures.R` | The published copy of Writing's figure script (drafted in `writing/W08_Repo/figures/`); it only draws (Section 2.4) | Writing writes, Engineering signs off the location |
| `examples/reference_outputs/*` | The saved curves the figure is drawn from (small CSV files, no posterior draws) and `readme_fig.png` | Curves: Engineering (E-20, E-18). Image: Writing |
| `examples/fit_vs_joint.R` | The E-20 fit behind panel (a), so that a reader can rerun it | Engineering |
| `engineering/README.md` | The working rules now on the front page: commit with explicit paths, size hook, task IDs, what `ops/ runs/ tmp/` are. No cluster path, no account name. | Engineering |
| `theory/README.md`, `writing/README.md` | Three lines each: what the folder is, that it is a working record, where the final statements live (`paper/`, `lean/`) | Theory, Writing |

One dependency to check before the front-page rules move: any department brief or note that says "see README for the commit rules" must point to `engineering/README.md` afterwards.

---

## 4. Usage / quick start (draft text)

Commands and dependencies are those of the current `README.md`, `method/README.md`, `paper/README.md` and `lean/README.md`.

```markdown
## Quick start

You need R 4.4 or later with the packages `Rcpp`, `RcppArmadillo`, `glmgen` and `Matrix`, and a
C++17 compiler. The C++ kernels compile themselves the first time a sampler runs.

**Fit one quantile trend.** From the repository root:

    Rscript method/individual/Individual_Sampler_PMALA_Augmented.R

This simulates one data set, runs the sampler with the settings at the top of the file (the paper's
defaults: order k = 2, 30,000 sweeps with 10,000 burn-in) and writes a summary and a plot of the
fit with its 95% band to `method/individual/results_pmala_aug/`. To change the signal, the noise,
the sample size or the quantile level, edit the "Settings" block at the top of the file.
[Eng: time for the default run]

**Redraw the figure above.**

    cd examples
    Rscript make_readme_figures.R   # draws the figure from the saved curves in reference_outputs/; seconds
    Rscript fit_vs_joint.R          # optional: refits panel (a) with the joint sampler; [E-20: time]

**Check the samplers.**

    cd method/individual && Rscript Individual_Sampler_PMALA_Augmented.R test    # about 100 s, ends with "all tests passed"
    cd method/joint      && Rscript Joint_Sampler_PMALA_Augmented.R test_prox    # needs the R package clarabel

**Check the proofs.** Install [elan](https://github.com/leanprover/elan), then

    cd lean
    lake exe cache get              # prebuilt Mathlib
    lake build                      # ends with "Build completed successfully"
    lake env lean AxiomCheck.lean   # every line should read [propext, Classical.choice, Quot.sound]

**Build the paper.** `cd paper && latexmk -pdf main.tex` (TeX Live with `algorithmicx`, `bbm` and `bbold`).
```

```markdown
## Requirements

- **R** 4.4 or later: `Rcpp`, `RcppArmadillo`, `glmgen`, `Matrix`; the joint sampler's tests also
  need `clarabel`. A C++17 compiler.
- **Lean**: [elan](https://github.com/leanprover/elan) installs the pinned toolchain
  (`leanprover/lean4:v4.35.0-rc2`) and Mathlib.
- **LaTeX**: only to recompile the paper.
- The full simulation campaigns ran on a Slurm cluster from frozen packages; each experiment folder
  ships its summaries, so the paper's tables can be compared without rerunning them.
```

Points Engineering must settle before this text is final:

1. **Using the sampler on one's own data.** The sampler file ends with a main block that always runs the pilot fit (`Individual_Sampler_PMALA_Augmented.R`, from line 767), so `source()`-ing it to call `gibbs_pmala_aug()` on new data also runs the pilot. A user-data example (and `examples/fit_vs_joint.R`) therefore needs either the loading trick E-18 already uses (`engineering/E18_Air_Refit/e18_common.R`) or a small guard in the sampler. The first changes no canonical file. The quick start should show a user-data call only once one of these exists; the draft above does not promise it.
2. **`glmgen` is not on CRAN.** The README should give the install line Engineering actually uses (for example `remotes::install_github("glmgen/glmgen", subdir = "R_pkg/glmgen")`; to be confirmed against the project's R library).
3. **Compiler note.** The bitwise tests fail by 2e-16 where the compiler contracts to FMA (`method/README.md`). Keep that note in `method/README.md`; the front page says only "see `method/README.md` if a bitwise test fails".
4. **Times.** Every `[Eng: time]` is a measured wall time on one named class of machine ("a laptop", "one core"), not a host name.
5. **Default n.** The settings block has n = 500; the figure uses n = 1,000. `fit_vs_joint.R` states its own settings.
6. **The figure commands** depend on Section 2.4 (where the published script and curves live). If they stay under `writing/`, the quick start gives that path instead.

---

## 5. File-move list

Rule used: a move is proposed only if it changes what a visitor sees first and its references can be listed on one screen. References were found with `git grep -n -F '<old path>'` over the tracked files on 2026-11-26; Engineering should rerun the same command just before moving, since E-18 and E-19 are adding files.

"Historical" files record the repo at an earlier date (the E-03 migration scripts and inventories, dated paper-history folders). They should not be edited after a move; they are listed so that nobody mistakes them for live references.

### 5.1 Recommended

| # | Old path | New path | Files that reference the old path | Risk |
|---|---|---|---|---|
| M1 | `applications/Munich Rent/` (125 files; application dropped from the paper on 2026-10-28) | `archive/munich_rent/code/` (the target E-03 itself planned, `engineering/E03_Repo_Organization/migration/01_moves.sh:168`) | **To edit:** `README.md:22` (rewritten anyway); `applications/README.md:9`, `:18` (rows about Munich); `archive/README.md:7`. **Historical, leave:** `engineering/E03_Repo_Organization/INVENTORY.md`, `PROPOSAL.md`, `migration/01_moves.sh`, `01b_heavy_rm.sh`, `05_history_rewrite.sh`, `migration/03_new_files/{README.md, applications/README.md, archive/README.md}`; `paper/history/remove_munich_20261028/data_application.tex:33` (uses the older name `Data Applications/`). **Not referenced by:** any script outside the folder, any `SHA256SUMS`, any `\input` or `\includegraphics`. | Low. The scripts inside are already not runnable (old layout, Windows paths; `applications/README.md` items 4 and 5). `DATA.md` moves with the folder. |

Effect: `applications/` holds the two applications that are in the paper.

### 5.2 Optional

| # | Old path | New path | Files that reference the old path | Risk |
|---|---|---|---|---|
| M2 | `paper/history/` (263 files: dated edit sessions, old section snapshots, review notes) | `archive/paper/history/` (this name keeps the `.gitignore` rule `**/history/**/build/` valid) | **To edit:** `paper/README.md` (Contents row for `history/`); `experiments/README.md:16`, `:17`, `:19`, `:32`; `engineering/E14_Inner_Rerun/DATA_MATCH.md:169`, `:197`, `:258` (relative links `../../paper/history/...`); `README.md` (rewritten anyway). **Leave:** `paper/sections/scalability.tex:13` is a TeX comment that already uses a still older name (`notes/`); the paper is not to be changed. **Historical, leave:** `engineering/E03_Repo_Organization/PROPOSAL.md`, `migration/01_moves.sh`, `02_path_fixes.md`, `05_history_rewrite.sh`, `migration/03_new_files/experiments/README.md`. **Not referenced by:** `paper/main.tex`, any `\input` or `\includegraphics`, any `SHA256SUMS`. | Medium. Many files; the folder gets one level deeper, so any relative path inside it that climbs to the repo root breaks (Engineering to grep for `../..` inside the folder before moving). E-14's three links must be fixed in the same commit. |

Effect: `paper/` becomes `main.pdf`, `main.tex`, `sections/`, `figures/`, `references.bib`, build files. M2 also takes most of the Windows user paths and the old e-mail snapshots off the paper folder, but it does not remove them from the public repo (Section 7, items 5 and 6). Best done at paper freeze, when no edit session is open.

### 5.3 Costed, not recommended now

| # | Old path | New path | Files that reference the old path | Risk |
|---|---|---|---|---|
| M3 | `engineering/`, `theory/`, `writing/`, `literature/`, `archive/` | `records/engineering/` ... `records/archive/` | `engineering/`: 117 files, 83 code (R, shell, Slurm, Python), nearly all inside `engineering/` itself, plus `method/` (2), `theory/` (6), `writing/` (4), `archive/` (2), `README.md`. `theory/`: 36 files (`engineering/` 9, `lean/` 7, `writing/` 3, `literature/` 1, `README.md`, the rest inside `theory/`). `writing/`: 11 files. `literature/`: 18 files and `.gitignore` (two rules). `archive/`: 20 files (`applications/README.md`, `experiments/README.md`, `paper/README.md`, `README.md`, E-03 records). Also untracked: run folders under `runs/` and the cluster checkout use the same paths. | **Risky.** Live tasks (E-18, E-19) run from these paths; run records and ledgers quote them; a partial update leaves scripts that fail on the cluster. If wanted: one scripted commit by Engineering after the open tasks close, followed by the samplers' tests and one smoke run per live task. |

### 5.4 Paths that must not move

| Path | Why |
|---|---|
| `paper/figures/*`, `paper/sections/*`, `paper/main.tex` | `\input` and `\includegraphics` paths (10 figure includes); no change to the paper |
| `method/individual/`, `method/joint/` | Referenced by 52 and 32 files; the joint kernel `#include`s the individual one; `applications/Growth/` compiles both by relative path |
| `experiments/*/` frozen packages | Sealed with `SHA256SUMS`; their contents and names stay as run |
| `lean/BQTF/`, `lean/AxiomCheck.lean`, `lean/BQTF.lean` | Listed in `lean/SHA256SUMS.txt` (58 entries); the final audit refers to these paths |
| `lean/notes/`, `lean/docs/` | Linked from `lean/README.md` |
| `applications/Air Quality/` | Read by `engineering/E18_Air_Refit/e18_prepare_spod.R:7` |

Count: 1 recommended move, 1 optional, 5 folders left in place.

---

## 6. What was checked for the "must sell" list

| Claim | Evidence in the repo | Status |
|---|---|---|
| Both theorems verified in Lean 4 with Mathlib, standard axioms only | `lean/README.md`; `lean/AxiomCheck.lean` (four `example : ...Statement := ...` lines and four `#print axioms`); 56 modules under `lean/BQTF/`, about 16,200 lines; toolchain `v4.35.0-rc2` | True as documented. I did not rebuild. The full README section is in `LEAN_SECTION.md`, with one point the Lean head must rule on: the final audit read commit 5c3d923, and `lean/` has six later commits (the polish pass, reviewed separately). |
| Independent final audit CLEAN | `lean/notes/reviews/FINAL_AUDIT_astra.md:3` begins "**CLEAN.** All four compiled propositions imply their paper counterparts." | True. At the audited commit two appendix interfaces (D10, D12) were weaker than the paper's lemmas, neither reaching a theorem. D12 was closed afterwards, so "only D10 is weaker" is true of the current tree but is not what the final audit says. `LEAN_SECTION.md` words it accordingly. |
| Exact P-MALA on the whole conditional, banded, linear in n | `paper/sections/methodology.tex`, abstract, `method/individual/` header comment; timings in `paper/sections/scalability.tex` (2.0 ms at n = 250 to 36.6 ms at n = 4,000) | True |
| Joint sampler: no crossing by construction | Abstract ("draws that never cross"), `method/joint/` | True |
| Air quality: competitive with ADMM, better at τ = 0.01 | Pre-refit paper table: ADMM ahead at 0.01. Refit: `engineering/E18_Air_Refit/results_a0_n/report_table.csv` | Depends on E-18; placeholders used. See the coverage remark in Section 1.2. |

---

## 7. Privacy and public-view items found in the tracked files

Ordered by how soon they matter.

**Owner's ruling (received during drafting).** Scrubbing the current files is approved in principle, to be done in the implementation phase with Engineering's sign-off:

- absolute home paths become repo-relative paths or `$HOME`;
- cluster paths, host names and allocation names become neutral placeholders (for example `<cluster-project-dir>`, `<login-node>`, `<allocation>`);
- run records keep their provenance: nothing is deleted, and each scrubbed record gets a short note saying that paths were generalized.

The ruling covers items 3, 4, 5 and 7 below. Items 1, 2, 6, 8 and 11 are outside it and stay with the owner; item 9 (git history) and the PDF under `literature/` are listed as open items in Section 8.

How I would apply the ruling, for Engineering to accept or change:

1. One scripted pass, one commit, by Engineering. The script lists every substitution it makes (`file, line, old, new`) in a tracked log, so the change can be reviewed and repeated.
2. One note file, for example `engineering/PATHS_GENERALIZED.md`: date, commit, the substitution rules, and the statement that no other content was changed. Each scrubbed run-record folder gets a one-line pointer to it. This is the "short note" of the ruling, written once.
3. **Sealed packages need a decision the ruling does not settle.** Of the 275 tracked text files that contain one of these strings, about 79 are named in a tracked checksum manifest (15 folders hold one: 5 under `experiments/interior_quantiles/`, 5 under `experiments/joint_upper_levels/`, 1 under `experiments/air_simulation/`, and others). Editing such a file makes `sha256sum -c` fail. Three options: (i) scrub and regenerate the manifest, keeping the original as `SHA256SUMS.original` with the note; this keeps a working check, but the manifest no longer certifies the bytes that ran; (ii) leave sealed files untouched and scrub only unsealed ones, which leaves the user id and host names public in those packages; (iii) scrub and state in the note that the manifests are historical. I recommend (i). `experiments/README.md` says today that these files "must not be edited", so that sentence changes with it. `lean/SHA256SUMS.txt` is not affected: it covers the Lean sources only, and the home paths under `lean/` are in `lean/notes/` and `lean/PLAN.md`.
4. Code is scrubbed like text, then run: any script whose path was changed gets its test or a dry run (`applications/Growth/Growth_Joint_checks.R:13` is a fallback path in code that the paper's growth fit uses).
5. The scrub does not touch `paper/main.tex` or `paper/sections/` (no change to the paper).

1. **Raw sensor data is public and its terms are unknown.** The seven files `applications/Air Quality/S08_2018-06-1{5..9},2{0,1}.csv` (20 MB each, 140 MB) are tracked in HEAD. `applications/Air Quality/DATA.md` and the current README say they "were removed from git"; they were not. The same `DATA.md` has "Source: TODO (sensor owner / download URL)". Until the source and its redistribution terms are known, the README cannot say the data are public. E-18 reads the first file from this path, so do not untrack before E-18 decides how the data are supplied. The files also exceed the 5 MB policy.
2. **Third-party paper text.** `paper/history/simulation_revision_20260914/Brantley_2020.txt` is the extracted text of a published article (it carries its authors' e-mail addresses). The repo's own rule keeps third-party PDFs out of git; this text file slipped past it. Other extracted texts under `paper/history/` should be checked the same way.
3. **Cluster project path on the front page.** `README.md:28` prints the cluster checkout path with the project allocation name and the user id. The proposed README drops the line. *Covered by the ruling.*
4. **User id and home paths.** The Rice user id appears in 237 tracked files and absolute home paths in 202: `experiments/interior_quantiles/` (63 files, inside sealed packages that cannot be edited without breaking their checksums), `lean/notes/` (26 files; the reviews link to worktree paths under the home directory, for example `lean/notes/reviews/CheckLoss_2026-11-25.md:44`), `lean/PLAN.md:26`, `engineering/` (about 80 files), `theory/` (5), `applications/Munich Rent/Others/results_pmala_k2/RUN_METADATA.txt:3`. Low sensitivity each, but it is exactly the class the brief names. *Covered by the ruling.* In `lean/notes/reviews/` the home paths sit inside Markdown links to a worktree, so the links are dead on GitHub; the scrub should turn them into repo-relative links (`../../BQTF/CheckLoss.lean#L111`), which also makes the reviews usable by a reader.
5. **Windows user paths.** `C:\Users\<name>\OneDrive\...` in 44 files, about 1,900 occurrences, mostly `paper/history/` (29 files); also `applications/Growth/Growth_Joint_checks.R:13` (a fallback path in code the paper uses) and `applications/Munich Rent/Munich_PMALA_checks.R:9`, `:12`. *Covered by the ruling* (same rule as home paths).
6. **E-mail addresses.** The three authors' addresses are in `paper/main.tex:54-58` and therefore in `paper/main.pdf` (normal for a manuscript; owner's decision), and in old snapshots: six files under `paper/history/` and `experiments/joint_upper_levels/paper_reference/main.txt`.
7. **Cluster host names and addresses.** Login and data node names and two private IP addresses appear in 17 files under `experiments/` (the `environment.sh` files of the frozen packages, deployment logs, `metadata/environment.txt`, `air_simulation/onizuka_laplace_20261023/BUILD_REPORT.md`). Slurm account and partition lines (`--account=commons`) appear in the frozen job scripts; the allocation name appears in 14 files. *Covered by the ruling.*
8. **Internal process shown in public.** Task ledgers, agent work logs (`lean/notes/logs/`), `theory/TUESDAY_PLAN.md`, and phrases such as "Ask Felipe for the PC path" and "needs HQ's OK" (current README, `.githooks/pre-commit`). Nothing secret; the owner should decide whether this is the picture wanted next to the paper. The arrangement above keeps it off the front page.
9. **Git history.** Scrubbing the current files leaves every old path, host name and address reachable in the history. Only a history rewrite removes them, which Engineering did once in E-03 and which changes every commit hash. *Open item for the owner* (Section 8).
10. **No credentials found.** A search for keys, tokens, passwords and private-key headers over the tracked files found none (the two hits were the words "token" in a Lean log and a Lean identifier).
11. **Licence of the shipped data.** `applications/Growth/data/fdgs.csv` is exported from the R package `mice` (stated in its `README.txt`); the README's Data section should name the source and that package's licence. The Munich data go to `archive/` with M1.

---

## 8. Open items for the owner

Decisions the owner has asked to see listed:

1. **Rewriting the git history to remove the old paths.** The scrub of Section 7 cleans the current files only. A rewrite would also remove the user id, home and cluster paths, host names, the Windows paths and anything else scrubbed, from every past commit. Cost: every commit hash changes (the hashes quoted in `lean/notes/`, in `PAPER_CORRECTIONS.md`, in run ledgers and in `engineering/E03_Repo_Organization/hash_map.tsv` would need a second map), every clone and the cluster checkout must be re-cloned, and forks or caches made before the rewrite keep the old content. Gain: the strings are low-sensitivity identifiers, not credentials. My reading: not worth it for the paths alone; worth it only if it is also the way to remove item 1 (raw sensor data, 140 MB) or item 2 (third-party article text) of Section 7, should the owner decide those must go.
2. **Whether `literature/Large Prior.pdf` stays public.** It is the only PDF tracked under `literature/` (1.3 MB), kept by an explicit exception in `.gitignore` as "our own manuscript". It is the manuscript of a different paper, which has its own public repository with its own PDF. Points for the decision: whether a journal now holds rights to that text; whether this copy is the current version (two public copies drift apart); and whether a link to the other repository in `literature/READING_LIST.md` would serve the same purpose. I would replace the file by the link.

Other decisions still open:

3. **SPod data** (Section 7, item 1): who owns it and may it be redistributed? Today the files are tracked although `DATA.md` says they were removed. This decides the README's Data section.
4. **Third-party article text** in `paper/history/` (Section 7, item 2): remove from the current tree, and from history or not (ties to item 1 above).
5. **Authors' e-mail addresses** in `paper/main.tex` and `main.pdf`: normal for a manuscript; the brief's rule says none. Owner's call; no change to the paper is proposed here.
6. **Department folders**: listed last (recommended) or moved under `records/` after E-18 and E-19 (M3)?
7. **H1 of the README**: short ("Bayesian quantile trend filtering") or the full paper title?
8. **Where the published figure, its script and its curves live** (Section 2.4): `examples/` (proposed) or `writing/`.
9. **Sealed packages and the scrub** (Section 7, point 3 of "How I would apply the ruling"): regenerate the manifests, leave sealed files alone, or mark the manifests historical.

Settled during drafting, recorded so that nobody reopens them: the hero is the joint sampler's 0.1 to 0.9 band (not per-curve credible bands); Writing draws the README figures from Engineering's saved curves; the growth panel is captioned as a joint-sampler fit and never as the paper's figure; the SPod panel shows the low baseline only.

---

## 9. What we take from the LP repo

I read the Large Prior repository as a whole: its front page, the READMEs of `sampler/`, `applications/`, `lean/` and `paper/`, and its layout (five top-level folders: `applications/`, `lean/`, `paper/`, `sampler/`, `simulations/`).

### Adopt as it is

| From the LP repo | Here |
|---|---|
| Front-page order: badges, one sentence with title and authors, "The main idea behind this project" in three paragraphs (method, theory, computing), figure with a one-line italic caption, "Our work" table, requirements, data, citation and license | Section 1 follows it |
| "Our work" table: paper item, folder, command typed in that folder, time | Section 1.3 |
| A subtitle line under each folder README's title naming the paper items it serves (*Section 3.4 · Figure 4*) | Add to `method/`, `experiments/*/`, `applications/*/`, `examples/` READMEs |
| `reference_outputs/` with small CSV files, summaries and the figure, no posterior draws; and a `--from=reference_outputs` way to redraw without fitting | `examples/reference_outputs/` now; per-experiment "from the shipped results" commands as Engineering adds them |
| The Lean README's structure: what is proved, build and check, table "Paper / Lean statement / Proved by", differences from the paper, files | `lean/README.md` already follows it, and `LEAN_SECTION.md` keeps the same order |
| Stating limits where the claim is made (the LP sampler README opens with a "Scope" box; its Lean README says which classical inputs are hypotheses) | The theory paragraph says that random λ and σ are not covered; the Lean section names D10; the figure rules of Section 2.3 |
| Plain prose, numbers in place of adjectives, "we" for the authors, no hype words | Throughout |
| "Questions or problems? Please open an issue." and no e-mail addresses | Section 1.1 |
| Data section that names each source, its licence, and whether the raw files are shipped | Needed here as soon as the SPod terms are known (Section 8, item 3); Growth: `mice` |

### Adapt

| From the LP repo | Why it changes here |
|---|---|
| The sampler is a function you `source()` and call, with a usage block, arguments, value and errors | Our samplers are scripts with a settings block, and sourcing one runs its pilot fit (Section 4, point 1). The quick start shows the script run today. A callable entry point with a usage block like LP's is the single change that would most improve the repo for a user; it needs Engineering and is not required for this proposal. |
| Lean: one line on the front page | Here the owner wants a full section, since two theorems are verified with no classical result assumed, which is a stronger claim than LP's (LP takes three classical approximation results as hypotheses). `LEAN_SECTION.md`. |
| Figure: a figure of the paper, redrawn by a script in `applications/` | Our hero is not a figure of the paper. It is made for the README from saved curves, so its caption must not cite a paper figure number, and panel (c) must not be presented as the paper's growth figure. |
| "Every figure and table of the paper comes from a script in this repository" | Not true here yet (generators for several figures are missing). The sentence is replaced by one that says which items have no script. |
| Everything reruns on a laptop in seconds to minutes | Our campaigns are cluster runs from frozen packages. The table gives "from the shipped results" commands where they exist and says "full run only" otherwise. |
| Licence: MIT with a GPL-3 exception for adapted code | MIT for code; the manuscript text is excluded. Engineering should confirm that `method/admm_qtf/` and the Onizuka add-on under `experiments/air_simulation/` contain no adapted third-party code that needs its own notice. |
| Five top-level folders | Six public folders plus five record folders (Section 3). |

### Does not fit us

| From the LP repo | Why not |
|---|---|
| A repository that contains only the public product | This repository is also the project's working record (task folders, pilots, reviews, run ledgers), and the owner wants those kept. They are listed last and described as records. The alternative, a separate clean release repository like LP's, would be the closest match to LP; it is a larger decision than this proposal and I only name it. |
| `paper/Overleaf/` plus one PDF named after the paper | The paper is built from `paper/main.tex` here, and `\input` paths must not change. Renaming `main.pdf` is not worth a move. |
| A separate `simulations/` and `sampler/` at the top | Ours are `experiments/` and `method/`, referenced by 50 to 190 files each; renaming them to match LP would cost far more than it gives. |
| Byte-for-byte reproduction claims for reruns | We have bitwise tests for the kernels only, and they depend on compiler flags (`method/README.md`). No such claim on the front page. |
| A 15-minute Lean build stated on the front page | No measured build time is in our Lean notes; placeholder until the Lean head supplies one. |
