# H-RW · Whole-history publication rewrite

Engineering design for HQ, 2026-11-26. The publication window stays closed until HQ accepts the privacy and verification results. The rehearsal used disposable, no-hardlink mirrors under `/tmp` with their remotes removed. The production pass follows E-03’s archive receipts, path and blob removal, commit map, smoke tests, and coordinated cutover. It adds path-aware replacement and a fresh-mirror verification pass.

## 1. Rules

[replace-text.txt](replace-text.txt) is the exact ordered `--replace-text` input. The regexes use character classes and escaping for personal values. Use the file as supplied, since substitutions can expose a second match, such as a project suffix after the home path is replaced.

| Rule lines | Match and replacement |
| --- | --- |
| 1–4 | Owner login in the known allocation path, home path, tilde home, or a non-university host address. Use `<PROJECTS>`, `<HOME>`, or `<USER_AT_HOST>`. The author address is excluded by an explicit host boundary. |
| 5–8 | Cluster project tree and allocation paths, Windows user profile in slash/backslash and escaped forms, and shared allocation path. Use `<PROJECTS>`, `<WINHOME>`, or `<ALLOC>`. |
| 9–13 | Numeric Slurm identity fields, allocation tokens, and named account/partition/QOS fields. The numeric user-field rule changes the UID alone. |
| 14–18 | Cluster DNS names and observed short node names, the Linux runner hostname, non-email institution DNS names, and the two observed login-node IPv4 addresses. |

**HQ ruling, 2026-11-26.** Preserve the two recorded author/committer identities, their dates, and all commit messages including Co-Authored-By trailers. Use neither a mailmap nor identity callbacks. The owner’s university address is public on the paper title page. The other title-page addresses also stay. Preserve historical email bytes and confirm whether each citation-file version contains the address. Regenerated commits and annotated tags can lose old Git signatures, which cover old object IDs. Re-sign a release tag after the cutover if required.

Bare login tokens are **audit-only**. The four login substitution contexts are the home path, tilde home, allocation path and a non-university host address. Check residual login uses such as Slurm fields and scratch paths individually. A bare login in a retained record remains visible. Approved path exemptions and any proposed revision to HQ’s context rule require explicit sign-off.

Third-party article addresses leave with the articles. The scanner counts credential markers without emitting matched content. Record scan limitations. Inspect private path and ref names, commit/tag messages, PDFs and their links and metadata, nested archive names and members, and remaining binary formats before release. The trial preserves commit messages and applies the path rules to Git tree entries. If a ref name or message exposes an in-scope value, bring that exact case to HQ. Publish only the branches and tags on the freeze allowlist.

## 2. Remove across all history

[remove-paths.txt](remove-paths.txt) is the exact ordered `--paths-from-file` input used with `--invert-paths`. Paths are repo-relative. E-03 used historical aliases because Git path filtering does not follow renames.

| Scope | Treatment |
| --- | --- |
| Raw SPod `S08_*.csv` under `applications/Air Quality/` and `Data Applications/Air Quality/` | Purge seven CSVs after checking the PC and runner copies. See §7 for the replacement. |
| Munich `Others/results*/**/*.rds` and direct children under `applications/Munich Rent/`, `Data Applications/Munich Rent/`, and `archive/munich_rent/code/` | Archive the draws and verify the E-01 receipt. Purge RDS files at all aliases, including the move in `0aa2bac`. Keep small plot and diagnostic material. |
| `{Project_Paper/notes,paper/history}/simulation_revision_20260914/{Brantley_2020,Onizuka_2023}.txt` | Purge both exact historical locations of each publisher text. Already absent at current main after `e24bbd9`. |
| `{Papers,literature}/**/*.pdf` | Purge the 17 identified third-party titles. Keep citations and verified links in the reading list. Preserve `literature/Large Prior.pdf` and its old `Papers/` alias. The owner handles that PDF separately. |
| Monitor JSONL, tracked bytecode, and dated manuscript build/before PDFs | Purge the aliases in the rules. Verify the E-01 receipt for the monitor log. The latter PDFs are regenerable snapshots. Preserve the paper entry point and its assets. |

[BLOB_INVENTORY.tsv](BLOB_INVENTORY.tsv) gives a byte count and recommendation for every observed path/blob pair at or above 1 MiB, every PDF identified by its magic bytes, and the two publisher text names. Moved paths and multiple versions have separate rows. Treat the remaining PDFs as first-party candidates subject to provenance review. Check the Dutch growth, Munich and benchmark inputs for documented redistribution terms, and verify the origin and license of the Onizuka `BQTF-function.R` copies before inclusion. Bibliography entries and original technical reports can stay. Review copied text extracts and small vendored code separately from the size test.

