window.GEMCRUSHER = null

init = ->
  window.GEMCRUSHER = new GemCrusher.Main()
  window.GEMCRUSHER.init()

document.addEventListener 'deviceready', init

if jQuery?
  jQuery init
    