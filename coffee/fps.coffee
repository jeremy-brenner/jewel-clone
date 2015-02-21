
class Fps 
  constructor: ->
    @reset()
    @refresh = 1000
    @createDiv()

  createDiv: ->
    div = document.createElement "div"
    div.id = 'fps'
    document.getElementsByTagName('body')[0].appendChild div

  reset: ->
    @frames = 0
    @lasttime = 0

  update: (t) ->
    @frames++
    diff = t - @lasttime    
    if diff > @refresh 
      fps = Math.floor( @frames/(diff/100000) ) / 100
      document.getElementById('fps').innerText = "fps: #{fps}"
      @reset()
   