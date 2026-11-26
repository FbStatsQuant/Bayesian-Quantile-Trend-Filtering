# H-RW · Public repository build

The current repository is the private internal record. Its history, files, seals, manifests, and hashes remain intact. HQ is asking the owner to set its GitHub visibility to private. Departments and remote jobs can continue using it. At paper submission, after W-08, E-18 and E-19, Engineering derives a **new** public repository from a named private commit and hands it to the owner.

## 1. Privacy and history rules

[replace-text.txt](replace-text.txt) is the ordered, escaped replacement policy. It covers personal home and project paths, Windows profiles, account and allocation identifiers, DNS names, and login-node IP addresses. The public build applies it to editable text across the selected lineage and replaces other non-authorship login occurrences with `<USER>`. The verification report classifies remaining login occurrences by path, object, and byte offset, including decoded content. Allowed occurrences are the public author address and explicit authorship lines. Review binary and filename findings separately. Binary formats are either preserved, removed by approved ID, or held for review. Raw byte substitution can corrupt structured binary files.

The build preserves the author and committer identities, timestamps, and commit topology. A message callback uses [eleven exact message fingerprints](message-fingerprints.txt) to apply only the approved privacy substitutions outside trailers. One of the eleven messages also contains a scratch-path login token covered by the new bare-login rule. It preserves all other messages, public author email bytes and trailers. Preflight requires all eleven fingerprints exactly once and fails on any remaining message-pattern match or new unapproved match. Independent verification compares the actual commit messages, identities, parent lists, and addresses in `paper/main.tex`, its historical alias, and `CITATION.cff`. Git signatures over private commit IDs do not carry over to newly generated objects.

## 2. Removals in the public lineage

[remove-paths.txt](remove-paths.txt) covers the historic and current aliases for the seven raw SPod CSVs, Munich `Others/results*/` RDS draws, the Brantley and Onizuka publisher texts, the 17 third-party literature PDFs, the monitor log, Python bytecode, and dated manuscript PDFs. Keep the current paper PDF and preserve `literature/Large Prior.pdf` and its old alias for the owner’s separate decision.

The build removes the five unreadable PDF versions by [blob ID](strip-pdfs.txt) (four `paper/main.pdf` versions and one W-02 theorem PDF), plus the twelve E-03 IDs in the selected commit's `engineering/E03_Repo_Organization/migration/strip_blobs.txt`. The five malformed PDF IDs were reachable in the all-ref rehearsal but are absent from the current main lineage. Keep them on the removal list in case the submission commit brings any of them into scope. It checks object reachability after filtering so a duplicate at another path cannot preserve the bytes. All three sealed tar archives leave the published history, including their old path aliases. Each gets a sibling `.PUBLICATION.md` pointer naming the archive and SHA-256 and stating that the original is in the private record. A manifest that originally checks an archive checks the pointer in the public tree.

The internal plan, historical [blob inventory](BLOB_INVENTORY.tsv), [seal findings](EXEMPTIONS.tsv), [login inventory](LOGIN_REMAINING.tsv), and any earlier tracked E-03 commit map belong in the private record. The build excludes them from public history. The pipeline, escaped patterns and hook remain tracked.

## 3. Re-sealing the public copy

[public_build.py](public_build.py) derives a complete public snapshot for each private commit. It resolves checksum entries in the original tree, sanitizes text, follows manifest dependencies in order, and writes each affected manifest using the resulting target bytes and paths relative to the manifest. A complete snapshot also handles merges, changes to a target in a different commit from its manifest, and relocation. It preserves an untouched manifest's bytes when its entries still agree. The filter-repo commit callback imports these prepared snapshots. Preparation and filter-repo operate exclusively on isolated copies.

Each changed sealed or manifested file, including a changed manifest, gets a sibling note in the public snapshot using the approved wording: “paths generalized for publication; the original sealed bytes are kept in the private record, hash <old sha256>”. Old-to-new SHA-256 pairs go to the private handoff. If the old manifest disagrees with its own tree, the report records the discrepancy separately and the public digest verifies the public snapshot. Review these cases before publication. The build preserves the Lean proof payload and verifies all 58 Lean checksums at the selected tip.

