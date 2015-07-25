{CompositeDisposable} = require 'atom'
LabelView = require './label-view'
CiteView = require './cite-view'

module.exports =
  class LatexerHook
    beginRex: /\\begin{([^}]+)}/
    refRex: /\\(ref|eqref|cref){$/
    citeRex: /\\(cite|textcite|citet|citep|citet\*|citep\*)(\[[^\]]+\])?{$/
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
      return unless title? and title.match(/\.tex$/)
      @buffer = @editor.getBuffer()
      @disposableBuffer = @buffer.onDidStopChanging => @checkText()

    unsubscribeBuffer: ->
      @disposableBuffer?.dispose()
      @buffer = null

    checkText: ->
      pos = @editor.getCursorBufferPosition().toArray()
      line = @editor.getTextInBufferRange([[pos[0], 0], pos])
      if (match = line.match(@refRex))
        @lv.show(@editor)
      else if (match = line.match(@citeRex))
        @cv.show(@editor)
      #Check if the previous line contains a \begin{something} or \[.
      #If it does, try to find the closing item, and if that doesn't exist put it in.
      else if pos[0]>1
        previousLine = @editor.lineTextForBufferRow(pos[0]-1)
        if (match = @beginRex.exec(previousLine)) or (match = /\\\[/.exec(previousLine))
          lineCount = @editor.getLineCount()
          remainingText = @editor.getTextInBufferRange([[pos[0],0],[lineCount+1,0]])
          if match[0] is "\\["
            beginText = "\\["
            endText = "\\]"
          else
            beginText = "\\begin{#{match[1]}}"
            endText = "\\end{#{match[1]}}"
          remainingOnPrevLine = previousLine.substring(previousLine.indexOf(beginText))
          return if remainingOnPrevLine.indexOf(endText) isnt -1
          if (not remainingText?) or (remainingText.indexOf(endText) < 0) or ((remainingText.indexOf(beginText) < remainingText.indexOf(endText)) and (remainingText.indexOf(beginText) > 0))
            @editor.insertText "\n"
            @editor.insertText endText
            @editor.moveUp 1
