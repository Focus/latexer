{SelectListView, $, $$} = require 'atom-space-pen-views'
Citation = require './citation'
FindLabels = require './find-labels'
fs = require 'fs'

module.exports =
class CiteView extends SelectListView
  editor: null
  panel: null

  initialize: ->
    super
    @addClass('overlay from-top')

  show: (editor) ->
    return unless editor?
    @editor = editor
    cites = @getCitations()
    @setItems(cites)
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()
    @focusFilterEditor()

  getEmptyMessage: ->
    "No citations found"

  getFilterKey: ->
    "filterKey"

  viewForItem: ({title, key, author}) ->
    "<li><span style='display:block;'>#{title}</span><span style='display:block;font-size:xx-small;'>#{author}</span></li>"

  hide: ->
    @panel?.hide()

  confirmed: ({title, key, author}) ->
    @editor.insertText key
    @restoreFocus()
    @hide()
  cancel: ->
    super
    @hide()

  getCitations: ->
    cites = []
    bibRex = /\\bibliography{([^}]+)}/g
    while (match = bibRex.exec(@editor.getText()))
      path = FindLabels.getAbsolutePath(@editor.getPath(), match[1])
      cites = cites.concat(@getCitationsFromPath(path))
    cites

  getCitationsFromPath: (path) ->
    cites = []
    text = fs.readFileSync(path).toString()
    return [] unless text?
    text = text.replace(/(\r\n|\n|\r)/gm,"")
    textSplit = text.split("@")
    textSplit.shift()
    for cite in textSplit
      continue unless cite?
      ct = new Citation
      ct.parse(cite)
      cites.push({title: ct.get("title"), key: ct.get("key"), author: ct.get("author"), filterKey: ct.get("author") + " " + ct.get("title")})
    cites
