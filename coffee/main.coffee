
class Main
  constructor: ->
    @grid_width = 8
    @grid_height = 8
    @logger = new Logger(false)
    @logger.log "logger started"
    @fps = new Fps()
    @roaming_light = new RoamingLight(GEMGAME.screen.realWidth())
    @logger.log 'init three'
    @initThree()
    @grid = new Grid(@grid_width, @grid_height,@)
    @drawBackground()
    @scene.add( @grid.object )
    
    GEMGAME.gem_factory.onload = @gemsLoaded
    @renderLoop(0)

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()

    @camera = new THREE.OrthographicCamera( 0, GEMGAME.screen.realWidth(), GEMGAME.screen.realHeight(), 0, 0, 200000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true

    @renderer.setSize GEMGAME.screen.realWidth(), GEMGAME.screen.realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x666666 ) )

    @scene.add( @roaming_light.object )

  drawBackground: ->
    bg = new THREE.MeshLambertMaterial
      map: THREE.ImageUtils.loadTexture( 'img/wallpaper.png' ) 
    
    bgg = new THREE.PlaneBufferGeometry GEMGAME.screen.realHeight(), GEMGAME.screen.realHeight() 
    background = new THREE.Mesh( bgg, bg )
    background.position.x = GEMGAME.screen.realWidth()/2
    background.position.y = GEMGAME.screen.realHeight()/2
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
    
