
class JewelClone
  constructor: ->
    @logger = new Logger()
    @logger.log "logger started"
    @fps = new Fps()
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

  updateOrientation: (orientation) =>
    @deviceAlpha = orientation.alpha
    @deviceGamma = orientation.gamma
    @deviceBeta = orientation.beta

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera( 75, @aspect(), 0.1, 1000 )
    @renderer = new THREE.WebGLRenderer
      antialias: true
    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @deviceAlpha = null;
    @deviceGamma = null;
    @deviceBeta = null;
    @betaAxis = 'x'
    @gammaAxis = 'y'
    @betaAxisInversion = -1
    @gammaAxisInversion = -1

    @scene.add( new THREE.AmbientLight( 0x555555 ) )
    light = new THREE.DirectionalLight( 0xffffff, 1 )
    light.position.z = 3
    light.position.y = 1
    @scene.add( light )
    @camera.position.z = 3

  jewelsLoaded: =>
    @logger.log "jewels loaded"
    @scene.add( @jewels.objects[0].mesh )
    @renderLoop(0)

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    @fps.update(t)
    @renderer.render( @scene, @camera )

    
