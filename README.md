# latexer

Laxer is a package to help you with your every day LaTex needs. It does reference, citation and environment autocompletion on the fly or at the touch of a keystroke.

[![Build Status](https://travis-ci.org/Focus/latexer.svg?branch=master)](https://travis-ci.org/Focus/latexer)

Features
--------

#### Reference autocompletion
  ![Autocompletion of references](https://github.com/Focus/latexer/raw/master/screenshots/ref.gif)
Triggers:
  * Typing in `\ref{`, `\eqref{` or any control sequences that ends in `ref{`
  * Deleting anything so that the left of the cursor reads `\ref{`, `\eqref{`, and the like. E.g. deleting the word 'something' from `\pageref{something}`


#### Bibliography autocompletion
  ![Autocompletion of bibliography](https://github.com/Focus/latexer/raw/master/screenshots/cite.gif)
Will scan through the file to find `\bibliography{mybib1.bib, mybib2}` and then scan through the file named `mybib1.bib` and `mymbib2.bib` to get the citations.
Triggers:
  * Typing in `\cite{`, `\textcite{`, `\citet{`, `\citet*{`, `\citep{` or `\citep*{`. You can also write something in square brackets before, e.g. `\cite[Theorem 1]{`.
  * Deleting anything so that the left of the cursor reads `\cite{`, `\textcite{`, `\citet{`, `\citet*{`, `\citep{` or `\citep*{`, e.g. deleting the word 'something' from `\cite{something}`

Will look for Bibtex files given in the current file of the form `\bibliography`, `\addbibresource` and `\addglobalbib`.

You can edit from the preferences window which parameters you would like to search the bibliographies by. The default is `title,author`, for example `key,year` will search through entries by their key, i.e. `@key{...}`, and the year it was published.


##### Environment autocompletion
  ![Autocompletion of environments](https://github.com/Focus/latexer/raw/master/screenshots/env.gif)
Triggers:
  * Having an unmatched `\begin{env_name}` or `\[` in the line above.

#### Multifile support

For multifile support, from the child files use `%!TEX root = mainfile.tex` to point to the root file.


Options
--------

You can switch off any of the autocompletions in the settings menu. If you prefer a manual approach you can bind keys as follows. First go to `Atom>Open Your Keymap` and then paste the following, choosing whatever key binding you find convenient:

```cson
'atom-text-editor':
  'cmd-alt-o': 'latexer:omnicomplete'
  'cmd-alt-r': 'latexer:insert-reference'
  'cmd-alt-c': 'latexer:insert-citation'
```

Latex on Atom
-----------

This package only provides autocompletion. If you want the full latex experience then I would recommend getting the [language-latex](https://atom.io/packages/language-latex) package for syntax highlighting, and the [latex](https://atom.io/packages/latex) or the [latex-plus](https://atom.io/packages/latex-plus) package for compiling latex documents. You can also view pdf documents from within Atom by installing the [pdf-view](https://atom.io/packages/pdf-view) package.
