import Init.Data.Rat.Lemmas

namespace CertifiedOptionExercise

/-- A fixed finite binary model. An internal node has an exercise payoff only on eligible dates. -/
inductive Tree where
  | terminal (payoff : Rat)
  | node (discount upProbability : Rat) (payoff : Option Rat) (up down : Tree)
  deriving Repr

/-- Unverified price bounds proposed by a certificate producer. -/
structure Bounds where
  lower : Rat
  upper : Rat
  deriving Repr, DecidableEq

/-- The producer supplies bounds at every node. The checker validates the shape. -/
inductive Certificate where
  | terminal (bounds : Bounds)
  | node (bounds : Bounds) (up down : Certificate)
  deriving Repr

def Certificate.bounds : Certificate → Bounds
  | .terminal bounds | .node bounds _ _ => bounds

/-- Discounted conditional expectation at a node in the given model. -/
def continuation (discount upProbability upValue downValue : Rat) : Rat :=
  discount * (upProbability * upValue + (1 - upProbability) * downValue)

/-- The value before the decision at one node. -/
def step (payoff : Option Rat) (hold : Rat) : Rat :=
  match payoff with
  | none => hold
  | some exercise => if exercise ≤ hold then hold else exercise

/-- The reference price from exact backward induction, independent of all certificates. -/
def Tree.price : Tree → Rat
  | .terminal payoff => payoff
  | .node discount q payoff up down =>
    step payoff (continuation discount q up.price down.price)

/-- The one-node checks validate the model inputs and the proposed Bellman inequalities. -/
def NodeValid (discount q : Rat) (payoff : Option Rat) (atNode up down : Bounds) : Prop :=
  0 < discount ∧ 0 ≤ q ∧ q ≤ 1 ∧
    atNode.lower ≤ step payoff (continuation discount q up.lower down.lower) ∧
    step payoff (continuation discount q up.upper down.upper) ≤ atNode.upper

instance (discount q : Rat) (payoff : Option Rat) (atNode up down : Bounds) :
    Decidable (NodeValid discount q payoff atNode up down) := by
  unfold NodeValid
  infer_instance

/-- A certificate covers the full tree and satisfies each local check. -/
def Valid : Tree → Certificate → Prop
  | .terminal payoff, .terminal bounds => bounds.lower ≤ payoff ∧ payoff ≤ bounds.upper
  | .node discount q payoff up down, .node bounds upCert downCert =>
    NodeValid discount q payoff bounds upCert.bounds downCert.bounds ∧
      Valid up upCert ∧ Valid down downCert
  | _, _ => False

/-- Check each proposed bound once, using exact rational arithmetic throughout. -/
def check : Tree → Certificate → Bool
  | .terminal payoff, .terminal bounds => decide (bounds.lower ≤ payoff ∧ payoff ≤ bounds.upper)
  | .node discount q payoff up down, .node bounds upCert downCert =>
    decide (NodeValid discount q payoff bounds upCert.bounds downCert.bounds) &&
      (check up upCert && check down downCert)
  | _, _ => false

theorem check_iff_valid (tree : Tree) (certificate : Certificate) :
    check tree certificate = true ↔ Valid tree certificate := by
  induction tree generalizing certificate with
  | terminal payoff => cases certificate <;> simp [check, Valid]
  | node discount q payoff up down upIH downIH =>
    cases certificate <;> simp [check, Valid, upIH, downIH]

theorem continuation_mono {discount q u₁ u₂ d₁ d₂ : Rat}
    (hDiscount : 0 ≤ discount) (hq₀ : 0 ≤ q) (hq₁ : q ≤ 1)
    (hUp : u₁ ≤ u₂) (hDown : d₁ ≤ d₂) :
    continuation discount q u₁ d₁ ≤ continuation discount q u₂ d₂ := by
  have hNotQ : 0 ≤ 1 - q := (Rat.le_iff_sub_nonneg q 1).mp hq₁
  have hWeightedUp := Rat.mul_le_mul_of_nonneg_left hUp hq₀
  have hWeightedDown := Rat.mul_le_mul_of_nonneg_left hDown hNotQ
  unfold continuation
  apply Rat.mul_le_mul_of_nonneg_left _ hDiscount
  exact Rat.le_trans (Rat.add_le_add_right.mpr hWeightedUp)
    (Rat.add_le_add_left.mpr hWeightedDown)

