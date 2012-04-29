beforeEach ->
  @addMatchers
    toBeEmpty: -> @actual.length == 0