# T07d: plan for a self-contained proof of the mode corollary

**Gate: PASS.** About 1.5 pages in `T07c_proof.tex`, no new lemma, no new tool. Padilla's Theorem 3, Proposition 3 and Lemmas 17–25 are not used.

## Statement to prove (r ≥ 2)
Assumptions A and B, V* ≤ V̄, any c > 0, λ_TV = c n^{1/(2r+1)} (log n)^{1/(2r+1)}. There are C_ρ, T, n₀ depending only on (c, r, L, f, V̄) such that for n ≥ n₀, with probability at least 1 − 256/(f² n ρ_n²), **every** minimizer θ̂ of the PQTF criterion has

‖θ̂ − θ*‖_n² ≤ ρ_n² := C_ρ n^{−2r/(2r+1)} (log n)^{1/(2r+1)}, TV^{(r)}(θ̂ − θ*) ≤ T, ‖θ̂ − θ*‖_∞ ≤ min(1, L),

hence Δ_n²(θ̂ − θ*) ≤ ρ_n². The failure probability is O(n^{−1/(2r+1)}), so "probability ≥ 1 − ε" holds for n ≥ n_ε.

## Steps
1. **Basic inequality along the ray.** The criterion is convex, so for δ̂ = θ̂ − θ* and every s ∈ [0,1]: L̂(sδ̂) + λ_TV TV(sδ̂) ≤ 2 λ_TV V*. (New, three lines.)
2. **Set and event.** K = K(ρ_n, T) as in Section 7. Lemma 9 (interpolation) gives sup-norm → 0 on K because T is a constant and r ≥ 2. Lemma 8 (width) with J ≍ (T √log n / ρ_n)^{1/r} and Lemma 10 (symmetrization, contraction, Efron–Stein) give G = sup_K |L̂ − 𝓛| ≤ (f/8) n ρ_n² with probability ≥ 1 − 256/(f² n ρ_n²).
3. **Ray argument (as in Prop. 2).** If δ̂ ∉ K, scale it to the boundary of K. On the face ‖δ‖_n = ρ_n, Lemma 2(d) gives L̂ ≥ (3f/8) n ρ_n² > 2 λ_TV V̄: contradiction when C_ρ > 16 c V̄/(3f). On the face TV = T, L̂ ≥ −G and λ_TV (T − 2V̄) = (f/4) n ρ_n² > G: contradiction.
4. **Constants.** T = 2V̄ + f C_ρ/(4c); C_ρ = max of three explicit terms, of order c V̄ + V̄^{2/(2r+1)} + c^{−2/(2r−1)}.

## Reused / new
- Reused as is: Lemma 2(a),(b),(d); Lemma 8; Lemma 9; Lemma 10; the ray device of Prop. 2.
- New: only Step 1 and the bookkeeping of constants.

## Differences from the accepted corollary (for the Theory head to rule on)
- **r ≥ 2 only.** At r = 1 the sup-norm on K is bounded but does not vanish, so the proof needs the global margin and a Δ-defined set; a sketch is given as a remark, not a proof.
- **Log power:** (log n)^{1/(2r+1)}, the same as Padilla's. It comes from the union bound in Lemma 8.
- **No threshold c_{1,ε}:** any c > 0 works; ε enters only through n ≥ n_ε.
- Constants do not depend on f̄ or τ; B is used only for F(θ*_i) = τ.