E-03’s `migration/strip_blobs.txt` identifies 12 earlier large versions of files whose paths survive. The 12 object IDs were still reachable at the rehearsal baseline. Review the exact aliases and manifest dependencies, then use the optional strip-file argument only for IDs HQ approves. Keep the latest first-party paper PDF. Review old versions at `paper/main.pdf` by blob ID if HQ wants a smaller clone, since the path is also used by the current manuscript. Test duplicate content under alternate paths as well as the named removal patterns.

## 3. Preserve and verify sealed bytes

Use the installed `git-filter-repo` build `a40bce548d2c` with [file-info.py](file-info.py). In that build, supplying `--file-info-callback` disables the automatic blob-wide replacement. The callback gets the filename and original blob ID. It returns the original ID at protected paths and explicitly calls `value.apply_replace_text` for other text files. The protection test precedes caching, so a rewrite at one path cannot contaminate a protected alias. Binary formats are reported and handled by approved removal or tool-specific review. Raw regex writes to PDFs, archives, and RDS files can corrupt them.

The protection list is a NUL-delimited inventory derived from all historical trees. It covers the three sealed directories in `.gitattributes` and observed E-03 aliases, Lean sources and build inputs, manifest files themselves, and files named by historical manifests. Both path resolution and matching recorded SHA-256 against **all reachable blobs** contribute to protection. In particular, relocated archives keep path-based coverage, and copies with matching content contribute protection for the entire path history. This union is conservative when a basename resolves at multiple package roots. For example, historical `README.md` paths can resolve to both package and root candidates. Confirm the manifest’s original root before deciding whether a candidate can be scrubbed normally. Keep the raw inputs and results of the audit offline. The SHA-256 coverage includes `*SHA256SUMS*` and `*.sha256`, including the E-09 PC archive inventory. Review other provenance formats such as `source_snapshot_sha256.json` before freeze.

[EXEMPTIONS.tsv](EXEMPTIONS.tsv) lists the affected protected path/version entries, rule numbers and protection evidence. A listed match represents a residual exposure until HQ decides. Each row gives the recommended treatment. For a re-seal, keep original bytes and the original manifest in a private archive. Record its SHA-256, who approved the change, and the date and reason for the public derivative. Rewrite each approved historical variant with its own matching manifest and record the original-to-sanitized digests. Avoid blessing pre-existing checksum differences. Historical deletion of a named dependency also requires an explicit archive-and-provenance decision.

| Case | Proposed treatment |
| --- | --- |
| `experiments/joint_upper_levels/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/summary/SHA256SUMS` | Re-seal the six path entries as relative to the summary directory. The original exposes the home path and campaign tree. Verify all six original target hashes using a read-only path mapping first. |
| Absolute air-simulation output manifest | Apply the same path-only re-seal after verifying its five original hashes. |
| Active frozen package scripts, deployment and Slurm records, and the E-09 archive manifest | Recommend private originals and re-sealed public derivatives for rows containing personal paths, hostnames, allocations, or identifiers. Keep any byte-exact exception only after HQ accepts the listed residual exposure. |
| `lean/SHA256SUMS.txt` | Preserve all 58 sources byte for byte. Treat unlisted Lean planning notes and logs as ordinary text, except where another manifest independently protects a copy. |
| Munich manifests | Verify found inputs and output tables against the original values. Document the original layout and absent `run.log`. Keep the archived manifest content, or re-seal the public pointer if HQ changes what is kept. |

## 4. Rehearsal results

The input mirror pinned `main` at `18971d934d63d60200fbae60e2601aab551a6d77`, plus all refs captured by the mirror and the remote-tracking tip. The 2,025 scratch refs included 1,994 private T3 checkpoint refs. Other work continued after the mirror was captured. The trial applied the path rules without the optional E-03 blob-ID strip file or HQ re-sealing.

