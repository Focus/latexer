{SelectListView, $, $$} = require 'atom-space-pen-views'
Citation = require './citation'
FindLabels = require './find-labels'
fs = require 'fs-plus'
_ = require 'lodash'
pathModule = require 'path'
pandoc = require './pandoc-citations'

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
    """
    <li><span style='display:block;'>#{title}</span>
    <span style='display:block;font-size:xx-small;'>#{author}</span></li>
    """

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
    for bibFile in _.uniq(bibFiles)
      cites = cites.concat(@getCitationsFromPath(bibFile))
    cites

  getBibFiles: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer?.file
    basePath = file?.path
    activePaneItemPath = basePath
    if basePath.lastIndexOf(pathModule.sep) isnt -1
      basePath = basePath.substring 0, basePath.lastIndexOf(pathModule.sep)
    bibFiles = @getBibFileFromText(@editor.getText())
    if bibFiles == null or bibFiles.length == 0
      texRootRex = /%(\s+)?!TEX root(\s+)?=(\s+)?(.+)/gi
      while(match = texRootRex.exec(@editor.getText()))
        absolutFilePath =
          FindLabels.getAbsolutePath(activePaneItemPath,match[4])
        basePath = pathModule.dirname(absolutFilePath)
        try
          text = fs.readFileSync(absolutFilePath).toString()
          #todo append basePath to each BibFiles in
          bibFiles = @getBibFileFromText(text)
          if bibFiles != null and bibFiles.length != 0
            break
        catch error
          atom.notifications.addError('could not load content '+ match[4],
                                        {dismissable: true })
          console.log(error)
    result = []
    basePath = basePath + pathModule.sep
    for bfpath in bibFiles
      result = result.concat(FindLabels.getAbsolutePath(basePath, bfpath) )
      for bibDir in atom.config.get("latexer.directories_to_search_bib_in")
        result = result.concat(FindLabels.getAbsolutePath(bibDir, bfpath) )
    result

  getBibFileFromText: (text) ->
    bibFiles = []
    bibRex = /\\(?:bibliography|addbibresource|addglobalbib){([^}]+)}/g
    while( match = bibRex.exec(text) ) #try editor text for bibfile
      foundBibs = match[1].split ","
      for found in foundBibs
        if not /\.bib$/.test(found)
          found += ".bib"
        bibFiles = bibFiles.concat(found)
    yaml = pandoc.extractYAMLmetadata(text)
    yamlBibFiles = pandoc.getBibfilesFromYAML(yaml)
    if yamlBibFiles is not null
      bibFiles = bibFiles.concat(yamlBibFiles)
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
      filter = ""
      for key in atom.config.get("latexer.parameters_to_search_citations_by")
        filter += ct.get(key) + " "
      cites.push({
        title: ct.get("title"),
        key: ct.get("key"),
        author: ct.get("author"),
        filterKey: filter})
    cites
