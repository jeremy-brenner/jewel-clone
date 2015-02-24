class Cell
  constructor: (x,y,main) ->
    @x = x
    @y = y
    @main = main
    @gem = @main.gem_factory.random()
    @gem.setX @xPos()
    @gem.setY @yPos()
    @buildSquare()

  xPos: ->
    @x+0.5

  yPos: ->
    @y+0.5

  checkMatches: ->
    h = [@gem].concat @match( 'left' ).concat @match( 'right' )
    v = [@gem].concat @match('up' ).concat @match( 'down' ) 
    if h.length >= 3
      g.destroy() for g in h
    if v.length >= 3
      g.destroy() for g in v

  match: (dir) ->
    cell = switch dir
      when 'left'
        @main.grid.cells[@x-1]?[@y]
      when 'right'
        @main.grid.cells[@x+1]?[@y]
      when 'up'
        @main.grid.cells[@x]?[@y+1]
      when 'down'
        @main.grid.cells[@x]?[@y-1]

    if cell?.gem.id == @gem.id
      [cell.gem].concat cell.match(dir)  
    else 
      [] 

  swapGem: (cell) ->
    new_gem = cell.gem
    cell.gem = @gem
    @gem = new_gem

    @gem.swapTo @xPos(), @yPos(), false 
    cell.gem.swapTo cell.xPos(), cell.yPos()

  squareOpacity: ->
    if @y%2 isnt @x%2 then 0.2 else 0.5

  buildSquare: ->
    mat = new THREE.MeshBasicMaterial
      transparent: true
      opacity: @squareOpacity()
      color: 'gray'
    geom = new THREE.PlaneBufferGeometry 1, 1 
    @square = new THREE.Mesh geom,mat
    @square.position.x = @xPos()
    @square.position.y = @yPos()

  highlite: (t) ->
    @gem.object.rotation.z = Math.PI*2-t/400%Math.PI*2
    @gem.object.scale.x = 1.25
    @gem.object.scale.y = 1.25

  reset: ->
    @gem.object.rotation.z = 0    
    @gem.object.scale.x = 1
    @gem.object.scale.y = 1

