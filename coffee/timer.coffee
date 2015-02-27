class Timer
  constructor: (length,scale,w) ->
    @started = false
    @scale = scale
    @length = length
    @warning_seconds = 15
    @danger_seconds = 5
    @w = w
    @buildObject()

  buildObject: ->
    @object = new THREE.Object3D()
    @object.scale.x = @scale
    @object.scale.y = @scale
    @object.scale.z = @scale
    @object.position.x = @w/2*@scale
    @object.position.y = 0.5*@scale
    @object.rotation.z = Math.PI/2
    geometry = new THREE.CylinderGeometry( 0.25, 0.25, @w-0.5, 4 )
    material = new THREE.MeshPhongMaterial
      color: 'teal'
      ambient: 'teal'
      shininess: 60

    @cylinder = new THREE.Mesh( geometry, material )
    @object.add @cylinder    

  start: ->
    @started = true

  update: (t) ->
    return unless @started
    @start_time ?= t
    elapsed = (t-@start_time) / 1000
    remaining = @length - elapsed

    if remaining < @danger_seconds
      @cylinder.material.color.setStyle "red"
      @cylinder.material.ambient.setStyle "red"      
    else if remaining < @warning_seconds
      @cylinder.material.color.setStyle "yellow"
      @cylinder.material.ambient.setStyle "yellow"  
    if remaining >= 0 
      perc = remaining / @length
      @cylinder.scale.y = perc
      @cylinder.position.y = (@w-0.5)/2 * (1-perc)

   
    