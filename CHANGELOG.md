#### Upcoming
Proposed:
* Added support for \autocite command from biblatex
* Added support for file inclusion via the subimport package (\subimport command)
* Relaxed requirements of %TEX root magic (additional spaces allowed, case insensitive)
* Removed additional brace characters from citation view

* Expanded autocomplete support to include [pandoc-style citations](http://pandoc.org/MANUAL.html#citations) when you're writing in [Markdown](https://guides.github.com/features/mastering-markdown/#syntax) (`.md`) or [Rmarkdown](http://rmarkdown.rstudio.com/) (`.Rmd`).
* Added support for specifying your bibfile (for citation autocompletion) as part of a [YAML Metadata block](http://pandoc.org/MANUAL.html#extension-yaml_metadata_block)
* UPDATED README with an example of pandoc citation autocompletion


#### 0.3.0
* Options to switch off autocompletion
* Added Atom commands
* Bug fix for duplicate environment detection

#### 0.2.9
* Small bug fixes
* Sorted out README

#### 0.2.8
* New autocomplete system for environments that ignores comments and implements nesting
* Generalized \ref matching to include any control sequence that ends in `ref`
* Small bug fixes

#### 0.2.5
* Added support for searching citations by different parameters
* Added support for comma separated citations/references
* Fixed issues with paths on Windows

#### 0.2.4
* Allowing multiple Bibtex files from bibliography{bib1,bib2}
* Can use cite with square brackets
* Allows for natbib style citations
* Added multifile support
* Fixed a bug where the environment closing was not checked if it was on the same line

#### 0.2.3

* Now `\bibliography{bla}` will work without the `.bib` extension
* Catching file opening exceptions for bibliography
* Saving file and changing the file name will now also trigger the extension
