class Menu
  constructor: ->
    @object = new THREE.Object3D()
    @fontcfg = 
      size: @fontSize()
      height: 10
      curveSegments: 3
      font: "droid sans"
      weight: "normal"
      style: "normal"
      bevelThickness: 10
      bevelSize: 5
      bevelEnabled: true
      extrudeMaterial: 1
    @chosen = null
    @menu =
      main: [
        label: 'New Game'
        color: 'green'
        exec: =>
          @cascade.stop()
          GEMGAME.start()
    #  ,
    #    label: 'Config'
    #    color: 'yellow'
    #    exec: ->
    #      GEMGAME.menu.open('main')
      , 
        label: 'About'
        color: 'teal'
        exec: ->
          GEMGAME.showAbout()
      ,
        label: 'Quit'
        color: 'red'
        exec: navigator.app.exitApp
      ]
    @outline = new THREE.MeshBasicMaterial
      color: 'black'  
      side: THREE.BackSide 

    @meshes = []
    @busy = false
    GEMGAME.input.addEventListener 'touchstart', @handleTouch

  handleTouch: (e) =>
    if @menuIsOpen() 
      i = @checkTouch(e.y)
      if i isnt false
        @choose(i)

  fontSize: ->
    GEMGAME.realWidth()/12

  center: (width) ->
    GEMGAME.realWidth()/2 - width/2

  open: (menu) ->
    unless @cascade
      @cascade ?= new GemCascade(25)
      @object.add @cascade.object

    @cascade.start()
    @current = @menu[menu]
    @createItem(item,i) for item,i in @current when not item.object
    for item in @current
      item.object.scale.x = 1
      item.object.scale.y = 1
      item.object.position.x = @center item.width
      @object.add item.object 
    


  createItem: (item,i) ->
    mat = new THREE.MeshPhongMaterial
      color: item.color
      ambient: item.color
      shininess: 60
    
    item.object = new THREE.Object3D()

    letters = ( @createLetter(letter,mat) for letter in item.label.split('') )
    item.width = 0
    for letter in letters
      if letter 
        letter.position.x = item.width
        item.object.add letter 
        item.width += (letter.children[0].geometry.boundingBox.max.x-letter.children[0].geometry.boundingBox.min.x)+@fontSize()/8
      else
        item.width += @fontSize()/8
 
    item.object.position.x = @center item.width
   
    item.object.position.y = i*@fontSize()*-2 + GEMGAME.realHeight()/2 + @current.length*@fontSize()/2

  createLetter: (letter,mat) ->
    return if letter is ' '
    os=1.15
    object = new THREE.Object3D()
    geom = new THREE.BufferGeometry().fromGeometry( new THREE.TextGeometry( letter, @fontcfg ))
    geom.computeBoundingBox()
    w=geom.boundingBox.max.x-geom.boundingBox.min.x
    h=geom.boundingBox.max.y-geom.boundingBox.min.y
    wd = w*os-w
    hd = h*os-h
    mesh = new THREE.Mesh( geom,mat )
    mesh.position.x = wd/2
    mesh.position.y = hd/2
    mesh.position.z = 2
    outline_mesh = new THREE.Mesh( geom,@outline )
    outline_mesh.position.z = -2
    outline_mesh.scale.multiplyScalar os
    outline_mesh.geometry.computeBoundingBox()
    object.add mesh
    object.add outline_mesh
    object

  choose: (index) ->
    @chosen = index
    @choseAnimation()
   
  chooseComplete: =>
    exec = @current[@chosen].exec  
    @chosen = null 
    @current = null
    exec?()

  choseAnimation: () ->
    @tween_data = {}
    close_to = {}
    chosen_to = {}
    for item,i in @current 
      @tween_data[i] = 1
      if i isnt @chosen
        close_to[i] = 0
      else
        chosen_to[i] = 0
      

    close_tween = new TWEEN.Tween( @tween_data )
             .to( close_to, 500 ) 
             .easing( TWEEN.Easing.Linear.None )
             .onUpdate( @tweenTick )
    close_tween.start()  

    chosen_tween = new TWEEN.Tween( @tween_data )
             .to( chosen_to, 1000 ) 
             .easing( TWEEN.Easing.Back.In )
             .onUpdate( @tweenTick )
             .onComplete( @chooseComplete )
    chosen_tween.start()  

  tweenTick: =>
    for i,s of @tween_data
      if s isnt 0
        @current[i].object.scale.x = s
        @current[i].object.scale.y = s
        @current[i].object.position.x = @center @current[i].width*s
      else
        @object.remove @current[i].object

  menuIsOpen: ->
    @current isnt null and @chosen is null

  checkTouch: (ty) ->
    return false if ty > @fontSize()+@current[0].object.position.y
    for item,i in @current
      return i if ty > item.object.position.y
    return false
   