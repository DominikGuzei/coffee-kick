describe "Application", ->

  beforeEach -> @application = new Application()

  it "should be placeholder", ->
    (expect @application.isPlaceholder).toBe true

  it 'should not have any child elements', ->
    # custom matcher in spec_helper.coffee
    (expect @application.childElements).toBeEmpty()