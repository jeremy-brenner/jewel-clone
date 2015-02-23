class Jewel
  constructor: (id) ->
    @loaded = false
    @id = id
    @scalefactor = 1.25
    @colors = [
      'red'
      'white'
      'lime'
      'blue'
      'orange'
      'purple'
      'teal'
      'deeppink'
    ]
    color = @randomColor()
    @material = new THREE.MeshPhongMaterial
      color: color
      ambient: color
      shininess: 50
    @loadModel()
  
  randomColor: -> 
    @colors[Math.floor(Math.random() * @colors.length)]

  build: ->
    new THREE.Mesh( @geometry, @material )

  modelUrl: ->
    "models/#{@id}.json" 

  modelLoaded: =>
    jsonloader = new THREE.JSONLoader()
    json = JSON.parse @req.responseText
    geometry = jsonloader.parse( json.geometries[0].data ).geometry
    @geometry = new THREE.BufferGeometry().fromGeometry geometry
    rx = new THREE.Matrix4().makeRotationX( Math.PI/2 )
    s = new THREE.Matrix4().makeScale @scalefactor, @scalefactor, @scalefactor
    r = new THREE.Matrix4().multiplyMatrices rx, s
    @geometry.applyMatrix r

    @loaded = true
    @onload()

  loadModel: ->
    @req = new XMLHttpRequest()
    @req.onload = @modelLoaded
    @req.open "GET", @modelUrl()
    @req.send()

  onload: ->
    #stub

class Jewels
  constructor: ->
    @loaded = false
    @list = [
      'archaic2'
      'asterism'
      'button'
      'litehouse'
      'novice3'
      'novice6'
      'starcut'
      'arrow'
      'cascade'
      'novice1'
      'novice5'
      'novice8'
    ]
    @objects = @load()
    for jewel in @objects 
      jewel.onload = @jewelLoaded   
  
  random: ->
    @objects[Math.floor(Math.random() * @objects.length)].build()

  load: ->
    new Jewel(id) for id in @list

  allLoaded: ->
    for jewel in @objects
      return false if not jewel.loaded
    true

  jewelLoaded: =>
    @onload() if @allLoaded()

  onload: ->
    #stub 