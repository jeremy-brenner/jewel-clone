class AudioManager
  constructor: (files) ->
    @context = new AudioContext()
    @audio_loaders = @loadFiles(files)
    @buffers = {}
    @buildNodes()
    @buildGraph()

  buildNodes: ->
    @nodes = 
      destination: @context.destination
      masterGain: @context.createGain()
      backgroundMusicGain: @context.createGain()
      coreEffectsGain: @context.createGain()
      effectsGain: @context.createGain()
      pausedEffectsGain: @context.createGain()
   
  buildGraph: ->
    @nodes.masterGain.connect @nodes.destination 
    @nodes.backgroundMusicGain.connect @nodes.masterGain 
    @nodes.coreEffectsGain.connect @nodes.masterGain
    @nodes.effectsGain.connect @nodes.coreEffectsGain
    @nodes.pausedEffectsGain.connect @nodes.coreEffectsGain 

  loadFiles: (files) ->
    for file in files
      af = new AudioLoader(file) 
      af.onload = @fileLoaded
      af

  allLoaded: ->
    for f in @audio_loaders
      return false if f.loaded is false
    return true

  fileLoaded: =>
    if @allLoaded()
      for f in @audio_loaders
        @buffers[f.name()] = f.buffer
      @onload()

  play: (name) ->
    return unless @buffers[name]
    source = @context.createBufferSource()
    #source.noteOnAt = Date.now()
    channel = @nodes.effectsGain
    source.buffer = @buffers[name]
    source.connect channel 
    source.loop = false
    source.start( start )

  onload: ->
    #noop
  

