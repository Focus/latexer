LabelView = require './label-view'
CiteView = require './cite-view'
{TextEditor, CompositeDisposable} = require 'atom'

module.exports = Latexer =
  view: null
  editor: null
  observe: null
  editorChange: null
  cv: null
  lv: null
  beginRex: /\\begin{([^}]+)}/
  refRex: /\\(ref|eqref|cite|textcite){$/
  activate: ->
    lv = new LabelView
    cv = new CiteView
    atom.workspace.observeTextEditors (editor) =>
      title = editor?.getTitle()
      return unless title? and title.match(/\.tex$/)
      @editor = editor
      editor.onDidStopChanging () =>
        pos = @editor.getCursorBufferPosition().toArray()
        line = @editor.getTextInBufferRange([[pos[0], 0], pos])
        if (match = line.match(@refRex))
          lv.show(@editor) if match[1] is "ref" or match[1] is "eqref"
          cv.show(@editor) if match[1] is "cite" or match[1] is "textcite"
        #Check if the previous line contains a \beging{something} or \[.
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
            if (not remainingText?) or (remainingText.indexOf(endText) < 0) or ((remainingText.indexOf(beginText) < remainingText.indexOf(endText)) and (remainingText.indexOf(beginText) > 0))
              @editor.insertText "\n"
              @editor.insertText endText
              @editor.moveUp 1            

  deactivate: ->
    @observe.dispose()
    @editorChange.dispose()
    @view.destroy()

  serialize: ->
    latexerViewState: @latexerView.serialize()
