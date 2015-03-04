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

    @material = new THREE.MeshPhongMaterial
      color: 'yellow'
      ambient: 'yellow'
      shininess: 60

    @outline_material = new THREE.MeshBasicMaterial
      color: 'black'  
      side: THREE.BackSide 
  
    @objects = {}
    @meshes = {}

    @buildObjects()
    GEMGAME.score.addEventListener 'scorechange', @scoreChange

  fontSize: ->
    @height()*0.12

  baseX: ->
    -@width()/2

  baseY: ->
    -@height()/2

  buildObjects: ->
    @object = new THREE.Object3D()
    @object.add @buildBackdrop()
    @object.position.x = @width()/2*1.125
    @object.position.y = GEMGAME.realWidth() + @height()/2 + GEMGAME.realWidth()/8*1.125
   
    @objects.score = new THREE.Object3D()
   # @objects.score.position.x = @baseX()
    @objects.score.position.y = @baseY() + @fontSize()*1.5
    @object.add @objects.score
    
    @objects.cleared = new THREE.Object3D()
   # @objects.cleared.position.x = @baseX()
    @objects.cleared.position.y = @baseY() + @fontSize()*1.5*2
    @object.add @objects.cleared

    @objects.level = new THREE.Object3D()
  #  @objects.level.position.x = @baseX()
    @objects.level.position.y = @baseY() + @fontSize()*1.5*3
    @object.add @objects.level

  width: ->
    GEMGAME.realWidth()*0.5

  height: ->
    GEMGAME.realWidth()*(4/15)

  buildBackdrop: ->
    mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.7

    geom = new THREE.PlaneBufferGeometry @width(), @height()
    new THREE.Mesh( geom, mat )  

  scoreChange: (e) =>
    @updateNumber 'score', e.score 
    @updateNumber 'cleared', e.cleared
    @updateNumber 'level', e.level

  updateNumber: (type,num) ->
    @objects[type].remove( @meshes[type] ) if @meshes[type]
    geom = new THREE.BufferGeometry().fromGeometry( new THREE.TextGeometry( num, @fontcfg ))
    @meshes[type] = new THREE.Mesh( geom,@material )
    @objects[type].add @meshes[type]