theorem step_mono (payoff : Option Rat) {a b : Rat} (hab : a ≤ b) :
    step payoff a ≤ step payoff b := by
  cases payoff with
  | none => exact hab
  | some exercise =>
    by_cases ha : exercise ≤ a
    · have hb := Rat.le_trans ha hab
      simpa [step, ha, hb] using hab
    · by_cases hb : exercise ≤ b
      · simp [step, ha, hb]
      · simp [step, ha, hb]

/-- A valid certificate encloses the reference value at its root. -/
theorem bounds_of_valid {tree certificate} (h : Valid tree certificate) :
    certificate.bounds.lower ≤ tree.price ∧ tree.price ≤ certificate.bounds.upper := by
  induction tree generalizing certificate with
  | terminal payoff =>
    cases certificate with
    | terminal bounds => exact h
    | node bounds up down => exact False.elim h
  | node discount q payoff up down upIH downIH =>
    cases certificate with
    | terminal bounds => exact False.elim h
    | node bounds upCert downCert =>
      obtain ⟨⟨hDiscount, hq₀, hq₁, hLower, hUpper⟩, hUp, hDown⟩ := h
      obtain ⟨hUpLower, hUpUpper⟩ := upIH hUp
      obtain ⟨hDownLower, hDownUpper⟩ := downIH hDown
      have hContinuationLower :=
        continuation_mono (Rat.le_of_lt hDiscount) hq₀ hq₁ hUpLower hDownLower
      have hContinuationUpper :=
        continuation_mono (Rat.le_of_lt hDiscount) hq₀ hq₁ hUpUpper hDownUpper
      exact ⟨Rat.le_trans hLower (step_mono payoff hContinuationLower),
        Rat.le_trans (step_mono payoff hContinuationUpper) hUpper⟩

/-- The Boolean verifier certifies enclosure for every accepted input. -/
theorem check_sound {tree certificate} (h : check tree certificate = true) :
    certificate.bounds.lower ≤ tree.price ∧ tree.price ≤ certificate.bounds.upper :=
  bounds_of_valid ((check_iff_valid tree certificate).mp h)

/-- A strict verdict is returned only when the continuation interval excludes the exercise payoff. -/
inductive Decision where
  | maturity
  | continuationOnly
  | exercise
  | continue
  | unresolved
  deriving Repr, DecidableEq

/-- The semantics of reported decisions. Unresolved conveys no strict claim. -/
def Decision.Sound (tree : Tree) (decision : Decision) : Prop :=
  match tree, decision with
  | .terminal _, .maturity => True
  | .node _ _ none _ _, .continuationOnly => True
  | .node discount q (some g) up down, .exercise =>
    continuation discount q up.price down.price < g
  | .node discount q (some g) up down, .continue =>
    g < continuation discount q up.price down.price
  | .node _ _ (some _) _ _, .unresolved => True
  | _, _ => False

private def classify (payoff : Rat) (hold : Bounds) : Decision :=
  if hold.upper < payoff then .exercise
  else if payoff < hold.lower then .continue
  else .unresolved

private def continuationBounds (discount q : Rat) (up down : Bounds) : Bounds :=
  ⟨continuation discount q up.lower down.lower,
    continuation discount q up.upper down.upper⟩

private def rawDecision : Tree → Certificate → Decision
  | .terminal _, _ => .maturity
  | .node _ _ none _ _, _ => .continuationOnly
  | .node discount q (some g) _ _, .node _ up down =>
    classify g (continuationBounds discount q up.bounds down.bounds)
  | _, _ => .unresolved

private theorem strict_of_le_of_lt {a b c : Rat} (hab : a ≤ b) (hbc : b < c) : a < c :=
  Rat.not_le.mp (fun hca => (Rat.not_le.mpr hbc) (Rat.le_trans hca hab))

private theorem strict_of_lt_of_le {a b c : Rat} (hab : a < b) (hbc : b ≤ c) : a < c :=
  Rat.not_le.mp (fun hca => (Rat.not_le.mpr hab) (Rat.le_trans hbc hca))

