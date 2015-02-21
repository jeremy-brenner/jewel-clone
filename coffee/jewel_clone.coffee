
class JewelClone
  constructor: ->
    @logger = new Logger()
    @logger.log "logger started"
    @fps = new Fps()
    @deviceAlpha = 0
    @deviceBeta = 0
    @deviceGamma = 0
    @registerEvents()
    @logger.log 'init three'
    @initThree()
    @jewels = new Jewels()
    @jewels.onload = @jewelsLoaded

  registerEvents: ->
    window.addEventListener 'deviceorientation', @updateOrientation 

  realWidth: ->
    window.innerWidth * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio

  aspect: ->
    window.innerWidth / window.innerHeight

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()
 #   @camera = new THREE.PerspectiveCamera( 75, @aspect(), 0.1, 1000 )
    @camera = new THREE.OrthographicCamera( @realWidth() / - 2, @realWidth() / 2, @realHeight() / 2, @realHeight() / - 2, 0, 1000 )
    @camera.position.z = 100
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true
    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x555555 ) )
    @light = new THREE.DirectionalLight( 0xffffff, 1 )
    @light.position.z = 100
    @light.position.y = 10
    @scene.add( @light )


  jewelsLoaded: =>
    @logger.log "jewels loaded"
    d = 8
    s = @realWidth() / d
    @board = new Grid(d,d,@jewels)
    
    @board.object.scale.multiplyScalar(s)
    @board.object.position.x = -s*((d/2)-0.5)
    @board.object.position.y = -s*((d/2)-0.5)
    @scene.add( @board.object )
    @renderLoop(0)


  updateOrientation: (orientation) =>
    @deviceAlpha = orientation.alpha
    @deviceGamma = orientation.gamma
    @deviceBeta = orientation.beta

  updateLight: ->
    @light.position.x = @deviceGamma * -10
    @light.position.y = @deviceBeta * 10

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    @fps.update(t)
    @updateLight()
    @renderer.render( @scene, @camera )

    
