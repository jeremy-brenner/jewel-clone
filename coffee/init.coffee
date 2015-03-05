window.GEMGAME = null

document.addEventListener 'deviceready', -> 
  window.GEMGAME = new Main()
  window.GEMGAME.init()