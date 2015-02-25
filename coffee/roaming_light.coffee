class RoamingLight 
  constructor: (scale,input) ->
    @scale = scale
    @input = input
    @object = new THREE.DirectionalLight( 0xffffff, 1 )
    @object.position.z = scale/2
    @speed = 2500

  xPos: (t) ->
    Math.sin(t/@speed) * @scale

  yPos: (t) ->
    Math.cos(t/(@speed*2)) * @scale

  xOffset: ->
    @input.orientation.gamma * (Math.PI/180) * -1 * @scale

  yOffset: ->
    @input.orientation.beta * (Math.PI/180) * @scale

  update: (t) ->
    @object.position.x = @xPos(t)+@xOffset()
    @object.position.y = @yPos(t)+@yOffset()
