
class Logger
  constructor: ->
    @loglines = []

  log: (text) ->
    @loglines.push text
    document.getElementById('log').innerText = @loglines.join("\n")
