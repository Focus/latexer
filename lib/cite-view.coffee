{SelectListView, $, $$} = require 'atom-space-pen-views'
Citation = require './citation'
FindLabels = require './find-labels'
fs = require 'fs-plus'
pathModule = require 'path'

module.exports =
class CiteView extends SelectListView
  editor: null
  panel: null

  initialize: ->
    super
    @addClass('overlay from-top cite-view')

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
    bibFiles = @getBibFiles()
    for bibFile in bibFiles
      cites = cites.concat(@getCitationsFromPath(bibFile))
    cites

  getBibFiles: ->
    basePath = @editor.getPath()
    bibFiles = @getBibFileFromText(@editor.getText())
    if bibFiles == null or bibFiles.length == 0
      texRootRex = /%!TEX root = (.+)/g
      while(match = texRootRex.exec(@editor.getText()))
        absolutFilePath = FindLabels.getAbsolutePath(@editor.getPath(), match[1])
        basePath = pathModule.dirname(absolutFilePath)
        try 
          text = fs.readFileSync(absolutFilePath).toString()
          bibFiles = @getBibFileFromText(text) #todo append basePath to each BibFiles in
          if bibFiles != null and bibFiles.length != 0
            break
        catch error
          atom.notifications.addError('could not load content '+ match[1], { dismissable: true })
          console.log(error)
    result = []
    basePath = basePath + pathModule.sep
    for bfpath in bibFiles
      result = result.concat(FindLabels.getAbsolutePath(basePath, bfpath) )
    result

  getBibFileFromText: (text) ->
    bibFiles = []
    bibRex = /\\(?:bibliography|addbibresource|addglobalbib){([^}]+)}/g
    while( match = bibRex.exec(text) ) #try editor text for bibfile
      if not /\.bib$/.test(match[1])
        match[1] += ".bib"
      bibFiles = bibFiles.concat(match[1])
    bibFiles

  getCitationsFromPath: (path) ->
    cites = []
    text = null
    try text = fs.readFileSync(path).toString()
    catch error
       console.log(error)
       return []
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
