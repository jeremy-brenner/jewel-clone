window.GEMGAME = {}

document.addEventListener 'deviceready', -> 
  GEMGAME.input = new Input()
  GEMGAME.screen = new Screen()
  GEMGAME.score = new Score()
  GEMGAME.gem_factory = new GemFactory()
  GEMGAME.audio = new AudioManager(['sounds/woosh.mp3','sounds/pop.mp3'])
  GEMGAME.main = new Main() 