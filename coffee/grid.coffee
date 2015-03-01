class Grid
  constructor: (w,h) ->
    @w = w
    @h = h
    @margin = 0
    @footer = 1
    @cells = @buildCells()
    @object = new THREE.Object3D()
    @ready_for_input = true
    @board = @buildBoard()
    @object.add(@board)
    @object.position.x = @boardScale(@margin)
    @object.position.y = @boardScale(@margin+@footer)
    #GEMGAME.screen.realHeight()/2 - @boardScale(@h)/2
    @object.scale.multiplyScalar @boardScale()

  flatCells: ->
    Array.prototype.concat.apply([],@cells)

  doomedCells: ->
    cell for cell in @flatCells() when cell.gem?.doomed and cell.gem?.exploding isnt true

  emptyCells: ->
    cell for cell in @flatCells() when cell.gem is null

  dirtyCells: ->
    cell for cell in @flatCells() when cell.dirty

  animating: ->
    for cell in @flatCells()
      return true if cell.gem?.animating
    false

  clearDoomed: ->
    for cell,i in @doomedCells()
      cell.gem.explode(i*50)
      cell.gem = null

  checkDirty: ->
    cell.flagCleared() for cell in @dirtyCells()

  fillHoles: -> 
    @fillCell(cell) for cell in @emptyCells()

  fillCell: (cell) ->
    cell.dirty = true
    for y in [cell.y+1..@h]
      if y is @h
        cell.gem = GEMGAME.gem_factory.random()
        cell.gem.setX( cell.xPos() )
        cell.gem.setY( @h*2 )
        @object.add( cell.gem.object )
        cell.gem.dropTo cell.yPos(), 0, 0, 500
      else
        new_cell = @cells[cell.x][y]
        if new_cell.gem
          cell.gem = new_cell.gem
          new_cell.gem = null
          cell.gem.dropTo cell.yPos(), 0, 0, 500
          @fillCell(new_cell)
          break  

  update: (t) ->
    return if @animating()
    @clearDoomed()
    @fillHoles() while @emptyCells().length > 0
    if @dirtyCells().length > 0 
      @checkDirty()
    else
      GEMGAME.score.chain = 0

    if @ready_for_input and GEMGAME.input.touching
      @selected = @touchedCell(GEMGAME.input.start)
      current = @touchedCell(GEMGAME.input.move)
      return @stopInput() unless @validMove( @selected, current )

      if @selected is current
        @selected?.highlite(t)
      else
        @stopInput()
        @selected.swapGems current
  
    if not GEMGAME.input.touching and not @animating()
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
    GEMGAME.realHeight() - @boardScale(@h+@margin+@footer)

  touchedCell: (pos) ->
    x = Math.floor pos.x/@boardScale()-@margin
    y = @h - 1 - Math.floor (pos.y-@topOffset())/@boardScale()
    @cells[x]?[y]

  boardScale: (i=1)->
    GEMGAME.realWidth() / @w * i

  addGems: ->
    for row in @cells
      for cell in row
        loop
          cell.gem = GEMGAME.gem_factory.random()
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
        new Cell(x,y)

  show: ->
    cell.show() for cell in @flatCells()