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

  flagCleared: ->
    if @horizontalMatches().length >= 3
      m.doomed = true for m in @horizontalMatches()
    if @verticalMatches().length >= 3
      m.doomed = true for m in @verticalMatches()

  swapGems: (cell) ->
    @new_gem = cell.gem
    cell.new_gem = @gem

    if @willClear() or cell.willClear()
      @new_gem.doSwap(@xPos(),@yPos(),true,false)
      cell.new_gem.doSwap(cell.xPos(),cell.yPos(),true,true)
      @commitNew()
      cell.commitNew()
      @flagCleared()
      cell.flagCleared()
    else
      @new_gem.doSwap(@xPos(),@yPos(),false,false)
      cell.new_gem.doSwap(cell.xPos(),cell.yPos(),false,true)
      @new_gem = null
      cell.new_gem = null

  matchGem: ->
    @new_gem or @gem

  horizontalMatches: () ->
    [@matchGem()].concat( @match( @matchGem().def_id, 'left' ) ).concat @match( @matchGem().def_id, 'right' )

  verticalMatches: () ->
    [@matchGem()].concat( @match( @matchGem().def_id, 'up' ) ).concat @match( @matchGem().def_id, 'down' ) 

  willClear: ->
    @horizontalMatches().length >= 3 or @verticalMatches().length >= 3

  match: (def_id,dir) ->
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

    if cell.matchGem().def_id == def_id
      [cell.matchGem()].concat cell.match(def_id,dir)
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
    @gem?.highlite(t)

  reset: ->
    @gem?.reset()


