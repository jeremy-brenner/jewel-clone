class Score extends THREE.EventDispatcher
  constructor: ->
    @reset()
    @last_updated = 0

  worth: (cleared) ->
    (cleared-2) * cleared * (@chain+1) * 100

  updateChain: ->
    @chain += 1
    @max_chain = if @chain > @max_chain then @chain else @max_chain

  add: (cleared,x,y) ->
    @score += @worth(cleared)
    @cleared += cleared
    @updateChain()
    @dispatchEvent @scoreEvent(x,y)
    if @cleared >= @goal()
      @dispatchEvent @goalEvent(x,y)

  reset: ->
    @score = 0
    @cleared = 0
    @chain = 0
    @level = 0
    @max_chain = 0

  levelUp: ->
    @level += 1
    @cleared = 0
    @chain = 0
    @dispatchEvent @scoreEvent()

  goal: ->
    50+(@level-1)*5

  scoreEvent: (x,y) ->
    type: 'scorechange'
    level: @level
    score: @score
    cleared: @cleared
    chain: @chain   
    max_chain: @max_chain 
    goal: @goal()
    x: x
    y: y

  goalEvent: (x,y) ->
    type: 'goalreached'
    level: @level
    score: @score
    cleared: @cleared
    chain: @chain  
    max_chain: @max_chain
    goal: @goal()
    x: x
    y: y


window.GemCrusher ?= {}
GemCrusher.Score = Score