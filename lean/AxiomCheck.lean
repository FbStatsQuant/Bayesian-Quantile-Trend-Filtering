import BQTF
open BQTF

/-! Each main result has exactly its `Spec.lean` type and depends only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). Run with `lake env lean AxiomCheck.lean`. -/

/-! Theorem 1 (`thm:main`): posterior contraction at the unit scale, and at a general scale σ₀. -/

example : MainStatement := main_theorem
example : MainStatementScale := main_theorem_scale

#print axioms main_theorem
#print axioms main_theorem_scale

/-! Theorem 2 (`thm:joint`): joint contraction of the non-crossing posterior over a quantile grid. -/

example : JointStatement := joint_theorem
example : JointStatementScale := joint_theorem_scale

#print axioms joint_theorem
#print axioms joint_theorem_scale
