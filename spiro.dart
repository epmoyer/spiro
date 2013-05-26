import 'dart:html';
import 'dart:math';

num fpsAverage;
var spirograph;

void main() {  
  spirograph = new Spirograph(query("#container"));
  spirograph.start();
  //sprioEngine.start();
}

/**
 * Display the animation's FPS in a div.
 */
void showFps(num fps) {
  if (fpsAverage == null) {
    fpsAverage = fps;
  }

  fpsAverage = fps * 0.05 + fpsAverage * 0.95;

  query("#notes").text = "${fpsAverage.round().toInt()} fps";
}

class Spirograph {
  int num_wheels = 3;
  var wheels_1 = [];
  var wheels_2 = [];
  var wheels_interpolate = [];
  CanvasElement canvas;
  num _width;
  num _height;
  num renderTime;
  double slew = 0.00;
  bool slew_increasing = true;
  double rotation = 0.0;
  
  num get width => _width;
  num get height => _height;
  
  Spirograph(this.canvas){
    for(int i=0; i<num_wheels; i++){
      wheels_1.add(new Wheel());
      wheels_2.add(new Wheel());
      wheels_interpolate.add(new Wheel());
      
      randomize(wheels_1);
      randomize(wheels_2);
    }
    
    // Measure the canvas element.
    window.setImmediate(() {
      _width = (canvas.parent as Element).client.width;
      _height = (canvas.parent as Element).client.height;

      canvas.width = _width;
    });
  }
  
  start(){
    requestRedraw();
  }
  
  void draw(num _) {
    num time = new DateTime.now().millisecondsSinceEpoch;

    if (renderTime != null) {
      showFps((1000 / (time - renderTime)).round());
    }
    renderTime = time;
    
    if(slew_increasing){
      slew += 0.002;
      if(slew>=1.0){
        slew_increasing = false;
        randomize(wheels_2);
      }
    }
    else{
      slew -= 0.002;
      if(slew<=0.0){
        slew_increasing = true;
        randomize(wheels_1);
      }
    }
    interpolate(wheels_1, wheels_2, wheels_interpolate, (cos(slew*PI)+1.0)/2.0);

    render();
    requestRedraw();
  }
  
  void requestRedraw() {
    window.requestAnimationFrame(draw);
  }
  
  void randomize(var wheel_list) {
    // create random wheels
    for(var wheel in wheel_list){
      wheel.randomize();
    }
  }
  
  void interpolate(var wheel_list_1, var wheel_list_2, var interpolated_wheel_list, double slew){
    for(int i=0; i<num_wheels; i++){
      var r1 = wheel_list_1[i].radius;
      var r2 = wheel_list_2[i].radius;
      interpolated_wheel_list[i].radius = r1 + (r2 - r1)*slew;

      var sf1 = wheel_list_1[i].speed_factor;
      var sf2 = wheel_list_2[i].speed_factor;
      interpolated_wheel_list[i].speed_factor = sf1 + (sf2 - sf1)*slew;
    }
  }

  void render(){
    var context = this.canvas.context2D;
    // Clear the background
    context.fillStyle = 'blue';
    context.strokeStyle = 'blue';
    context.clearRect(0, 0, width, height);
    
    Point center = new Point(width/2, height/2);
    
    // Draw a circle at center
    /*
    context.beginPath();
    context.arc(center.x, center.y, 5, 0, PI * 2, true);
    context.closePath();
    context.fill();
    */
    
    // Draw spirograph
    bool first_point = true;
    double prev_x = 0.0;
    double prev_y = 0.0;
    double temp_x = 0.0;
    double temp_y = 0.0;
    double cur_x = 0.0;
    double cur_y = 0.0;
    double step = PI/400.0;
    
    context.lineWidth = 3.0;
    for(double angle=0.0; angle<=2.0*PI + 2.0*step; angle+=PI/400.0){
      prev_x = cur_x;
      prev_y = cur_y;
      temp_x = 0.0;
      temp_y = 0.0;
      
      for(var wheel in wheels_interpolate){
        temp_x += cos(angle * wheel.speed_factor) * wheel.radius;
        temp_y += sin(angle * wheel.speed_factor) * wheel.radius;
      }
      double s = sin(rotation);
      double c = cos(rotation);
      cur_x = (temp_x * c) - (temp_y * s) + center.x;
      cur_y = (temp_x * s) + (temp_y * c) + center.y;
      
      if (!first_point) {
        double color_factor = angle/(2.0*PI);
        context
          ..strokeStyle = 'rgb(64,'+ (255*(1.0-color_factor)).floor().toString() + ',' + (255*color_factor).floor().toString() + ')'
          ..beginPath()
          ..moveTo(prev_x, prev_y)
          ..lineTo(cur_x, cur_y)
          ..stroke();
      }
      first_point = false;
    }
    rotation += PI/3000.0;
    
    //print('render()');
  }
}

class Wheel {
  double radius;
  double speed_factor;
  
  void randomize(){
    Random random = new Random();
    
    radius = 20.0 + 60.0 * random.nextDouble();
    speed_factor = random.nextInt(20).toDouble();
  }
}