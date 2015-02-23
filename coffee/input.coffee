class Input
  constructor: ->
    @touching = false
    @bindEvents()
    @start = 
      x: null
      y: null
    @move = 
      x: null
      y: null
    @orientation =
      alpha: 0
      beta: 0
      gamma: 0


  bindEvents: ->
    window.addEventListener 'touchstart', @touchStart
    window.addEventListener 'touchend', @touchEnd
    window.addEventListener 'touchmove', @touchMove
    window.addEventListener 'deviceorientation', @updateOrientation 

  debug: ->
    document.getElementById('input').innerText = """
      touching: #{@touching.toString()}
      start: #{@start.x}, #{@start.y}
      move: #{@move.x}, #{@move.y}
      alpha: #{@orientation.alpha}
      beta: #{@orientation.beta}
      gamma: #{@orientation.gamma}
    """

  touchStart: (e) =>
    @touching = true
    @start.x = e.touches[0].screenX * window.devicePixelRatio
    @start.y = e.touches[0].screenY * window.devicePixelRatio
    @debug()

  touchEnd: (e) =>
    @touching = false
    @debug()

  touchMove: (e) =>
    @move.x = e.touches[0].screenX * window.devicePixelRatio
    @move.y = e.touches[0].screenY * window.devicePixelRatio
    @debug()

  updateOrientation: (orientation) =>
    @orientation.alpha = orientation.alpha or 0
    @orientation.gamma = orientation.gamma or 0
    @orientation.beta = orientation.beta or 0 
    @debug()