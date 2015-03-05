class Score extends THREE.EventDispatcher
  constructor: ->
    @score = 0
    @cleared = 0
    @chain = 0
    @level = 0
    @max_chain = 0
    @last_updated = 0

  worth: (cleared) ->
    (cleared-2) * cleared * (@chain+1) * 100

  updateChain: ->
    @chain += 1
    @max_chain = if @chain > @max_chain then @chain else @max_chain

  add: (cleared) ->
    @score += @worth(cleared)
    @cleared += cleared
    @updateChain()
    @dispatchEvent @scoreEvent()
    if @cleared >= @goal()
      @dispatchEvent @goalEvent()

  levelUp: ->
    @level += 1
    @cleared = 0
    @chain = 0
    @dispatchEvent @scoreEvent()

  goal: ->
    50+(@level-1)*5

  scoreEvent: ->
    type: 'scorechange'
    level: @level
    score: @score
    cleared: @cleared
    chain: @chain   
    max_chain: @max_chain 
    goal: @goal()

  goalEvent: ->
    type: 'goalreached'
    level: @level
    score: @score
    cleared: @cleared
    chain: @chain  
    max_chain: @max_chain
    goal: @goal()