private theorem rawDecision_sound {tree certificate} (h : Valid tree certificate) :
    (rawDecision tree certificate).Sound tree := by
  cases tree with
  | terminal payoff => trivial
  | node discount q payoff up down =>
    cases certificate with
    | terminal bounds => exact False.elim h
    | node bounds upCert downCert =>
      cases payoff with
      | none => trivial
      | some g =>
        obtain ⟨⟨hDiscount, hq₀, hq₁, _, _⟩, hUp, hDown⟩ := h
        obtain ⟨hUpLower, hUpUpper⟩ := bounds_of_valid hUp
        obtain ⟨hDownLower, hDownUpper⟩ := bounds_of_valid hDown
        have hLower :=
          continuation_mono (Rat.le_of_lt hDiscount) hq₀ hq₁ hUpLower hDownLower
        have hUpper :=
          continuation_mono (Rat.le_of_lt hDiscount) hq₀ hq₁ hUpUpper hDownUpper
        simp only [rawDecision, classify]
        by_cases hExercise : (continuationBounds discount q upCert.bounds downCert.bounds).upper < g
        · rw [ite_eq_left hExercise]
          exact strict_of_le_of_lt hUpper hExercise
        · rw [ite_eq_right hExercise]
          by_cases hContinue : g < (continuationBounds discount q upCert.bounds downCert.bounds).lower
          · rw [ite_eq_left hContinue]
            exact strict_of_lt_of_le hContinue hLower
          · rw [ite_eq_right hContinue]
            trivial

/-- A path is a list of branch choices starting at the root. -/
inductive Branch where
  | up
  | down
  deriving Repr, DecidableEq

/-- Find a corresponding subtree and subcertificate. -/
def select : Tree → Certificate → List Branch → Option (Tree × Certificate)
  | tree, certificate, [] => some (tree, certificate)
  | .node _ _ _ up _, .node _ upCert _, .up :: path => select up upCert path
  | .node _ _ _ _ down, .node _ _ downCert, .down :: path => select down downCert path
  | _, _, _ => none

theorem valid_of_select {tree certificate path subtree subcertificate}
    (h : Valid tree certificate)
    (hs : select tree certificate path = some (subtree, subcertificate)) :
    Valid subtree subcertificate := by
  induction path generalizing tree certificate with
  | nil =>
    simp only [select, Option.some.injEq, Prod.mk.injEq] at hs
    rcases hs with ⟨rfl, rfl⟩
    exact h
  | cons branch path ih =>
    cases tree with
    | terminal payoff => cases certificate <;> cases branch <;> simp [select] at hs
    | node discount q payoff up down =>
      cases certificate with
      | terminal bounds => exact False.elim h
      | node bounds upCert downCert =>
        cases branch with
        | up => exact ih h.2.1 hs
        | down => exact ih h.2.2 hs

structure Report where
  bounds : Bounds
  decision : Decision
  deriving Repr, DecidableEq

private def report (tree : Tree) (certificate : Certificate) : Report :=
  ⟨certificate.bounds, rawDecision tree certificate⟩

/-- Check the whole certificate and report the bound and decision at the requested path. -/
def inspect (tree : Tree) (certificate : Certificate) (path : List Branch := []) : Option Report :=
  if check tree certificate then
    (select tree certificate path).map (fun (subtree, subcertificate) => report subtree subcertificate)
  else none

/-- Every returned report encloses the selected node's price and has a sound decision. -/
theorem inspect_sound {tree certificate path result}
    (h : inspect tree certificate path = some result) :
    ∃ subtree subcertificate,
      select tree certificate path = some (subtree, subcertificate) ∧
      result.bounds.lower ≤ subtree.price ∧ subtree.price ≤ result.bounds.upper ∧
      result.decision.Sound subtree := by
  unfold inspect at h
  split at h
  · rename_i hCheck
    cases hSelect : select tree certificate path with
    | none => simp [hSelect] at h
    | some pair =>
      rcases pair with ⟨subtree, subcertificate⟩
      simp only [hSelect, Option.map_some, Option.some.injEq] at h
      subst result
      have hv := valid_of_select ((check_iff_valid tree certificate).mp hCheck) hSelect
      have hBounds := bounds_of_valid hv
      exact ⟨subtree, subcertificate, rfl, hBounds.1, hBounds.2, rawDecision_sound hv⟩
  · simp at h

end CertifiedOptionExercise
