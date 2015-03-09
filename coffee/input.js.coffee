
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
    @scale_factor = 1

  bindEvents: ->
    window.addEventListener 'mousedown', @mouseDown
    window.addEventListener 'mousemove', @mouseMove
    window.addEventListener 'mouseup', @mouseUp
    window.addEventListener 'touchstart', @touchStart
    window.addEventListener 'touchend', @touchEnd
    window.addEventListener 'touchmove', @touchMove
    window.addEventListener 'deviceorientation', @updateOrientation 

  mouseDown: (e) =>
    if e.buttons is 1
      @startEvent e.clientX, e.clientY

  mouseMove: (e) =>
    if e.buttons is 1
      @moveEvent e.clientX, e.clientY

  mouseUp: (e) =>
    if e.buttons is 1
      @endEvent()

  touchStart: (e) =>
    @startEvent @touchX(e), @touchY(e)

  startEvent: (x,y) ->
    @touching = true
    @start.x = @scale x
    @start.y = @scale( @realHeight() - y )
    @move = 
      x: @start.x
      y: @start.y

    @dispatchEvent 
      type: 'touchstart'
      x: @start.x
      y: @start.y

  touchEnd: (e) =>
    @endEvent()

  endEvent: ->
    @touching = false
    @dispatchEvent 
      type: 'touchend'

  touchMove: (e) =>
    @moveEvent @touchX(e), @touchY(e)

  moveEvent: (x,y) ->
    @move.x = @scale x
    @move.y = @scale( @realHeight() - y )
    
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

  scale: (i) ->
    i*@scale_factor


window.GemCrusher ?= {}
GemCrusher.Input = Input