| Check | Result |
| --- | --- |
| Git footprint | 247,684,502 → 96,293,695 bytes (236.2 → 91.8 MiB, down 61.1%). Pack size 241,548 → 93,706 KiB. The after value is from a fresh mirror of the rewritten result. |
| Commits and refs | 2,587 commits before and after. The TSV has 2,587 mappings, 2,584 changed, 3 carried through, and 0 pruned. The final mirror passed `git fsck --full --no-reflogs`. |
| Removal and protected paths | Removed all 183 matched historical paths. All selected blob IDs were unreachable, including 7 SPod, 33 Munich draws, 2 publisher texts and 17 literature PDFs. All 506,005 retained protected tree/path comparisons agreed exactly. The owner PDF’s blob ID was identical. |
| Raw all-blob pattern scan | 3,024 → 2,949 blobs. 6,172 → 388 regex occurrences across distinct blobs, with all 388 in 100 protected blobs. Zero raw matches in unprotected retained blobs and zero matching historical filenames. Zero matched credential markers. |
| Decoded scan | 6,890 further occurrences in members of three protected gzip tar blobs. These require HQ review even though their outer bytes passed the raw scan. No retained PDF text, metadata, or extracted link matched a purge expression. Five historical PDF versions could not be decoded. Four were versions of `paper/main.pdf` and one was `writing/W02_Theorems/theorems.pdf`. Review their exact blob IDs and remove or replace the broken versions before sign-off. |
| Commit metadata and emails | All 2,587 author/committer and message comparisons matched exactly, including trailers. The owner’s public address matched byte for byte across 1,183 occurrences in 1,037 `paper/main.tex` and 146 historical `Project_Paper/main.tex` tree/path comparisons. All 1,029 `CITATION.cff` comparisons confirmed the address is absent, including at HEAD. The three title-page email lines remained present at HEAD. |
| Remaining login tokens | 350 path/blob rows. Counting historical aliases separately, there are 75 recognized author-address hits, 14,365 other hits in sealed/manifest-covered paths and container contents, and 140 other hits outside the replacement contexts. [LOGIN_REMAINING.tsv](LOGIN_REMAINING.tsv) classifies them. The private offset report gives individual matches. |
| Commit message residue | 17 purge-pattern hits across 11 preserved messages. HQ needs to clear those disclosures or approve a narrowly scoped message edit that keeps identities and trailers. |
| Manifests | 19 manifest files, 233 verified entries, zero mismatches and 4,789 unavailable archived entries, identical before and after. The missing entries are the Munich `run.log` (1), four archived comparison scripts (4), and E-09 PC archive entries (4,784). The VS_upper6 manifest passed 6/6 and the air-simulation manifest passed 5/5 when resolved relative to the matching local run directories. |
| Lean | 58/58 SHA-256 entries passed in the rewritten HEAD export. The `lake build` and `AxiomCheck.lean` builds were deferred to production verification. |
| Paper | `latexmk -pdf -g -interaction=nonstopmode -halt-on-error main.tex` passed in the rewritten export. The rebuilt `main.pdf` has 53 pages. |

The scratch mirror suite and private reports are at `/tmp/bqtf-h-rw.VdbUaVw2/` (owner access only). `after/findings.tsv` identifies matches by path, blob, decoder and rule. `after/login-locations.tsv` gives every counted hit’s byte offset in the raw or extracted view. Join to `after/login.tsv` for paths and classifications. `hash_map.tsv` is the E-03 style old-to-new map. The checked-in tables use per-path version numbers instead of old Git object IDs. Exact locations, including the preserved message findings and the malformed PDF IDs, stay in the private reports.

To repeat from an agreed snapshot, run `engineering/H_RW/dry-run.sh "$PWD" /tmp/bqtf-h-rw-rehearsal` with a new scratch name. An optional third argument supplies reviewed Git blob IDs to strip. The script only rewrites the new remote-free mirror. It uses Python, Poppler utilities and the installed filter-repo build. The hook passed a staged-content, purged-path, size-limit and staged-allowlist smoke test in a disposable repo.

## 5. Freeze and cutover

