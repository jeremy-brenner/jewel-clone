
class JewelClone
  constructor: ->
    @logger = new Logger()
    @logger.log "logger started"
    @fps = new Fps()
    @input = new Input()
    @deviceAlpha = 0
    @deviceBeta = 0
    @deviceGamma = 0
    @logger.log 'init three'
    @initThree()
    @jewels = new Jewels()
    @jewels.onload = @jewelsLoaded

  realWidth: ->
    window.innerWidth * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio

  aspect: ->
    window.innerWidth / window.innerHeight

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()

    @camera = new THREE.OrthographicCamera( 0, @realWidth(), @realHeight(), 0, 0, 1000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true
    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x333333 ) )
    @light = new THREE.DirectionalLight( 0xffffff, 1 )
    @light.position.z = 100
    @light.position.x = 30
    @light.position.y = 30
    @scene.add( @light )


  jewelsLoaded: =>
    @logger.log "jewels loaded"
    d = 8
    s = @realWidth() / d

    @board = new Grid(d,d,@jewels)
    @board.object.scale.multiplyScalar(s)

    @scene.add( @board.object )
    @renderLoop(0)

  updateLight: ->
    @light.position.x = ( @input.orientation.gamma * -1 ) + 30
    @light.position.y = ( @input.orientation.beta ) + 30

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    @fps.update(t)
    @updateLight()
    @renderer.render( @scene, @camera )

    
