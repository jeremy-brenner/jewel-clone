class Gem extends THREE.EventDispatcher
  constructor: (def,id) ->
    @id = id
    @def = def
    @def_id = def.id
    @object = new THREE.Object3D()
    @mesh = new THREE.Mesh( def.geometry, def.material )
    @outline = new THREE.Mesh( def.geometry, def.outline )
    @chunks = ( @buildChunk() for i in [0..3] )

    @outline.scale.multiplyScalar(1.125)
    @outline.position.z = -0.05
    @animating = false
    @object.add @mesh
    @object.add @outline
    @swap_length = 400

  setX: (x) ->
    @object.position.x = x

  setY: (y) ->
    @object.position.y = y

  buildChunk: ->
    object = new THREE.Object3D()
    mesh = new THREE.Mesh( @def.chunk, @def.material )
    outline = new THREE.Mesh( @def.chunk, @def.outline )
    outline.scale.multiplyScalar(1.125)
    object.add mesh
    object.add outline
    object.rotation.set Math.PI*2*Math.random(), Math.PI*2*Math.random(), Math.PI*2*Math.random()
    object.position.z = -1
    object 

  explode: (delay=0) ->
    @object.add(chunk) for chunk in @chunks
    @hurlChunks(delay)

  removeGem: ->
    @object.remove @mesh    
    @object.remove @outline    

  hurlStart: =>
    @removeGem()
    chunk.position.z = 1 for chunk in @chunks
    GEMGAME.audio.play('pop')

  hurlChunks: (delay) ->

    @hurl_tween = { 
      x0: @chunks[0].position.x, 
      y0: @chunks[0].position.y, 
      x1: @chunks[1].position.x, 
      y1: @chunks[1].position.y, 
      x2: @chunks[2].position.x, 
      y2: @chunks[2].position.y, 
      x3: @chunks[3].position.x, 
      y3: @chunks[3].position.y, 
      s: 1 
    }

    d = ( @randomDest() for chunk in @chunks )
    th =  { 
      x0: d[0].x
      y0: d[0].y 
      x1: d[1].x 
      y1: d[1].y 
      x2: d[2].x 
      y2: d[2].y 
      x3: d[3].x 
      y3: d[3].y 
      s: 6 
    }

    hurl_tween = new TWEEN.Tween( @hurl_tween )
      .to( th, 1500 ) 
       .easing( TWEEN.Easing.Linear.None )
       .onStart( @hurlStart )
       .onUpdate( @hurlTweenTick )
       .onComplete( @hurlTweenComplete )
       .delay(delay)
    hurl_tween.start()

  randomDest: ->
    ra = Math.PI*2*Math.random()
    rx = Math.sin(ra) * GEMGAME.grid_height*(1+Math.random())
    ry = Math.cos(ra) * GEMGAME.grid_height*(1+Math.random())
    { x: rx, y: ry }

  hurlTweenTick: =>
    for i in [0..3]
      @chunks[i].rotation.x += @hurl_tween["x#{i}"]-@chunks[i].position.x
      @chunks[i].rotation.y += @hurl_tween["y#{i}"]-@chunks[i].position.y
      @chunks[i].position.x = @hurl_tween["x#{i}"]
      @chunks[i].position.y = @hurl_tween["y#{i}"]
      @chunks[i].scale.x = @hurl_tween.s
      @chunks[i].scale.y = @hurl_tween.s
      @chunks[i].scale.z = @hurl_tween.s

  hurlTweenComplete: =>
    GEMGAME.grid.object.remove( @object )

  animationComplete: =>
    @object.position.z = 0
    @updateShakeOrigin() if @shake_data
    @animating = false
    @dispatchEvent
      type: 'animationcomplete'
  
  randomAngle: ->
    Math.random()*Math.PI*2

  shake: ->
    return if @shake_data
    @shake_data = 
      original_x: @object.position.x
      original_y: @object.position.y
      x: @object.position.x
      y: @object.position.y

    @doShake()

  updateShakeOrigin: ->
    @shake_tween.stop()
    @shake_data = null
    @shake()

  doShake: ->
    a = @randomAngle()
    to = 
      x: @shake_data.original_x+Math.cos(a)/32
      y: @shake_data.original_y+Math.sin(a)/32

    @shake_tween = new TWEEN.Tween( @shake_data )
              .to( to, 50 ) 
              .easing( TWEEN.Easing.Linear.None )
              .onComplete( @shakeDone )
              .onUpdate( @shakeTweenTick )
    @shake_tween.start()
  
  shakeDone: =>
    @doShake()

  shakeTweenTick: =>
    return if @animating
    @object.position.x = @shake_data.x
    @object.position.y = @shake_data.y

  dropToDoom: ->
    @addEventListener 'animationcomplete', @removeGem
    @dropTo -5, Math.random()*1000, -@object.position.y

  dropTo: (y,delay,z,length=1250) ->
    @animating = true
    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1, z: z }
    drop_tween = new TWEEN.Tween( @tween_data )
             .to( { y: y }, length ) 
             .easing( TWEEN.Easing.Bounce.Out )
             .onUpdate( @tweenTick )
    drop_tween.onComplete( @animationComplete ).delay(delay).start()

  tumbleTo: (y,delay,z,length=1250) ->
    @animating = true
    @object.position.z = z
    @tumble_data = { y: @object.position.y }
    drop_tween = new TWEEN.Tween( @tumble_data )
             .to( { y: y }, length ) 
             .easing( TWEEN.Easing.Linear.None )
             .onUpdate( @tumbleTweenTick )
    drop_tween.onComplete( @animationComplete ).delay(delay).start()

  tumbleTweenTick: =>
    @object.position.y = @tumble_data.y
    @object.rotation.x += 0.01
    @object.rotation.y += 0.01
    @object.rotation.z += 0.01

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

  flyAway: ->
    @animating = true
    fly_time = 2000

    @tween_data = { x: @object.position.x, y: @object.position.y, s: 1, z: 0, spin: 0 }
  
    vx = @object.position.x-4
    vy = @object.position.y-4
    dist = Math.sqrt(Math.pow(Math.abs(vx),2)+Math.pow(Math.abs(vy),2))
    a = Math.atan2(vx,vy)
    
    mult = dist/5
    
    to = 
      x: @object.position.x + Math.sin(a) * GEMGAME.grid_height*1.5 
      y: @object.position.y + Math.cos(a) * GEMGAME.grid_height*1.5 
   
    fly_tween = new TWEEN.Tween( @tween_data )
                         .to( to, fly_time ) 
                         .easing( TWEEN.Easing.Back.In )
                         .onUpdate( @tweenTick )
                         .onComplete( @animationComplete )
    fly_tween2 = new TWEEN.Tween( @tween_data )
                         .to( { s: 2, spin: 5 }, fly_time ) 
                         .easing( TWEEN.Easing.Linear.None )
                        

    fly_tween2.delay((mult)*4000).start()
    fly_tween.delay((mult)*4000).start()

  tweenTick: =>
    @object.position.x = @tween_data.x
    @object.position.y = @tween_data.y
    @object.position.z = @tween_data.z
    @object.scale.x = @tween_data.s
    @object.scale.y = @tween_data.s
    if @tween_data.spin
      @object.rotation.z = @tween_data.spin
      @object.rotation.x = @tween_data.spin
      @object.rotation.y = @tween_data.spin

  highlite: (t) ->
    @object.rotation.z = Math.PI*2-t/400%Math.PI*2
    @object.scale.x = 1.25
    @object.scale.y = 1.25

  reset: -> 
    @object.rotation.z = 0    
    @object.scale.x = 1
    @object.scale.y = 1