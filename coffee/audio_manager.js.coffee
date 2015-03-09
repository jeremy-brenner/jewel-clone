class AudioManager
  constructor: (files) ->
    @context = new AudioContext()
    @buffers = {}
    @buildNodes()
    @buildGraph()
    @audio_loaders = @loadFiles(files)

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
    #console.log 'loadfiles', files
    for file in files
      #console.log 'loading', file
      af = new GemCrusher.AudioLoader(file) 
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
    source.buffer = @buffers[name]
    source.connect @nodes.effectsGain 
    source.loop = false
    source.start()

  onload: ->
    #noop
  
window.GemCrusher ?= {}
GemCrusher.AudioManager = AudioManager