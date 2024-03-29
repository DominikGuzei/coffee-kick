jasmine.honeymoon =

  integrate: ->
    beforeEach -> @addMatchers jasmine.honeymoon.Matchers
    jasmine.honeymoon.Sandbox.overrideJasmineFunctions()

  Sandbox:

    originalBeforeEach: beforeEach
    originalIt: it

    create: (sandboxConfiguration={}) ->
      sandboxConfiguration.context ?= window
      sandboxConfiguration.useFakeTimers ?= false
      sandboxConfiguration.useFakeServer ?= false
      sandboxConfiguration.useFakeXMLHttpRequest ?= false

      context = sandboxConfiguration.context

      # don't override existing sandbox
      if context._sinonSandbox?
        if sandboxConfiguration.useFakeTimers
          context._sinonSandbox.useFakeTimers()
          context.clock = context._sinonSandbox.clock
          
        if sandboxConfiguration.useFakeServer
          context._sinonSandbox.useFakeServer()
          context.server = context._sinonSandbox.server
          
      else
        context._sinonSandbox = sinon.sandbox.create
          injectInto: context
          properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
          useFakeTimers: sandboxConfiguration.useFakeTimers
          useFakeServer: sandboxConfiguration.useFakeServer

    beforeEach: (sandboxConfiguration, customBeforeEachBlock) ->

      # no sandbox configuration provided
      if arguments.length is 1 then customBeforeEachBlock = arguments[0]

      decoratedBeforeEach = ->
        sandboxConfiguration.context = this
        jasmine.honeymoon.Sandbox.create sandboxConfiguration
        customBeforeEachBlock.call this

      jasmine.honeymoon.Sandbox.originalBeforeEach decoratedBeforeEach

    it: (specText, specFunction) ->

      decoratedSpecFunction = ->
        jasmine.honeymoon.Sandbox.create { context: this }
        specFunction.call this
        @_sinonSandbox.verifyAndRestore()

      jasmine.honeymoon.Sandbox.originalIt specText, decoratedSpecFunction

    overrideJasmineFunctions: ->
      window.beforeEach = jasmine.honeymoon.Sandbox.beforeEach
      window.it = jasmine.honeymoon.Sandbox.it

    restoreJasmineFunctions: ->
      window.beforeEach = jasmine.honeymoon.Sandbox.originalBeforeEach
      window.it = jasmine.honeymoon.Sandbox.originalIt


  Matchers:

    toHaveBeenCalled: ->
      if jasmine.isSpy @actual
        jasmine.Matchers.prototype.toHaveBeenCalled.call this
      else

        unless @actual.called? and @actual.displayName?
          throw "Error in toHaveBeenCalled: Wrong argument. Jasmine or Sinon spy needed."

        @message = ->
          [
            "Expected ##{@actual.displayName} to have been called at least once."
            "Expected ##{@actual.displayName} not to have been called."
          ]

        return this.actual.called
        
    toHaveBeenCalledTimes: (times) ->
      displayName = ""
      
      if jasmine.isSpy @actual
        displayName = @actual.callCount
        
      else
        unless @actual.callCount? and @actual.displayName?
          throw "Error in toHaveBeenCalled: Wrong argument. Jasmine or Sinon spy needed."

        displayName = @actual.displayName
        
      timesString = if times is 1 then "time" else "times"
      actualTimesString = if @actual.callCount is 1 then "time" else "times"
        
      @message = ->
        [
          "Expected ##{displayName} to have been called #{times} #{timesString} but it was called #{@actual.callCount} #{actualTimesString}."
          "Expected ##{displayName} not to have been called #{times} #{timesString} but it was."
        ]
        
      return @actual.callCount is times
    
    toHaveBeenCalledOnce: -> jasmine.honeymoon.Matchers.toHaveBeenCalledTimes.call this, 1
    toHaveBeenCalledTwice: -> jasmine.honeymoon.Matchers.toHaveBeenCalledTimes.call this, 2
    toHaveBeenCalledThrice: -> jasmine.honeymoon.Matchers.toHaveBeenCalledTimes.call this, 3

    toHaveBeenCalledWith: ->
      if jasmine.isSpy @actual
        jasmine.Matchers.prototype.toHaveBeenCalledWith.apply this, arguments
      else
        expectedArgs = jasmine.util.argsToArray arguments

        unless @actual.called
          @message = ->
            [
              "Expected ##{@actual.displayName} to have been called with #{jasmine.pp expectedArgs} but was never called."
              "Expected ##{@actual.displayName} not to have been called with #{jasmine.pp expectedArgs} but it was."
            ]

        else
          firstCallArgs = @actual.args[0][0]
          @message = ->
            [
              "Expected ##{@actual.displayName} to have been called with #{jasmine.pp expectedArgs} but it was called with #{jasmine.pp([firstCallArgs])}."
              "Expected ##{@actual.displayName} not to have been called with #{jasmine.pp expectedArgs} but it was called with #{jasmine.pp([firstCallArgs])}."
            ]

        return @actual.calledWith.apply @actual, arguments
        
jasmine.honeymoon.integrate()