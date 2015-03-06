class MultiplierDisplay
  constructor: ->
    @object = new THREE.Object3D()
    @max_age = 2000

    @fontcfg = 
      size: @fontSize()
      height: 10
      curveSegments: 3
      font: "droid sans"
      weight: "normal"
      style: "normal"
      bevelThickness: 1
      bevelSize: @fontSize()*0.125
      bevelEnabled: true
      extrudeMaterial: 1

    @buffer_font = new THREE.FontBufferGeometry(@fontcfg,'0123456789X')

    @materials = {}
    for color in ['red', 'teal', 'green', 'yellow']
      @materials[color] = new THREE.MeshPhongMaterial
        color: color
        ambient: color
        transparent: true
        opacity: 1.0
        shininess: 60

    @meshes = []

    GEMGAME.score.addEventListener 'scorechange', @scoreChange 

  fontSize: ->
    @cellSize()/2

  cellSize: ->
    GEMGAME.realWidth()/8

  color: (c) ->
    switch c
      when 2 then 'red'
      when 3 then 'teal'
      when 4 then 'green'
      else 'yellow'

  scoreChange: (e) =>
    if e.x and e.y and e.chain > 1
      mesh = @buffer_font.buildMesh( "#{e.chain}X", @materials[@color(e.chain)] )
      mesh.position.x = (e.x+0.125)*@cellSize()
      mesh.position.y = (e.y+1.25)*@cellSize()
      mesh.position.z = 100
      @object.add mesh
      @meshes.push 
        object: mesh
  
  update: (t) ->
    new_meshes = []
    for mesh in @meshes
      mesh.created_at ?= t
      diff = t-mesh.created_at
      perc = diff/@max_age
      mesh.object.scale.x = perc/2+1
      mesh.object.scale.y = perc/2+1
      mesh.object.rotation.z = -perc/2
      child.material.opacity = 1.5-perc for child in mesh.object.children
      if diff < @max_age
        new_meshes.push(mesh) 
      else 
        @object.remove mesh.object
    @meshes = new_meshes
   

