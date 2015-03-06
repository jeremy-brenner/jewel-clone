class THREE.FontBufferGeometry
  constructor: (parameters,prebuild_chars='') ->
    @parameters = parameters
    @geometries = {}
    @preBuildGeometries(prebuild_chars.split(''))

  preBuildGeometries: (chararray) ->
    @geometries[char] = @buildGeometry(char) for char in chararray
    
  buildGeometry: (char) ->
    object = {}
    object.geometry = new THREE.BufferGeometry().fromGeometry( new THREE.TextGeometry( char, @parameters ))
    object.geometry.computeBoundingBox()
    object.width = object.geometry.boundingBox.max.x - object.geometry.boundingBox.min.x
    object

  buildMesh: (string,mat) ->
    mesh = new THREE.Object3D()
    pos = 0
    for char in string.split('')
      if char is ' '
        pos += @parameters.height/2
      else
        @geometries[char] ?= @buildGeometry(char)
        letter = new THREE.Mesh( @geometries[char].geometry, mat )
        letter.position.x = pos
        pos += @geometries[char].width + @parameters.height/4
        mesh.add letter
    mesh
