# Astra-1 feedback on T07c (draft of 2026-11-24, 863 lines)

Restored by the Theory head from Astra-1's thread. Astra-1's file write went through `owls_run ... tee` with a heredoc, and the file came out empty. Content as Astra-1 wrote it, with the shell quoting removed.

Verdict: the log-free upper bound, its explicit constants and the lower bound at λ = c n^{r−1/2} all survive. One boundary case needs an explicit branch in Prop 1.

## Findings requiring changes

1. **GAP, lines 390–402 (Prop 1).** The hypothesis allows V̄ = 0, e.g. θ*_i = i with Gaussian errors, where D^{(r)}θ* = 0 for r ≥ 2. The bandwidth at line 400 then divides by zero. Fix: set u° = 0 in that case. The approximation error and the shift cost both vanish, and Lemma 4 at ε_n/2 gives exactly the first summand of C_pr.
2. **ERROR (wording), line 412 (Remark on balance).** "The three terms are of the same order" is too strong. For a polynomial truth the approximation and shift terms are identically zero; what is proved is a uniform upper bound of that order. The log-improvement sentence must also say which bandwidth it refers to.
3. **ERROR (wording), line 568 (Remark r = 2).** At r = 2 the width bound has slack. A loss of n^γ in the width gives ρ²T_n ≍ n^{−1/10+8γ/5}, which still tends to 0 for γ < 1/16. Only a loss of at least n^{1/16} breaks localization. The proposition itself is valid.
4. **IMPRECISION, lines 341–351 (Lemma 5).** The secant quotient is written at a = 0, and the integration cutoff divides by δ_A, which may be 0. Fix: use the undivided concavity inequality, and integrate over |t| ≤ 1/λ, where |t|δ_A ≤ ϱ/2 always holds. The stated constant follows.
5. **IMPRECISION, line 593.** Saying all ordered off-diagonal terms are uncorrelated is wrong, because (i,k) and (k,i) coincide. Group unordered pairs first. The factor 2 on line 595 already does this.
6. **IMPRECISION, lines 661 and 817.** Prop 3 bounds the truncated expectation E[N(E_a) 1_{Ω_ψ}], not the realized numerator pathwise. I₂ stays random until Jensen is applied. Reword "realized numerator" in Remark 6 and in the status table.

## Checked OK (summary)

1. Lemma 4: Eckart–Young with rank J′, μ_q ≤ 8·6^{2r−1}c_F²n^{2r−1}λ^{−2}q^{−2r}, head/tail, C_sb. Padding with zero eigenvalues handles K > m.
2. Lemma 11: the ℓ₂ part via Σ s_i(W)⁴ ≤ ‖W‖²_op‖W‖²_F; (4r/3)h/m ≤ 8r/(3J).
3. Lemma 3: interior interpolation, boundary cases, and a Schur test on the residual matrix (column sums ≤ r c_∞ h^r, row sums ≤ 3r c_∞ h^r).
4. Lemma 5: the quadratic charge and neighbour compensation.
5. Prop 1 and Lemma 7, for V̄ > 0.
6. Prop 2: the exponents and the Gamma tilt.
7. Prop 3: the coarse, fine and truth terms; no independence between the score event and the remainder is used.
8. The assembly.
9. Lemma 12: the log-concave variance bound.
10. Lemma 13: the last block fits (b(r+1)ℓ − r ≤ m); the p₀ bound.
11. Prop 4: Anderson's inequality and the choice of c₀.
12. Lemma 10:
    - van der Vaart–Wellner Lemma 2.3.6 (right-hand side, arbitrary μ_i): factor 2. Checked in the 2nd edition; the 1996 printing was not inspected.
    - Ledoux–Talagrand Thm 4.12 (½ inside the test function): factor 2.
    - The Efron–Stein positive-part form is correct.
