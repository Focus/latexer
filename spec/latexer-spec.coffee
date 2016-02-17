Latexer = require '../lib/latexer'
LabelView = require '../lib/label-view'
CiteView = require '../lib/cite-view'
Citation = require '../lib/citation'
FindLabels = require '../lib/find-labels'
fs = require 'fs-plus'

describe "Latexer", ->

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

  describe "the views", ->
    [workspaceElement, editor] = []
    citeText = "\\bibliography{bibfile.bib}\\cite{"
    labelText = "\\label{value}\\ref{"
    bibText = "
    @{key0,
    title = {title0},
    author = {author0}
    }

    comments here

    @{key1,
    title = {title1},
    author = {author1}
    }
    "
    beforeEach ->
      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
      waitsFor ->
        workspaceElement
      runs ->
        jasmine.attachToDOM(workspaceElement)
      waitsForPromise ->
        atom.workspace.open("sample.tex")
      waitsFor ->
        editor = atom.workspace.getActiveTextEditor()
      waitsForPromise ->
        atom.packages.activatePackage("latexer")
      runs ->
        spyOn(FindLabels, "getAbsolutePath").andReturn("bibfile.bib")
        spyOn(fs, "readFileSync").andReturn(bibText)

    describe "typing \\ref{", ->
      it "shows the labels to select from", ->
        editor.setText labelText
        advanceClock(editor.getBuffer().getStoppedChangingDelay())
        labelElement = workspaceElement.querySelector('.label-view')
        expect(labelElement).toExist()
        displayedLabels = labelElement.querySelectorAll('li')
        expect(displayedLabels.length).toBe 1
        expect(displayedLabels[0].textContent).toBe "value"

    describe "typing \\cite{", ->
      it "show the bibliography", ->
        editor.setText citeText
        advanceClock(editor.getBuffer().getStoppedChangingDelay())
        expect(fs.readFileSync).toHaveBeenCalledWith("bibfile.bib")
        citeElement = workspaceElement.querySelector('.cite-view')
        expect(citeElement).toExist()
        displayedCites = citeElement.querySelectorAll('li')
        expect(displayedCites.length).toBe 2
        for cite, i in displayedCites
          info = cite.querySelectorAll("span")
          expect(info.length).toBe 2
          expect(info[0].textContent).toBe "title#{i}"
          expect(info[1].textContent).toBe "author#{i}"

  describe "typing \\begin{evironment} or \\[", ->
    [workspaceElement, editor] = []
    beforeEach ->
      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
      waitsFor ->
        workspaceElement
      runs ->
        jasmine.attachToDOM(workspaceElement)
      waitsForPromise ->
        atom.workspace.open("sample.tex")
      waitsFor ->
        editor = atom.workspace.getActiveTextEditor()
      waitsForPromise ->
        atom.packages.activatePackage("latexer")
    it "autocompletes the environment", ->
      editor.setText "\\begin{env}\n"
      advanceClock(editor.getBuffer().getStoppedChangingDelay())
      expect(editor.getText()).toBe "\\begin{env}\n\n\\end{env}"
      editor.setText "\\[\n"
      advanceClock(editor.getBuffer().getStoppedChangingDelay())
      expect(editor.getText()).toBe "\\[\n\n\\]"
    it "ignores comments", ->
      editor.setText "%\\begin{env}\n"
      advanceClock(editor.getBuffer().getStoppedChangingDelay())
      expect(editor.getText()).toBe "%\\begin{env}\n"
      editor.setText "%\\[\n"
      advanceClock(editor.getBuffer().getStoppedChangingDelay())
      expect(editor.getText()).toBe "%\\[\n"
    it "ignores extra backslashes for \\[", ->
      editor.setText "\\\\[\n"
      advanceClock(editor.getBuffer().getStoppedChangingDelay())
      expect(editor.getText()).toBe "\\\\[\n"
