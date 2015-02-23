class Jewels
  constructor: ->
    @loaded = false
    @jsonloader = new THREE.JSONLoader()
    @scalefactor = 1.125
    @outline_material = new THREE.MeshBasicMaterial
      color: 'black'  
      side: THREE.BackSide 
      
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
      shininess: 60
  
  buildJewel: (def) ->
    jewel = new THREE.Object3D()
    jewel_mesh = new THREE.Mesh( def.geometry, def.material )
   
    outline_mesh = new THREE.Mesh( def.geometry, @outline_material )
    outline_mesh.scale.multiplyScalar(1.125)

    jewel.add jewel_mesh
    jewel.add outline_mesh
    jewel

  random: ->
    @buildJewel @objects[Math.floor(Math.random() * @objects.length)]

  onload: ->
    #stub 