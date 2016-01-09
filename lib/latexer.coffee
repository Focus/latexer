LabelView = require './label-view'
CiteView = require './cite-view'
LatexerHook = require './latexer-hook'
{TextEditor, CompositeDisposable} = require 'atom'


module.exports = Latexer =
  config:
    parametersToSearchCitationsBy:
      type: "array"
      default: ["title", "author"]
      items:
        type: "string"

  activate: ->
    atom.workspace.observeTextEditors (editor) =>
      new LatexerHook(editor)

  deactivate: ->
