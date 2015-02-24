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
    @swap_length = 750

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y
 
  animationComplete: =>
    console.log 'animation complete'
    @animating = false

  dropTo: (y,delay) ->
    @animating = true
    length = 1250
    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1 }
    drop_tween = new TWEEN.Tween( @tween_data )
             .to( { y: y }, length ) 
             .easing( TWEEN.Easing.Bounce.Out )
             .onUpdate( @tweenTick )
    drop_tween.onComplete( @animationComplete ).delay(delay).start()

  doSwap: (x,y,real=true,front=true) ->
    @animating = true
    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1 }
    if real
      @zoomTween(front).start()
      @realSwapTween(x,y).start()
    else
      @failedZoomTween(front).start()
      @failedSwapTween(x,y).start()


  zoomTween: (front=true) ->
    sc = if front then 0.25 else -0.25
    zoom_tween_start = new TWEEN.Tween( @tween_data )
             .to( { s: 1+sc }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )
    zoom_tween_end = new TWEEN.Tween( @tween_data )
             .to( { s: 1 }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )

    zoom_tween_start.chain zoom_tween_end

  realSwapTween: (x,y) ->
    new TWEEN.Tween( @tween_data )
             .to( { x: x, y: y }, @swap_length ) 
             .easing( TWEEN.Easing.Back.InOut )
             .onUpdate( @tweenTick )
             .onComplete( @animationComplete )

  failedSwapTween: (x,y) ->
    swap_start = new TWEEN.Tween( @tween_data )
             .to( { x: x, y: y }, @swap_length ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )

    swap_end = new TWEEN.Tween( @tween_data )
             .to( { x: @object.position.x, y: @object.position.y }, @swap_length ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )
             .onComplete( @animationComplete )
    swap_start.chain swap_end

  failedZoomTween: (front=true) ->
    sc = if front then 0.25 else -0.25
    z = []
    z[0] = new TWEEN.Tween( @tween_data )
             .to( { s: 1+sc }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )
    z[1] = new TWEEN.Tween( @tween_data )
             .to( { s: 1 }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )
    z[2] = new TWEEN.Tween( @tween_data )
             .to( { s: 1-sc }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.In )
             .onUpdate( @tweenTick )
    z[3] = new TWEEN.Tween( @tween_data )
             .to( { s: 1 }, @swap_length/2 ) 
             .easing( TWEEN.Easing.Circular.Out )
             .onUpdate( @tweenTick )
    z[0].chain z[1]
    z[1].chain z[2]
    z[2].chain z[3]
    z[0]

  tweenTick: =>
    @object.position.x = @tween_data.x
    @object.position.y = @tween_data.y
    @object.position.z = @tween_data.s
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