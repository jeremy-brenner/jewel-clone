
class Main
  constructor: ->
    @grid_width = 8
    @grid_height = 8
    @logger = new Logger()
    @logger.log "logger started"
    @fps = new Fps()
    @input = new Input()
    @logger.log 'init three'
    @initThree()
    @drawBackground()
    @gem_factory = new GemFactory()
    @gem_factory.onload = @gemsLoaded

  realWidth: ->
    window.innerWidth * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio

  aspect: ->
    window.innerWidth / window.innerHeight

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()

    @camera = new THREE.OrthographicCamera( 0, @realWidth(), @realHeight(), 0, 0, 5000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true

    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x666666 ) )
    @light = new THREE.DirectionalLight( 0xffffff, 1 )
    @light.position.z = 100
    @light.position.x = 60
    @light.position.y = 60
    @scene.add( @light )
    

  drawBackground: ->
    bg = new THREE.MeshLambertMaterial
      map: THREE.ImageUtils.loadTexture( 'img/wallpaper.png' ) 
    
    bgg = new THREE.PlaneBufferGeometry @realHeight(), @realHeight() 
    background = new THREE.Mesh( bgg, bg )
    background.position.x = @realWidth()/2
    background.position.y = @realHeight()/2
    background.position.z = -1000

    @scene.add( background )

  gemsLoaded: =>
    @logger.log "gems loaded"
    @grid = new Grid(@grid_width, @grid_height,@)
    @scene.add( @grid.object )
    @renderLoop(0)

  updateLight: ->
    @light.position.x = ( @input.orientation.gamma * -1 ) + 60
    @light.position.y = ( @input.orientation.beta ) + 60

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    TWEEN.update t

    @updateLight()
    @grid.update t
    @renderer.render( @scene, @camera )
    @fps.update t
    
