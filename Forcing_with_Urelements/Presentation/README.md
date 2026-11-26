# Forcing with Urelements — Presentation

Last updated: 26 November 2026. Mathematical content dated 25 November 2026.

- [Read the bright presentation (PDF)](Forcing_with_Urelements.pdf)
- [Read the dark presentation (PDF)](Forcing_with_Urelements_Dark.pdf)
- [Read the bright content LaTeX source](Forcing_with_Urelements.tex)
- [Read the dark content LaTeX source](Forcing_with_Urelements_Dark.tex)
- [Interactive handbook and teaching companion](https://simonetestino.pages.dev/research/forcing-with-urelements/first-step/)

Both editions contain the same 35 English slides, with the same mathematical body, bookmarks and page destinations. The current exports use linked textual institutional affiliations. The presentation first works out the two generic filters of the finite forcing order, then poses the witness question. The same traditional set-name is evaluated in both filters before Yao’s repaired names resolve the finite example. The general theorem relating Collection to fullness follows separately.

## Content source and rendering

These `.tex` files publish the presentation content and import the author’s privately maintained `ac-illc-presentation` package. The package, reusable macros and styles, and local `.texinputs` files are not distributed. The public source is readable; reproducing its original rendering requires the current private package and its dependencies in a TeX search path. These public files alone are not a standalone build.

The bright main selects `\usepackage[light,text-affiliations]{ac-illc-presentation}`. The dark main selects `\usepackage[dark,text-affiliations]{ac-illc-presentation}`. Their document bodies are identical. The optional `.texinputs` lookup is only a local editor hook; it is unnecessary when the private package is otherwise available to TeX.

With that package available locally, run the corresponding XeLaTeX command twice from this directory so section navigation and bookmarks settle:

```sh
mkdir -p /tmp/forcing-with-urelements-build
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements.tex
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements_Dark.tex
```

The PDFs can be read without the rendering package. Earlier editions retain their exact history.

## Source references

The principal source is Bokai Yao’s [*Set Theory with Urelements*, arXiv v3](https://arxiv.org/pdf/2303.14274v3). References in the slides distinguish printed page numbers from PDF page numbers.
