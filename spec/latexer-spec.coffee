Latexer = require '../lib/latexer'
LabelView = require '../lib/label-view'
CiteView = require '../lib/cite-view'
Citation = require '../lib/citation'
FindLabels = require '../lib/find-labels'

describe "Latexer Parsers", ->

  describe "finding labels", ->
    it "gets the correct labels", ->
      text = "\\label{value0} some text \\label{value1} \\other{things} \\label{value2}"
      labels = FindLabels.getLabelsByText(text)
      for label, i in labels
        expect(label.label).toBe "value#{i}"

  describe "new citation is created", ->
    it "extracts the correct values", ->
      testCite = """
      @test {key,
      field0 = {vfield0},
      field1 = {vfield1},
      field2 = "vfield2",
      field3 = "vfield3"
      }
      """
      cite = new Citation
      cite.parse(testCite)
      expect(cite.get("key")).toBe "key"
      for i in [0,1,2,3]
        expect(cite.get("field#{i}")).toBe "vfield#{i}"

describe "Label View", ->
  [workspaceElement, editor, lv] = []

  labelText = "\\label{value}\\ref{"

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = null

    waitsForPromise ->
      atom.workspace.open("sample.tex")

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      activationPromise = atom.packages.activatePackage("latexer")
      editor.setText labelText
      lv = new LabelView
      lv.show(editor)

      jasmine.attachToDOM(workspaceElement)

    waitsForPromise ->
      activationPromise

  describe "typing \\ref{", ->
    it "shows the list with references", ->
      labelElement = workspaceElement.querySelector('.label-view')
      expect(labelElement).toExist()
      displayedLabels = labelElement.querySelectorAll('li')
      expect(displayedLabels.length).toBe 1
      expect(displayedLabels[0].textContent).toBe "value"
    it "pastes the label in", ->
      lv.confirmed({label:"value"})
      expect(editor.getText()).toBe "#{labelText}value"
