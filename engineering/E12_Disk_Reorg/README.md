# E-12 Disk reorganisation (Owls side), 2026-11-25

Felipe's rule is one BQTF folder per machine.
- **Owls:** the repo `/home/fb31/Bayesian-Quantile-Trend-Filtering` (ROOT), which holds three git-ignored top-level folders: `ops/`, `runs/` and `tmp/`.
- **NOTS:** `~/BQTF` → `/projects/ml75/fb31/BQTF`, a checkout of the same repo with the same three git-ignored folders.

The NOTS side was done by Opus-NOTS. This page covers Owls. Executed by Opus-Owls under the Engineering manager's GO (11:05 CT).

## Layout

| Folder | Contents |
|---|---|
| `ops/` | The E-01 pipeline (was `~/BQTF_ops`). It holds `CLAUDE.md`, `README.md`, `bin/` (`bqtf_ops.sh`, `residue_remote.sh`, `verify_receipt.py`, `sshlock/`), `ledger/`, `logs/`, `seal_run.sh` (the sealer, at the same path as on NOTS `~/BQTF/ops/seal_run.sh`), `pc/bqtf_pull.ps1`, `backup/`, and `Rlib/`, the Owls R library that was `~/R/e02lib`. |
| `runs/` | `E02/` and `E04/` (were `~/BQTF_runs`), `E08-lambdaprior-20261123/` (was `~/BQTF_ops/runs`), `pilot-lambda_mixing-20261124/` (the 8 pilot `.rds` files), and `archive-owls-session-scratch-20261125/` (see below). |
| `tmp/` | `e03/` (holds the E-03 rollback bundle), `e03_kit/`, `paper_smoke/`, `smoke/`, `s/`, `loose/` (19 BQTF files from `/tmp/claude-71711`), `theory_scratch/` (was `~/BQTF_ops/theory_scratch`), and the E-12 records `E12_*`. |

## Moves

All moves were checked against sha256 lists taken before the move; the lists are in `tmp/E12_premove_manifest/`.

| From | To |
|---|---|
| `~/BQTF_ops` | `ops/` |
| `~/BQTF_runs/{E02,E04}` | `runs/` (the Rcpp cache `E02/.rcpp_cache`, 17M, was deleted) |
| `~/BQTF_ops/runs/E08-…` | `runs/` |
| `~/R/e02lib` | `ops/Rlib` |
| `/tmp/claude-71711/{e03,e03_kit,paper_smoke,smoke,s}` and 19 loose files | `tmp/` (copied, verified, then removed from `/tmp`) |

`~/BQTF_ops`, `~/BQTF_runs` and `~/R/e02lib` no longer exist, and no symlinks were left behind.

## Archives for the PC (sealed on NOTS by Opus-NOTS, pulled by E-01)

**`archive-owls-session-scratch-20261125`**
- Contents: the scratchpads of 8 Claude sessions (E-06/E-07 code and validation chains, theory literature extracts), with caches and symlinks removed.
- On NOTS: 4856 files, manifest `db231142…`.
- On NOTS only, two file names had their spaces replaced. The mapping is in `RENAMES.tsv` inside that run.

**`archive-owls-runs-E02-E04-20261125`**
- Contents: `runs/E02` and `runs/E04`.
- On NOTS: 885 files, manifest `8e45325b…`.

The Owls originals in `runs/` stay until the PC receipt arrives.

**Before the Owls copy of the session-scratch archive is deleted.** These 10 E-07 scripts point into `runs/archive-owls-session-scratch-20261125/` on Owls. Each takes the session's scratchpad as its code or data folder (`SCR`/`S`, or a `source`/`saveRDS` path).

| Script (under `engineering/E07_Tuning_Free/`) | Line | Session dir |
|---|---|---|
| `joint/smoke_scripts/identity.R` | 1 | `5a5aaa0b…` |
| `joint_gibbs/common_v3.R` | 6 | `12592220…` |
| `joint_gibbs/felipe_run_v3.R` | 5 | `12592220…` |
| `joint_gibbs/unit_v3.R` | 2 | `12592220…` |
| `joint_gibbs/validate/analyze_b2.R` | 2 | `7aecef86…` |
| `joint_gibbs/validate/common.R` | 6 | `7aecef86…` |
| `joint_gibbs/validate/common2.R` | 6 | `7aecef86…` |
| `joint_gibbs/validate/felipe_run.R` | 4 | `7aecef86…` |
| `joint_gibbs/validate/val_b.R` | 16 | `7aecef86…` |
| `joint_gibbs/validate/val_b_smooth.R` | 16 | `7aecef86…` |

After the Owls delete these scripts will not run as they are. To rerun one, restore that session dir from the PC archive to the same path, or point its line at the restore location. These are frozen E-07 records, and the canonical sampler code in `method/` does not depend on them.

## Deleted

- **Session scratch** under `/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/`: 689 empty dirs with no transcript, plus 4 E-07/theory worker dirs (117M) whose content is in the archive above. The full list is in `tmp/E12_deleted_sessions.txt`, written before deletion, and the outcomes are in `tmp/E12_deleted_sessions.log`.
- **Kept:** every session of HQ, the department heads, the advisors (VP, Fable), the E-01 runners and the live E-12 agents. Empty dirs created within the last 60 minutes were also kept.
- **Trash:**
  - `/tmp/claude-71711/paper_build_test` (copy of `paper/` plus the failed 11-22 build);
  - `/tmp/claude-71711/texdl.6ZQA` (LaTeX package downloads, already installed in `~/texmf`);
  - the git-ignored `paper/main.{aux,bbl,blg,fdb_latexmk,fls,log,out,toc}`;
  - `theory/T03_Feasibility/scratch/__pycache__`.

