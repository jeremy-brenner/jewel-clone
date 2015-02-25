
class Main
  constructor: ->
    @grid_width = 8
    @grid_height = 8
    @logger = new Logger(false)
    @logger.log "logger started"
    @fps = new Fps()
    @input = new Input()
    @roaming_light = new RoamingLight( @realWidth(), @input)
    @logger.log 'init three'
    @initThree()
    @score = new Score()
    @grid = new Grid(@grid_width, @grid_height,@)
    @drawBackground()
    @scene.add( @grid.object )
    @gem_factory = new GemFactory()
    @gem_factory.onload = @gemsLoaded
    @renderLoop(0)

  realWidth: ->
    window.innerWidth * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio

  aspect: ->
    window.innerWidth / window.innerHeight

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()

    @camera = new THREE.OrthographicCamera( 0, @realWidth(), @realHeight(), 0, 0, 200000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true

    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x666666 ) )

    @scene.add( @roaming_light.object )

  drawBackground: ->
    bg = new THREE.MeshLambertMaterial
      map: THREE.ImageUtils.loadTexture( 'img/wallpaper.png' ) 
    
    bgg = new THREE.PlaneBufferGeometry @realHeight(), @realHeight() 
    background = new THREE.Mesh( bgg, bg )
    background.position.x = @realWidth()/2
    background.position.y = @realHeight()/2
    background.position.z = -100000

    @scene.add( background )

  gemsLoaded: =>
    @logger.log "gems loaded"
    @grid.addGems()

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    TWEEN.update t

    @roaming_light.update t
    @grid.update t
    @renderer.render( @scene, @camera )
    @fps.update t
    