1. **HQ announces the freeze.** Set the window and publish-branch allowlist. Confirm E-01 PC archive receipts and verified restore paths for the SPod, Munich and monitor data. Preserve any private literature copies before removing them from Git. Record server branch/tag tips and fetchable PR refs. Preserve a private pre-cutover mirror for rollback. Record which public-facing release assets, wikis, job artifacts and issue or PR discussions were reviewed. HQ keeps the repo private if a release gate fails.
2. **Departments commit and stop writing.** Ask each owner to report its branch tip and untracked work that must survive. Stop agents that write, including checkpointing agents, before capturing the final refs. Running NOTS jobs that never commit can continue against their existing run directories. Schedule the NOTS/Owl&#115; filesystem swap after any jobs that require the old checkout or E-01 ledger finish, or preserve their live path and cut over a separate checkout first.
3. **Engineering runs and verifies.** Use a server mirror for advertised branches/tags/PR refs and a pre-freeze local mirror for local-only refs; import missing commits as scratch-only refs before running the filter. Capture all source ref tips before removing origin, including remote-tracking refs, because remote removal can drop those aliases. Compare the input ref and reachable commit census against the frozen inventory. Run [dry-run.sh](dry-run.sh) on the frozen source and use the procedure below for the production candidate. Export the E-03 style `hash_map.tsv` with `old<TAB>new` from `filter-repo/commit-map`. Keep the map and first-changed IDs in HQ’s private handoff. Commit a map on the rewritten branch only if HQ explicitly approves disclosing the old IDs and each retained pointer; otherwise update any public README reference to the map. Rerun verification after any post-rewrite commit.
4. **HQ updates GitHub.** Check remote tips against the freeze snapshot. Force-update approved branches/tags and delete approved stale server refs with explicit refspecs and expected-old leases for branch updates. Keep internal branches, checkpoint refs, scratch remote-tip refs and recovery refs private. Coordinate branch protections and restore them as soon as verification of the new remote refs succeeds. HQ alone performs this operation.
5. **Re-sync every clone and worktree.** Prefer a clean clone and reattach only reviewed patches to new tips from the map. For an in-place recovery, follow the E-03 checklist after preserving local changes, fetch new refs, reset the agreed branches to their new tips, and clean up old tags, backup refs and reflogs after sign-off. Verify each checkout points to a new commit and any carried patches pass the scan. Stop if an old-history merge would revive removed objects.
6. **Retire stale state.** Recreate active agent worktrees from rewritten tips. Remove stale worktrees, branches, tags, agent checkpoints and old clones after the recovery window and HQ agreement. Keep only the agreed private recovery archive. HQ confirms server refs, fork cleanup and any Support action before lifting the freeze and making the repo public.

### Worktrees and clone inventory

The current project had nine worktrees at inspection. The project checkout was on `main`. Linked worktrees were under `$HOME/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/`, as returned by `git worktree list`.

| Directory basename | Branch |
| --- | --- |
| `Bayesian-Quantile-Trend-Filtering` | `main` |
| `t3-2fb7a876-f88e88f7d6310cd5` | `t3/w08-independent-recheck` |
| `t3-358c100d-f93a06a259855aa7` | `t3/paper-appendix-reaudit` |
| `t3-3f80a225-baeac462d53c1a23` | `t3/review-w08-proposal` |
| `t3-78b08b74-b5945b81dfc4bf25` | `t3/rewrite-appendix-d-e` |
| `t3-90cd5233-8cd17d8f9175b09d` | `t3/audit-warmup-claims` |
| `t3-c160b4ec-3a4c9df3fa5a1a82` | `t3/confirm-w08-revision` |
| `t3-f6098f88-e31dc35cc235f122` | `t3/rewrite-pmala-appendix` |
| `w07-integration` | `w07-integration` |

Other local branches from `git branch -a`: `backup/sol-w1-assembly-before-rebase` and the following branches under `t3/`.

```text
efron-stein-inequality          efron-stein-inequality-1
formalize-lean-proofs           general-scale-supnorm
joint-theorem-final-assembly    joint-transfer-bound
lean-formalization-polish
prove-checkloss-score-lemmas    prove-contraction-principle
prove-eckart-young-bound        prove-main-theorem
prove-prekopa-laplace           prove-reduction-prior-mass
sol-w1-assembly                 sol-w2-shift-width
theorem-two-skeleton            thm2-integration
thm2-neonC-j6                   thm2-solP1-j5
thm2-solP2-j7
```

Remote-tracking branches were `origin/main` and the `origin/HEAD` alias. Refresh both inventory commands at freeze. The NOTS operator re-syncs `~/BQTF/repo` on NOTS and confirms the live path before the swap. The Owl&#115; operator re-syncs `~/Bayesian-Quantile-Trend-Filtering`. Preserve `ops/`, `runs/`, `tmp/`, the E-01 ledger and untracked raw SPod files in their expected locations. Verify the PC archive and re-sync the PC clone without disturbing archived run folders. Coordinate with E-18 and test the pinned file from the actual runner work directory. This plan requires no remote login during rehearsal.

### Verification checklist

