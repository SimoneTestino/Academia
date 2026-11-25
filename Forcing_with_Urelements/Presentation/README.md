# Forcing with Urelements — Presentation

Last updated: 25 November 2026.

- [Read the presentation](Forcing_with_Urelements.pdf)
- [Read the content LaTeX source](Forcing_with_Urelements.tex)

The presentation is in English. It first works out the two generic filters of the finite forcing order, then poses the witness question. The same traditional set-name is evaluated in both filters before Yao’s repaired names resolve the finite example. The general theorem relating Collection to fullness follows separately. Clickable section links and PDF bookmarks connect the main parts of the talk and the appendix.

## Content source and rendering

This revision publishes the presentation content. The `.tex` imports the author’s privately maintained `ac-illc-presentation` package. That package and its reusable macros, styles and institutional logo source assets are not included in the current revision.

The content source can be read directly. Reproducing the original PDF requires XeLaTeX, the private package and its dependencies installed in a local TeX search path; the public files alone are not a standalone build. The optional `.texinputs` lookup in the source is a local workspace hook, whose files are not distributed.

With the author’s package available locally, compile twice from this directory:

```sh
mkdir -p /tmp/forcing-with-urelements-build
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements.tex
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements.tex
```

The resulting PDF is `/tmp/forcing-with-urelements-build/Forcing_with_Urelements.pdf`. The published PDF can be read without the rendering package.

## Source references

The principal source is Bokai Yao’s [*Set Theory with Urelements*, arXiv v3](https://arxiv.org/pdf/2303.14274v3). References in the slides distinguish printed page numbers from PDF page numbers.
