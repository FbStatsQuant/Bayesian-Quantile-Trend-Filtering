# E-03 migration runbook (PREPARED, NOT APPLIED)

Owner: Engineering head. Executor: a Sonnet agent for the commands, reviewed by the Engineering head. HQ pushes. Window: about 2 hours, agreed with Theory (HQ amendment 4). Nothing in this kit has been run.

Kit contents: `01_moves.sh` (moves, one commit per area, plus DELETE section), `01b_heavy_rm.sh` (git rm of PC-archived data, receipts required), `02_path_fixes.md` (edits), `03_new_files/` (README, .gitignore, hook, LICENSE, CITATION.cff, folder READMEs, DATA.md), `04_smoke.sh`, `05_history_rewrite.sh` (D1).

Decisions already taken (Felipe, HQ): D1 history rewrite YES; D2 `paper/main.pdf` tracked; D3 third-party PDFs not tracked, `Large Prior.pdf` tracked, links in `READING_LIST.md`; D4 MIT for code, manuscript all rights reserved, `CITATION.cff`. Applications moved as-is. Case renames in two steps. The sampler-defaults reset is its own commit. SPod/Munich/monitor data are archived to the PC first; `git rm` only after the signed receipt.

## A. Before the window (T minus 1 day or more)

1. **E-01 transfers, with signed receipts** (blocking for step 11 and for the history rewrite):
   - SPod CSVs: 7 files, 139 MB (SHA-256 already in `03_new_files/applications/Air_Quality_DATA.md`).
   - Munich `Others/results*`: 115 MB, 90 files (hashes in `Munich_Rent_DATA.md`).
   - `history.jsonl` of the joint upper-levels run: 10,834,398 bytes, SHA-256 `c8223d49...48b0`.
   - Put the receipt run ids into the three `DATA.md` / `MONITOR_LOG_POINTER.md` files (the TODO lines) and into `03_new_files/` before the window.
2. **Local PDFs.** Confirm `Papers/*.pdf` are all present on Owls; they stay on disk but leave git (copy kept by `05_history_rewrite.sh` in `~/BQTF_literature_pdfs`). Felipe's PC copy: make sure he has them too.
3. **Fill the two TODOs** you can: `Large Prior` link in `READING_LIST.md` (if posted), SPod source in `Air_Quality_DATA.md`.
4. **Review** the kit: Engineering head reads `02_path_fixes.md` and `03_new_files/*`; HQ reads the README and the open-items list.
5. **Dry run:** `DRY_RUN=1 bash 01_moves.sh` (default). It is read-only; check that every `git mv` source exists (the preflight does) and read the echoed plan once.
6. **Theory** commits (or discards) its untracked file `Theory/T03_Feasibility/scratch/gibbs_validation_grid2.out` and everything else it wants in git. Untracked files travel with their folder, but a clean state is safer.
7. **Engineering** has no unsaved edits in `Engineering/` (E-02 and E-04 are still changing files, 2026-11-22), and no job is reading the repo directly. NOTS jobs run from `$RUN/code` snapshots, so they are unaffected; check with `squeue -u fb31` on NOTS only if a job takes its code from the repo path.
8. Install on Owls (needed by the smoke tests, user-level only): LaTeX `algorithmicx` (algpseudocode), `bbm`, `bbold` in a user texmf; R package `clarabel` in a user library. Owls compute policy: the smoke tests are single-threaded and about 5 minutes in total, inside the 8-core budget.

## B. Freeze announcement (send to Theory, CC HQ, at T minus 1 hour)

> **E-03 freeze, today HH:MM to HH:MM (about 2 h).** From HH:MM nobody edits or commits in `/home/fb31/Bayesian-Quantile-Trend-Filtering` (Theory: please commit what you want kept before then and do not run scripts that write into the repo). The repo will be reorganized: `Theory/` becomes `theory/`, `Papers/` becomes `literature/` (PDFs stay on disk, not in git), `Project_Paper/` becomes `paper/`, `Simulations/` becomes `method/` and `experiments/`. Your task folders keep their contents and sub-folder names; prose references to `Papers/` in your memos need a one-line `sed` afterwards (I will send it). I will message when the window closes. Until then, work in a scratch folder outside the repo.

## C. In the window (Engineering head + Sonnet agent)

Run everything from a copy of the kit outside the repo (the script refuses otherwise: `Engineering/` is renamed in step 7):
`cp -r /home/fb31/Bayesian-Quantile-Trend-Filtering/Engineering/E03_Repo_Organization/migration /tmp/e03_kit`

