class Cell
  constructor: (x,y,main) ->
    @x = x
    @y = y
    @main = main
    @buildSquare()

  xPos: ->
    @x+0.5

  yPos: ->
    @y+0.5

  commitNew: ->
    @gem = @new_gem
    @new_gem = null

  swapGems: (cell) ->
    @new_gem = cell.gem
    cell.new_gem = @gem

    if @willClear() or cell.willClear()
      @new_gem.doSwap(@xPos(),@yPos())
      cell.new_gem.doSwap(cell.xPos(),cell.yPos())
      @commitNew()
      cell.commitNew()
    else
      @new_gem.doSwap(@xPos(),@yPos(),false)
      cell.new_gem.doSwap(cell.xPos(),cell.yPos(),false)
      @new_gem = null
      cell.new_gem = null

  horizontalMatches: () ->
    [@new_gem].concat @match( @new_gem.id, 'left' ).concat @match( @new_gem.id, 'right' )

  verticalMatches: () ->
    [@new_gem].concat @match( @new_gem.id, 'up' ).concat @match( @new_gem.id, 'down' ) 

  willClear: ->
    @horizontalMatches().length >= 3 or @verticalMatches().length >= 3

  match: (id,dir) ->
    cell = switch dir
      when 'left'
        @main.grid.cells[@x-1]?[@y]
      when 'right'
        @main.grid.cells[@x+1]?[@y]
      when 'up'
        @main.grid.cells[@x]?[@y+1]
      when 'down'
        @main.grid.cells[@x]?[@y-1]

    return [] unless cell

    gem = cell.new_gem or cell.gem
      
    if gem.id == id
      [gem].concat cell.match(id,dir)  
    else 
      [] 

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
    @gem?.object.rotation.z = Math.PI*2-t/400%Math.PI*2
    @gem?.object.scale.x = 1.25
    @gem?.object.scale.y = 1.25

  reset: ->
    @gem?.object.rotation.z = 0    
    @gem?.object.scale.x = 1
    @gem?.object.scale.y = 1

