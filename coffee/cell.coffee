class Cell
  constructor: (x,y,main) ->
    @x = x
    @y = y
    @main = main
    @setJewel @main.jewels.random()
    @buildSquare()

  xPos: ->
    @x+0.5

  yPos: ->
    @y+0.5

  swapJewel: (cell) ->
    new_jewel = cell.jewel
    cell.tweenJewel @jewel
    @tweenJewel new_jewel,false

  tweenJewel: (jewel,front=true) ->
    @jewel = jewel
    length = 500
    sc = if front then 0.1 else -0.1

    @tween = { x: @jewel.position.x, y: @jewel.position.y, s: 1 }
    
    new TWEEN.Tween( @tween )
             .to( { x: @xPos(), y: @yPos() }, length ) 
             .easing( TWEEN.Easing.Back.InOut )
             .onUpdate( @tweenTick )
             .start()

    s1 = new TWEEN.Tween( @tween )
             .to( { s: 1+sc }, length/2 ) 
             .easing( TWEEN.Easing.Quadratic.Out )
             .onUpdate( @tweenTick )
    s2 = new TWEEN.Tween( @tween )
             .to( { s: 1 }, length/2 ) 
             .easing( TWEEN.Easing.Quadratic.In )
             .onUpdate( @tweenTick )

    s1.chain(s2).start()
             

  tweenTick: =>
    @jewel.position.x = @tween.x
    @jewel.position.y = @tween.y
    @jewel.position.z = @tween.s-1
    @jewel.scale.x = @tween.s
    @jewel.scale.y = @tween.s

  setJewel: (j) ->
    @jewel = j
    @jewel.position.x = @xPos()
    @jewel.position.y = @yPos()

  squareOpacity: ->
    if @y%2 isnt @x%2 then 0.2 else 0.5

  buildSquare: ->
    mat = new THREE.MeshBasicMaterial
      transparent: true
      opacity: @squareOpacity()
      color: 'gray'
    geom = new THREE.PlaneBufferGeometry 1, 1 
    @square = new THREE.Mesh geom,mat
    @square.position.x = @xPos()
    @square.position.y = @yPos()

  highlite: ->
    @jewel.rotation.z += 0.1
    @jewel.scale.x = 1.25
    @jewel.scale.y = 1.25

  reset: ->
    @jewel.rotation.z = 0    
    @jewel.scale.x = 1
    @jewel.scale.y = 1

