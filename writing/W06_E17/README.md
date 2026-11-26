# W-06: E-17 paper update, NOT ADOPTED (archived)

**Closed 2026-11-26 (Felipe via HQ): the paper keeps the current b0. This patch was NOT applied and must not be applied.** It is kept only as a record.

## History

HQ (2026-11-25): the whole E-17 update is on hold until Felipe decides whether b0 = 1e-5 goes into the paper at all. The update covers the tables, the b0 = 1e-5 text and the VS factor. At b0 = 1e-5, S coverage falls to 0.52 against a nominal 0.95.

`E17_paper_NOT_ADOPTED.patch` is the full prepared edit. It applies with `git apply` on top of 30625fd. It contains:
- the six interior tables from engineering/E17_b0_1e5/out/interior/out (738c4b5), with only the PMALA rows changed;
- Section 4.1: b0 = 1e-5 for both signals; the VS factor 1.22 → 1.37, with a sentence on the mixed-normal cells at τ = 0.25–0.75 (+7–37%), and 1.21 for the other cells; S at 1.2–1.6× ADMM, and 34–49% / 20–50% below the better Onizuka sampler;
- App C: b0 = 1e-5 in the "Rate of the Gamma prior" paragraph;
- abstract, introduction and conclusions: 1.22 → 1.37.

Not yet in the patch: the App C run diagnostics for the interior runs (acceptance range, wall time, ESS). I asked Engineering for the E-17 values. One E-17 fit has acceptance 0.388.

The working tree was restored to HEAD so that Lean/Theory packet commits, which include main.pdf, cannot pick up these uncommitted edits.
