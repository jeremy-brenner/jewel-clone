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
      current = @touchedCell(@main.input.move) or @selected
   
      if @selected is current
        @selected.highlite(t)
      else
        @ready_for_input = false
        @selected?.reset()
        @selected.swapJewel current

    if not @main.input.touching
      @ready_for_input = true
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
        @object.add( cell.jewel )

  buildCells: ->
    for x in [0...@h]
      for y in [0...@w]
        new Cell(x,y,@main)
