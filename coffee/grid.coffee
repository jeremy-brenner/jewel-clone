class Grid
  constructor: (w,h,main) ->
    @w = w
    @h = h
    @main = main
    @margin = 0.25
    @cells = @buildCells()
    @object = new THREE.Object3D()
    @ready_for_input = true
    @board = @buildBoard()
    @object.add(@board)
    @object.position.x = @boardScale(@margin)
    @object.position.y = @boardScale(@margin)

    @object.scale.multiplyScalar @boardScale()

  flatCells: ->
    Array.prototype.concat.apply([],@cells)

  doomedGems: ->
    cell.gem for cell in @flatCells() when cell.gem?.doomed

  animating: ->
    for cell in @flatCells()
      return true if cell.gem?.animating
    false

  clearDoomed: ->
    @object.remove( gem.object ) for gem in @doomedGems()

  update: (t) ->
    return if @animating()
    @clearDoomed()
    if @ready_for_input and @main.input.touching
      @selected = @touchedCell(@main.input.start)
      current = @touchedCell(@main.input.move)
      return @stopInput() unless @validMove( @selected, current )

      if @selected is current
        @selected?.highlite(t)
      else
        @stopInput()
        @selected.swapGems current
  
    if not @main.input.touching and not @animating()
      if @selected
        @selected.reset()
        @selected = null
      @ready_for_input = true

  validMove: (cell1, cell2) ->
    cell1 and cell1.gem and cell2 and cell2.gem and ( Math.abs(cell1.x-cell2.x) + Math.abs(cell1.y-cell2.y) ) <= 1

  stopInput: ->
    @ready_for_input = false
    @selected?.reset()  


  topOffset: ->
    @main.realHeight() - @boardScale(@h+@margin)

  touchedCell: (pos) ->
    x = Math.floor pos.x/@boardScale()-@margin
    y = @h - 1 - Math.floor (pos.y-@topOffset())/@boardScale()
    @cells[x]?[y]

  boardScale: (i=1)->
    @main.realWidth() / (@w+@margin*2) * i

  addGems: ->
    for row in @cells
      for cell in row
        loop
          cell.gem = @main.gem_factory.random()
          break unless cell.willClear()
        cell.gem.setX( cell.xPos() )
        cell.gem.setY( @h*2 )
        @object.add( cell.gem.object )
        cell.gem.dropTo cell.yPos(), 1000+cell.yPos()*50+cell.xPos()*10, -cell.yPos()

  buildBoard: ->
    board = new THREE.Object3D()
    board.position.z = -20*@h
    for cell in @flatCells()
      board.add( cell.square )
    board

  buildCells: ->
    for x in [0...@h]
      for y in [0...@w]
        new Cell(x,y,@main)
