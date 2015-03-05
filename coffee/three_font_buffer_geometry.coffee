class THREE.FontBufferGeometry
  constructor: (parameters,charset='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') ->
    @parameters = parameters
    @geometries = @buildGeometries(charset.split(''))

  buildGeometries: (chararray) ->
    h = {}
    h[char] = @buildGeometry(char) for char in chararray
    h

  buildGeometry: (c) ->
    object = {}
    object.geometry = new THREE.BufferGeometry().fromGeometry( new THREE.TextGeometry( c, @parameters ))
    object.geometry.computeBoundingBox()
    object.width = object.geometry.boundingBox.max.x - object.geometry.boundingBox.min.x
    object

  buildMesh: (string,mat) ->
    mesh = new THREE.Object3D()
    pos = 0
    for c in string.split('')
      if @geometries[c]
        letter = new THREE.Mesh( @geometries[c].geometry, mat )
        letter.position.x = pos
        pos += @geometries[c].width
        mesh.add letter
      else
        pos += @parameters.height/2
    mesh