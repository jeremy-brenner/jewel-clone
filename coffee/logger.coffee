
class Logger
  constructor: ->
    @loglines = []
    div = document.createElement "div"
    div.id = 'log'
    document.getElementsByTagName('body')[0].appendChild div

  log: (text) ->
    @loglines.push text
    document.getElementById('log').innerText = @loglines.join("\n")
