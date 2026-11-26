# Working rules

These are the rules the departments follow when they work in this repository. They were on the front page until the public README replaced it (task W-08). Engineering owns this file.

## Committing (all departments share one working tree and git index)

- Commit with explicit paths, staging and committing in ONE command: `git add <your paths> && git commit -m "..."`, or, for files already tracked, `git commit -m "..." -- <your paths>`.
- Never use `git commit -a`, `git add -A` or `git add .`, and never commit an index you did not stage yourself in that same command. A commit picks up whatever any department has staged.
- Departments commit locally; only HQ pushes.

## No absolute paths

No absolute paths. Write paths relative to the repository root, or use `$HOME` or an environment variable; never a home directory, a cluster project path, a host name or an account name. The README, the folder READMEs and every new document follow this rule. Engineering adds a check for the agreed patterns to the pre-commit hook (draft: `engineering/H_RW/pre-commit`, not yet enabled).

## Size hook

Enable the hook once per clone: `git config core.hooksPath .githooks`. It refuses staged files over 5 MB. Anything larger than 5 MB needs HQ's OK; approved exceptions are listed in `.githooks/size_allowlist.txt`. Chains, raw draws, monitor logs and raw data go to the PC through E-01, never to git.

## Departments and task IDs

Work is tracked as `T-xx` (Theory, `theory/T0x_*`), `E-xx` (Engineering, `engineering/E0x_*`) and `W-xx` (Writing, `writing/W0x_*`); the Lean formalization is in `lean/`. Commit messages start with the task ID (for example `E-18: ...`, `W-08: ...`). Reports are `MEMO.md`, `REPORT.md`, `README.md` in the task folder.

## Folders that are not in git

`ops/`, `runs/` and `tmp/` are git-ignored and local to each machine.

- `ops/` holds the E-01 operations pipeline: ops scripts, receipt ledger, PC puller, ssh lock shim and the R library `ops/Rlib`.
- `runs/` holds run outputs and sealed `archive-*` runs headed for the PC.
- `tmp/` is scratch.

Each compute machine keeps one checkout with this same layout; see `engineering/E12_Disk_Reorg/`.

## Rerunning older experiments after F12

F12 (`4fceea8`) removed the unadopted λ jump move from `method/individual/Individual_Sampler_PMALA_Augmented.R`. Its default fits are bit-identical to the old ones. The E-14, E-15, E-16, E-18 and E-20 runners still pass the old `lamjump` arguments. These runners are records of the runs they made and are not edited. To rerun one, build its code copy with `method/individual/Individual_Sampler_PMALA_Augmented.R` and `prox_admm_metric.cpp` restored to their blobs at sampler commit `63f2a56` (`git show 63f2a56:<path>`), and check the two blob hashes before fitting. E-19 does this (see its Run log).
