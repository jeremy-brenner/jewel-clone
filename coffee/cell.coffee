class Cell
  constructor: (x,y,jewel) ->
    @x = x
    @y = y
    @jewel = jewel
    @jewel.position.x = x + 0.5
    @jewel.position.y = y + 0.5