0. **Safety copies** (not in git):
   - `cd /home/fb31/Bayesian-Quantile-Trend-Filtering && git status -sb` (main, clean except the two untracked paths) and `git log -1 --format=%H > /tmp/e03_pre_hash.txt`
   - `git bundle create /tmp/e03_pre_migration.bundle --all`
   - `mkdir -p /tmp/e03_untracked && cp -a Engineering /tmp/e03_untracked/ && cp -a Theory/T03_Feasibility/scratch /tmp/e03_untracked/theory_scratch`
1. **Moves:** `cd /tmp/e03_kit && DRY_RUN=0 bash 01_moves.sh 2>&1 | tee /tmp/e03_moves.log`. It refuses to start if any tracked file has changes (`git status --porcelain --untracked-files=no`). It prints the pre-migration hash and writes the SHA256SUMS baseline of the frozen packages into `.git/E03_SHA_BASELINE`. It creates 13 commits: paper, method, sampler-defaults, experiments, applications, archive, departments, literature, newfiles, bib merge, stale-bib removal, throwaway removal, untrack (heavy data is step 5).
2. **Check the tree:** `git status` clean; `find Simulations Temp "Data Applications" Papers Project_Paper -type f` empty; `git ls-files | sort -f | uniq -di` prints nothing (no case-only duplicates, the Windows check); `git log --stat -1 <departments commit>` shows `Theory/... => theory/...` renames, not delete+add.
3. **Path fixes** from `02_path_fixes.md`, sections A to G, as separate commits `E-03: path fix: ...`. The Engineering head reviews `git diff` before each commit. Re-derive the E-02/E-04 line numbers first (section F of the file).
4. **Smoke tests:** `bash /tmp/e03_kit/04_smoke.sh all` (paper, individual `test`, joint `test_prox`, path grep, hook, seals). All must print PASS and the script must end with `ALL SMOKE TESTS PASSED`. If one fails, fix and re-run; do not hand over to HQ with a FAIL. The individual-driver check in `02_path_fixes.md` G2 is run by the Engineering head by hand.
5. **Heavy data removal (only with signed receipts):** `DRY_RUN=0 RECEIPT_SPOD=1 RECEIPT_MUNICH=1 RECEIPT_MONITOR=1 bash /tmp/e03_kit/01b_heavy_rm.sh`. It re-checks the SHA-256 of the SPod files against `DATA.md` before removing them.
6. **Close the window:** tell Theory and HQ ("window closed; Theory works in `theory/` now; here is the `sed` for `Papers/` -> `literature/`").

## D. History rewrite (D1) and push
- **Blob-level drop (added 2026-11-23, HQ):** `strip_blobs.txt` lists the 12 superseded 300-dpi gate-result PNGs from commit **f297aef** (`engineering/E07_Tuning_Free/joint_gibbs/gate_results/*.png`, ≈ 5.9 MB in total).
  - The same paths now hold 150-dpi versions, so they are dropped by blob id (`--strip-blobs-with-ids`, wired into `05_history_rewrite.sh`), not by path.
  - None of the 12 ids is in the current tree (checked).

Done right after step C5 while the freeze still holds, so that only one push happens.

