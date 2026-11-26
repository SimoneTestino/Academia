# Forcing with Urelements — Presentation

Updated 26 November 2026. The cover and four section outlines place the Master of Logic programme under the University of Amsterdam at the left, with the ILLC wordmark at the right. Each outline highlights the current section. A progress bar and a page counter on every slide show the current page and the total number of pages.

- [Read the bright presentation (PDF)](Forcing_with_Urelements.pdf)
- [Read the dark presentation (PDF)](Forcing_with_Urelements_Dark.pdf)
- [Read the bright content LaTeX source](Forcing_with_Urelements.tex)
- [Read the dark content LaTeX source](Forcing_with_Urelements_Dark.tex)
- [Interactive handbook and teaching companion](https://simonetestino.pages.dev/research/forcing-with-urelements/first-step/)

Both editions contain the same 35 English slides, with the same mathematical body, bookmarks and page destinations. The cover and section outlines link to the university, the programme and the institute. The ILLC artwork comes from the [Master of Logic thesis template](https://github.com/m4lvin/illc-mol-thesis-template/tree/ae51780e48702831acaf1fd082facd541c236f1a). The presentation first works out the two generic filters of the finite forcing order, then poses the witness question. The same traditional set-name is evaluated in both filters before Yao’s repaired names resolve the finite example. The general theorem relating Collection to fullness follows separately.

The cover links to the checked finite Isabelle/HOL teaching exercise. The final page distinguishes that finite result from my ongoing study and independent research development; the general theorem remains mathematical reading. It links to the handbook, the [research-code status](../Formalisation/), this content source and Yao’s thesis. No proof code appears in the slides.

## Content source and rendering

These `.tex` files publish the presentation content and import the author’s privately maintained `ac-illc-presentation` package. The package, reusable macros and styles, and local `.texinputs` files are not distributed. The public source is readable; reproducing its original rendering requires the current private package and its dependencies in a TeX search path. These public files alone are not a standalone build.

The bright main selects `\usepackage[light,illc-artwork]{ac-illc-presentation}[2026/11/26]`. The dark main selects `\usepackage[dark,illc-artwork]{ac-illc-presentation}[2026/11/26]`. Their document bodies are identical. The optional `.texinputs` lookup is only a local editor hook; it is unnecessary when the private package is otherwise available to TeX.

With that package available locally, run the corresponding XeLaTeX command twice from this directory so section navigation and bookmarks settle:

```sh
mkdir -p /tmp/forcing-with-urelements-build
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements.tex
xelatex -halt-on-error -interaction=nonstopmode -output-directory=/tmp/forcing-with-urelements-build Forcing_with_Urelements_Dark.tex
```

The PDFs can be read without the rendering package. Earlier editions retain their exact history.

## Source references

The principal source is Bokai Yao’s [*Set Theory with Urelements*, arXiv v3](https://arxiv.org/pdf/2303.14274v3). References in the slides distinguish printed page numbers from PDF page numbers.
