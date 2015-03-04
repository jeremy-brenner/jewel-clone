class Score extends THREE.EventDispatcher
  constructor: ->
    @score = 0
    @cleared = 0
    @chain = 0
    @goal = 0
    @level = 1
    @longest_chain = 0
    @last_updated = 0

  setGoal: (goal) ->
    @goal = goal
    @dispatchEvent @scoreEvent()
    
  worth: (cleared) ->
    (cleared-2) * cleared * (@chain+1) * 100

  updateChain: ->
    @chain += 1
    @longest_chain = if @chain > @longest_chain then @chain else @longest_chain

  add: (cleared) ->
    @score += @worth(cleared)
    @cleared += cleared
    @updateChain()
    @dispatchEvent @scoreEvent()
    if @cleared >= @goal
      @dispatchEvent @goalEvent()

  levelUp: ->
    @level += 1
    @cleared = 0
    @chain = 0
    @dispatchEvent @scoreEvent()

  scoreEvent: ->
    type: 'scorechange'
    level: @level
    score: @score
    cleared: @cleared
    chain: @chain    
    goal: @goal  

  goalEvent: ->
    type: 'goalreached'
    level: @level
    score: @score
    cleared: @cleared
    chain: @chain  
    goal: @goal  

