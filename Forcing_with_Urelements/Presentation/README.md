# Forcing with Urelements — Presentation

Last updated: 25 November 2026.

- [Read the presentation](Forcing_with_Urelements.pdf)
- [Download the LaTeX source](Forcing_with_Urelements.tex)

The presentation is in English. It first works out the two generic filters of the finite forcing order, then poses the witness question. The same traditional set-name is evaluated in both filters before Yao’s repaired names resolve the finite example. The general theorem relating Collection to fullness follows separately.

## Build

The source is self-contained and uses XeLaTeX, Beamer, TikZ, `fontspec`, `fontawesome5`, `adjustbox`, the TeX Gyre font files and the standard AMS mathematics packages. It uses Times New Roman when available and falls back to TeX Gyre Termes. The design follows the project’s UvA presentation style.

From this directory, compile twice with a TeX distribution containing those packages:

```sh
mkdir -p /tmp/forcing-with-urelements-build
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements.tex
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements.tex
```

The resulting PDF is `/tmp/forcing-with-urelements-build/Forcing_with_Urelements.pdf`.

## Source references

The principal source is Bokai Yao’s [*Set Theory with Urelements*, arXiv v3](https://arxiv.org/pdf/2303.14274v3). References in the slides distinguish printed page numbers from PDF page numbers.
