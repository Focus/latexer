jsYaml = require 'js-yaml' # https://www.npmjs.com/package/js-yaml
pandoc = require '../lib/pandoc-citations'

describe "Detecting and auto-completing pandoc-style citations", ->

  beforeEach ->
    spyOn(pandoc, 'isPandocStyleCitation')
      .andCallThrough() #.andCallThrough is old Jasmine 1.3 syntax

  it "detects the beginning of a pandoc-style citation key", ->
    citeText = "[@"
    result = pandoc.isPandocStyleCitation(citeText)
    expect(pandoc.isPandocStyleCitation).toHaveBeenCalledWith(citeText)
    expect(result).toBe true

  it "detects the beginning of the Nth key in a citation", ->
    expect(pandoc.isPandocStyleCitation(
      "[@Fallows1997; @"
    )).toBe true
    expect(pandoc.isPandocStyleCitation(
      "[@Turing1944; see also @Church1936; @"))
      .toBe true
    expect(pandoc.isPandocStyleCitation(
      "[@Goldberg2014 et al.; @Forbus2014; @Finnegan; @Felber; @"))
      .toBe true
    expect(pandoc.isPandocStyleCitation(
      "[a claim supported by multiple empirical studies [@Elby2001; @Gauss1989; and also @"))
      .toBe true

  it "Recognizes when the user has NOT yet begun to type/edit a cite key", ->
    citeTexts = [ "[@Fallows1997; "
                , "[ @Richards2014;"
                , "[ @Gupta "
                , "[@Chemler2005 and others; @Suzuki1992; "
    ]
    citeTexts.map(
      (currentValue) ->
        expect(
          pandoc.isPandocStyleCitation(currentValue)
        ).toBe false # FALSE because the user isn't beginning a new cite key yet
        return
    )


describe "getting a bibfile from a YAML metadata block in (R)Markdown files", ->
  it "fails to find a bibfile if the document has no leading YAML block", ->
    fileText = 'This text has no leading YAML block'
    yaml = pandoc.extractYAMLmetadata(fileText)
    bibFile = pandoc.getBibfileFromYAML(yaml)
    expect(yaml).toBe undefined
    expect(bibFile).toBe undefined

  it "correctly gets the value of the `bibliography` key", ->
    fileText = """
               ---
               title: "Batman v. Superman: The Good Version"
               author:
                 - "Joel Coen"
                 - "Ethan Coen"
               bibliography: "batmanVsupermanButNotTheCrappyOne-References.bib"
               ...

               We open on Metropolis...
               """

    yaml = pandoc.extractYAMLmetadata(fileText)
    bibFile = pandoc.getBibfileFromYAML(yaml)
    metadata = jsYaml.safeLoad(yaml)
    expect(bibFile).toBe 'batmanVsupermanButNotTheCrappyOne-References.bib'
    expect(metadata.author[0]).toBe 'Joel Coen'
    expect(metadata.title).toBe 'Batman v. Superman: The Good Version'

  it "fails to find a bibfile if the YAML block exists but contains no `bibliography` field", ->
    fileText = """
               ---
               author: "Alan Turing"
               ...
               """
    yaml = pandoc.extractYAMLmetadata(fileText)
    bibFile = pandoc.getBibfileFromYAML(yaml)
    metadata = jsYaml.safeLoad(yaml)
    expect(metadata.author).toBe "Alan Turing"
    expect(bibFile).toBe undefined

  it "can handle multiple values for the bibliography key", ->
    fileText = """
               ---
               author:
                 - "Ada Lovelace"
                 - "Grace Murray Hopper"
                 - "Anita Borg"
               bibliography:
                 - bibfile0.bib
                 - bibfile1.bib
                 - bibfile2.bib
               ...
               """
    yaml = pandoc.extractYAMLmetadata(fileText)
    bibFile = pandoc.getBibfileFromYAML(yaml)
    metadata = jsYaml.safeLoad(yaml)
    expect(bibFile[1]).toBe 'bibfile1.bib'
    expect(bibFile[0]).toBe 'bibfile0.bib'
    expect(metadata.author[2]).toBe 'Anita Borg'
