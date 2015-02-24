class Gem
  constructor: (def) ->
    @id = def.id
    @object = new THREE.Object3D()
    @mesh = new THREE.Mesh( def.geometry, def.material )
    @outline = new THREE.Mesh( def.geometry, def.outline )
    @outline.scale.multiplyScalar(1.125)

    @object.add @mesh
    @object.add @outline

  destroy: ->
    if @tweens
      t.stop() for t in @tweens
    @object.position.z = 99999

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y

  swapTo: (x,y,front=true) ->
    length = 500
    sc = if front then 0.2 else -0.2

    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1 }
    
    s = new TWEEN.Tween( @tween_data )
             .to( { x: x, y: y }, length ) 
             .easing( TWEEN.Easing.Back.InOut )
             .onUpdate( @tweenTick )
             .start()

    s1 = new TWEEN.Tween( @tween_data )
             .to( { s: 1+sc }, length/2 ) 
             .easing( TWEEN.Easing.Quadratic.Out )
             .onUpdate( @tweenTick )
    s2 = new TWEEN.Tween( @tween_data )
             .to( { s: 1 }, length/2 ) 
             .easing( TWEEN.Easing.Quadratic.In )
             .onUpdate( @tweenTick )

    s1.chain(s2).start()
    @tweens = [s,s1,s2]

  tweenTick: =>
    @object.position.x = @tween_data.x
    @object.position.y = @tween_data.y
    @object.position.z = @tween_data.s-1
    @object.scale.x = @tween_data.s
    @object.scale.y = @tween_data.s