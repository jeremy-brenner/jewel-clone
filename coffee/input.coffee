class Input extends THREE.EventDispatcher
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

  touchStart: (e) =>
    @touching = true
    @start.x = @touchX(e)
    @start.y = @realHeight() - @touchY(e)
    @move = 
      x: @start.x
      y: @start.y

    @dispatchEvent 
      type: 'touchstart'
      x: @start.x
      y: @start.y

  touchEnd: (e) =>
    @touching = false
    @dispatchEvent 
      type: 'touchend'

  touchMove: (e) =>
    @move.x = @touchX(e)
    @move.y = @realHeight() - @touchY(e)
    
    @dispatchEvent 
      type: 'touchmove'
      x: @move.x
      y: @move.y

  updateOrientation: (orientation) =>
    @orientation.alpha = orientation.alpha or 0
    @orientation.gamma = orientation.gamma or 0
    @orientation.beta = orientation.beta or 0 

  touchX: (e) ->
    e.touches[0].screenX * window.devicePixelRatio

  touchY: (e) ->
    e.touches[0].screenY * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio