# Isabelle teaching example and research-code status

Last updated: 26 November 2026.

## Checked finite teaching exercise

A finite Isabelle/HOL teaching companion is available with the [interactive English handbook](https://simonetestino.pages.dev/research/forcing-with-urelements/first-step/#learning-cells). It has been checked using Isabelle2025-2. The [project overview](https://simonetestino.pages.dev/research/forcing-with-urelements/#isabelle) describes its scope and provides the downloadable companion.

For the explicit three-condition order and its specified recursive finite name grammars, the companion checks:

1. Exactly the two generic filters of the terminal branches.
2. The traditional singleton-valued name and the absence of a uniform atom-valued witness among the old names.
3. The admissibility and branch values of the repaired selector, with atom-valued and singleton-valued names kept distinct.
4. Admissible mixing of arbitrary finite repaired names assigned to these two terminal branches.

The handbook's browser interactions are finite explanatory previews. The Isabelle/HOL session in the companion supplies the machine-checked proofs.

## Independent research development

My study and independent research development are ongoing. This repository currently publishes the presentation and its content LaTeX; research proof code is not published here. The teaching companion is distributed on the personal website. Research-code publication remains a later step, after I can explain the development myself.

The finite exercise does not formalise the general forcing theorem, Lemma 60 for arbitrary posets, or Theorem 61 equating Collection and fullness for all posets. These remain source-based mathematical reading. No completed Lean development is claimed.

## Mathematical references

Bokai Yao, [*Set Theory with Urelements*, arXiv v3](https://arxiv.org/pdf/2303.14274v3):

- Remark 55: p. 47 / PDF 54.
- Definition 57: p. 48 / PDF 55.
- Lemma 60: pp. 49–50 / PDF 56–57.
- Theorem 61: pp. 50–52 / PDF 57–59.

[Return to the project](../)
