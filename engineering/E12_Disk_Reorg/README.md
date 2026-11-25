# E-12 Disk reorganisation (Owls side), 2026-11-25

Felipe's rule is one BQTF folder per machine.
- **Owls:** the repo `/home/fb31/Bayesian-Quantile-Trend-Filtering` (ROOT), which holds three git-ignored top-level folders: `ops/`, `runs/` and `tmp/`.
- **NOTS:** `~/BQTF` → `/projects/ml75/fb31/BQTF`, a checkout of the same repo with the same three git-ignored folders.

The NOTS side was done by Opus-NOTS. This page covers Owls. Executed by Opus-Owls under the Engineering manager's GO (11:05 CT).

## Layout

| Folder | Contents |
|---|---|
| `ops/` | The E-01 pipeline (was `~/BQTF_ops`). It holds `CLAUDE.md`, `README.md`, `bin/` (`bqtf_ops.sh`, `residue_remote.sh`, `verify_receipt.py`, `sshlock/`), `ledger/`, `logs/`, `nots/seal_run.sh`, `pc/bqtf_pull.ps1`, `backup/`, and `Rlib/`, the Owls R library that was `~/R/e02lib`. |
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
- The residue sweep moves to `ops/bin/residue_remote.sh`. It works on root `$HOME/BQTF` and prunes `.git`, `runs`, `ops` and `tmp`. It goes live after the manager approves the dry run.
- E-03: only the re-clone lines changed (commit 23ca11e).

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
