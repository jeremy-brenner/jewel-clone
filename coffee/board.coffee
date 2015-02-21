class Grid
  constructor: (w,h,jewels) ->
    @w = w
    @h = h
    @jewels = jewels
    @cells = @buildCells()
    @object = new THREE.Object3D()
    for row in @cells
      for cell in row
        @object.add( cell.jewel )


  buildCells: ->
    for x in [0...@h]
      for y in [0...@w]
        new Cell(x,y,@jewels.random())