| Manifest | Public treatment |
| --- | --- |
| VS_upper6 `summary/SHA256SUMS` | Resolve the six absolute run paths against the matching `summary/` directory. Write six relative entries. |
| Air-simulation attempt `OUTPUT_SHA256SUMS` | Resolve against the matching attempt directory. Write five relative entries. |
| VS_upper6 `metadata/comparison_source_SHA256SUMS` | Verify the four relocated files using the mapping below. Write relative paths from `metadata/`. |
| Munich `SHA256SUMS.inputs` and `SHA256SUMS.outputs` | Resolve the retained data and summary tables. Keep the historical `run.log` checksum as a comment because the log is unavailable. |
| E-09 `quant_reg_archive/MANIFEST.sha256` | Keep the manifest and its archived checksums. Verify available entries and add one line to the adjacent README stating that archived targets are offline in the private record. The previous baseline listed 4,784 offline entries. |
| Historically unavailable or deliberately omitted targets | Preserve the original digest and generalized target in a manifest comment and record the reason in the private report. An unresolved, non-exception target at the release tip stops the build. |

The comparison-source mapping below is relative to `experiments/joint_upper_levels/`. The original hashes match the tracked files at these destinations. Earlier `Simulations/Joint/NOTS/` versions use the analogous mapping when present. The verifier resolves these paths without moving the files.

| Manifest entry | Tracked path |
| --- | --- |
| `postprocess/compare_paper.R` | `compare_paper.R` |
| `postprocess/compare.slurm` | `slurm/compare.slurm` |
| `postprocess/monitor.py` | `monitor.py` |
| `postprocess/start_monitor.sh` | `start_monitor.sh` |

## 4. Previous rehearsal

The earlier, all-ref isolation rehearsal rewrote 2,587 commits and reduced the bare mirror from 236.2 MiB to 91.8 MiB. It preserved the sealed bytes, compared author metadata and public address bytes, built the 53-page paper, and verified all 58 Lean source checksums. It found 388 raw matches in protected content, 6,890 more inside the three archives, 140 other login hits outside the prior policy, and 17 matches across the eleven messages. The current build policy addresses those findings. The old rehearsal used different scope and rules and its scratch directory was deleted. A fresh run at submission supplies the publication verification evidence.

## 5. Public build runbook

0. **Set the public URL.** The owner creates the empty public GitHub repository first (step 5 pushes to it) and gives Engineering its URL. Before pinning, commit in the private repository: set `repository-code` in `CITATION.cff`, and every repository URL in `README.md` and its badges, to the new public URL. Check: `git grep -nF 'FbStatsQuant/Bayesian-Quantile-Trend-Filtering' -- CITATION.cff README.md '*/README.md'` returns nothing. Any remaining hit of the old URL elsewhere must be a historical record (for example under `engineering/E03_Repo_Organization/`). List those hits in the private report.
1. **Pin the inputs.** Once W-08, E-18 and E-19 land, record the full private commit ID and confirm it contains the reviewed paper, data and scripts. That commit fixes the release inputs while internal work continues. Confirm the SPod and other retained private inputs are archived. Run the reviewed version of this kit.
2. **Run the build.** From the private checkout invoke `engineering/H_RW/build.sh <source-commit> /tmp/bqtf-public-submission` with a fresh output path. The script fetches only that commit into an empty bare repo and imports its ancestry as public `main`. It uses filter-repo build `a40bce548d2c` on a remote-free clone, then opens a fresh mirror for verification. The shell leaves no intermediate source clone or prepared trees in the output.
3. **Verify the public candidate.** The automated gates check refs, object integrity, forbidden-blob reachability, original-to-public tree and metadata comparisons, manifests, and all reachable blobs, including PDF text, metadata and links and any remaining supported archive formats. Review the private reports for baseline checksum differences, historical archival exceptions, classifier output and unsupported binary formats. The public checksum audit verifies the VS, air-simulation, comparison-source and Munich mappings. In an isolated worktree of the verified candidate, run the following:
   - From `lean/`, run `sha256sum --strict -c SHA256SUMS.txt`, `lake build`, and `lake env lean AxiomCheck.lean`. Run heavy commands through `~/.config/bvs-hq/owl[s]/owls_run -j 2 --` or its `-j 3` setting.
   - From `paper/`, run `latexmk -pdf -g -interaction=nonstopmode -halt-on-error main.tex` and inspect the PDF.
   - Run the paper's public SPod input path against the pinned derived CSV. Confirm that the E-18 private runner still has the untracked raw copy at its pinned path.
   - Check first-party figure and third-party source provenance and smoke-test any public code whose historical hard-coded paths became placeholders. Resolve findings before handoff.
