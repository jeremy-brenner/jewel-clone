class Jewels
  constructor: ->
    @loaded = false
    @jsonloader = new THREE.JSONLoader()
    @scalefactor = 1.25
    @loadJewels()

  loadJewels: ->
    @req = new XMLHttpRequest()
    @req.onload = @jewelsLoaded
    @req.open "GET", 'models/jewels.json'
    @req.send()

  jewelsLoaded: =>
    json = JSON.parse @req.responseText
    @objects = for jewel in json
      {
        geometry: @buildGeometry(jewel.geometry)
        material: @buildMaterial(jewel.color)
      }
    @loaded = true
    @onload()

  buildGeometry: (def) ->
    geom = @jsonloader.parse( def ).geometry
    rx = new THREE.Matrix4().makeRotationX( Math.PI/2 )
    s = new THREE.Matrix4().makeScale @scalefactor, @scalefactor, @scalefactor
    r = new THREE.Matrix4().multiplyMatrices rx, s
    geom.applyMatrix r
    new THREE.BufferGeometry().fromGeometry geom

  buildMaterial: (color) ->
    new THREE.MeshPhongMaterial
      color: color
      ambient: color
      shininess: 50

  random: ->
    j = @objects[Math.floor(Math.random() * @objects.length)]
    new THREE.Mesh( j.geometry, j.material )

  load: ->
    new Jewel(id) for id in @list

  onload: ->
    #stub 