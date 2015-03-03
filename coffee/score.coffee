class Score extends THREE.EventDispatcher
  constructor: ->
    @score = 0
    @cleared = 0
    @chain = 0
    @goal = 0
    @longest_chain = 0
    @last_updated = 0
    @update_interval = 1000

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

  reset: ->
    @cleared = 0
    @chain = 0
    @longest_chain = 0
    @dispatchEvent @scoreEvent()

  scoreEvent: ->
    type: 'scorechange'
    score: @score
    cleared: @cleared
    chain: @chain    
    goal: @goal  

  goalEvent: ->
    type: 'goalreached'
    score: @score
    cleared: @cleared
    chain: @chain  
    goal: @goal  


  timeToUpdate: (t) ->
    t-@last_updated > @update_interval

  scoreText: ->
    """
      Cleared: #{@cleared}
      Chain: #{@chain}
      Longest Chain: #{@longest_chain}
      Score: #{@score}
    """

  update: (t) ->
    return unless @timeToUpdate(t)
    document.getElementById('score').innerText = @scoreText()