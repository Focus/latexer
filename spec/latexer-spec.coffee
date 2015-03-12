Latexer = require '../lib/latexer'
LabelView = require '../lib/label-view'
CiteView = require '../lib/cite-view'
Citation = require '../lib/citation'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Latexer", ->
  [workspaceElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise -> atom.packages.activatePackage('latexer')

  describe "when the label view is triggers", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.latexer')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      lv = new LabelView

      runs ->
        expect(workspaceElement.querySelector('.latexer-view')).toExist()

        latexerElement = workspaceElement.querySelector('.latexer')
        expect(latexerElement).toExist()

        latexerPanel = atom.workspace.panelForItem(latexerElement)
        expect(latexerPanel.isVisible()).toBe true
        lv.cancel()
        expect(latexerPanel.isVisible()).toBe false


  describe "when a new citation is added", ->
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
###
    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.latexer')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'latexer:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        latexerElement = workspaceElement.querySelector('.latexer')
        expect(latexerElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'latexer:toggle'
        expect(latexerElement).not.toBeVisible()
###
