// Generated by CoffeeScript 1.9.1
(function() {
  var Cell, Fps, Gem, GemFactory, Grid, Input, Logger, Main,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Cell = (function() {
    function Cell(x, y, main) {
      this.x = x;
      this.y = y;
      this.main = main;
      this.buildSquare();
    }

    Cell.prototype.xPos = function() {
      return this.x + 0.5;
    };

    Cell.prototype.yPos = function() {
      return this.y + 0.5;
    };

    Cell.prototype.commitNew = function() {
      this.gem = this.new_gem;
      return this.new_gem = null;
    };

    Cell.prototype.flagCleared = function() {
      var j, k, len, len1, m, ref, ref1, results;
      if (this.horizontalMatches().length >= 3) {
        ref = this.horizontalMatches();
        for (j = 0, len = ref.length; j < len; j++) {
          m = ref[j];
          m.doomed = true;
        }
      }
      if (this.verticalMatches().length >= 3) {
        ref1 = this.verticalMatches();
        results = [];
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          m = ref1[k];
          results.push(m.doomed = true);
        }
        return results;
      }
    };

    Cell.prototype.swapGems = function(cell) {
      this.new_gem = cell.gem;
      cell.new_gem = this.gem;
      if (this.willClear() || cell.willClear()) {
        this.new_gem.doSwap(this.xPos(), this.yPos(), true, false);
        cell.new_gem.doSwap(cell.xPos(), cell.yPos(), true, true);
        this.commitNew();
        cell.commitNew();
        this.flagCleared();
        return cell.flagCleared();
      } else {
        this.new_gem.doSwap(this.xPos(), this.yPos(), false, false);
        cell.new_gem.doSwap(cell.xPos(), cell.yPos(), false, true);
        this.new_gem = null;
        return cell.new_gem = null;
      }
    };

    Cell.prototype.matchGem = function() {
      return this.new_gem || this.gem;
    };

    Cell.prototype.horizontalMatches = function() {
      return [this.matchGem()].concat(this.match(this.matchGem().def_id, 'left')).concat(this.match(this.matchGem().def_id, 'right'));
    };

    Cell.prototype.verticalMatches = function() {
      return [this.matchGem()].concat(this.match(this.matchGem().def_id, 'up')).concat(this.match(this.matchGem().def_id, 'down'));
    };

    Cell.prototype.willClear = function() {
      return this.horizontalMatches().length >= 3 || this.verticalMatches().length >= 3;
    };

    Cell.prototype.match = function(def_id, dir) {
      var cell;
      cell = (function() {
        var ref, ref1, ref2, ref3;
        switch (dir) {
          case 'left':
            return (ref = this.main.grid.cells[this.x - 1]) != null ? ref[this.y] : void 0;
          case 'right':
            return (ref1 = this.main.grid.cells[this.x + 1]) != null ? ref1[this.y] : void 0;
          case 'up':
            return (ref2 = this.main.grid.cells[this.x]) != null ? ref2[this.y + 1] : void 0;
          case 'down':
            return (ref3 = this.main.grid.cells[this.x]) != null ? ref3[this.y - 1] : void 0;
        }
      }).call(this);
      if (!cell) {
        return [];
      }
      if (cell.matchGem().def_id === def_id) {
        return [cell.matchGem()].concat(cell.match(def_id, dir));
      } else {
        return [];
      }
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
      var ref;
      return (ref = this.gem) != null ? ref.highlite(t) : void 0;
    };

    Cell.prototype.reset = function() {
      var ref;
      return (ref = this.gem) != null ? ref.reset() : void 0;
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

  Gem = (function() {
    function Gem(def, id) {
      this.tweenTick = bind(this.tweenTick, this);
      this.animationComplete = bind(this.animationComplete, this);
      this.id = id;
      this.def_id = def.id;
      this.object = new THREE.Object3D();
      this.mesh = new THREE.Mesh(def.geometry, def.material);
      this.outline = new THREE.Mesh(def.geometry, def.outline);
      this.mesh.position.z = 2;
      this.outline.scale.multiplyScalar(1.125);
      this.animating = false;
      this.object.add(this.mesh);
      this.object.add(this.outline);
      this.swap_length = 750;
    }

    Gem.prototype.setX = function(x) {
      return this.object.position.x = x;
    };

    Gem.prototype.setY = function(y) {
      return this.object.position.y = y;
    };

    Gem.prototype.animationComplete = function() {
      console.log('animation complete');
      return this.animating = false;
    };

    Gem.prototype.dropTo = function(y, delay) {
      var drop_tween, length;
      this.animating = true;
      length = 1250;
      this.tween_data = {
        x: this.object.position.x,
        y: this.object.position.y,
        s: 1
      };
      drop_tween = new TWEEN.Tween(this.tween_data).to({
        y: y
      }, length).easing(TWEEN.Easing.Bounce.Out).onUpdate(this.tweenTick);
      return drop_tween.onComplete(this.animationComplete).delay(delay).start();
    };

    Gem.prototype.doSwap = function(x, y, real, front) {
      if (real == null) {
        real = true;
      }
      if (front == null) {
        front = true;
      }
      this.animating = true;
      this.tween_data = {
        x: this.object.position.x,
        y: this.object.position.y,
        s: 1
      };
      if (real) {
        this.zoomTween(front).start();
        return this.realSwapTween(x, y).start();
      } else {
        this.failedZoomTween(front).start();
        return this.failedSwapTween(x, y).start();
      }
    };

    Gem.prototype.zoomTween = function(front) {
      var sc, zoom_tween_end, zoom_tween_start;
      if (front == null) {
        front = true;
      }
      sc = front ? 0.25 : -0.25;
      zoom_tween_start = new TWEEN.Tween(this.tween_data).to({
        s: 1 + sc
      }, this.swap_length / 2).easing(TWEEN.Easing.Circular.In).onUpdate(this.tweenTick);
      zoom_tween_end = new TWEEN.Tween(this.tween_data).to({
        s: 1
      }, this.swap_length / 2).easing(TWEEN.Easing.Circular.Out).onUpdate(this.tweenTick);
      return zoom_tween_start.chain(zoom_tween_end);
    };

    Gem.prototype.realSwapTween = function(x, y) {
      return new TWEEN.Tween(this.tween_data).to({
        x: x,
        y: y
      }, this.swap_length).easing(TWEEN.Easing.Back.InOut).onUpdate(this.tweenTick).onComplete(this.animationComplete);
    };

    Gem.prototype.failedSwapTween = function(x, y) {
      var swap_end, swap_start;
      swap_start = new TWEEN.Tween(this.tween_data).to({
        x: x,
        y: y
      }, this.swap_length).easing(TWEEN.Easing.Circular.In).onUpdate(this.tweenTick);
      swap_end = new TWEEN.Tween(this.tween_data).to({
        x: this.object.position.x,
        y: this.object.position.y
      }, this.swap_length).easing(TWEEN.Easing.Circular.Out).onUpdate(this.tweenTick).onComplete(this.animationComplete);
      return swap_start.chain(swap_end);
    };

    Gem.prototype.failedZoomTween = function(front) {
      var sc, z;
      if (front == null) {
        front = true;
      }
      sc = front ? 0.25 : -0.25;
      z = [];
      z[0] = new TWEEN.Tween(this.tween_data).to({
        s: 1 + sc
      }, this.swap_length / 2).easing(TWEEN.Easing.Circular.In).onUpdate(this.tweenTick);
      z[1] = new TWEEN.Tween(this.tween_data).to({
        s: 1
      }, this.swap_length / 2).easing(TWEEN.Easing.Circular.Out).onUpdate(this.tweenTick);
      z[2] = new TWEEN.Tween(this.tween_data).to({
        s: 1 - sc
      }, this.swap_length / 2).easing(TWEEN.Easing.Circular.In).onUpdate(this.tweenTick);
      z[3] = new TWEEN.Tween(this.tween_data).to({
        s: 1
      }, this.swap_length / 2).easing(TWEEN.Easing.Circular.Out).onUpdate(this.tweenTick);
      z[0].chain(z[1]);
      z[1].chain(z[2]);
      z[2].chain(z[3]);
      return z[0];
    };

    Gem.prototype.tweenTick = function() {
      this.object.position.x = this.tween_data.x;
      this.object.position.y = this.tween_data.y;
      this.object.position.z = this.tween_data.s;
      this.object.scale.x = this.tween_data.s;
      return this.object.scale.y = this.tween_data.s;
    };

    Gem.prototype.highlite = function(t) {
      this.object.rotation.z = Math.PI * 2 - t / 400 % Math.PI * 2;
      this.object.scale.x = 1.25;
      return this.object.scale.y = 1.25;
    };

    Gem.prototype.reset = function() {
      this.object.rotation.z = 0;
      this.object.scale.x = 1;
      return this.object.scale.y = 1;
    };

    return Gem;

  })();

  GemFactory = (function() {
    function GemFactory() {
      this.gemsLoaded = bind(this.gemsLoaded, this);
      this.loaded = false;
      this.jsonloader = new THREE.JSONLoader();
      this.scalefactor = 1.125;
      this.outline = new THREE.MeshBasicMaterial({
        color: 'black',
        side: THREE.BackSide
      });
      this.gemid = 0;
      this.loadGems();
    }

    GemFactory.prototype.loadGems = function() {
      this.req = new XMLHttpRequest();
      this.req.onload = this.gemsLoaded;
      this.req.open("GET", 'models/gems.json');
      return this.req.send();
    };

    GemFactory.prototype.gemsLoaded = function() {
      var gem, i, json;
      json = JSON.parse(this.req.responseText);
      this.defs = (function() {
        var j, len, results;
        results = [];
        for (i = j = 0, len = json.length; j < len; i = ++j) {
          gem = json[i];
          results.push({
            id: i,
            geometry: this.buildGeometry(gem.geometry),
            material: this.buildMaterial(gem.color),
            outline: this.outline
          });
        }
        return results;
      }).call(this);
      this.loaded = true;
      return this.onload();
    };

    GemFactory.prototype.buildGeometry = function(def) {
      var geom, r, rx, s;
      geom = this.jsonloader.parse(def).geometry;
      rx = new THREE.Matrix4().makeRotationX(Math.PI / 2);
      s = new THREE.Matrix4().makeScale(this.scalefactor, this.scalefactor, this.scalefactor);
      r = new THREE.Matrix4().multiplyMatrices(rx, s);
      geom.applyMatrix(r);
      return new THREE.BufferGeometry().fromGeometry(geom);
    };

    GemFactory.prototype.buildMaterial = function(color) {
      return new THREE.MeshPhongMaterial({
        color: color,
        ambient: color,
        shininess: 60
      });
    };

    GemFactory.prototype.buildGem = function(def) {
      return new Gem(def, this.gemid++);
    };

    GemFactory.prototype.random = function() {
      return this.buildGem(this.defs[Math.floor(Math.random() * this.defs.length)]);
    };

    GemFactory.prototype.onload = function() {};

    return GemFactory;

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

    Grid.prototype.flatCells = function() {
      return Array.prototype.concat.apply([], this.cells);
    };

    Grid.prototype.doomedGems = function() {
      var cell, j, len, ref, ref1, results;
      ref = this.flatCells();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        cell = ref[j];
        if ((ref1 = cell.gem) != null ? ref1.doomed : void 0) {
          results.push(cell.gem);
        }
      }
      return results;
    };

    Grid.prototype.animating = function() {
      var cell, j, len, ref, ref1;
      ref = this.flatCells();
      for (j = 0, len = ref.length; j < len; j++) {
        cell = ref[j];
        if ((ref1 = cell.gem) != null ? ref1.animating : void 0) {
          return true;
        }
      }
      return false;
    };

    Grid.prototype.clearDoomed = function() {
      var gem, j, len, ref, results;
      ref = this.doomedGems();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        gem = ref[j];
        results.push(this.object.remove(gem.object));
      }
      return results;
    };

    Grid.prototype.update = function(t) {
      var current, ref;
      if (this.animating()) {
        return;
      }
      this.clearDoomed();
      if (this.ready_for_input && this.main.input.touching) {
        this.selected = this.touchedCell(this.main.input.start);
        current = this.touchedCell(this.main.input.move);
        if (!this.validMove(this.selected, current)) {
          return this.stopInput();
        }
        if (this.selected === current) {
          if ((ref = this.selected) != null) {
            ref.highlite(t);
          }
        } else {
          this.stopInput();
          this.selected.swapGems(current);
        }
      }
      if (!this.main.input.touching && !this.animating()) {
        if (this.selected) {
          this.selected.reset();
          this.selected = null;
        }
        return this.ready_for_input = true;
      }
    };

    Grid.prototype.validMove = function(cell1, cell2) {
      return cell1 && cell1.gem && cell2 && cell2.gem && (Math.abs(cell1.x - cell2.x) + Math.abs(cell1.y - cell2.y)) <= 1;
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

    Grid.prototype.addGems = function() {
      var cell, g, j, len, ref, results, row;
      ref = this.cells;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        row = ref[j];
        results.push((function() {
          var k, len1, results1;
          results1 = [];
          for (k = 0, len1 = row.length; k < len1; k++) {
            cell = row[k];
            g = this.main.gem_factory.random();
            g.setX(cell.xPos());
            g.setY(this.h * 2);
            cell.gem = g;
            this.object.add(cell.gem.object);
            results1.push(g.dropTo(cell.yPos(), 1000 + cell.yPos() * 50 + cell.xPos() * 10));
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    Grid.prototype.buildBoard = function() {
      var cell, j, len, ref, results;
      ref = this.flatCells();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        cell = ref[j];
        results.push(this.object.add(cell.square));
      }
      return results;
    };

    Grid.prototype.buildCells = function() {
      var j, ref, results, x, y;
      results = [];
      for (x = j = 0, ref = this.h; 0 <= ref ? j < ref : j > ref; x = 0 <= ref ? ++j : --j) {
        results.push((function() {
          var k, ref1, results1;
          results1 = [];
          for (y = k = 0, ref1 = this.w; 0 <= ref1 ? k < ref1 : k > ref1; y = 0 <= ref1 ? ++k : --k) {
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
      this.gemsLoaded = bind(this.gemsLoaded, this);
      this.grid_width = 8;
      this.grid_height = 8;
      this.logger = new Logger();
      this.logger.log("logger started");
      this.fps = new Fps();
      this.input = new Input();
      this.logger.log('init three');
      this.initThree();
      this.drawBackground();
      this.grid = new Grid(this.grid_width, this.grid_height, this);
      this.scene.add(this.grid.object);
      this.gem_factory = new GemFactory();
      this.gem_factory.onload = this.gemsLoaded;
      this.renderLoop(0);
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

    Main.prototype.gemsLoaded = function() {
      this.logger.log("gems loaded");
      return this.grid.addGems();
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
