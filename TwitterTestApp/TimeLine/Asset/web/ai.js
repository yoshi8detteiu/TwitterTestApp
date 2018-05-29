

var velocity = 80;        // for add t
var acceleration = 0.07; // for add velocity

function sketchProc(processing) {

    processing.setup = function() {
      processing.size(320, 320, processing.P3D);
      processing.frameRate(30);
      processing.background(0, 0);
    }

    processing.draw = function() {
      processing.background(0, 0);

      // 位置
      processing.translate(160, 160, 0);
      // 回転
      processing.rotateX(processing.frameCount*0.01);
      processing.rotateY(processing.frameCount*0.01);
      //processing.rotateZ(processing.frameCount*0.01);
      // 線の太さ
      processing.strokeWeight(1);

      var lastX = 0;
      var lastY = 0;
      var lastZ = 0;
      var radius = 140;
      var s = 0;
      var t = 0;
        
      while(s <= 180){
        var radianS = processing.radians(s);
        var radianT = processing.radians(t);
        var x = radius * processing.sin(radianS) * processing.cos(radianT);
        var y = radius * processing.sin(radianS) * processing.sin(radianT);;
        var z = radius * processing.cos(radianS);

        // 色
        processing.stroke(s * 1.1, 156 + s/3, 240 - s/5);

        if(lastX != 0){
          processing.line(x, y, z, lastX, lastY, lastZ);
        }
        
        lastX = x;
        lastY = y;
        lastZ = z;
        
        s++;
        t += velocity;
      }
      velocity += acceleration;
    }
  }

  var canvas = document.getElementById("canvas");
  var p = new Processing(canvas, sketchProc);
