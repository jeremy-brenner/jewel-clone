class Cell
  constructor: (x,y,jewel) ->
    @x = x
    @y = y
    @jewel = jewel
    @jewel.position.x = x
    @jewel.position.y = y