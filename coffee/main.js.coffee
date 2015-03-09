class Main extends THREE.EventDispatcher
  constructor: ->
    @grid_width = 8
    @grid_height = 8
    @base_width = 1000
    document.getElementById('closebutton').addEventListener('touchstart', @closeAbout )
    document.getElementById('closebutton').addEventListener('click', @closeAbout )

  init: ->
    @initThree()
    @input = new GemCrusher.Input()
    @input.scale_factor = 1/(@width()/1000)
    @score = new GemCrusher.Score()
    @score.addEventListener('goalreached', @goalReached )
    @gem_factory = new GemCrusher.GemFactory()
    @audio = new GemCrusher.AudioManager(['sounds/woosh.mp3','sounds/pop.mp3'])
    @roaming_light = new GemCrusher.RoamingLight(GEMCRUSHER.width())   
    @grid = new GemCrusher.Grid(@grid_width, @grid_height,@)
    @grid.addEventListener 'ready', @gridReady
    @grid.addEventListener 'levelcomplete', @nextLevel
    @grid.addEventListener 'gemsdropped', @gameOver

    @menu = new GemCrusher.Menu()
    @background = new GemCrusher.Background()
    @background.scale 1/@aspect()
    @progress_meter = new GemCrusher.ProgressMeter()
    @timer = new GemCrusher.Timer()
    @timer.addEventListener 'danger', =>
      @timeDanger()

    @timer.addEventListener 'end', =>
      @timesUp()
    
    @score_board = new GemCrusher.ScoreBoard()

    @multiplier_display = new GemCrusher.MultiplierDisplay()
    @scene.add @multiplier_display.object

    @scene.add( @score_board.object )
    @scene.add( @timer.object )
    @scene.add( @progress_meter.object )
    @scene.add( @menu.object )
    @scene.add( @roaming_light.object )
    @scene.add( @background.object )
    @scene.add( @grid.object )
    @scene.scale.x = @scale()
    @scene.scale.y = @scale()
    GEMCRUSHER.gem_factory.onload = @gemsLoaded
    @renderLoop(0)

  aspect: ->
    @width()/@height()

  scale: ->
    @width()/@base_width

  width: ->
    if @realAspect() > 0.7
      @realHeight() * 0.7
    else
      @realWidth()

  height: ->
    @realHeight()

  realWidth: ->
    window.innerWidth * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio

  realAspect: ->
    window.innerWidth / window.innerHeight

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()
    @camera = new THREE.OrthographicCamera( 0, @width(), @height(), 0, 0, 200000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true

    @renderer.setSize @width(), @height()
    document.body.appendChild @renderer.domElement 
    window.addEventListener 'resize', @resize     
    @scene.add( new THREE.AmbientLight( 0x666666 ) )

  resize: =>
    @renderer.setSize( @width(), @height() )
    @camera.left = 0
    @camera.right = @width()
    @camera.top = @height()
    @camera.bottom = 0
    @camera.updateProjectionMatrix()
    @scene.scale.x = @scale()
    @scene.scale.y = @scale()
    @input.scale_factor = 1/@scale()

  gemsLoaded: =>
    @menu.open 'main'

  showAbout: ->
    about = document.getElementById('about')
    about.style.fontSize = "#{@width()/23}px"
    about.style.lineHeight = "#{@width()/23*1.5}px"
    about.className += ' show'

  closeAbout: (e) =>
    document.getElementById('about').className = ''    
    e.stopPropagation()
    @menu.open('main')

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    TWEEN.update t
    @roaming_light.update t
    @grid.update t
    @timer.update t
    @multiplier_display.update t
    @renderer.render( @scene, @camera )
    
  gridReady: =>
    @timer.start()

  start: ->
    @score.reset()
    @grid.show()
    @grid.addGems()
    @progress_meter.show()
    @timer.show()
    @timer.setTime(60)
    @score.levelUp()
    @score_board.show()

  nextLevel: =>
    @score.levelUp()
    @timer.setTime(60)     
    @grid.addGems()

  goalReached: (e) =>
    @timer.stop()
    @grid.complete()

  timeDanger: ->
    @grid.shakeGems()

  gameOver: =>
    @grid.hide()
    @timer.hide()
    @timer.stop()
    @progress_meter.hide()
    @score_board.hide()
    @menu.open 'main'

  timesUp: ->
    @grid.dropGems()

window.GemCrusher ?= {}
GemCrusher.Main = Main