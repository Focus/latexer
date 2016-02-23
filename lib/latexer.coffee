LabelView = require './label-view'
CiteView = require './cite-view'
LatexerHook = require './latexer-hook'
{CompositeDisposable} = require 'atom'


module.exports = Latexer =
  config:
    parameters_to_search_citations_by:
      type: "array"
      default: ["title", "author"]
      items:
        type: "string"

    autocomplete_environments:
      type: "boolean"
      default: true

    autocomplete_references:
      type: "boolean"
      default: true

    autocomplete_citations:
      type: "boolean"
      default: true


  activate: ->
    instance = this
    atom.commands.add "atom-text-editor",
      "latexer:omnicomplete": (event)->
        instance.latexHook.refCiteCheck @getModel(), true, true
        instance.latexHook.environmentCheck @getModel()
      "latexer:insert-reference": (event)->
        instance.latexHook.lv.show @getModel()
      "latexer:insert-citation": (event)->
        instance.latexHook.cv.show @getModel()
    atom.workspace.observeTextEditors (editor) =>
      @latexHook = new LatexerHook(editor)

  deactivate: ->
    @latexHook.destroy()
