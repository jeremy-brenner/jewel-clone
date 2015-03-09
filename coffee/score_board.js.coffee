class ScoreBoard
  constructor: ->
    @fontcfg = 
      size: @fontSize()
      height: 10
      curveSegments: 3
      font: "droid sans"
      weight: "normal"
      style: "normal"
      bevelThickness: 1
      bevelSize: 1
      bevelEnabled: true
      extrudeMaterial: 1

    @buffer_font = new THREE.FontBufferGeometry(@fontcfg,'0123456789/')

    @material = new THREE.MeshPhongMaterial
      color: 'yellow'
      ambient: 'yellow'
      shininess: 60
  
    @objects = {}
    @meshes = {}

    @buildObjects()
    GEMCRUSHER.score.addEventListener 'scorechange', @scoreChange

  fontSize: ->
    @height()*0.12

  baseX: ->
    -@width()/2

  baseY: ->
    -@height()/2

  hiddenX: ->
    -@width()/2

  shownX: ->
    @width()/2*1.125

  buildObjects: ->
    @object = new THREE.Object3D()
    @object.position.z = -90000
    @buildBackdrop()
    @object.position.x = @hiddenX()
    @object.position.y = GEMCRUSHER.base_width + @height()/2 + GEMCRUSHER.base_width/8*1.125

    for label,i in ['score','max_chain','cleared','level']
      text_label = label.split('_').join(' ')
      label_geom = new THREE.BufferGeometry().fromGeometry( new THREE.TextGeometry( text_label, @fontcfg ))
      label_mesh = new THREE.Mesh( label_geom,@material )
      label_mesh.position.x = @baseX() + @fontSize()*1.5
      label_mesh.position.y = @baseY() + @fontSize()*1.5*(i+1)
      @object.add label_mesh

      @objects[label] = new THREE.Object3D()
      @objects[label].position.x = @fontSize()*1.5
      @objects[label].position.y = @baseY() + @fontSize()*1.5*(i+1)
      @object.add @objects[label]

  

  width: ->
    GEMCRUSHER.base_width*0.5

  height: ->
    GEMCRUSHER.base_width*(4/15)

  buildBackdrop: ->
    mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.2

    geom = new THREE.PlaneBufferGeometry @width(), @height()
    @object.add new THREE.Mesh( geom, mat )  

    mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.5

    geom = new THREE.PlaneBufferGeometry @width()*0.9, @height()*0.9
    @object.add new THREE.Mesh( geom, mat )  

  scoreChange: (e) =>
    @updateNumber 'score', e.score 
    @updateNumber 'max_chain', e.max_chain
    @updateNumber 'cleared', "#{e.cleared} / #{e.goal}"
    @updateNumber 'level', e.level

  updateNumber: (type,num) ->
    @objects[type].remove( @meshes[type] ) if @meshes[type]
    @meshes[type] =  @buffer_font.buildMesh( num.toString(), @material )
    @objects[type].add @meshes[type]

  show: ->
    @animate @hiddenX(), @shownX()

  hide: ->
    @animate @shownX(), @hiddenX()

  animate: (startx,endx) ->
    @show_tween = { x: startx }
    to =  { x: endx }
    tween = new TWEEN.Tween( @show_tween )
                     .to( to, 1000 ) 
                     .easing( TWEEN.Easing.Linear.None )
                     .onUpdate( @showTweenTick )
    tween.start()   

  showTweenTick: =>
    @object.position.x = @show_tween.x

window.GemCrusher ?= {}
GemCrusher.ScoreBoard = ScoreBoard