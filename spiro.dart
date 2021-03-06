//-----------------------------------------------------------------------------
// Copyright (c) 2013, Eric Moyer.
//
// Distributed under the terms of the Modified BSD License.
//
// The full license is in the file COPYING.txt, distributed with this software.
//-----------------------------------------------------------------------------
// Source code: https://github.com/epmoyer/spiro
// Web demo:    http://www.lemoncrab.com/spiro/spiro.html
//-----------------------------------------------------------------------------

import 'dart:html';
import 'dart:math';

var version = 'v1.1';
bool show_fps = true; // Enable to show FPS when running
num fpsAverage;
var spirograph;
num max_wheel_radius  = 0.0;
var speed_factors = [-19, -17, -13, -11, -7, -5, -3, -2, 2, 3, 5, 7, 11, 13, 17, 19];

void main() {  
  spirograph = new Spirograph(query("#container"));
  spirograph.start();
}

//-------------------------------------------
// Show animation FPS (frames per second)
//-------------------------------------------
void showFps(num fps) {
  if (show_fps){
    if (fpsAverage == null) {
      fpsAverage = fps;
    }
  
    fpsAverage = fps * 0.05 + fpsAverage * 0.95;
  
    query("#notes").text = "${version}, ${fpsAverage.round().toInt()} fps";
  }
}

//-------------------------------------------
// Spirograph class
//-------------------------------------------
class Spirograph {
  int num_wheels = 5;
  var wheels_1 = [];
  var wheels_2 = [];
  var wheels_interpolate = [];
  CanvasElement canvas;
  num _width;
  num _height;
  num refreshTime;
  num slew = 0.00;
  bool slew_increasing = true;
  num rotation = 0.0;
  
  // Slowly rotate the figure
  num rotation_radians_per_sec = (2 * PI)/100;
  num slew_per_sec = 0.12;
  
  num get width => _width;
  num get height => _height;
  
  Spirograph(this.canvas){
    // Set canvas size and max wheel radius
    num margin = 130;
    _height = window.innerHeight - margin;
    _width = window.innerWidth - 20;

    canvas.width = _width;
    canvas.height = _height;
    max_wheel_radius = (min(canvas.width, canvas.height)/2)/num_wheels - 10;
   
    // Create initial wheels
    for(int i=0; i<num_wheels; i++){
      wheels_1.add(new Wheel());
      wheels_2.add(new Wheel());
      wheels_interpolate.add(new Wheel());
      
      randomize(wheels_1);
      randomize(wheels_2);
    }
  }
  
  start(){
    requestRedraw();
  }
  
  void draw(num _) {
    num elapsed_seconds;
    num time = new DateTime.now().millisecondsSinceEpoch;

    if (refreshTime != null) {
      elapsed_seconds = (time - refreshTime) / 1000;
      showFps((1/elapsed_seconds).round());
    }else{
      elapsed_seconds = 1/60;
    }
    refreshTime = time;
    
    rotation += elapsed_seconds * rotation_radians_per_sec;
    
    if(slew_increasing){
      slew += elapsed_seconds * slew_per_sec;
      if(slew>=1.0){
        slew_increasing = false;
        randomize(wheels_2);
      }
    }
    else{
      slew -= elapsed_seconds * slew_per_sec;
      if(slew<=0.0){
        slew_increasing = true;
        randomize(wheels_1);
      }
    }
    interpolate(wheels_1, wheels_2, wheels_interpolate, (cos(slew*PI)+1.0)/2.0);

    render();
    time = new DateTime.now().millisecondsSinceEpoch;
    query("#notes").text += ", ${(time - refreshTime)} msec render";
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
  
  //-------------------------------------------
  // interpolate
  //   Given two wheel lists (effectively, the coefficients for two different
  //   spirographs) and an interpolation slew factor (between zero and one), 
  //   generates an interpolated wheel list (effectively, the 
  //   coefficents representing a spirograph that is 'slew' distant between
  //   the first and the second).
  //-------------------------------------------
  void interpolate(var wheel_list_1, var wheel_list_2, var interpolated_wheel_list, num slew){
    for(int i=0; i<num_wheels; i++){
      // Interpolate radius
      var r1 = wheel_list_1[i].radius;
      var r2 = wheel_list_2[i].radius;
      interpolated_wheel_list[i].radius = r1 + (r2 - r1)*slew;

      // Interpolate speed factor
      var sf1 = wheel_list_1[i].speed_factor;
      var sf2 = wheel_list_2[i].speed_factor;
      interpolated_wheel_list[i].speed_factor = sf1 + (sf2 - sf1)*slew;
    }
  }

  //-------------------------------------------
  // Render the spirograh
  //-------------------------------------------
  void render(){
    var context = this.canvas.context2D;
    
    // Clear the background
    context.clearRect(0, 0, width, height);
    
    Point center = new Point(width/2, height/2);
    
    // Draw spirograph
    bool first_point = true;
    num prev_x = 0.0;
    num prev_y = 0.0;
    num temp_x = 0.0;
    num temp_y = 0.0;
    num cur_x = 0.0;
    num cur_y = 0.0;
    num step = PI/400.0;
    
    context.lineWidth = 3;
    for(num angle=0.0; angle<=2.0*PI + 2.0*step; angle+=PI/400.0){
      prev_x = cur_x;
      prev_y = cur_y;
      temp_x = 0.0;
      temp_y = 0.0;
      
      for(var wheel in wheels_interpolate){
        temp_x += cos(angle * wheel.speed_factor) * wheel.radius;
        temp_y += sin(angle * wheel.speed_factor) * wheel.radius;
      }
      
      // Rotate the figure about the orign, and translate it to the
      // center.
      num s = sin(rotation);
      num c = cos(rotation);
      cur_x = (temp_x * c) - (temp_y * s) + center.x;
      cur_y = (temp_x * s) + (temp_y * c) + center.y;
      
      if (!first_point) {
        num color_factor = angle/(2.0*PI);
        context
          ..strokeStyle = 'rgb(64,'+ (255*(1.0-color_factor)).floor().toString() + ',' + (255*color_factor).floor().toString() + ')'
          ..beginPath()
          ..moveTo(prev_x, prev_y)
          ..lineTo(cur_x, cur_y)
          ..stroke();
      }
      first_point = false;
    }
  }
}

//-------------------------------------------
// Wheel class
//-------------------------------------------
class Wheel {
  num radius=0.0;
  num speed_factor=1.0;
  
  void randomize(){
    Random random = new Random();
    
    radius = max_wheel_radius * 0.2 + max_wheel_radius * 0.8 * random.nextDouble();
    speed_factor = speed_factors[random.nextInt(speed_factors.length)];
  }
}