4. **Prepare the owner handoff.** The output contains `public.git` and `private/`. Record the verification results and sign-off in `private/verification.txt`. Keep that report, `hash_map.tsv`, `resealed_digests.tsv`, and per-match reports private. Hand the owner the verified repository and the private evidence separately. If any public file is edited after verification, rebuild from a new pinned input and reverify.
5. **Owner publishes.** The owner creates an empty GitHub repository and pushes only the verified `main` ref from `public.git`. Use a new repository rather than transferring the private repository or creating a fork from it. This gives the new repository its own history references and PRs. The existing private repository remains the record for worktrees, jobs, and old commits.
6. **Check the published repository.** Fetch a fresh clone of the new public repository, match its main tip and refs to the verified output, check Git object integrity and rerun the publication audit and representative build checks. Confirm the repo contains the derived SPod CSV and DATA.md and that the private repo still has private visibility. In the fresh clone, confirm that `CITATION.cff` `repository-code` equals the published URL and that `git grep -nF 'FbStatsQuant/Bayesian-Quantile-Trend-Filtering' -- CITATION.cff README.md '*/README.md'` returns nothing.

## 6. Guardrails for the public repository

[pre-commit](pre-commit) reads staged paths, blobs, and the staged size allowlist. It rejects forbidden paths, publication-pattern and non-authorship login matches, credential markers, and blobs exceeding 5 MiB without an approved exception. For public use, wire it through a thin `.githooks/pre-commit` wrapper. Require CI to apply the equivalent checks to every incoming commit, including intermediate commits. Add manifest verification and container/format checks to CI. The scripts in this plan update leave the current hook configuration alone.

## 7. SPod release input

Ship `applications/Air Quality/spod_s08_d_2018-06-15_10s.csv` and `DATA.md`, as well as the E-18 preparation script and its common dependency. The build takes the CSV from the pinned tree if it matches the approved digest. Otherwise it stages the pinned June 15 source from private history, runs E-18 preparation and [export_spod.R](export_spod.R), and verifies the two digests. It adds the raw-path ignore rule in the public tree. The private E-18 runner continues using its own raw copy at `applications/Air Quality/S08_2018-06-15.csv`.

The 8,640 rows contain `offset_seconds`, `n_readings`, `imputed`, `pid_block_mean_counts`, and `pid_standardized`. The preparation drops 30 literal `N/A` readings, excludes four readings from June 16, and interpolates 19 empty blocks. The pinned prepared RDS SHA-256 is `7034864ae177b222d19d2df68347d1112f5491703fbeb5636adff05a07b76261`, and the pinned CSV SHA-256 is `45e04964b2ea51b49c244e7b4778652300435cd2dd035a9be0d4cc73793ee2a0`.

**Owner ruling for DATA.md.** Use the [approved template](SPOD_DATA.md). Cite Brantley et al. (2020) in bibliographic form and describe EPA Rubbertown SPod sensor d, June 15, 2018. DATA.md carries no URL or data license claim.

**Private source notes, not for DATA.md.** EPA identifies Site S8 in the NGEM study and catalogs a related workbook with selected event data. The exact raw download and distribution terms were unverified. The catalog contact and study links are for internal provenance follow-up. [NGEM study](https://www.mdpi.com/1660-4601/16/11/2041) · [EPA catalog](https://catalog.data.gov/dataset/rubbertown-ngem-demo-project-paper-1-dataset)
