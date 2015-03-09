class ProgressMeter
  constructor: () ->
    @cleared = 0
    @goal = 0
    @width = GEMCRUSHER.base_width/8
    @length = GEMCRUSHER.base_width-@width/2
    @buildObject()
    GEMCRUSHER.score.addEventListener('scorechange', @scoreChange )

  scoreChange: (e) =>
    @cleared = e.cleared
    @goal = e.goal
    @resizeBar()

  perc: ->
    switch
      when @cleared/@goal is 0 then 0.0001
      when @cleared/@goal > 1 then 1
      else @cleared/@goal

  show: ->
    @animate -@width/2, @width/2

  hide: ->
    @animate @width/2, -@width/2

  animate: (starty,endy) ->
    @show_tween = { y: starty }
    to =  { y: endy }
    tween = new TWEEN.Tween( @show_tween )
                     .to( to, 1000 ) 
                     .easing( TWEEN.Easing.Linear.None )
                     .onUpdate( @showTweenTick )
    tween.start()  

  showTweenTick: =>
    @object.position.y = @show_tween.y

  resizeBar: ->
    @tween_data = { scale: @cylinder.scale.y, position: @cylinder.position.y }
    tween = new TWEEN.Tween( @tween_data )
                     .to( { scale: @perc(), position: @posY() } , 500 ) 
                     .easing( TWEEN.Easing.Linear.None )
                     .onUpdate( @tweenTick )
    tween.start()

  tweenTick: =>
    @cylinder.scale.y = @tween_data.scale
    @cylinder.position.y = @tween_data.position
    if @tween_data.scale == 1
      @cylinder.material.color.setStyle "yellow"
      @cylinder.material.ambient.setStyle "yellow"  
    else 
      @cylinder.material.color.setStyle "teal"
      @cylinder.material.ambient.setStyle "teal"  
      
  posY: ->
    @length/2-@length*@perc()/2
   
  buildObject: ->
    @object = new THREE.Object3D()
    @object.position.x = GEMCRUSHER.base_width/2
    @object.position.y = -@width/2
    @object.rotation.z = Math.PI/2

    geometry = new THREE.CylinderGeometry( @width/4, @width/4, @length, 4 )
    material = new THREE.MeshPhongMaterial
      color: 'teal'
      ambient: 'teal'
      shininess: 60

    @cylinder = new THREE.Mesh( geometry, material )  
    @object.add @cylinder

    cyl_hole_mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.5

    cyl_hole_geom = new THREE.PlaneBufferGeometry @width/2, @length 
    cyl_hole = new THREE.Mesh( cyl_hole_geom, cyl_hole_mat )  
    cyl_hole.position.z = -1
    @object.add cyl_hole

    cyl_outline_mat = new THREE.MeshBasicMaterial
      color: 'grey'
      transparent: true
      opacity: 0.2

    cyl_outline_geom = new THREE.PlaneBufferGeometry @width, GEMCRUSHER.base_width
    cyl_outline = new THREE.Mesh( cyl_outline_geom, cyl_outline_mat )  
    cyl_outline.position.z = -1
    @object.add cyl_outline     

window.GemCrusher ?= {}
GemCrusher.ProgressMeter = ProgressMeter