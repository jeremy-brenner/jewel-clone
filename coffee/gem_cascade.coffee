class GemCascade
  constructor: (count) ->
    @count = count
    @object = new THREE.Object3D()
    @scale = GEMGAME.realWidth()/8
    @object.scale.multiplyScalar @scale
    @gems = @buildGems()
    @run = false

  buildGems: ->
    @buildGem() for i in [0...@count]

  buildGem: ->
    gem = GEMGAME.gem_factory.random()
    gem.setY( GEMGAME.realHeight()/GEMGAME.realWidth()*9)  
    @object.add( gem.object )
    gem.addEventListener 'animationcomplete', =>
      @drop(gem)
    gem

  drop: (gem) ->
    return unless @run
    scale = Math.random()
    time = 3000+5000*(1-scale)
    gem.setX( 8*Math.random() )
    gem.setY( GEMGAME.realHeight()/GEMGAME.realWidth()*9 )  
    gem.object.rotation.set Math.PI*2*Math.random(), Math.PI*2*Math.random(), Math.PI*2*Math.random()
    gem.object.scale.set(scale*1.5+0.2,scale*1.5+0.2,scale*1.5+0.2)
    gem.tumbleTo -1, 10000*Math.random(), scale*20-30, time
    
  start: ->
    return if @run
    @run = true
    @drop(gem) for gem in @gems
    @object.visible = true

  stop: ->
    @object.visible = false
    @run = false