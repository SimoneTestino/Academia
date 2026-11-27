import CertifiedOptionExercise.Core

namespace CertifiedOptionExercise.Examples

private def put (strike spot : Rat) : Rat :=
  if strike ≤ spot then 0 else strike - spot

/-- Two steps starting from 100, with up factor 6/5, down factor 4/5 and return 21/20. -/
def putTree (strike : Rat) (exerciseAtFirstStep : Bool) : Tree :=
  .node (20 / 21) (5 / 8) none
    (.node (20 / 21) (5 / 8) (if exerciseAtFirstStep then some (put strike 120) else none)
      (.terminal (put strike 144)) (.terminal (put strike 96)))
    (.node (20 / 21) (5 / 8) (if exerciseAtFirstStep then some (put strike 80) else none)
      (.terminal (put strike 96)) (.terminal (put strike 64)))

private def exact (value : Rat) : Bounds := ⟨value, value⟩

/-- Values are supplied independently, in model-tree order. -/
def put100Certificate : Certificate :=
  .node (exact (1175 / 147))
    (.node (exact (10 / 7)) (.terminal (exact 0)) (.terminal (exact 4)))
    (.node (exact 20) (.terminal (exact 4)) (.terminal (exact 36)))

example : (putTree 100 true).price = 1175 / 147 := by decide +kernel
example : (putTree 100 false).price = 925 / 147 := by decide +kernel
example : check (putTree 100 true) put100Certificate = true := by decide +kernel
example : inspect (putTree 100 true) put100Certificate =
    some ⟨exact (1175 / 147), .continuationOnly⟩ := by decide +kernel
example : (inspect (putTree 100 true) put100Certificate [.up]).map Report.decision =
    some .continue := by decide +kernel
example : (inspect (putTree 100 true) put100Certificate [.down]).map Report.decision =
    some .exercise := by decide +kernel
example : (inspect (putTree 100 true) put100Certificate [.down, .up]).map Report.decision =
    some .maturity := by decide +kernel
example : inspect (putTree 100 true) put100Certificate [.down, .up, .up] =
    none := by decide +kernel

def wrongCertificate : Certificate :=
  .node ⟨0, 100⟩
    (.node ⟨0, 100⟩ (.terminal ⟨0, 100⟩) (.terminal (exact 5)))
    (.node ⟨0, 100⟩ (.terminal ⟨0, 100⟩) (.terminal ⟨0, 100⟩))

/-- The invalid upper subtree causes rejection even when inspecting the other subtree. -/
example : inspect (putTree 100 true) wrongCertificate [.down] = none := by decide +kernel
example : check (putTree 100 true) (.terminal ⟨0, 100⟩) = false := by decide +kernel
example :
    check (.node 1 (3/2) none (.terminal 0) (.terminal 0))
      (.node (exact 0) (.terminal (exact 0)) (.terminal (exact 0))) = false := by decide +kernel
example :
    check (.node 0 (1/2) none (.terminal 0) (.terminal 0))
      (.node (exact 0) (.terminal (exact 0)) (.terminal (exact 0))) = false := by decide +kernel

/-- For strikes near 800/9, the only nonzero terminal payoff is strike minus 64. -/
def nearThresholdCertificate (strike uncertainty : Rat) : Certificate :=
  .node ⟨0, 100⟩
    (.node (exact 0) (.terminal (exact 0)) (.terminal (exact 0)))
    (.node ⟨0, 100⟩ (.terminal (exact 0))
      (.terminal ⟨strike - 64 - uncertainty, strike - 64 + uncertainty⟩))

def strikeThreshold : Rat := 800 / 9

def strikeAbove : Rat := strikeThreshold + 1 / 100000000

def strikeBelow : Rat := strikeThreshold - 1 / 100000000

def downDecision (strike uncertainty : Rat) : Option Decision :=
  (inspect (putTree strike true) (nearThresholdCertificate strike uncertainty) [.down]).map
    Report.decision

example : downDecision strikeAbove 0 = some .exercise := by decide +kernel
example : downDecision strikeBelow 0 = some .continue := by decide +kernel
example : downDecision strikeThreshold 0 = some .unresolved := by decide +kernel
example : downDecision strikeAbove (1 / 1000000) = some .unresolved := by decide +kernel
example : downDecision strikeBelow (1 / 1000000) = some .unresolved := by decide +kernel

end CertifiedOptionExercise.Examples
