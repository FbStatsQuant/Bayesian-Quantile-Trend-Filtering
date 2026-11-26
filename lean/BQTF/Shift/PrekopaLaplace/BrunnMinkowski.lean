import Mathlib

/-!
# One-dimensional weighted Brunn–Minkowski

For nonempty measurable `A, B ⊆ ℝ` and any `C ⊇ (1 − t) A + t B`,
`(1 − t) |A| + t |B| ≤ |C|`. Proof: compact case by splitting `C` at
`(1 − t) max K + t min L`, then inner regularity.
-/

open MeasureTheory Set
open scoped ENNReal

noncomputable section

namespace BQTF.PL

/-- Lebesgue measure of an affine preimage on `ℝ`. -/
lemma ofReal_mul_volume_affine_preimage {a : ℝ} (ha : 0 < a) (c : ℝ) (S : Set ℝ) :
    ENNReal.ofReal a * volume ((fun x => a * x + c) ⁻¹' S) = volume S := by
  have : (fun x => a * x + c) ⁻¹' S = (a * ·) ⁻¹' ((· + c) ⁻¹' S) := rfl
  rw [this, Real.volume_preimage_mul_left ha.ne', measure_preimage_add_right, ← mul_assoc,
    ← ENNReal.ofReal_mul ha.le, abs_of_pos (inv_pos.2 ha), mul_inv_cancel₀ ha.ne',
    ENNReal.ofReal_one, one_mul]

/-- Weighted Brunn–Minkowski for nonempty compact sets. -/
lemma bm_compact {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) {K L C : Set ℝ}
    (hK : IsCompact K) (hL : IsCompact L) (hKn : K.Nonempty) (hLn : L.Nonempty)
    (hC : ∀ x ∈ K, ∀ y ∈ L, (1 - t) * x + t * y ∈ C) :
    ENNReal.ofReal (1 - t) * volume K + ENNReal.ofReal t * volume L ≤ volume C := by
  have h1t : 0 < 1 - t := by linarith
  set M := sSup K with hMdef
  set m := sInf L with hmdef
  have hM : M ∈ K := hK.sSup_mem hKn
  have hm : m ∈ L := hL.sInf_mem hLn
  set p := (1 - t) * M + t * m
  have hK' : K ⊆ (fun x => (1 - t) * x + t * m) ⁻¹' (C ∩ Iic p) := by
    intro x hx
    refine ⟨hC x hx m hm, ?_⟩
    have : x ≤ M := le_csSup hK.bddAbove hx
    show (1 - t) * x + t * m ≤ p
    nlinarith
  have hL' : L \ {m} ⊆ (fun y => t * y + (1 - t) * M) ⁻¹' (C \ Iic p) := by
    intro y hy
    have hyL : y ∈ L := hy.1
    have hne : y ≠ m := hy.2
    have hmy : m ≤ y := csInf_le hL.bddBelow hyL
    have hlt : m < y := lt_of_le_of_ne hmy (Ne.symm hne)
    refine ⟨?_, ?_⟩
    · have := hC M hM y hyL
      simpa [add_comm] using this
    · simp only [mem_Iic, not_le]
      show p < t * y + (1 - t) * M
      nlinarith
  have hLvol : volume (L \ {m}) = volume L := measure_sdiff_null (measure_singleton m)
  calc ENNReal.ofReal (1 - t) * volume K + ENNReal.ofReal t * volume L
      ≤ volume (C ∩ Iic p) + volume (C \ Iic p) := by
        gcongr
        · rw [← ofReal_mul_volume_affine_preimage h1t (t * m) (C ∩ Iic p)]
          gcongr
        · rw [← hLvol, ← ofReal_mul_volume_affine_preimage ht0 ((1 - t) * M) (C \ Iic p)]
          gcongr
    _ = volume C := measure_inter_add_sdiff C measurableSet_Iic

/-- The measure of a measurable set as a supremum over compact subsets, indexed by a subtype. -/
lemma volume_eq_iSup_compact {A : Set ℝ} (hA : MeasurableSet A) :
    volume A = ⨆ K : {K : Set ℝ // K ⊆ A ∧ IsCompact K}, volume K.1 := by
  apply le_antisymm
  · rw [hA.measure_eq_iSup_isCompact]
    exact iSup₂_le fun K hKA => iSup_le fun hK =>
      le_iSup (fun K : {K : Set ℝ // K ⊆ A ∧ IsCompact K} => volume K.1) ⟨K, hKA, hK⟩
  · exact iSup_le fun K => measure_mono K.2.1

instance nonempty_compact_subsets (A : Set ℝ) :
    Nonempty {K : Set ℝ // K ⊆ A ∧ IsCompact K} :=
  ⟨⟨∅, empty_subset _, isCompact_empty⟩⟩

/-- **Weighted Brunn–Minkowski on `ℝ`.** -/
theorem bm_one {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) {A B C : Set ℝ}
    (hA : MeasurableSet A) (hB : MeasurableSet B) (hAn : A.Nonempty) (hBn : B.Nonempty)
    (hC : ∀ x ∈ A, ∀ y ∈ B, (1 - t) * x + t * y ∈ C) :
    ENNReal.ofReal (1 - t) * volume A + ENNReal.ofReal t * volume B ≤ volume C := by
  obtain ⟨a₀, ha₀⟩ := hAn
  obtain ⟨b₀, hb₀⟩ := hBn
  rw [volume_eq_iSup_compact hA, volume_eq_iSup_compact hB, ENNReal.mul_iSup, ENNReal.mul_iSup]
  refine ENNReal.iSup_add_iSup_le fun K L => ?_
  have hK : IsCompact (K.1 ∪ {a₀}) := K.2.2.union isCompact_singleton
  have hL : IsCompact (L.1 ∪ {b₀}) := L.2.2.union isCompact_singleton
  have key := bm_compact ht0 ht1 (C := C) hK hL ⟨a₀, Or.inr rfl⟩ ⟨b₀, Or.inr rfl⟩
    (fun x hx y hy => hC x (hx.elim (fun h => K.2.1 h) fun h => h ▸ ha₀)
      y (hy.elim (fun h => L.2.1 h) fun h => h ▸ hb₀))
  refine le_trans ?_ key
  gcongr <;> exact subset_union_left

end BQTF.PL