- [ ] Record before/after mirror byte size and pack size, ref counts and commit counts. Validate the private commit map, inspect Git’s report of first changed commits, and run `git fsck --full` on a fresh mirror of the candidate.
- [ ] Compare protected tree entries using the commit map and audit all historical content via `git rev-list --all --objects` and `git cat-file`. Confirm prohibited paths and the corresponding blob IDs are unreachable through aliases. Inspect container and filename findings and clear all unexpected matches. Compare old and new author/committer lines and commit messages. Confirm byte equality of the public address in `paper/main.tex` and all historical versions, including the pre-move alias, and preserve `CITATION.cff` address bytes or their absence. Classify every remaining login hit.
- [ ] Verify every checksum at the proposed HEAD from the proper checkout/run root. Run `sha256sum --strict -c` for local manifests and compare pre/post using `audit.py checksums`. Use explicit suffix relocation for VS_upper6 and the air-simulation attempt. Use the mapped Munich inputs and tables and record the missing `run.log`. Check archive-only manifests on their own restored original trees. Resolve all new mismatches before publication. The E-09 manifest requires its PC archive. The archived VS comparison source list also names four `postprocess/` files absent from the checkout. Obtain them from the original run/code archive or document the exception.
- [ ] In an isolated checkout at the verified tip run `sha256sum --strict -c SHA256SUMS.txt` from `lean/`. Run `lake build` and `lake env lean AxiomCheck.lean` from `lean/` through `~/.config/bvs-hq/owl[s]/owls_run -j 2 --` or its `-j 3` setting. The Lean commands are documented in `lean/README.md`. Check the reported axioms. In `paper/` force a fresh `latexmk -pdf -g -interaction=nonstopmode -halt-on-error main.tex` and inspect the rebuilt PDF. Smoke-test live sampler, archive scripts required for reproduction, and the E-18 public CSV loader and internal raw-file entry point. Retire or port executable hard-coded defaults to environment variables or paths relative to the checkout before production. Angle-bracket placeholders in historical scripts reproduce a record of the old code and can require operator inputs to run.
- [ ] Rerun the scans after any production re-sealing, binary rebuild, or data handoff commit. Fetch a fresh mirror from the rewritten GitHub repository, inventory what the host advertises, and compare its publish refs to the signed-off candidate. Check remote PR refs and cached SHAs as described below.

## 6. GitHub residue and guardrails

