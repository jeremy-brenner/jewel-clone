
class Main
  constructor: ->
    @grid_width = 8
    @grid_height = 8
    @logger = new Logger()
    @logger.log "logger started"
    @fps = new Fps()
    @input = new Input()
    @deviceAlpha = 0
    @deviceBeta = 0
    @deviceGamma = 0
    @logger.log 'init three'
    @initThree()
    @drawBackground()
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

    @camera = new THREE.OrthographicCamera( 0, @realWidth(), @realHeight(), 0, 0, 5000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true
    @renderer.shadowMapEnabled = true
    @renderer.shadowMapType = THREE.PCFSoftShadowMap
    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x555555 ) )
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

  jewelsLoaded: =>
    @logger.log "jewels loaded"
    @grid = new Grid(@grid_width, @grid_height,@)
    @scene.add( @grid.object )
    @renderLoop(0)

  updateLight: ->
    @light.position.x = ( @input.orientation.gamma * -1 ) + 60
    @light.position.y = ( @input.orientation.beta ) + 60

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    @fps.update(t)
    @updateLight()
    @renderer.render( @scene, @camera )

    
