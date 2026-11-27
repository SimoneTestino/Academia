import CertifiedOptionExercise.Core
import Lean.Data.Json

namespace CertifiedOptionExercise.CLI

open Lean

private def parseRat (value : Json) : Except String Rat := do
  match value.getInt? with
  | .ok number => return (number : Rat)
  | .error _ =>
    let numerator ← (← value.getObjVal? "num").getInt?
    let denominator ← (← value.getObjVal? "den").getNat?
    if h : denominator = 0 then
      throw "Rational denominator must be positive"
    else
      return Rat.normalize numerator denominator h

private def getRat (value : Json) (field : String) : Except String Rat :=
  (value.getObjVal? field >>= parseRat).mapError (fun error => field ++ ": " ++ error)

private def parsePayoff (value : Json) : Except String (Option Rat) :=
  match value with
  | .null => .ok none
  | value => some <$> parseRat value

private def parseTree : Nat → Json → Except String Tree
  | 0, _ => .error "Model tree exceeds the maximum depth"
  | remaining + 1, value => do
    match ← (← value.getObjVal? "kind").getStr? with
    | "terminal" => return .terminal (← getRat value "payoff")
    | "node" =>
      let discount ← getRat value "discount"
      let probability ← getRat value "upProbability"
      let exercise ← parsePayoff (← value.getObjVal? "exercise")
      let up ← parseTree remaining (← value.getObjVal? "up")
      let down ← parseTree remaining (← value.getObjVal? "down")
      return .node discount probability exercise up down
    | kind => throw s!"Invalid model node kind: {kind}"

private def parseCertificate : Nat → Json → Except String Certificate
  | 0, _ => .error "Certificate tree exceeds the maximum depth"
  | remaining + 1, value => do
    let lower ← getRat value "lower"
    let upper ← getRat value "upper"
    match ← (← value.getObjVal? "kind").getStr? with
    | "terminal" => return .terminal ⟨lower, upper⟩
    | "node" =>
      let up ← parseCertificate remaining (← value.getObjVal? "up")
      let down ← parseCertificate remaining (← value.getObjVal? "down")
      return .node ⟨lower, upper⟩ up down
    | kind => throw s!"Invalid certificate node kind: {kind}"

private def parseInput (input : String) : Except String (Tree × Certificate) := do
  let value ← Json.parse input
  let tree ← parseTree 256 (← value.getObjVal? "model")
  let certificate ← parseCertificate 256 (← value.getObjVal? "certificate")
  return (tree, certificate)

private def parsePath (path : String) : Except String (List Branch) :=
  path.toList.mapM fun
    | 'U' => .ok .up
    | 'D' => .ok .down
    | _ => .error "A path must contain only U and D"

private def decisionName : Decision → String
  | .maturity => "maturity"
  | .continuationOnly => "continuation-only"
  | .exercise => "exercise"
  | .continue => "continue"
  | .unresolved => "unresolved"

private def printReport (path : String) (result : Report) : IO Unit :=
  IO.println <| Json.compress <| Json.mkObj [
    ("path", toJson path),
    ("lower", toJson (toString result.bounds.lower)),
    ("upper", toJson (toString result.bounds.upper)),
    ("decision", toJson (decisionName result.decision))]

private def run (file path : String) : IO UInt32 := do
  let input ← IO.FS.readFile file
  let args := do
    let branches ← parsePath path
    let (tree, certificate) ← parseInput input
    return (branches, tree, certificate)
  match args with
  | .error message =>
    IO.eprintln s!"optioncert: {message}"
    return 2
  | .ok (branches, tree, certificate) =>
    match inspect tree certificate branches with
    | some result =>
      printReport path result
      return 0
    | none =>
      if check tree certificate then
        IO.eprintln "optioncert: path does not identify a node"
        return 2
      else
        IO.eprintln "optioncert: certificate rejected"
        return 1

/-- A caller supplies a JSON file and, optionally, a branch path such as UD. -/
def main (args : List String) : IO UInt32 := do
  try
    match args with
    | [file] => run file ""
    | [file, path] => run file path
    | _ =>
      IO.eprintln "usage: optioncert INPUT.json [PATH]"
      return 2
  catch error =>
    IO.eprintln s!"optioncert: {error}"
    return 2

end CertifiedOptionExercise.CLI

def main := CertifiedOptionExercise.CLI.main
