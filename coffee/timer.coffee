class Timer
  constructor: () ->
    @time = 0
    @start_time = null
    @fontcfg = 
      size: @height()*0.5
      height: 10
      curveSegments: 3
      font: "droid sans"
      weight: "normal"
      style: "normal"
      bevelThickness: 10
      bevelSize: 5
      bevelEnabled: true
      extrudeMaterial: 1

    @material = new THREE.MeshPhongMaterial
      color: 'yellow'
      ambient: 'yellow'
      shininess: 60

    @outline_material = new THREE.MeshBasicMaterial
      color: 'black'  
      side: THREE.BackSide 

    @digits = [@buildDigits(),@buildDigits()]
    @buildObject()

  width: ->
    GEMGAME.realWidth()/2.5

  height: ->
    @width()/1.5

  digitColor: ->
    switch
      when @remaining() > 30 then 'green'
      when @remaining() > 5 then 'yellow'
      else 'red'

  updateClock: ->
    for digit,i in @remainingDigits()
      d.visible = false for k,d of @digits[i]
      @digits[i][digit].visible = true
      @digits[i][digit].children[0].material.color.setStyle @digitColor()
      @digits[i][digit].children[0].material.ambient.setStyle @digitColor()

  buildDigits: ->
    digits = {}
    for d in [0..9]
      digits[d] = @buildDigit(d)
    digits

  buildDigit: (d) ->
    os=1.125
    object = new THREE.Object3D()
    geom = new THREE.BufferGeometry().fromGeometry( new THREE.TextGeometry( d, @fontcfg ))
    geom.computeBoundingBox()
    w=geom.boundingBox.max.x-geom.boundingBox.min.x
    h=geom.boundingBox.max.y-geom.boundingBox.min.y
    wd = w*os-w
    hd = h*os-h
    mesh = new THREE.Mesh( geom,@material )
    mesh.position.x = wd/2
    mesh.position.y = hd/2
    mesh.position.z = 50
    outline_mesh = new THREE.Mesh( geom,@outline_material )
    outline_mesh.position.z = 25
    outline_mesh.scale.multiplyScalar os
    outline_mesh.geometry.computeBoundingBox()
    object.add mesh
    object.add outline_mesh
    object.visible = false
    object.position.x = -w/2
    object.position.y = -h/2
    object

  buildObject: ->
    @object = new THREE.Object3D()
    backdrop = @buildBackdrop()
    @object.add backdrop
    @cells = for i in [0..1]
      cell = @buildCell()
      cell.position.x = -@width()/4 + @width()/2*i
      cell.add(digit) for k,digit of @digits[i]
      @object.add cell
      cell

    @object.position.z = -90000
    @object.position.x = @hiddenX()
    @object.position.y = GEMGAME.realWidth() + @height()/2 + GEMGAME.realWidth()/8*1.125
  
  hiddenX: ->
    GEMGAME.realWidth() + @width()/2

  shownX: ->
    GEMGAME.realWidth() - @width()/2*1.125

  buildCell: ->
    object = new THREE.Object3D()
    mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.5

    geom = new THREE.PlaneBufferGeometry @width()/2*0.875, @height()*0.875
    mesh = new THREE.Mesh( geom, mat )      
    object.add mesh
    object

  buildBackdrop: ->
    mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.2

    geom = new THREE.PlaneBufferGeometry @width(), @height()
    new THREE.Mesh( geom, mat )  

  start: ->
    @start_time = @updated_at
    @last_remaining = -1

  elapsed: ->
    Math.floor( (@updated_at-@start_time)/1000 )

  remaining: ->
    @time-@elapsed()
  
  remainingDigits: ->
    r = @remaining().toString().split('')
    if r.length is 1
      ['0',r[0]]
    else
      r

  show: ->
    @object.position.x = @shownX()

  show: ->
    @show_tween = { x: @hiddenX() }
    to =  { x: @shownX() }
    tween = new TWEEN.Tween( @show_tween )
                     .to( to, 1000 ) 
                     .easing( TWEEN.Easing.Linear.None )
                     .onUpdate( @showTweenTick )
    tween.start()

  showTweenTick: =>
    @object.position.x = @show_tween.x


  setTime: (time) ->
    @time = time

  update: (t) ->
    @updated_at = t
    return if @start_time is null
    if @last_remaining isnt @remaining() and @remaining() >= 0
      @updateClock()
      @last_remaining = @remaining()