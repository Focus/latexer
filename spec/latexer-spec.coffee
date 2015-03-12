Latexer = require '../lib/latexer'
LabelView = require '../lib/label-view'
CiteView = require '../lib/cite-view'

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
        expect(workspaceElement.querySelector('.latexer')).toExist()

        latexerElement = workspaceElement.querySelector('.latexer')
        expect(latexerElement).toExist()

        latexerPanel = atom.workspace.panelForItem(latexerElement)
        expect(latexerPanel.isVisible()).toBe true
        lv.cancel()
        expect(latexerPanel.isVisible()).toBe false
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
