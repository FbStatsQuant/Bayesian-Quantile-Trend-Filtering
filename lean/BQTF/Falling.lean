import BQTF.Basic

/-!
# Falling factorials (appendix, eq. `pf:eq:pascal`)

Owner: Neon-A. Pascal's rule for `b_p(t) = C(t,p) 1{t ≥ 0}` and its iterate, the fact behind
`D S = I` in Lemma `pf:lem:coord`(a).
-/

namespace BQTF

/-- Paper eq. `pf:eq:pascal`, first part: `b_p(t+1) − b_p(t) = b_{p−1}(t)` for `p ≥ 1`. -/
theorem bfun_pascal (p : ℕ) (hp : 1 ≤ p) (t : ℤ) :
    bfun p (t + 1) - bfun p t = bfun (p - 1) t := by
  sorry

/-- Paper eq. `pf:eq:pascal`, second part: `b_0(t+1) − b_0(t) = 1(t = −1)`. -/
theorem bfun_zero_pascal (t : ℤ) :
    bfun 0 (t + 1) - bfun 0 t = if t = -1 then 1 else 0 := by
  sorry

end BQTF
