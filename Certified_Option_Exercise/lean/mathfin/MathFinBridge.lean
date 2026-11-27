import CertifiedOptionExercise.Core
import Mathlib.Data.Rat.Cast.Order
import MathFin.Models.Binomial.Model

namespace CertifiedOptionExercise.MathFinBridge

/-- Build the rational specialization of the constant-parameter binomial tree.
The exercise schedule is specified by the number of steps remaining. -/
def crrTree (exerciseDates : Nat → Bool) (discount q upFactor downFactor : Rat)
    (payoff : Rat → Rat) : Nat → Rat → Tree
  | 0, spot => .terminal (payoff spot)
  | n + 1, spot =>
    .node discount q (if exerciseDates (n + 1) then some (payoff spot) else none)
      (crrTree exerciseDates discount q upFactor downFactor payoff n (spot * upFactor))
      (crrTree exerciseDates discount q upFactor downFactor payoff n (spot * downFactor))

private theorem cast_continuation (discount q up down : Rat) :
    (continuation discount q up down : ℝ) =
      (discount : ℝ) * ((q : ℝ) * (up : ℝ) + (1 - (q : ℝ)) * (down : ℝ)) := by
  simp only [continuation, Rat.cast_mul, Rat.cast_add, Rat.cast_sub, Rat.cast_one]

private theorem cast_step_some (payoff hold : Rat) :
    (step (some payoff) hold : ℝ) = max (payoff : ℝ) (hold : ℝ) := by
  by_cases hp : payoff ≤ hold
  · have hCast : (payoff : ℝ) ≤ (hold : ℝ) := Rat.cast_le.mpr hp
    rw [step, ite_eq_left hp, max_eq_right hCast]
  · have hCast : (hold : ℝ) ≤ (payoff : ℝ) := Rat.cast_le.mpr (Rat.le_of_lt (Rat.not_le.mp hp))
    rw [step, ite_eq_right hp, max_eq_left hCast]

/-- Exact rational backward induction agrees with MathFin when the model inputs agree.
The probability and discount hypotheses make the calibration of the finite model explicit. -/
theorem price_eq_bermudan (exerciseDates : Nat → Bool) (discount q upFactor downFactor : Rat)
    (payoff : Rat → Rat) (r : ℝ) (g : ℝ → ℝ)
    (hDiscount : (discount : ℝ) = Real.exp (-r))
    (hProb : (q : ℝ) = MathFin.crrUpProb (upFactor : ℝ) (downFactor : ℝ) r)
    (hPayoff : ∀ s : Rat, (payoff s : ℝ) = g (s : ℝ))
    (steps : Nat) (spot : Rat) :
    ((crrTree exerciseDates discount q upFactor downFactor payoff steps spot).price : ℝ) =
      MathFin.bermudanPrice {i | exerciseDates i = true} (upFactor : ℝ) (downFactor : ℝ)
        r g steps (spot : ℝ) := by
  induction steps generalizing spot with
  | zero =>
    simpa only [crrTree, Tree.price, MathFin.bermudanPrice_zero] using hPayoff spot
  | succ n ih =>
    simp only [crrTree, Tree.price]
    by_cases eligible : exerciseDates (n + 1) = true
    · have hm : n + 1 ∈ {i : Nat | exerciseDates i = true} := eligible
      rw [ite_eq_left eligible, MathFin.bermudanPrice_succ_of_mem hm]
      simp only [cast_step_some, cast_continuation, ih, hDiscount, hProb,
        hPayoff, Rat.cast_mul, MathFin.binomialOptionPriceOnePeriod]
    · have hm : n + 1 ∉ {i : Nat | exerciseDates i = true} := eligible
      rw [ite_eq_right eligible, MathFin.bermudanPrice_succ_of_notMem hm]
      simp only [step, cast_continuation, ih, hDiscount, hProb,
        Rat.cast_mul, MathFin.binomialOptionPriceOnePeriod]

/-- Accepted executable certificates bound the corresponding MathFin Bermudan price. -/
theorem bounds_bermudan_of_check (exerciseDates : Nat → Bool)
    (discount q upFactor downFactor : Rat) (payoff : Rat → Rat) (r : ℝ) (g : ℝ → ℝ)
    (hDiscount : (discount : ℝ) = Real.exp (-r))
    (hProb : (q : ℝ) = MathFin.crrUpProb (upFactor : ℝ) (downFactor : ℝ) r)
    (hPayoff : ∀ s : Rat, (payoff s : ℝ) = g (s : ℝ))
    (steps : Nat) (spot : Rat) (certificate : Certificate)
    (h : check (crrTree exerciseDates discount q upFactor downFactor payoff steps spot)
      certificate = true) :
    let price := MathFin.bermudanPrice {i | exerciseDates i = true}
      (upFactor : ℝ) (downFactor : ℝ) r g steps (spot : ℝ)
    (certificate.bounds.lower : ℝ) ≤ price ∧ price ≤ (certificate.bounds.upper : ℝ) := by
  dsimp only
  obtain ⟨hLower, hUpper⟩ := check_sound h
  rw [← price_eq_bermudan exerciseDates discount q upFactor downFactor payoff r g hDiscount
    hProb hPayoff steps spot]
  exact ⟨Rat.cast_le.mpr hLower, Rat.cast_le.mpr hUpper⟩

end CertifiedOptionExercise.MathFinBridge
