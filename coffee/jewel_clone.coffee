
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
    @camera = new THREE.OrthographicCamera( @realWidth() / - 2, @realWidth() / 2, @realHeight() / 2, @realHeight() / - 2, -100, 1000 )
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
    top_offset = ( @realHeight() - @realWidth() ) / 2
    offset = -s*((d/2)-0.5)

    @board = new Grid(d,d,@jewels)
    
    @board.object.scale.multiplyScalar(s)
    @board.object.position.x = offset
    @board.object.position.y = offset - top_offset
    @scene.add( @board.object )
    @renderLoop(0)

  updateLight: ->
    @light.position.x = @input.orientation.gamma * -5
    @light.position.y = @input.orientation.beta * 5

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    @fps.update(t)
    @updateLight()
    @renderer.render( @scene, @camera )

    
