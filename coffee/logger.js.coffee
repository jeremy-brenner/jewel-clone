
class Logger
  constructor: (enabled=true) ->
    @enabled = enabled
    @loglines = []

  log: (text) ->
    return unless @enabled
    @loglines.push text
    document.getElementById('log').innerText = @loglines.join("\n")


window.GemCrusher ?= {}
GemCrusher.Logger = Logger