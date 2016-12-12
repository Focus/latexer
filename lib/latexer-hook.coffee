{CompositeDisposable} = require 'atom'
LabelView = require './label-view'
CiteView = require './cite-view'
pandoc = require './pandoc-citations'

module.exports =
  class LatexerHook
    beginRex: /\\begin{([^}]+)}/
    mathRex: /(\\+)\[/
    refRex: /\\(\w*ref({|{[^}]+,)|[cC](page)?refrange({[^,}]*})?{)$/
    citeRex: /\\\w*(cite|citet|citep|citet\*|citep\*)(\[[^\]]+\])?({|{[^}]+,)$/
    constructor: (@editor) ->
      @disposables = new CompositeDisposable
      @disposables.add @editor.onDidChangeTitle => @subscribeBuffer()
      @disposables.add @editor.onDidChangePath => @subscribeBuffer()
      @disposables.add @editor.onDidSave => @subscribeBuffer()

      @disposables.add @editor.onDidDestroy(@destroy.bind(this))
      @subscribeBuffer()
      @lv = new LabelView
      @cv = new CiteView

    destroy: ->
      @unsubscribeBuffer()
      @disposables.dispose()
      @lv?.hide()
      @cv?.hide()


    subscribeBuffer: ->
      @unsubscribeBuffer()
      return unless @editor?
      title = @editor?.getTitle()

      return unless title? and (
        title.match(/\.tex$/) or
        title.match(/\.md$/) or # also match Markdown
        title.match(/\.Rmd$/)   #   and RMarkdown files
        title.match(/\.[rs]nw$/) # Knitr/Sweeve
      )
      @buffer = @editor.getBuffer()
      @disposableBuffer = @buffer.onDidStopChanging => @editorHook()

    unsubscribeBuffer: ->
      @disposableBuffer?.dispose()
      @buffer = null

    refCiteCheck: (editor, refOpt, citeOpt, pandocCiteOpt) ->
      cursor = editor.getCursorBufferPosition()
      line = editor.getTextInBufferRange(
        [
          [cursor.row, 0],
          [cursor.row, cursor.column]
        ]
      )
      if refOpt and (match = line.match(@refRex))
        @lv.show(editor)
      if citeOpt and (match = line.match(@citeRex))
        @cv.show(editor)
      if pandocCiteOpt and pandoc.isPandocStyleCitation(line)
        @cv.show(editor)

    environmentCheck: (editor)->
      pos = editor.getCursorBufferPosition().toArray()
      return if pos[0] <= 0
      previousLine = editor.lineTextForBufferRow(pos[0]-1)
      if (match = @beginRex.exec(previousLine))
        beginText = "\\begin{#{match[1]}}"
        endText = "\\end{#{match[1]}}"
        beginTextRegify = beginText.replace(/([()[{*+.$^\\|?])/g, "\\$1")
        beginTextRex = new RegExp beginTextRegify, "gm"
        endTextRegify = endText.replace(/([()[{*+.$^\\|?])/g, "\\$1")
        endTextRex = new RegExp endTextRegify, "gm"
      else if (match = @mathRex.exec(previousLine)) and match[1].length % 2
        beginText = "\\["
        endText = "\\]"
        beginTextRex = new RegExp "\\\\\\[", "gm"
        endTextRex = new RegExp "\\\\\\]", "gm"
      else
        return
      lineCount = editor.getLineCount()
      preText= editor.getTextInBufferRange([[0,0], [pos[0],0]]).replace /%.+$/gm,""
      remainingText = editor.getTextInBufferRange([[pos[0],0],[lineCount+1,0]]).replace /%.+$/gm,""
      balanceBefore = (preText.match(beginTextRex)||[]).length - (preText.match(endTextRex)||[]).length
      balanceAfter = (remainingText.match(beginTextRex)||[]).length - (remainingText.match(endTextRex)||[]).length
      return if balanceBefore + balanceAfter < 1
      posBefore = editor.getCursorBufferPosition()
      editor.insertText endText
      editor.moveUp 1
      editor.moveToEndOfLine()
      editor.insertText "\n"

    editorHook: (editor = @editor)->
      envOpt = atom.config.get "latexer.autocomplete_environments"
      refOpt = atom.config.get "latexer.autocomplete_references"
      citeOpt = atom.config.get "latexer.autocomplete_citations"
      pandocCiteOpt = atom.config.get "latexer.autocomplete_pandoc_markdown_citations"
      @refCiteCheck(editor, refOpt, citeOpt, pandocCiteOpt) if refOpt or citeOpt or pandocCiteOpt
      @environmentCheck(editor) if envOpt
