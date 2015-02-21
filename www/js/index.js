// Generated by CoffeeScript 1.9.1
(function() {
  var Fps, JewelClone, Logger,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Fps = (function() {
    function Fps() {
      this.reset();
      this.refresh = 1000;
      this.createDiv();
    }

    Fps.prototype.createDiv = function() {
      var div;
      div = document.createElement("div");
      div.id = 'fps';
      return document.getElementsByTagName('body')[0].appendChild(div);
    };

    Fps.prototype.reset = function() {
      this.frames = 0;
      return this.lasttime = 0;
    };

    Fps.prototype.update = function(t) {
      var diff, fps;
      this.frames++;
      diff = t - this.lasttime;
      if (diff > this.refresh) {
        fps = Math.floor(this.frames / (diff / 100000)) / 100;
        document.getElementById('fps').innerText = "fps: " + fps;
        return this.reset();
      }
    };

    return Fps;

  })();

  document.addEventListener('deviceready', function() {
    return new JewelClone();
  });

  JewelClone = (function() {
    function JewelClone() {
      this.renderLoop = bind(this.renderLoop, this);
      this.updateOrientation = bind(this.updateOrientation, this);
      this.logger = new Logger();
      this.fps = new Fps();
      this.registerEvents();
      this.logger.log('init three');
      this.initThree();
      this.logger.log('start renderloop');
      this.renderLoop(0);
    }

    JewelClone.prototype.registerEvents = function() {
      return window.addEventListener('deviceorientation', this.updateOrientation);
    };

    JewelClone.prototype.realWidth = function() {
      return window.innerWidth * window.devicePixelRatio;
    };

    JewelClone.prototype.realHeight = function() {
      return window.innerHeight * window.devicePixelRatio;
    };

    JewelClone.prototype.aspect = function() {
      return window.innerWidth / window.innerHeight;
    };

    JewelClone.prototype.updateOrientation = function(orientation) {
      this.deviceAlpha = orientation.alpha;
      this.deviceGamma = orientation.gamma;
      return this.deviceBeta = orientation.beta;
    };

    JewelClone.prototype.initThree = function() {
      var geometry, light, material;
      document.body.style.zoom = 1 / window.devicePixelRatio;
      this.scene = new THREE.Scene();
      this.camera = new THREE.PerspectiveCamera(75, this.aspect(), 0.1, 1000);
      this.renderer = new THREE.WebGLRenderer({
        antialias: true
      });
      this.renderer.setSize(this.realWidth(), this.realHeight());
      document.body.appendChild(this.renderer.domElement);
      this.deviceAlpha = null;
      this.deviceGamma = null;
      this.deviceBeta = null;
      this.betaAxis = 'x';
      this.gammaAxis = 'y';
      this.betaAxisInversion = -1;
      this.gammaAxisInversion = -1;
      geometry = new THREE.BufferGeometry().fromGeometry(new THREE.BoxGeometry(1, 1, 1));
      material = new THREE.MeshLambertMaterial({
        color: 'blue',
        ambient: 'blue'
      });
      this.cube = new THREE.Mesh(geometry, material);
      this.scene.add(new THREE.AmbientLight(0x555555));
      light = new THREE.DirectionalLight(0xffffff, 1);
      light.position.z = 3;
      light.position.y = 1;
      this.scene.add(light);
      this.scene.add(this.cube);
      this.camera.position.z = 3;
      return this.frames = 0;
    };

    JewelClone.prototype.updateCube = function() {
      this.cube.rotation[this.betaAxis] = this.deviceBeta * (Math.PI / 180) * this.betaAxisInversion;
      return this.cube.rotation[this.gammaAxis] = this.deviceGamma * (Math.PI / 180) * this.gammaAxisInversion;
    };

    JewelClone.prototype.renderLoop = function(t) {
      requestAnimationFrame(this.renderLoop);
      this.updateCube();
      this.fps.update(t);
      return this.renderer.render(this.scene, this.camera);
    };

    return JewelClone;

  })();

  Logger = (function() {
    function Logger() {
      this.loglines = [];
      this.createDiv();
    }

    Logger.prototype.createDiv = function() {
      var div;
      div = document.createElement("div");
      div.id = 'log';
      return document.getElementsByTagName('body')[0].appendChild(div);
    };

    Logger.prototype.log = function(text) {
      this.loglines.push(text);
      return document.getElementById('log').innerText = this.loglines.join("\n");
    };

    return Logger;

  })();

}).call(this);
