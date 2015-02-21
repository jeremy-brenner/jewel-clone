
class JewelClone
  constructor: ->
    @logger = new Logger()
    @fps = new Fps()
    @registerEvents()
    @logger.log 'init three'
    @initThree()
    @logger.log 'start renderloop'
    @renderLoop(0)

  registerEvents: ->
    window.addEventListener 'deviceorientation', @updateOrientation 


  realWidth: ->
    window.innerWidth * window.devicePixelRatio

  realHeight: ->
    window.innerHeight * window.devicePixelRatio

  aspect: ->
    window.innerWidth / window.innerHeight

  updateOrientation: (orientation) =>
    @deviceAlpha = orientation.alpha
    @deviceGamma = orientation.gamma
    @deviceBeta = orientation.beta

  initThree: ->
    document.body.style.zoom = 1 / window.devicePixelRatio
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera( 75, @aspect(), 0.1, 1000 )
    @renderer = new THREE.WebGLRenderer
      antialias: true
    @renderer.setSize @realWidth(), @realHeight()
    document.body.appendChild @renderer.domElement 

    @deviceAlpha = null;
    @deviceGamma = null;
    @deviceBeta = null;
    @betaAxis = 'x'
    @gammaAxis = 'y'
    @betaAxisInversion = -1
    @gammaAxisInversion = -1

    geometry = new THREE.BufferGeometry().fromGeometry( new THREE.BoxGeometry( 1, 1, 1 ) )
    material = new THREE.MeshLambertMaterial
      color: 'blue'
      ambient: 'blue'
    @cube = new THREE.Mesh( geometry, material )
    @scene.add( new THREE.AmbientLight( 0x555555 ) )
    light = new THREE.DirectionalLight( 0xffffff, 1 )
    light.position.z = 3
    light.position.y = 1
    @scene.add( light )
    @scene.add( @cube )
    @camera.position.z = 3
    @frames = 0


  updateCube: ->
    @cube.rotation[@betaAxis] = @deviceBeta * (Math.PI/180) * @betaAxisInversion
    @cube.rotation[@gammaAxis] = @deviceGamma * (Math.PI/180) * @gammaAxisInversion

  renderLoop: (t) =>
    requestAnimationFrame @renderLoop 
    @updateCube()
    @fps.update(t)
    @renderer.render( @scene, @camera )

    
