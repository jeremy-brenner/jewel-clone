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
    super

  bindEvents: ->
    window.addEventListener 'touchstart', @touchStart
    window.addEventListener 'touchend', @touchEnd
    window.addEventListener 'touchmove', @touchMove
    window.addEventListener 'deviceorientation', @updateOrientation 

  touchStart: (e) =>
    @touching = true
    @start.x = e.touches[0].screenX * window.devicePixelRatio
    @start.y = e.touches[0].screenY * window.devicePixelRatio
    @move = 
      x: @start.x
      y: @start.y

  touchEnd: (e) =>
    @touching = false

  touchMove: (e) =>
    @move.x = e.touches[0].screenX * window.devicePixelRatio
    @move.y = e.touches[0].screenY * window.devicePixelRatio

  updateOrientation: (orientation) =>
    @orientation.alpha = orientation.alpha or 0
    @orientation.gamma = orientation.gamma or 0
    @orientation.beta = orientation.beta or 0 