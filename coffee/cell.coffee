class Cell
  constructor: (x,y) ->
    @x = x
    @y = y
    @buildSquare()

  xPos: ->
    @x+0.5

  yPos: ->
    @y+0.5

  commitNew: ->
    @gem = @new_gem
    @new_gem = null

  hasSomeHope: (matches) ->
    doomed = true
    doomed = doomed and match.doomed for match in matches 
    not doomed

  flagCleared: ->
    if @horizontalMatches().length >= 3 and @hasSomeHope(@horizontalMatches())
      GEMGAME.score.add @horizontalMatches().length, @x, @y
      m.doomed = true for m in @horizontalMatches()
    if @verticalMatches().length >= 3 and @hasSomeHope(@verticalMatches())
      GEMGAME.score.add @verticalMatches().length, @x, @y
      m.doomed = true for m in @verticalMatches()
    @dirty = false

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
        GEMGAME.grid.cells[@x-1]?[@y]
      when 'right'
        GEMGAME.grid.cells[@x+1]?[@y]
      when 'up'
        GEMGAME.grid.cells[@x]?[@y+1]
      when 'down'
        GEMGAME.grid.cells[@x]?[@y-1]

    return [] unless cell

    if cell.matchGem()?.def_id == def_id
      [cell.matchGem()].concat cell.match(def_id,dir)
    else 
      []

  squareOpacity: ->
    if @y%2 isnt @x%2 then 0.2 else 0.5

  squareAxis: ->
    if @y%2 isnt @x%2 then 'x' else 'y'

  hide: ->
    @animate 0, Math.PI/2

  show: ->
    @animate Math.PI/2, 0

  animate: (startR, endR) ->
    @tween_data = { r: startR }
    show_tween = new TWEEN.Tween( @tween_data )
             .to( { r: endR }, 1000 ) 
             .easing( TWEEN.Easing.Quartic.In )
             .onUpdate( @tweenTick )
    show_tween.start() 

  tweenTick: =>
    @square.rotation[@squareAxis()] = @tween_data.r 

  buildSquare: ->
    mat = new THREE.MeshBasicMaterial
      transparent: true
      opacity: @squareOpacity()
      color: 'gray'
    geom = new THREE.PlaneBufferGeometry 1, 1 
    @square = new THREE.Mesh geom,mat
    @square.position.x = @xPos()
    @square.position.y = @yPos()
    @square.rotation[@squareAxis()] = Math.PI/2

  highlite: (t) ->
    @gem?.highlite(t)

  reset: ->
    @gem?.reset()
