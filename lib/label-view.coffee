{$,SelectListView} = require 'atom-space-pen-views'
FindLabels = require './find-labels'

module.exports =
class LabelView extends SelectListView
  editor: null
  panel: null

  initialize: ->
    super
    @addClass('overlay from-top label-view')

  show: (editor) ->
    return unless editor?
    @editor = editor
    labels = FindLabels.getLabelsByText(@editor.getText(), @editor.getPath())
    @setItems(labels)
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @storeFocusedElement()
    @focusFilterEditor()

  hide: ->
    @panel?.hide()

  getEmptyMessage: ->
    "No labels found"

  getFilterKey: ->
    "label"

  viewForItem: ({label}) ->
     "<li>#{label}</li>"

  confirmed: ({label}) ->
    @editor.insertText label
    @restoreFocus()
    @hide()
    
  cancel: ->
    super
    @hide()
