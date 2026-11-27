# Certified Option Exercise

A Lean 4 verifier for price bounds and exercise decisions in finite Bermudan
option models. The checker accepts a binary tree with rational discount factors,
transition probabilities and explicit exercise eligibility. A separate
certificate supplies a lower and upper value at every node. These values can
come from an external numerical routine or be entered by hand.

## Run the finite example

Install [Lean with Elan](https://lean-lang.org/install/), then enter `lean/`.

```sh
lake build
lake exe optioncert examples/bermudan-put.json
lake exe optioncert examples/bermudan-put.json D
lake env leanchecker --fresh CertifiedOptionExercise
```

The first command checks the proofs and builds the verifier. The next two
inspect the same certificate at the root and on the down branch. The root
interval is exactly `[1175/147, 1175/147]`. At the down branch the immediate
payoff is `20`, above continuation `320/21`, so the verifier reports
`exercise`. A path uses `U` and `D`. JSON amounts are integers or objects of
the form `{"num":20,"den":21}`.

## What the checker proves

- [`check_sound`](lean/CertifiedOptionExercise/Core.lean) proves that the
  root bounds of an accepted certificate enclose the finite model's price.
- [`inspect_sound`](lean/CertifiedOptionExercise/Core.lean) also proves
  enclosure and the reported strict decision at a selected node. When the
  exercise payoff lies inside the continuation interval, the result is
  `unresolved`.
- [Kernel-checked examples](lean/CertifiedOptionExercise/Examples.lean)
  include malformed certificates and two strikes that round to the same
  cent and nevertheless give opposite exact decisions on the down branch.

The model is a finite risk-neutral tree. The guarantees concern the input
tree, conditional on its supplied data. They do not bound market, calibration,
or continuous-time discretisation error.

## Further comparison and reading

The [MathFin bridge](lean/mathfin/MathFinBridge.lean) proves
`price_eq_bermudan` and `bounds_bermudan_of_check`. Under the stated
input equalities, the rational tree price equals the MathFin Bermudan
price, and accepted bounds enclose it. The bridge pins MathFin v2.0.0
and uses Lean v4.35.0, the toolchain chosen by that library.

```sh
cd mathfin
lake build MathFinBridge
lake env leanchecker --fresh MathFinBridge
```

Run that block from the `lean/` directory. Lake resolves the locked
dependencies for the bridge separately from the CLI package.

- [Online project page](https://simonetestino.pages.dev/academic/research-projects/certified-option-exercise/)
- [The handbook’s two-step example](https://simonetestino.pages.dev/academic/courses/computational-finance/handbook/#lecture-14)
- [MathFin’s binomial pricing model](https://github.com/formal-applied-math/formal-mathfin/blob/v2.0.0/MathFin/Models/Binomial/Model.lean#L212-L250)
- [Fang and Oosterlee, early exercise and discrete barriers, §2](https://mpra.ub.uni-muenchen.de/9248/1/cos_delft.pdf#page=4)
