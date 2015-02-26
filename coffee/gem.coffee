class Gem
  constructor: (def,id) ->
    @id = id
    @def = def
    @def_id = def.id
    @object = new THREE.Object3D()
    @mesh = new THREE.Mesh( def.geometry, def.material )
    @outline = new THREE.Mesh( def.geometry, def.outline )
    @chunks = for x in [0..1]
      for y in [0..1]
        @buildChunk x,y

    @outline.scale.multiplyScalar(1.125)

    @animating = false
    @object.add @mesh
    @object.add @outline
    @swap_length = 400

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y

  buildChunk: (x,y) ->
    object = new THREE.Object3D()
    mesh = new THREE.Mesh( @def.chunk, @def.material )
    outline = new THREE.Mesh( @def.chunk, @def.outline )
    outline.scale.multiplyScalar(1.125)
    object.add mesh
    object.add outline
    object.rotation.set Math.PI*2*Math.random(), Math.PI*2*Math.random(), Math.PI*2*Math.random()
    object.position.z = 1
    object.position.x = (x-0.5)*0.125
    object.position.y = (y-0.5)*0.125
    object 

  explode: ->
    @object.remove @mesh
    @object.remove @outline
    for row,x in @chunks
      for chunk,y in row
        @object.add chunk
        @hurlChunk(x,y)

  hurlChunk: (cx,cy) ->
    td = { x: @chunks[cx][cy].position.x, y: @chunks[cx][cy].position.y, s: 1, o: @chunks[cx][cy] }
    ra = Math.PI*2*Math.random()
    rx = Math.sin(ra) * GEMGAME.main.grid_height*2
    ry = Math.cos(ra) * GEMGAME.main.grid_height*2


    @hurl_tweens ?= []
    @hurl_tweens.push td
    hurl_tween = new TWEEN.Tween( td )
      .to( { x: rx, y: ry, s: 5 }, 2000 ) 
       .easing( TWEEN.Easing.Linear.None )
       .onUpdate( @hurlTweenTick )
       .onComplete( @hurlTweenComplete )
    hurl_tween.start()

  hurlTweenTick: =>
    for tween in @hurl_tweens
      tween.o.rotation.x += tween.x-tween.o.position.x
      tween.o.rotation.y += tween.y-tween.o.position.y
      tween.o.position.x = tween.x
      tween.o.position.y = tween.y
      tween.o.scale.x = tween.s
      tween.o.scale.y = tween.s
      tween.o.scale.z = tween.s

  hurlTweenComplete: =>
    GEMGAME.main.grid.object.remove( @object )

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
    GEMGAME.audio.play('woosh')

  zoomTween: (front=true) ->
    sc = if front then 1.5 else 0.5
    zoom_tween_start = new TWEEN.Tween( @tween_data )
             .to( { s: sc, z: sc-1 }, @swap_length/2 ) 
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