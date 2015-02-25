class Score
  constructor: ->
    @score = 0
    @cleared = 0
    @chain = 0
    @longest_chain = 0

  worth: (cleared) ->
    (cleared-2) * cleared * (@chain+1)

  updateChain: ->
    @chain += 1
    @longest_chain = if @chain > @longest_chain then @chain else @longest_chain

  add: (cleared) ->
    @score += @worth()
    @cleared += cleared
    @updateChain()
