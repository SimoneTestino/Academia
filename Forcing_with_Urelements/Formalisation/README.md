# Formalisation of the finite witness example

Last updated: 25 November 2026.

## Current status

Preparatory work is ongoing: the mathematical scope is being specified and studied. Implementation has not started; there are no Isabelle or Lean files or machine-checked results in this project.

## Proposed scope

A possible future development would formalise the finite two-branch example from Bokai Yao’s [*Set Theory with Urelements*, arXiv v3](https://arxiv.org/pdf/2303.14274v3):

1. Define the two-branch forcing order and the filters corresponding to its terminal branches.
2. Represent the traditional names and their evaluation, keeping atoms distinct from sets.
3. Show that the set-name evaluates to `{a}` on one branch and `{b}` on the other, while no single traditional name is a witness on both when `a` and `b` are distinct atoms.
4. Represent Yao’s repaired names, verify their compatibility requirement, and construct a single name evaluating to `a` or `b` according to the branch.
5. Consider invariance under consistent renaming of atoms and, subsequently, a finite family of terminal branches.

The implementation would need to justify its correspondence with Yao’s definitions. A finite typed model would be a study of this example, rather than a formalisation of the general forcing theorem or of Collection being equivalent to fullness for all posets. The provisional target is Isabelle/HOL; the exact encoding remains open.

## Mathematical references

- Remark 55: p. 47 / PDF 54.
- Definition 57: p. 48 / PDF 55.
- Lemma 60: pp. 49–50 / PDF 56–57.

[Return to the project](../)
