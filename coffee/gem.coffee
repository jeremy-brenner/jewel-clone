class Gem
  constructor: (def,id) ->
    @id = id
    @def_id = def.id
    @object = new THREE.Object3D()
    @mesh = new THREE.Mesh( def.geometry, def.material )
    @outline = new THREE.Mesh( def.geometry, def.outline )
    @mesh.position.z = 2
    @outline.scale.multiplyScalar(1.125)
    @animating = false
    @object.add @mesh
    @object.add @outline
    @swap_length = 400

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y
 
  animationComplete: =>
    @object.position.z = 0
    @animating = false

  dropTo: (y,delay,z,length=1250) ->
    @animating = true
    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1, z: z }
    drop_tween = new TWEEN.Tween( @tween_data )
             .to( { y: y }, length ) 
             .easing( TWEEN.Easing.Bounce.Out )
             .onUpdate( @tweenTick )
    drop_tween.onComplete( @animationComplete ).delay(delay).start()

  doSwap: (x,y,real=true,front=true) ->
    @animating = true
    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1, z: 0 }
    if real
      @zoomTween(front).start()
      @realSwapTween(x,y).start()
    else
      @failedZoomTween(front).start()
      @failedSwapTween(x,y).start()

  swapStart: ->
    game_audio.play('woosh')

  zoomTween: (front=true) ->
    sc = if front then 1.5 else 0.5
    zoom_tween_start = new TWEEN.Tween( @tween_data )
             .to( { s: sc, z: 1-sc }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )
    zoom_tween_end = new TWEEN.Tween( @tween_data )
             .to( { s: 1, z: 0 }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )

    zoom_tween_start.chain zoom_tween_end

  realSwapTween: (x,y) ->
    new TWEEN.Tween( @tween_data )
             .to( { x: x, y: y }, @swap_length ) 
             .easing( TWEEN.Easing.Back.InOut )
             .onUpdate( @tweenTick )
             .onStart( @swapStart )
             .onComplete( @animationComplete )

  failedSwapTween: (x,y) ->
    swap_start = new TWEEN.Tween( @tween_data )
             .to( { x: x, y: y }, @swap_length/1.5 ) 
             .easing( TWEEN.Easing.Back.In )
             .onStart( @swapStart )
             .onUpdate( @tweenTick )

    swap_end = new TWEEN.Tween( @tween_data )
             .to( { x: @object.position.x, y: @object.position.y }, @swap_length/1.5 ) 
             .easing( TWEEN.Easing.Quadratic.InOut )
             .onStart( @swapStart )
             .onUpdate( @tweenTick )
             .onComplete( @animationComplete )
    swap_start.chain swap_end

  failedZoomTween: (front=true) ->
    sc = if front then 1.5 else 0.5

    a = new TWEEN.Tween( @tween_data )
             .to( { s: sc, z: sc-1 }, @swap_length/3 ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )
    b = new TWEEN.Tween( @tween_data )
             .to( { s: 1, z: 0 }, @swap_length/3 ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )
    c = new TWEEN.Tween( @tween_data )
             .to( { s: 2-sc, z: 1-sc }, @swap_length/3 ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )
    d = new TWEEN.Tween( @tween_data )
             .to( { s: 1, z: 0 }, @swap_length/3 ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )
    
    c.chain d
    b.chain c
    a.chain b

  tweenTick: =>
    @object.position.x = @tween_data.x
    @object.position.y = @tween_data.y
    @object.position.z = @tween_data.z
    @object.scale.x = @tween_data.s
    @object.scale.y = @tween_data.s

  highlite: (t) ->
    @object.rotation.z = Math.PI*2-t/400%Math.PI*2
    @object.scale.x = 1.25
    @object.scale.y = 1.25

  reset: -> 
    @object.rotation.z = 0    
    @object.scale.x = 1
    @object.scale.y = 1