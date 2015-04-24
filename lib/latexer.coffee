LabelView = require './label-view'
CiteView = require './cite-view'
LatexerHook = require './latexer-hook'
{TextEditor, CompositeDisposable} = require 'atom'

module.exports = Latexer =

  activate: ->
    atom.workspace.observeTextEditors (editor) =>
      new LatexerHook(editor)

  deactivate: ->

  serialize: ->
    latexerViewState: @latexerView.serialize()
