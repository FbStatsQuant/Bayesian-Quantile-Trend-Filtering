# Working rules

These are the rules the departments follow when they work in this repository. They were on the front page until the public README replaced it (task W-08). Engineering owns this file.

## Committing (all departments share one working tree and git index)

- Commit with explicit paths, staging and committing in ONE command: `git add <your paths> && git commit -m "..."`.
- Never use `git commit -a`, `git add -A` or `git add .`, and never commit an index you did not stage yourself in that same command. A commit picks up whatever any department has staged.

## No absolute paths

No absolute paths. Write paths relative to the repository root, or use `$HOME` or an environment variable; never a home directory, a cluster project path, a host name or an account name. The README, the folder READMEs and every new document follow this rule. Engineering adds a check for the agreed patterns to the pre-commit hook.

## Size hook

Enable the hook once per clone: `git config core.hooksPath .githooks`. It refuses staged files over 5 MB. Anything larger than 5 MB needs HQ's OK; approved exceptions are listed in `.githooks/size_allowlist.txt`.

## Departments and task IDs

Work is tracked as `T-xx` (Theory, folders `theory/T0x_*`) and `E-xx` (Engineering, folders `engineering/E0x_*`). Commit messages start with the task ID (`T-03: ...`, `E-03: ...`). Reports are `MEMO.md`, `REPORT.md`, `README.md` in the task folder.

## Folders that are not in git

`ops/`, `runs/` and `tmp/` are git-ignored and local to each machine.

- `ops/` holds the E-01 operations pipeline: ops scripts, receipt ledger, PC puller, ssh lock shim and the R library `ops/Rlib`.
- `runs/` holds run outputs and sealed `archive-*` runs headed for the PC.
- `tmp/` is scratch.

Each compute machine keeps one checkout with this same layout; see `engineering/E12_Disk_Reorg/`.
