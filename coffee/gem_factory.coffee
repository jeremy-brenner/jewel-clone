class GemFactory
  constructor: ->
    @loaded = false
    @jsonloader = new THREE.JSONLoader()
    @scalefactor = 1.125
    @outline = new THREE.MeshBasicMaterial
      color: 'black'  
      side: THREE.BackSide 
    @gemid = 0  
    @loadGems()

  loadGems: ->
    @req = new XMLHttpRequest()
    @req.onload = @gemsLoaded
    @req.open "GET", 'models/gems.json'
    @req.send()

  gemsLoaded: =>
    json = JSON.parse @req.responseText
    chunk = @buildGeometry(json.chunk.geometry,@scalefactor/2)
    @defs = for gem,i in json.gems
      {
        id: i
        geometry: @buildGeometry(gem.geometry,@scalefactor)
        material: @buildMaterial(gem.color)
        outline: @outline
        chunk: chunk
      }
    @loaded = true
    @onload()

  buildGeometry: (def,scale) ->
    geom = @jsonloader.parse( def ).geometry
    rx = new THREE.Matrix4().makeRotationX( Math.PI/2 )
    s = new THREE.Matrix4().makeScale scale,scale*1.3,scale
    r = new THREE.Matrix4().multiplyMatrices rx, s
    geom.applyMatrix r
    new THREE.BufferGeometry().fromGeometry geom

  buildMaterial: (color) ->
    new THREE.MeshPhongMaterial
      color: color
      ambient: color
      shininess: 60
  
  buildGem: (def) ->
    new Gem(def,@gemid++)

  random: ->
    @buildGem @defs[Math.floor(Math.random() * @defs.length)]

  onload: ->
    #stub 