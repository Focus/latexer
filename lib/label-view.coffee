{$,SelectListView} = require 'atom-space-pen-views'
FindLabels = require './find-labels'
fs = require 'fs-plus'
pathModule = require 'path'

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
    file = editor?.buffer?.file
    basePath = file?.path
    activePaneItemPath = basePath
   #  texRootRex = /%!TEX root = (.+)/g
    texRootRex = /%(\s+)?!TEX root(\s+)?=(\s+)?(.+)/g
    while(match = texRootRex.exec(@editor.getText()))
      # absolutFilePath = FindLabels.getAbsolutePath(basePath,match[1])
      absolutFilePath = FindLabels.getAbsolutePath(activePaneItemPath,match[4])
      basePath = pathModule.dirname(absolutFilePath)
      try
        text = fs.readFileSync(absolutFilePath).toString()
        labels = FindLabels.getLabelsByText(text, absolutFilePath)
      catch error
        atom.notifications.addError('could not load content of '+ absolutFilePath, { dismissable: true })
        console.log(error)
    if labels == undefined or labels.length == 0
      labels = FindLabels.getLabelsByText(@editor.getText(), basePath)
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
