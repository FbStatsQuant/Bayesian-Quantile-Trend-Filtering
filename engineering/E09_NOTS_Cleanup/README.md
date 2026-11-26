# E-09: NOTS cleanup (2026-11-24)

Felipe reported that NOTS "seems to be full". HQ greenlit E-09 to diagnose the space, clean caches and move heavy data to his PC.

## Diagnosis (16:57 CT, read-only)

None of fb31's NOTS space was full.

| Filesystem | Usage | Notes |
|---|---|---|
| Home (`nfs1:/export/nots/home`) | 6.5 of 10 GB (65%) | Was 9.33 GB on 11-22. |
| `/projects` (ml75 group quota) | 85 of 100 GB (85%) | fb31 owns about 3.6 GB: BQTF 3.45 GB plus BVS 0.18 GB. The other ~80 GB belongs to other ml75 members (2017–19 files). |
| `/scratch/fb31` | 347 GB SMC (off-limits) plus 18 MB BQTF | No per-user quota shown. |
| `/rhf/allocations/ea14` | `16384G*` against a 16384G limit | **Not ours.** This is a 500 TB shared allocation at 100%, and fb31 has no access to it (permission denied). `quota` prints the same line for the generic groups `hpcusers` and `nots`, so it is a reporting artifact of that full allocation. This line is the likely source of the "full" signal. |

## Cleanup

The triage worker (Sonnet) inventoried the caches read-only. The executor (Haiku) and the Engineering head then deleted, checking each item first. There were no Slurm jobs running.

| Item | Size | Result |
|---|---|---|
| `~/.t3/runtime/versions/0.1.12-nightly.20261124.{5178,5191}` | 0.99 GB | Already removed by T3 itself between triage and execution. The in-use version 5204 is kept. |
| `~/.vscode-server/extensions/openai.codex-audio-26.1120.41243` (listed in `.obsolete`) | 5 MB | Deleted. |
| Stale watcher loop, PID 2598744 (running since Oct 21), polling a cancelled Quant_Reg run | none | Killed. |
| `~/projects/Quant_Reg` | 101 MB | Deleted after re-verifying all 4,784 files against the archive manifest. Its read-only sealed package folders were made writable first, then removed. |

Nothing else qualified. Every other large item is the single version in use: the VS Code server, the `chatgpt` and `claude-code` extensions, Codex 0.167.2, the Claude remote CLI and the Antigravity CLI. There are no pip, conda or npm caches, and the BQTF scratch is under 7 days old. Auth, config and session state were not touched.

## Quant_Reg archive (index kept here)

`quant_reg_archive/` holds the archive's `INDEX.md`, `SOURCE.txt`, `SYMLINKS.txt` and `MANIFEST.sha256`. The manifest's SHA-256 is `ce855a779e4e0f8ed37e98c177887bce0f6c4389769f6712c615ad4cd2510803`.

- **Archive:** run `legacy-quant-reg-20261122`, with 4,787 files and 81.8 MB.
- **PC copy:** at `C:\Users\felip\Documents\BQTF_Data\runs\legacy-quant-reg-20261122`, PC-verified on 2026-11-22 at 16:38 CT.
- **Receipt:** `/home/fb31/Bayesian-Quantile-Trend-Filtering/ops/ledger/receipts/legacy-quant-reg-20261122.json`. Its signature was re-verified on 11-24 against `ledger/state/pc_receipt_pubkey.txt`.

## Heavy data (E-01 path)

Finished runs were sealed on NOTS on 11-24 so that the next 19:00 PC pull takes them. They are deleted on NOTS from Owls only after a signed receipt and the 2-day grace period.

| Run | Files | Size | Manifest SHA-256 | Receipt (PC-verified, CT) |
|---|---|---|---|---|
| E05-pmala-fix-20261122 | 5 | 56 KB | `827c28f6…` | `ledger/receipts/E05-pmala-fix-20261122.json`, 11-25 20:29:11 |
| E07-tuningfree-20261123 | 2,862 | 48 MB | `e77f45b0…` | `ledger/receipts/E07-tuningfree-20261123.json`, 11-25 20:57:55 |
| E06-ratevalid-20261122 | 8,457 | 138 MB | `a331891e…` | `ledger/receipts/E06-ratevalid-20261122.json`, 11-25 20:49:47 |
| E02-rates-20261122 | 10,545 | 2.42 GB | `a2e5b0ac…` | `ledger/receipts/E02-rates-20261122.json`, 11-25 20:29:09 |

The E-02 seal outlived the ssh shim's 300 s control-lane limit: the shim killed the connection, but the sealer kept running on NOTS and wrote its manifest at 17:16. The run was checked afterwards: 10,545 manifest lines for 10,545 files, and no file is newer than the manifest. All four receipts arrived in the 11-25 manual re-pull (19:54 CT, one sftp session) and were recorded on Owls at 21:31 CT; each signature verified against the pinned PC key. The 11-23/24/25 scheduled pulls had failed on puller bugs, fixed on 11-25 (sftp output buffering on Windows; see the E-01 changelog). NOTS deletion follows the 2-day grace period.

## After (17:35 CT)

- **Home:** 5.77 of 10 GB. It was 6.5 GB at diagnosis; part of that drop came from T3 pruning its own runtimes.
- **`/projects`:** unchanged until the receipts arrive. About 2.9 GB of BQTF runs are then deleted after the grace period.
