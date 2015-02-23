class Cell
  constructor: (x,y,main) ->
    @x = x
    @y = y
    @main = main
    @getJewel()
    @buildSquare()

  getJewel: ->
    @jewel = @main.jewels.random()
    @jewel.position.x = @x+0.5
    @jewel.position.y = @y+0.5

  squareOpacity: ->
    if @y%2 isnt @x%2 then 0.2 else 0.5

  buildSquare: ->
    mat = new THREE.MeshBasicMaterial
      transparent: true
      opacity: @squareOpacity()
      color: 'gray'
    geom = new THREE.PlaneBufferGeometry 1, 1 
    @square = new THREE.Mesh geom,mat
    @square.position.x = @x+0.5
    @square.position.y = @y+0.5
