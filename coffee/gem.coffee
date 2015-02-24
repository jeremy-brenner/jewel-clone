class Gem
  constructor: (def) ->
    @id = def.id
    @object = new THREE.Object3D()
    @mesh = new THREE.Mesh( def.geometry, def.material )
    @outline = new THREE.Mesh( def.geometry, def.outline )
    @outline.scale.multiplyScalar(1.125)
    @animating = false
    @object.add @mesh
    @object.add @outline

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y
 
  animationComplete: =>
    @animating = false

  doSwap: (x,y,real=true) ->
    @animating = true
    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1 }
    if real
      @tweens = @swapTweens(x,y)
      @tweens.zoom_tween.start()
      @tweens.swap_tween.onComplete( @animationComplete ).start()
    else
      t = @swapTweens(x,y)
      t2 = @swapTweens(@object.position.x,@object.position.y)
      @tweens = {
        zoom_tween: t.zoom_tween.chain(t2.zoom_tween).start()
        swap_tween: t.swap_tween.chain(t2.swap_tween).onComplete( @animationComplete ).start()
      }

  swapTweens: (x,y,front=true) ->
    length = 500
    sc = if front then 0.2 else -0.2

    swap_tween = new TWEEN.Tween( @tween_data )
             .to( { x: x, y: y }, length ) 
             .easing( TWEEN.Easing.Back.InOut )
             .onUpdate( @tweenTick )

    zoom_tween_start = new TWEEN.Tween( @tween_data )
             .to( { s: 1+sc }, length/2 ) 
             .easing( TWEEN.Easing.Quadratic.Out )
             .onUpdate( @tweenTick )
    zoom_tween_end = new TWEEN.Tween( @tween_data )
             .to( { s: 1 }, length/2 ) 
             .easing( TWEEN.Easing.Quadratic.In )
             .onUpdate( @tweenTick )
    {
      zoom_tween: zoom_tween_start.chain(zoom_tween_end)
      swap_tween: swap_tween
    }


  tweenTick: =>
    @object.position.x = @tween_data.x
    @object.position.y = @tween_data.y
    @object.position.z = @tween_data.s-1
    @object.scale.x = @tween_data.s
    @object.scale.y = @tween_data.s