A branch update does not remove old GitHub objects. Anyone with a retained old SHA may still be able to open it. Forks, PR refs and cached views can keep old commits accessible. HQ should file a sensitive-data Support request when old infrastructure and personal identifiers remain accessible on GitHub after the rewrite. Provide owner/repo, first changed commit IDs, count of affected PR refs from `filter-repo/changed-refs`, and orphaned LFS object information if the tool reports it. Request dereferencing affected PRs, clearing cached commit and diff views, server garbage collection, and removal of orphaned LFS objects where applicable. Check forks and coordinate with their owners first. GitHub limits assistance to qualifying sensitive data. Oversized files and copyright cleanup alone do not establish eligibility. If residual private content cannot be purged on the existing repository, HQ should keep it private and consider a new public repository seeded from the verified candidate, outside the old fork network. [GitHub’s sensitive-data removal procedure](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

[pre-commit](pre-commit) extends the current `.githooks/pre-commit` policy and is ready for HQ to review in place. It reads staged blobs and staged allowlist content, applies the existing 5 MiB threshold and checks staged paths, context-specific replacement patterns and credential markers. The size allowlist is currently empty. Approve a size exception only for the named path, and review references to sealed exceptions by exact path and blob ID before permitting a new version. For deployment, use a thin `.githooks/pre-commit` wrapper invoking the H-RW script in the checkout. The hook requires Python 3.9 or newer. Mirror the same policy in required CI over **every incoming commit**, checking blobs added by intermediate commits as well as the final tree diff. CI should also extract PDF/archive content and run seal checks. Keep exception policy changes under HQ review.

## 7. SPod replacement

HQ’s release dataset is `applications/Air Quality/spod_s08_d_2018-06-15_10s.csv`, with `DATA.md` beside it and the canonical preparation script `engineering/E18_Air_Refit/e18_prepare_spod.R`. Keep the script’s `e18_common.R` dependency. Add an explicit RDS-to-CSV output step, or an optional CSV output from preparation, with these columns in this order.

| Column | Definition |
| --- | --- |
| `offset_seconds` | 0 through 86,390 in 10-second steps after the source clock’s June 15 midnight. |
| `n_readings` | Count of finite sensor `d` readings in that block. |
| `imputed` | Integer 1 for an empty block filled by linear interpolation, 0 otherwise. |
| `pid_block_mean_counts` | PID counts averaged within the block, with interpolation for empty blocks. |
| `pid_standardized` | The block mean centered and divided by the full series’ sample SD, as used by the fit. |

Use the June 15, 2018, sensor `d` PID column. E-18 commit `35cc297` drops 30 literal `N/A` readings, retains 86,179 numeric readings on that day, and interpolates 19 empty blocks to reach 8,640 rows. It excludes four readings from June 16. Treat timestamps as source clock labels. Emit ASCII comma-separated data with an unquoted header, LF line endings, no row names, and `sprintf("%.17g", x)` for doubles. The rehearsal regenerated the prepared RDS SHA-256 `7034864ae177b222d19d2df68347d1112f5491703fbeb5636adff05a07b76261`. The 373,120-byte CSV round-tripped to the exact numeric vectors and had SHA-256 `45e04964b2ea51b49c244e7b4778652300435cd2dd035a9be0d4cc73793ee2a0`. Record both hashes and the recipe in `DATA.md`. Read the derived CSV by default in public reproduction commands.

E-18 is still running and validates the raw input at `applications/Air Quality/S08_2018-06-15.csv` against SHA-256 `6086e8bdc1260cb90ca9250262aa7fc612a5e6e2d91490b7696f3e44f95cd7c3`. Stage an independent copy on the PC archive and the internal runner before cutover, then keep the runner copy at the same relative path as a Git-ignored file. Add `/applications/Air Quality/S08_*.csv` to the release ignore rules. Verify the seven raw hashes against the archive receipts and rerun preparation from an untracked copy. Replace the outdated `DATA.md` claims about E-18 use and archival status with the verified record. The released data bundle excludes the raw 1-Hz files.

**Provenance finding.** `paper/sections/data_application.tex` and `paper/references.bib` identify EPA Rubbertown and Brantley, Guinness and Chi (2020). The article describes a seven-day pair of colocated SPods. Its listed supplements are algorithm and simulation details and the `detrendr` package. The authors’ code repository provides the implementation. No verified link to the exact June 15 raw CSV or all seven pinned CSVs was found. [Journal article](https://www.ericchi.com/ec_papers/AOAS1318.pdf) · [Package supplement DOI](https://doi.org/10.1214/19-AOAS1318SUPPB) · [Authors’ package](https://github.com/halleybrantley/detrendr)

EPA identifies Site S8 in the NGEM study and publishes a related workbook, including selected aggregate event data from June 19. The similarly named 2022 EPA dataset is a workbook for a different paper. EPA ScienceHub has a public-domain default for EPA-produced data unless specified otherwise, plus a no-warranty notice. The raw files’ exact distribution terms remain unverified. In `DATA.md`, link the study and catalog record, direct requests for the original 1-Hz S08 export to the EPA catalog contact or the article’s corresponding author, and give the pinned SHA for validation. Ask the owner for the original receipt or source correspondence before claiming any direct download or specific data license. [NGEM study](https://www.mdpi.com/1660-4601/16/11/2041) · [EPA NGEM workbook and contact](https://catalog.data.gov/dataset/rubbertown-ngem-demo-project-paper-1-dataset) · [2022 EPA dataset](https://catalog.data.gov/dataset/epa-spod-fenceline-monitoring-rubbertown-dataset) · [EPA licensing and disclaimer](https://pasteur.epa.gov/license/sciencehub-license.html)

## 8. HQ decisions before publication

1. Rule on the protected-file rows and approved re-seal workflow, including the VS and air-simulation absolute manifests, private tar members, and historical versions of sealed files. Approve residual login occurrences outside the four permitted contexts or supply a revised rule for specific cases. Resolve the preserved commit message findings while retaining authorship and trailers.
2. Approve the final removal and retention list after checking receipts and the third-party provenance findings. Decide whether to drop stale first-party PDF versions and the 12 E-03 IDs. Approve any genuinely unavailable archived checksum targets.
3. Confirm raw-source provenance and permission for the derived SPod distribution, and confirm E-18’s runner path is ready before cutover.
4. Approve the branch/tag publish allowlist, freeze and recovery window, private map custody, and GitHub Support criteria or alternate publication venue if server residue remains.
