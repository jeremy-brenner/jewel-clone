class Grid
  constructor: (w,h,main) ->
    @w = w
    @h = h
    @main = main
    @margin = 0.25
    @cells = @buildCells()
    @board = new THREE.Object3D()
    @object = new THREE.Object3D()
    @object.add @board
    @buildBoard()

    @object.position.x = @boardScale(@margin)
    @object.position.y = @boardScale(@margin)

    @object.scale.multiplyScalar @boardScale()


  boardScale: (i=1)->
    @main.realWidth() / (@w+@margin*2) * i

  buildBoard: ->
    for row in @cells
      for cell in row
        @board.add( cell.square )
        @object.add( cell.jewel )

  buildCells: ->
    for x in [0...@h]
      for y in [0...@w]
        new Cell(x,y,@main)
