
class Main
  constructor: ->
    @grid_width = 8
    @grid_height = 8
    document.getElementById('closebutton').addEventListener('touchstart', @closeAbout )

  init: ->
    @initThree()
    @input = new Input()
    @score = new Score()
    @score.addEventListener('goalreached', @goalReached )
    @gem_factory = new GemFactory()
    @audio = new AudioManager(['sounds/woosh.mp3','sounds/pop.mp3'])
    @roaming_light = new RoamingLight(GEMGAME.realWidth())   
    @grid = new Grid(@grid_width, @grid_height,@)
    @menu = new Menu()
    @background = new Background()
    @progress_meter = new ProgressMeter()

    @scene.add( @progress_meter.object )
    @scene.add( @menu.object )
    @scene.add( @roaming_light.object )
    @scene.add( @background.object )
    @scene.add( @grid.object )

    GEMGAME.gem_factory.onload = @gemsLoaded
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

    @camera = new THREE.OrthographicCamera( 0, GEMGAME.realWidth(), GEMGAME.realHeight(), 0, 0, 200000 )

    @camera.position.z = 500
    @camera.updateProjectionMatrix()
    @renderer = new THREE.WebGLRenderer
      antialias: true

    @renderer.setSize GEMGAME.realWidth(), GEMGAME.realHeight()
    document.body.appendChild @renderer.domElement 

    @scene.add( new THREE.AmbientLight( 0x666666 ) )


  gemsLoaded: =>
    @menu.open 'main'

  showAbout: ->
    about = document.getElementById('about')
    about.style.fontSize = "#{@realWidth()/25}px"
    about.className += ' show'

  closeAbout: (e) =>
    document.getElementById('about').className = ''    
    e.stopPropagation()
    @menu.open('main')

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    TWEEN.update t
    GEMGAME.score.update t
    @roaming_light.update t
    @grid.update t
    @renderer.render( @scene, @camera )
    
  start: ->
    @grid.show()
    @grid.addGems()
    @score.setGoal(100)
    @progress_meter.show()
    @progress_meter.setGoal(100)

  goalReached: (e) =>
    @score.reset()