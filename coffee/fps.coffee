
class Fps 
  constructor: ->
    @refresh = 1000
    @frames = 0
    @lasttime = 0

  timeDiff: (t) ->
    t - @lasttime  

  update: (t) ->
    @frames++   
    if @timeDiff(t) > @refresh 
      fps = Math.floor( @frames/(@timeDiff(t)/100000) ) / 100
      document.getElementById('fps').innerText = "fps: #{fps}"
      @frames = 0
      @lasttime = t
   