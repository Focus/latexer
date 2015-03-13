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
Will scan through the file to find `\bibliography{mybib.bib}` and then scan through the file named `mybib.bib` to get the citations.
Triggers:
  * Typing in `\cite{` or `\textcite{`
  * Deleting anything so that the left of the cursor reads `\cite{` or `\textcite{`, e.g. deleting the word 'something' from `\cite{something}`

#####Environment autocompletion
  ![Autocompletion of environments](https://github.com/Focus/latexer/raw/master/screenshots/env.gif)
Triggers:
  * Having an unmatched `\begin{env_name}` or `\[` in the line above.
