class Background
  constructor: ->
    @size = 1000
    @drawBackground()

  drawBackground: ->
    bg = new THREE.MeshLambertMaterial
      map: THREE.ImageUtils.loadTexture( 'img/wallpaper.png' ) 
    
    bgg = new THREE.PlaneBufferGeometry @size,@size
    @object = new THREE.Mesh( bgg, bg )
    @object.position.x = @size/2
    @object.position.y = @size/2
    @object.position.z = -100000

  scale: (s) ->
    @object.scale.multiplyScalar s
    @object.position.x = @size*s/2
    @object.position.y = @size*s/2

window.GemCrusher ?= {}
GemCrusher.Background = Background
