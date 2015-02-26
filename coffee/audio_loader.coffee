class AudioLoader
  constructor: (file) ->
    @file = file
    @loaded = false
    @context = new AudioContext()
    @loadFile file

  name: ->
    @file.split('/').pop().split('.')[0]

  loadFile: (file) ->
    @request = new XMLHttpRequest()
    @request.open('GET', file, true)
    @request.responseType = 'arraybuffer';

    @request.onload = @fileLoaded
    @request.send()

  fileLoaded: =>
    @context.decodeAudioData @request.response, @loadBuffer

  loadBuffer: (buffer) =>
    @buffer = buffer
    @loaded = true
    @onload()
  
  onload: ->
    #noop