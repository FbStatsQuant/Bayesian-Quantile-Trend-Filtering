# Paper corrections found by the Lean formalization

This file is kept by the Lean head, under the owner's policy of 2026-11-25. Each entry records a place where the paper's proof or statement had to change for the Lean version to compile: a hypothesis added or weakened, a constant or threshold changed, a statement fixed, a proof step that was wrong or had a gap, or a missing measurability or integrability condition.

Pure formalization artifacts are **not** corrections: coercions, 0-based `Fin` indexing, `ℝ≥0∞` encodings, and stating a bound as a lower bound on a probability instead of an upper bound on −log.

**Who proposes entries.** Provers propose candidates in `notes/logs/*_questions.md`. The head decides what goes in. Any statement change is checked by Theory, and frozen statements are re-audited by Astra.

**When a packet is sent.** A module counts as finalized and checked when all of the following hold:
- it has no `sorry`;
- `#print axioms` shows only `propext`, `Classical.choice` and `Quot.sound` on its main declarations;
- a fresh Sol review has passed, and the head has ruled on every finding;
- it is merged to main with a green build.

At that point the head sends that module's entries to Writing and Theory (CC HQ), with the merge commit hash. When Writing has changed the paper, an independent reviewer checks that the new text matches the Lean statement, and the result goes to HQ.

**Status values:**
- `open`: found, and the Lean piece is not finalized yet;
- `sent`: the packet has gone to Writing and Theory;
- `in paper`: Writing has changed the text;
- `verified`: the paper text has been checked against Lean.

---

## C-01: g_r > 0 is used without proof

- **Paper label:** appendix, the paragraph before Lemma `pf:lem:smooth` (definition of g_r and C_s). It is used in Lemmas `pf:lem:smooth` and `pf:lem:interp`.
- **Current paper text:** "g_r = inf_{w≥r} λ_min(G_w) ∈ (0,1] (a constant depending only on r)". There is no argument that the infimum is positive.
- **Correct version:** the same claim, with a proof:
  - each G_w is positive definite for w ≥ r (root counting);
  - ‖H − G_w‖_F ≤ r/w, where H = ∫₀¹ b bᵀ is the Hilbert matrix (a Riemann-sum comparison);
  - H is positive definite;
  - hence λ_min(G_w) ≥ λ_min(H)/2 for w ≥ 2r/λ_min(H), and only finitely many positive values remain.

  Theory wrote this proof in `theory/T10_gr_positivity/NOTE.md` (commit 0c9f176).
- **Why it was needed:** a proof gap. The constant is used in C_s = 1 + r/g_r and C_0 = r/g_r.
- **Lean:** `BQTF.gr_pos`, in `lean/BQTF/Gram.lean`.
- **Status:** **open**. The Lean head flagged it on 2026-11-25. Theory has sent the proof to Writing for insertion. The packet goes out when `Gram` is finalized, and the paper text is then checked against `gr_pos`.
