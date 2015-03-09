class GemCascade
  constructor: (count) ->
    @count = count
    @minimum_falltime = 3000
    @maximum_falltime = 8000
    @object = new THREE.Object3D()
    @object.scale.multiplyScalar @scale()
    @gems = @buildGems()
    @run = false
    GEMCRUSHER.addEventListener 'resize', @resize

  scale: ->
    GEMCRUSHER.base_width / GEMCRUSHER.grid_width

  buildGems: ->
    @buildGem() for i in [0...@count]

  buildGem: ->
    gem = GEMCRUSHER.gem_factory.random()
    gem.setY( GEMCRUSHER.height()/GEMCRUSHER.width()*9)  
    gem.addEventListener 'animationcomplete', =>
      @dropLoop(gem)
    gem

  dropLoop: (gem,delay=false) ->
    if @run
      @animate(gem,delay)
    else
      @object.remove gem.object
  
  animate: (gem,delay=false) ->
    scale = Math.random()
    time = @minimum_falltime+(@maximum_falltime-@minimum_falltime)*(1-scale)
    delay = if delay then delay else 1000*Math.random()
    gem.setX( 8*Math.random() )
    gem.setY( GEMCRUSHER.height()/GEMCRUSHER.width()*9 )  
    gem.object.rotation.set Math.PI*2*Math.random(), Math.PI*2*Math.random(), Math.PI*2*Math.random()
    gem.object.scale.set(scale*1.5+0.2,scale*1.5+0.2,scale*1.5+0.2)
    gem.tumbleTo -1, delay, scale*20-30, time
    
  start: ->
    return if @run
    @run = true
    for gem,i in @gems
      @object.add gem.object
      @dropLoop(gem,i*(@maximum_falltime/@gems.length)) 
    @object.visible = true

  stop: ->
    @object.visible = false
    @run = false

window.GemCrusher ?= {}
GemCrusher.GemCascade = GemCascade