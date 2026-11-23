# Independent referee report on L10-I at 85317e1

**L10-I verdict — ACCEPT WITH FIXES.** Both advertised constants are valid. The draft needs an analytic upper bound for the discrete Christoffel constant.

**Huber corollary verdict — ACCEPT for the explicit statement (lines 19–21).** The proof also establishes the fixed-radius consequence on line 23 when its implicit constant is sufficiently small. Stage 2 follows under the proposed Stage 1 bounds.

Line references below refer to `theory/T05_Proofs/L10I_interpolation.md` at the reviewed commit.

1. **CONFIRMED — The exact Christoffel supremum is 9 (lines 11–13, 27–30, 77).** Line 29 proves finiteness. The value 8.9964 on line 77 is a finite-window value, so substituting it for the supremum leaves a gap. To fix this, center the nodes at zero, writing \(t=j-(w-1)/2\) for \(0\le j<w\), and let \(E\) denote their uniform average. The polynomials \(1,t,t^2-m\) are orthogonal, with \(m=Et^2=(w^2-1)/12\) and \(v=E(t^2-m)^2=(w^2-1)(w^2-4)/180\) by summing powers. In this basis the Christoffel function is
   \[
   F(t^2)=1+t^2/m+(t^2-m)^2/v.
   \]
   It is convex in \(t^2\), so its maximum is bounded by its larger value at 0 and \(b=(w-1)^2/4\). We have \(F(0)=1+5(w^2-1)/(4(w^2-4))\le3\) for \(w\ge3\), while
   \[
   F(b)=1+3\frac{w-1}{w+1}+5\frac{(w-1)(w-2)}{(w+1)(w+2)}.
   \]
   The last expression equals 3 at \(w=3\) and increases to 9. A window endpoint realizes it, so it equals \(C_{\rm eq}(w)\) even for even widths. Thus \(C=9\), \(2\sqrt C=6\), and \(K_1=(54\sqrt6)^{2/5}=7.056474\ldots<7.06\).

2. **CONFIRMED — Scaling, Taylor remainder and boundaries (lines 9, 32–46).** The empirical normalization is \(na^2=\sum_i\delta_i^2\) and \(T=n^2\sum_{j=1}^{n-3}|\Delta^3\delta_j|\), as in the statement draft. The Newton remainder vanishes at the first three window nodes and has third forward difference \(\Delta^3\delta\) thereafter in the sense that \(\Delta^3r_j=\Delta^3\delta_j\) for each stencil inside the window. This verifies the identity by recurrence. Its last index \(j=k-3\) ensures every stencil ends inside the window. For literal indexing in line 38, sum only over \(k_0\le j\le k_0+w-4\) (empty for \(w=3\)). Bounding each kernel by \(w^2/2\) gives the stated remainder. Any maximizing node belongs to a full contiguous window of every allowed width, including at either grid endpoint. At line 42, \((1+\sqrt C)\rho_w\le s/2\) follows from \(C\ge1\), giving the displayed mass bound.

3. **CONFIRMED — All window regimes yield the stated exponents (lines 48–58).** Take \(s=0\) as trivial and handle \(T=0\) before dividing by it. Then the full-window remainder vanishes, so \(s\le\sqrt C\,a\). For positive \(s,T\), the full window works when \(w_*\ge n\). For \(3\le w_*<n\), rounding down retains at least \(2w_*/3\), giving \(s^{5/2}\le6C(2\sqrt C)^{1/2}a^2 T^{1/2}\). For \(w_*<3\), the coordinate bound \(s\le\sqrt n\,a\) and \(s<18\sqrt C\,T/n^2\) give line 56. Both powers of \(n\) cancel. The argument applies to the whole vector, including its quadratic component.

4. **CONFIRMED — Huber bootstrap and fixed-radius constants (lines 19–23, 60–66).** For \(s>1\), coordinatewise comparison gives \(a^2\le s\Delta_n^2\). The two alternatives on lines 63–64 then each contradict \(s>1\) under the explicit hypotheses. Once \(s\le1\), the loss is exactly \(a^2\), yielding line 21. For line 23, say “with a sufficiently small universal constant.” For example, require \(\eta\le\Delta^2/(64C)\) and \(\eta^2 T_0\le(\Delta/(4K_1))^5\). For \(0<\Delta\le1\) these imply both strict bootstrap hypotheses and give \(s\le\Delta/2\). This formulation also covers \(T_0=0\).

5. **CONFIRMED — Stage 2 closes with the stated exponent slack (lines 68–73).** On the joint Stage 1 event, \(\eta\lesssim\lambda^{-2/7}\) and \(\eta^2T_0\lesssim n^3\lambda^{-11/7}\). Both tend to zero if \(\lambda/n^{21/11}\to\infty\), so the explicit bootstrap applies and gives
   \[
   \|\delta\|_\infty\lesssim\lambda^{-1/7}+(n^3\lambda^{-11/7})^{1/5}=o(1).
   \]
   Use the diverging-ratio condition on line 73. A fixed multiple above the threshold alone does not give this limit from these bounds. The requested \(\lambda\ge n^{21/11+\epsilon}\) for fixed \(\epsilon>0\), including the project's lower endpoint \(n^2\), suffices. The posterior conclusion is conditional on Stage 1 supplying the joint event with posterior probability tending to one.
