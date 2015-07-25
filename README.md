# latexer

Laxer is a package to help you with your every day LaTex needs.

[![Build Status](https://travis-ci.org/Focus/latexer.svg?branch=master)](https://travis-ci.org/Focus/latexer)

Features
--------

####Reference autocompletion
  ![Autocompletion of references](https://github.com/Focus/latexer/raw/master/screenshots/ref.gif)
Triggers:
  * Typing in `\ref{` or `\eqref{`
  * Deleting anything so that the left of the cursor reads `\ref{` or `\eqref{`, e.g. deleting the word 'something' from `\ref{something}`


####Bibliography autocompletion
  ![Autocompletion of bibliography](https://github.com/Focus/latexer/raw/master/screenshots/cite.gif)
Will scan through the file to find `\bibliography{mybib1.bib, mybib2}` and then scan through the file named `mybib1.bib` and `mymbib2.bib` to get the citations.
Triggers:
  * Typing in `\cite{`, `\textcite{`, `\citet{`, `\citet*{`, `\citep{` or `\citep*{`. You can also write something in square brackets before, e.g. `\cite[Theorem 1]{`.
  * Deleting anything so that the left of the cursor reads `\cite{`, `\textcite{`, `\citet{`, `\citet*{`, `\citep{` or `\citep*{`, e.g. deleting the word 'something' from `\cite{something}`

Will look for Bibtex files given in the current file of the form `\bibliography`, `\addbibresource` and `\addglobalbib`.

For **multifile** support, from the child files use `%!TEX root = mainfile.tex` to point to the root file.


#####Environment autocompletion
  ![Autocompletion of environments](https://github.com/Focus/latexer/raw/master/screenshots/env.gif)
Triggers:
  * Having an unmatched `\begin{env_name}` or `\[` in the line above.
