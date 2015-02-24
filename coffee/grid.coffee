class Grid
  constructor: (w,h,main) ->
    @w = w
    @h = h
    @main = main
    @margin = 0.25
    @cells = @buildCells()
    @object = new THREE.Object3D()
    @ready_for_input = true
    @buildBoard()

    @object.position.x = @boardScale(@margin)
    @object.position.y = @boardScale(@margin)

    @object.scale.multiplyScalar @boardScale()

  animating: ->
    for row in @cells
      for cell in row
        return true if cell.gem.animating
    false
    
  update: (t) ->
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
      @selected?.reset()

  validMove: (cell1, cell2) ->
    cell1 and cell2 and ( Math.abs(cell1.x-cell2.x) + Math.abs(cell1.y-cell2.y) ) <= 1

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

  buildBoard: ->
    for row in @cells
      for cell in row
        @object.add( cell.square )
        @object.add( cell.gem.object )

  buildCells: ->
    for x in [0...@h]
      for y in [0...@w]
        new Cell(x,y,@main)
