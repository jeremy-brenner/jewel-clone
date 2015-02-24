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

  update: (t) ->
    if @ready_for_input and @main.input.touching 
      @selected = @touchedCell(@main.input.start)
      current = @touchedCell(@main.input.move)
      return @stopInput() unless @selected and current
      return @stopInput() if Math.abs(@selected.x-current.x) + Math.abs(@selected.y-current.y) > 1 #diagonal or multi-space moves

      if @selected is current
        @selected?.highlite(t)
      else
        @stopInput()
        @selected.swapGem current
        current.checkMatches()
        @selected.checkMatches()

    if not @main.input.touching
      if @selected
        @selected.reset()
        @selected = null
      @ready_for_input = true
      @selected?.reset()

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
