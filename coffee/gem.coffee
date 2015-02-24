class Gem
  constructor: (def) ->
    @object = new THREE.Object3D()
    @mesh = new THREE.Mesh( def.geometry, def.material )
    @outline = new THREE.Mesh( def.geometry, def.outline )
    @outline.scale.multiplyScalar(1.125)

    @object.add @mesh
    @object.add @outline

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y

  swapTo: (x,y,front=true) ->
    length = 500
    sc = if front then 0.1 else -0.1

    @tween = { x: @object.position.x, y: @object.position.y, s: 1 }
    
    new TWEEN.Tween( @tween )
             .to( { x: x, y: y }, length ) 
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
    @object.position.x = @tween.x
    @object.position.y = @tween.y
    @object.position.z = @tween.s-1
    @object.scale.x = @tween.s
    @object.scale.y = @tween.s