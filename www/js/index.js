// Generated by CoffeeScript 1.9.1
(function() {
  var Cell, Fps, Grid, Input, Jewels, Logger, Main,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Cell = (function() {
    function Cell(x, y, main) {
      this.tweenTick = bind(this.tweenTick, this);
      this.x = x;
      this.y = y;
      this.main = main;
      this.setJewel(this.main.jewels.random());
      this.buildSquare();
    }

    Cell.prototype.xPos = function() {
      return this.x + 0.5;
    };

    Cell.prototype.yPos = function() {
      return this.y + 0.5;
    };

    Cell.prototype.swapJewel = function(cell) {
      var new_jewel;
      new_jewel = cell.jewel;
      cell.tweenJewel(this.jewel);
      return this.tweenJewel(new_jewel, false);
    };

    Cell.prototype.tweenJewel = function(jewel, front) {
      var length, s1, s2, sc;
      if (front == null) {
        front = true;
      }
      this.jewel = jewel;
      length = 500;
      sc = front ? 0.1 : -0.1;
      this.tween = {
        x: this.jewel.position.x,
        y: this.jewel.position.y,
        s: 1
      };
      new TWEEN.Tween(this.tween).to({
        x: this.xPos(),
        y: this.yPos()
      }, length).easing(TWEEN.Easing.Back.InOut).onUpdate(this.tweenTick).start();
      s1 = new TWEEN.Tween(this.tween).to({
        s: 1 + sc
      }, length / 2).easing(TWEEN.Easing.Quadratic.Out).onUpdate(this.tweenTick);
      s2 = new TWEEN.Tween(this.tween).to({
        s: 1
      }, length / 2).easing(TWEEN.Easing.Quadratic.In).onUpdate(this.tweenTick);
      return s1.chain(s2).start();
    };

    Cell.prototype.tweenTick = function() {
      this.jewel.position.x = this.tween.x;
      this.jewel.position.y = this.tween.y;
      this.jewel.position.z = this.tween.s - 1;
      this.jewel.scale.x = this.tween.s;
      return this.jewel.scale.y = this.tween.s;
    };

    Cell.prototype.setJewel = function(j) {
      this.jewel = j;
      this.jewel.position.x = this.xPos();
      return this.jewel.position.y = this.yPos();
    };

    Cell.prototype.squareOpacity = function() {
      if (this.y % 2 !== this.x % 2) {
        return 0.2;
      } else {
        return 0.5;
      }
    };

    Cell.prototype.buildSquare = function() {
      var geom, mat;
      mat = new THREE.MeshBasicMaterial({
        transparent: true,
        opacity: this.squareOpacity(),
        color: 'gray'
      });
      geom = new THREE.PlaneBufferGeometry(1, 1);
      this.square = new THREE.Mesh(geom, mat);
      this.square.position.x = this.xPos();
      return this.square.position.y = this.yPos();
    };

    Cell.prototype.highlite = function(t) {
      this.jewel.rotation.z = Math.PI * 2 - t / 300 % Math.PI * 2;
      this.jewel.scale.x = 1.25;
      return this.jewel.scale.y = 1.25;
    };

    Cell.prototype.reset = function() {
      this.jewel.rotation.z = 0;
      this.jewel.scale.x = 1;
      return this.jewel.scale.y = 1;
    };

    return Cell;

  })();

  Fps = (function() {
    function Fps() {
      this.refresh = 1000;
      this.frames = 0;
      this.lasttime = 0;
    }

    Fps.prototype.timeDiff = function(t) {
      return t - this.lasttime;
    };

    Fps.prototype.update = function(t) {
      var fps;
      this.frames++;
      if (this.timeDiff(t) > this.refresh) {
        fps = Math.floor(this.frames / (this.timeDiff(t) / 100000)) / 100;
        document.getElementById('fps').innerText = "fps: " + fps;
        this.frames = 0;
        return this.lasttime = t;
      }
    };

    return Fps;

  })();

  Grid = (function() {
    function Grid(w, h, main) {
      this.w = w;
      this.h = h;
      this.main = main;
      this.margin = 0.25;
      this.cells = this.buildCells();
      this.object = new THREE.Object3D();
      this.ready_for_input = true;
      this.buildBoard();
      this.object.position.x = this.boardScale(this.margin);
      this.object.position.y = this.boardScale(this.margin);
      this.object.scale.multiplyScalar(this.boardScale());
    }

    Grid.prototype.update = function(t) {
      var current, ref, ref1;
      if (this.ready_for_input && this.main.input.touching) {
        this.selected = this.touchedCell(this.main.input.start);
        current = this.touchedCell(this.main.input.move);
        if (!(this.selected && current)) {
          return this.stopInput();
        }
        if (this.selected === current) {
          if ((ref = this.selected) != null) {
            ref.highlite(t);
          }
        } else {
          this.stopInput();
          this.selected.swapJewel(current);
        }
      }
      if (!this.main.input.touching) {
        if (this.selected) {
          this.selected.reset();
          this.selected = null;
        }
        this.ready_for_input = true;
        return (ref1 = this.selected) != null ? ref1.reset() : void 0;
      }
    };

    Grid.prototype.stopInput = function() {
      var ref;
      this.ready_for_input = false;
      return (ref = this.selected) != null ? ref.reset() : void 0;
    };

    Grid.prototype.topOffset = function() {
      return this.main.realHeight() - this.boardScale(this.h + this.margin);
    };

    Grid.prototype.touchedCell = function(pos) {
      var ref, x, y;
      x = Math.floor(pos.x / this.boardScale() - this.margin);
      y = this.h - 1 - Math.floor((pos.y - this.topOffset()) / this.boardScale());
      return (ref = this.cells[x]) != null ? ref[y] : void 0;
    };

    Grid.prototype.boardScale = function(i) {
      if (i == null) {
        i = 1;
      }
      return this.main.realWidth() / (this.w + this.margin * 2) * i;
    };

    Grid.prototype.buildBoard = function() {
      var cell, k, len, ref, results, row;
      ref = this.cells;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        row = ref[k];
        results.push((function() {
          var l, len1, results1;
          results1 = [];
          for (l = 0, len1 = row.length; l < len1; l++) {
            cell = row[l];
            this.object.add(cell.square);
            results1.push(this.object.add(cell.jewel));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    Grid.prototype.buildCells = function() {
      var k, ref, results, x, y;
      results = [];
      for (x = k = 0, ref = this.h; 0 <= ref ? k < ref : k > ref; x = 0 <= ref ? ++k : --k) {
        results.push((function() {
          var l, ref1, results1;
          results1 = [];
          for (y = l = 0, ref1 = this.w; 0 <= ref1 ? l < ref1 : l > ref1; y = 0 <= ref1 ? ++l : --l) {
            results1.push(new Cell(x, y, this.main));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    return Grid;

  })();

  document.addEventListener('deviceready', function() {
    return new Main();
  });

  Input = (function() {
    function Input() {
      this.updateOrientation = bind(this.updateOrientation, this);
      this.touchMove = bind(this.touchMove, this);
      this.touchEnd = bind(this.touchEnd, this);
      this.touchStart = bind(this.touchStart, this);
      this.touching = false;
      this.bindEvents();
      this.start = {
        x: null,
        y: null
      };
      this.move = {
        x: null,
        y: null
      };
      this.orientation = {
        alpha: 0,
        beta: 0,
        gamma: 0
      };
    }

    Input.prototype.bindEvents = function() {
      window.addEventListener('touchstart', this.touchStart);
      window.addEventListener('touchend', this.touchEnd);
      window.addEventListener('touchmove', this.touchMove);
      return window.addEventListener('deviceorientation', this.updateOrientation);
    };

    Input.prototype.touchStart = function(e) {
      this.touching = true;
      this.start.x = e.touches[0].screenX * window.devicePixelRatio;
      this.start.y = e.touches[0].screenY * window.devicePixelRatio;
      return this.move = {
        x: this.start.x,
        y: this.start.y
      };
    };

    Input.prototype.touchEnd = function(e) {
      return this.touching = false;
    };

    Input.prototype.touchMove = function(e) {
      this.move.x = e.touches[0].screenX * window.devicePixelRatio;
      return this.move.y = e.touches[0].screenY * window.devicePixelRatio;
    };

    Input.prototype.updateOrientation = function(orientation) {
      this.orientation.alpha = orientation.alpha || 0;
      this.orientation.gamma = orientation.gamma || 0;
      return this.orientation.beta = orientation.beta || 0;
    };

    return Input;

  })();

  Jewels = (function() {
    function Jewels() {
      this.jewelsLoaded = bind(this.jewelsLoaded, this);
      this.loaded = false;
      this.jsonloader = new THREE.JSONLoader();
      this.scalefactor = 1.125;
      this.outline_material = new THREE.MeshBasicMaterial({
        color: 'black',
        side: THREE.BackSide
      });
      this.loadJewels();
    }

    Jewels.prototype.loadJewels = function() {
      this.req = new XMLHttpRequest();
      this.req.onload = this.jewelsLoaded;
      this.req.open("GET", 'models/jewels.json');
      return this.req.send();
    };

    Jewels.prototype.jewelsLoaded = function() {
      var jewel, json;
      json = JSON.parse(this.req.responseText);
      this.objects = (function() {
        var k, len, results;
        results = [];
        for (k = 0, len = json.length; k < len; k++) {
          jewel = json[k];
          results.push({
            geometry: this.buildGeometry(jewel.geometry),
            material: this.buildMaterial(jewel.color)
          });
        }
        return results;
      }).call(this);
      this.loaded = true;
      return this.onload();
    };

    Jewels.prototype.buildGeometry = function(def) {
      var geom, r, rx, s;
      geom = this.jsonloader.parse(def).geometry;
      rx = new THREE.Matrix4().makeRotationX(Math.PI / 2);
      s = new THREE.Matrix4().makeScale(this.scalefactor, this.scalefactor, this.scalefactor);
      r = new THREE.Matrix4().multiplyMatrices(rx, s);
      geom.applyMatrix(r);
      return new THREE.BufferGeometry().fromGeometry(geom);
    };

    Jewels.prototype.buildMaterial = function(color) {
      return new THREE.MeshPhongMaterial({
        color: color,
        ambient: color,
        shininess: 60
      });
    };

    Jewels.prototype.buildJewel = function(def) {
      var jewel, jewel_mesh, outline_mesh;
      jewel = new THREE.Object3D();
      jewel_mesh = new THREE.Mesh(def.geometry, def.material);
      outline_mesh = new THREE.Mesh(def.geometry, this.outline_material);
      outline_mesh.scale.multiplyScalar(1.125);
      jewel.add(jewel_mesh);
      jewel.add(outline_mesh);
      return jewel;
    };

    Jewels.prototype.random = function() {
      return this.buildJewel(this.objects[Math.floor(Math.random() * this.objects.length)]);
    };

    Jewels.prototype.onload = function() {};

    return Jewels;

  })();

  Logger = (function() {
    function Logger() {
      this.loglines = [];
    }

    Logger.prototype.log = function(text) {
      this.loglines.push(text);
      return document.getElementById('log').innerText = this.loglines.join("\n");
    };

    return Logger;

  })();

  Main = (function() {
    function Main() {
      this.renderLoop = bind(this.renderLoop, this);
      this.jewelsLoaded = bind(this.jewelsLoaded, this);
      this.grid_width = 8;
      this.grid_height = 8;
      this.logger = new Logger();
      this.logger.log("logger started");
      this.fps = new Fps();
      this.input = new Input();
      this.logger.log('init three');
      this.initThree();
      this.drawBackground();
      this.jewels = new Jewels();
      this.jewels.onload = this.jewelsLoaded;
    }

    Main.prototype.realWidth = function() {
      return window.innerWidth * window.devicePixelRatio;
    };

    Main.prototype.realHeight = function() {
      return window.innerHeight * window.devicePixelRatio;
    };

    Main.prototype.aspect = function() {
      return window.innerWidth / window.innerHeight;
    };

    Main.prototype.initThree = function() {
      document.body.style.zoom = 1 / window.devicePixelRatio;
      this.scene = new THREE.Scene();
      this.camera = new THREE.OrthographicCamera(0, this.realWidth(), this.realHeight(), 0, 0, 5000);
      this.camera.position.z = 500;
      this.camera.updateProjectionMatrix();
      this.renderer = new THREE.WebGLRenderer({
        antialias: true
      });
      this.renderer.setSize(this.realWidth(), this.realHeight());
      document.body.appendChild(this.renderer.domElement);
      this.scene.add(new THREE.AmbientLight(0x666666));
      this.light = new THREE.DirectionalLight(0xffffff, 1);
      this.light.position.z = 100;
      this.light.position.x = 60;
      this.light.position.y = 60;
      return this.scene.add(this.light);
    };

    Main.prototype.drawBackground = function() {
      var background, bg, bgg;
      bg = new THREE.MeshLambertMaterial({
        map: THREE.ImageUtils.loadTexture('img/wallpaper.png')
      });
      bgg = new THREE.PlaneBufferGeometry(this.realHeight(), this.realHeight());
      background = new THREE.Mesh(bgg, bg);
      background.position.x = this.realWidth() / 2;
      background.position.y = this.realHeight() / 2;
      background.position.z = -1000;
      return this.scene.add(background);
    };

    Main.prototype.jewelsLoaded = function() {
      this.logger.log("jewels loaded");
      this.grid = new Grid(this.grid_width, this.grid_height, this);
      this.scene.add(this.grid.object);
      return this.renderLoop(0);
    };

    Main.prototype.updateLight = function() {
      this.light.position.x = (this.input.orientation.gamma * -1) + 60;
      return this.light.position.y = this.input.orientation.beta + 60;
    };

    Main.prototype.renderLoop = function(t) {
      requestAnimationFrame(this.renderLoop);
      TWEEN.update(t);
      this.updateLight();
      this.grid.update(t);
      this.renderer.render(this.scene, this.camera);
      return this.fps.update(t);
    };

    return Main;

  })();

}).call(this);
