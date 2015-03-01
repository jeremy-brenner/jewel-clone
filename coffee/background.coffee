class Background
  constructor: ->
    @drawBackground()

  drawBackground: ->
    bg = new THREE.MeshLambertMaterial
      map: THREE.ImageUtils.loadTexture( 'img/wallpaper.png' ) 
    
    bgg = new THREE.PlaneBufferGeometry GEMGAME.realHeight(), GEMGAME.realHeight() 
    @object = new THREE.Mesh( bgg, bg )
    @object.position.x = GEMGAME.realWidth()/2
    @object.position.y = GEMGAME.realHeight()/2
    @object.position.z = -100000
   