## Path updates

- The repo scripts' `BQTF_runs` defaults now point to `ROOT/runs`.
- The E-07 session-scratch paths now point to the archive above, and the E-07 Rcpp caches now go to `ROOT/tmp/rcpp_cache`.
- `.libPaths` now uses `ROOT/ops/Rlib`.
- The NOTS job files use `$HOME/BQTF/tmp` and `$HOME/BQTF/ops/Rlib`.
- In ops: `bqtf_ops.sh` has `OPS=ROOT/ops` and the shim path relative to `OPS`; `CLAUDE.md` has the new self-paths and the PC puller download `/projects/ml75/fb31/BQTF/ops/pc/bqtf_pull.ps1`.
- The residue sweep moves to `ops/bin/residue_remote.sh`, called by `bqtf_ops.sh` (`residue [--dry-run]`). `ops/` is git-ignored, so the scripts are not in git.
  - It works on root `$HOME/BQTF` and never creates `tmp/` (no more `mkdir /scratch/fb31/BQTF`).
  - In `tmp/`, files are deleted when their **ctime** is more than 14 days old, and empty dirs when it is more than 3 days old (`-ctime +2`). Using ctime matters because `mv` and `cp -p` keep the old mtime. The 3-day limit is HQ's guard for a long Slurm job's empty TMPDIR.
  - The untracked-cache sweep (`__pycache__`, `*.pyc`, `.Rhistory`, core dumps) prunes `.git`, `runs`, `ops` and `tmp`, and skips anything git tracks.
  - Symlinks are never followed. The root (`~/BQTF`, a symlink) is resolved once with `realpath`, every `find` is `-P`, and a `tmp/` that is itself a symlink is skipped with a WARN.
  - The cache sweep fails closed. It is skipped with a WARN if git cannot read the index (`ls-files --error-unmatch .gitignore`), and a path is deleted only when `git ls-files` exits 0 and prints nothing. (These are Astra review points, verified by the manager.)
  - Dry runs on 2026-11-25 listed nothing on NOTS (Opus-NOTS) or on Owls. On test roots in the scratchpad, a root reached through a symlink resolves correctly, a symlinked `tmp/` with a 30-day-old file is skipped, and a non-git root skips the cache sweep.
  - It went live on 2026-11-25 at 12:00 CT, with HQ's and the manager's approval. The Astra fixes went in at 12:03. `bqtf_ops.sh status` ran OK through the shim (`ops/logs/20261125-120017-status.log`, and again at 12:03).
  - The old copies are in `ops/backup/`: `bqtf_ops.sh.20261125-{preE12,preResidueSwap,preAstra}`, `residue_remote.sh.20261125-{mtime,ctime1,preAstra}` and `seal_run.sh.20261125-preAstra`.
- `bqtf_ops.sh`:
  - The allowlist key `dir:/scratch/fb31/BQTF/e01_mirror_test` is kept, with a comment, so the old ledger entry `ledger/_tests/E01-mirrortest` still verifies. It creates nothing. (This was the manager's call on 11-25, after a brief removal at 12:02.)
  - `REMOTE_RUNS` and the verified-delete `R=` keep the physical path `/projects/ml75/fb31/BQTF/runs` on purpose. The checks there compare resolved paths, like the sealer, and the PC key is scoped to that path.
- `ops/seal_run.sh` (moved from `ops/nots/` so that Owls mirrors NOTS `~/BQTF/ops/seal_run.sh`; `ops/nots/` is removed): only the usage comment on line 4 changed, to `bash ~/BQTF/ops/seal_run.sh ~/BQTF/runs/<RUN_ID>`. The code lines are identical to the NOTS copy.
- E-03:
  - In the frozen files, only the re-clone lines changed (commit 23ca11e).
  - The working kit `tmp/e03_kit/` got the tracked `CHECKLIST.md` and `05_history_rewrite.sh`. A diff showed no kit-only edits, and the old kit copies are in `tmp/e03_kit_backup_20261125/`.
  - The kit has no `strip_blobs.txt` (the tracked folder does), so a rewrite run from the kit would skip the blob-level drop.

## Left alone (not BQTF, or shared)

- **Other projects:** in `/tmp/claude-71711`, `lhv` (BNP), `relo` (SMC-BVS), `xx`, `ckg`, `ksj`, `mt`, `mt2`, `lcfix2` and `ci_*` (BVS); `~/Papers_local`; `~/repo_backups`; `~/Misc`; `~/theory_campaign`; `~/phaseB_inbox`; `~/variety_*`; `~/tools`; `~/data/review`.
- **Shared tool installs:** `~/texmf`.
- **Not tied to BQTF:** 142 loose files in `/tmp/claude-71711` with no BQTF markers in their content.
- **Shared caches:**

| Folder | Size |
|---|---|
| `~/.t3` | 63G |
| `~/.cache` | 17G |
| `~/.codex` | 12G |
| `~/.vscode-server` | 7.0G |
| `~/.elan` | 6.9G |
| `~/envs` | 6.7G |
| `~/.claude-personal` | 5.5G |
| `~/.claude-third` | 4.2G |
| `~/.cursor-server` | 3.6G |
| `~/.claude` | 3.2G |
| `~/.conda` | 2.1G |
| `~/.local` | 2.0G |
