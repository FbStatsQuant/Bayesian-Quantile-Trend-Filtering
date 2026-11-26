# W-08 confirmation

**FAIL** at `18971d9`. Eight items are resolved and four remain open. References below are to the reviewed tree unless a different commit is named.

| Item | Status | Evidence |
|---|---|---|
| 3 | NOT RESOLVED | `PROPOSAL.md:50–58` requires all five conditions but defines condition 5 as optional for README release. Section 9.4 lists the accepted SPod figure in step 3 and says step 3 is required (`PROPOSAL.md:1019–1021`). Section 9.2 likewise lists the E-18 curve as a deliverable without stating the hero-only release option (`:993,1004`). Use the same conditional rule in each section. |
| 6 | NOT RESOLVED | `PROPOSAL.md:55,198,994,999` now requires F12, a complete joint run with `clarabel` and successful runs for measured times. The ban on a passing claim before F12 remains. Section 9.4 cites the gate but its required Engineering step omits the joint run (`:1020–1021`). State the requirement in that step. |
| 7 | RESOLVED | `PROPOSAL.md:179,203–204` identifies the masked command and link as pending substitutions, counts five linked folders among the six missing guides, and conditions the blanket README statement on the guides existing. |
| 9 | NOT RESOLVED | `PROPOSAL.md:562` correctly lists the six proposal-era files and labels `archive/README.md:8` as provenance for the move from the old path. The pinned literal query at `0fa2992` yields 23 historical and moved files but 22 matching lines in the E-03 inventory, versus the claimed 25. The pinned file:line list is deferred to sign-off. Section 5.1 also leaves the script's actual wrapper instruction at `figures/make_readme_figures.R:14` out of the M2 edits (`PROPOSAL.md:563`). |
| 10 | RESOLVED | `PROPOSAL.md:10,595–610` attributes the retained totals to `19be187` and preserves the scan scope. `drafts/INVENTORY.md:3` names that snapshot, and the tree contains 1,759 tracked files. |
| N1 | NOT RESOLVED | `PROPOSAL.md:536,583` marks both items done. `17b2176` deletes exactly four tracked bytecode caches. `8084f34` restores three sealed files and adds `-text -eol` overrides at `.gitattributes:37–41`. Hashing the tracked blobs against the sealed manifest gives 27/30 in the parent and 30/30 both at the fix and at `18971d9`. Section 9.4 still lists H1 under current work (`PROPOSAL.md:1017`), and the Engineering handoff still assigns H1 and F8 (`:994–995`). |
| N2 | RESOLVED | `PROPOSAL.md:106,1064` gives 302 and 332 under the same heading-inclusive convention and identifies 295 as the earlier heading-exclusive count. |
| N3 | RESOLVED | `figures/README.md:11–16` removes the machine name and retains plain `Rscript` commands. |
| N4 | RESOLVED | `figures/make_readme_figures.R:284–289` returns an empty numeric vector when the first six-hour boundary is above the upper limit, avoiding the invalid positive-step sequence for both curve orderings. Checked by inspection. R was not run. |
| N5 | RESOLVED | `PROPOSAL.md:626,996` explicitly carries the conditional retention rule into the Engineering handoff and specifies a public masked provenance record for sensitive originals. |
| N6 | RESOLVED | `PROPOSAL.md:131–133` identifies the timings as medians and includes `k = 2`, consistent with `paper/sections/scalability.tex:16–23,31,43`. |
| N7 | RESOLVED | `PROPOSAL.md:421` specifies demo mode alone. The independent SPod dispatch at `figures/make_readme_figures.R:312–315` still permits an explicit SPod file with demo mode. |

The E-18 changes introduce a SPod input mismatch. The Writing export selects only REPORT columns (`engineering/E18_Air_Refit/e18_paper_air.R:69–76,145`). If any level is HOLD, the figure hook rejects the resulting CSV because it requires all three quantile columns (`figures/make_readme_figures.R:267–276`). The hero-only option in `PROPOSAL.md:56` can cover that outcome once the order of work states it consistently.

The added and replacement lines contain no email addresses, literal home or cluster paths, login IDs, or host or machine names. The removed line at `figures/README.md:11` contained the machine name flagged by N3.