1. On a fresh mirror clone, never in the working repo: `DRY_RUN=0 RECEIPT_SPOD=1 RECEIPT_MUNICH=1 RECEIPT_MONITOR=1 PDFS_BACKED_UP=1 bash /tmp/e03_kit/05_history_rewrite.sh` (first run it with `DRY_RUN=1` to read the plan). It removes from all history the SPod CSVs, Munich `Others/results*`, the `before/` and `build/` `main.pdf` snapshots, the `history.jsonl` monitor log and every third-party PDF except `Large Prior.pdf`; checks that none is left; writes `engineering/E03_Repo_Organization/hash_map.tsv` (old to new hash) as the last commit in the work clone; prints before and after `.git` sizes (expected: 191 MB to about 15 MB).
2. Check in `/tmp/bqtf_rewrite/work`: `git log --oneline | head`, `git ls-files | wc -l`, a build of the paper (`cd paper && latexmk -pdf main.tex` in a scratch copy), `git rev-list --objects --all | git cat-file --batch-check` shows no blob above 5 MB.
3. **HQ pushes:** `cd /tmp/bqtf_rewrite/work && git push --force origin main`. Nobody else pushes meanwhile.
4. **Re-clone everywhere** (all old clones are stale and must not push):
   - **NOTS** (since E-12 the checkout IS `/projects/ml75/fb31/BQTF`, reached as `~/BQTF`; its gitignored `ops/ runs/ tmp/` must move into the fresh clone): `cd /projects/ml75/fb31 && mv BQTF BQTF.pre-rewrite && git clone https://github.com/FbStatsQuant/Bayesian-Quantile-Trend-Filtering BQTF && mv BQTF.pre-rewrite/ops BQTF.pre-rewrite/runs BQTF.pre-rewrite/tmp BQTF/`. The `~/BQTF` symlink keeps pointing at `/projects/ml75/fb31/BQTF` (`ls -l ~/BQTF` must still show that target; the PC key is pinned to that path). Check `squeue -u fb31` first: no job may be running, since jobs write into `runs/` and `tmp/`. Remove `BQTF.pre-rewrite` only after the first job from the new clone has run.
   - **Owls** (since E-12 the gitignored `ops/ runs/ tmp/` live inside the checkout and must move into the fresh clone; `ops/` holds the E-01 ledger, so no E-01 run may be in progress): `mv ~/Bayesian-Quantile-Trend-Filtering ~/Bayesian-Quantile-Trend-Filtering.pre-rewrite && git clone https://github.com/FbStatsQuant/Bayesian-Quantile-Trend-Filtering ~/Bayesian-Quantile-Trend-Filtering && mv ~/Bayesian-Quantile-Trend-Filtering.pre-rewrite/ops ~/Bayesian-Quantile-Trend-Filtering.pre-rewrite/runs ~/Bayesian-Quantile-Trend-Filtering.pre-rewrite/tmp ~/Bayesian-Quantile-Trend-Filtering/ && cp ~/BQTF_literature_pdfs/*.pdf ~/Bayesian-Quantile-Trend-Filtering/literature/ && cd ~/Bayesian-Quantile-Trend-Filtering && git config core.hooksPath .githooks`.
   - **Felipe's PC (one line, PowerShell, adjust the folder):** `Rename-Item BQTF BQTF_old; git clone https://github.com/FbStatsQuant/Bayesian-Quantile-Trend-Filtering BQTF; Copy-Item BQTF_old\Papers\*.pdf BQTF\literature\; git -C BQTF config core.hooksPath .githooks` (the old clone's `Papers\*.pdf` are the only local copies of the third-party PDFs: copy them before deleting `BQTF_old`).
5. Update the E-01 notes and the memory files that name `Engineering/` or `Simulations/` paths (Engineering head).

## E. Rollback

Before the push (nothing has left Owls):
1. Save the files that git does not know: `cp -a engineering /tmp/e03_engineering_now` (**mandatory**: `git reset --hard` deletes tracked files absent from the target commit, which includes everything under `engineering/` that the departments commit added).
2. `cd /home/fb31/Bayesian-Quantile-Trend-Filtering && git reset --hard <pre-migration-hash>` (the hash printed by step C1, also in `.git/E03_PRE_HASH` and `/tmp/e03_pre_hash.txt`).
3. Restore the untracked state: `rm -rf engineering theory` if any empty/untracked leftovers remain, then `cp -a /tmp/e03_untracked/Engineering ./Engineering` and the Theory scratch folder back into `Theory/T03_Feasibility/scratch/` (the `.out` file is untracked). Local PDFs: restore `Papers/*.pdf` from `~/BQTF_literature_pdfs` if `git reset` removed them (it does not remove ignored/untracked files, but check).
4. `git status` equals the state recorded in step C0. If anything is unclear, restore from the bundle: `git clone /tmp/e03_pre_migration.bundle /tmp/e03_restore` and compare.

After the force-push: rollback is a force-push of the pre-migration history from the bundle (`git push --force origin <pre-hash>:main` from a clone of the bundle), which only HQ does, with Felipe's OK.

## F. Handoff to HQ (message template)

> E-03 batch ready on Owls, local only, not pushed. Pre-migration `<hash>`. Commits: `<n>` (list with `git log --oneline <hash>..HEAD`). Smoke: paper builds, individual `test` all passed, joint `test_prox` all passed, size hook, seals unchanged, path grep clean. History rewrite prepared in `/tmp/bqtf_rewrite/work` (`.git` `<before>` to `<after>`; hash map `engineering/E03_Repo_Organization/hash_map.tsv`). Please force-push `main` from there, then NOTS/Owls/PC re-clone as in CHECKLIST D4. Open items (in `applications/README.md`): missing generators for nile, spod, growth_lms, growth_pmala, scal figures; Nile data missing.
