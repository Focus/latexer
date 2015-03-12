{$,SelectListView} = require 'atom-space-pen-views'
FindLabels = require './find-labels'

module.exports =
class LabelView extends SelectListView
  editor: null
  panel: null

  initialize: ->
    super
    @addClass('overlay from-top')
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActivePaneItem()
    if @editor?
      labels = FindLabels.getLabelsByText(@editor.getText(), @editor.getPath())
      @setItems(labels)
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  getEmptyMessage: ->
    "No labels found"

  getFilterKey: ->
    "label"

  viewForItem: ({label}) ->
     "<li>#{label}</li>"

  cancel: ->
    super
    @panel?.hide()
    @previouslyFocusedElement?.focus()

  confirmed: ({label}) ->
    @editor.insertText label
    @cancel()
