/*
  Make a static grain
  Start a fast fade down to min vol at mouse released
  When fade reached set grain to new value, and start a fade up to max vol
*/

import processing.sound.*;

SoundFile track;
ValueFader vol;

void setup(){
  size(400, 400);
  track = new SoundFile(this, "1.wav");
  track.loop();
  vol = new ValueFader();
  
}

void draw(){
  vol.update();
  println("Vol", vol.getVal());
}

void mouseReleased(){
  vol.setVal(map(mouseX, 0, width, vol.getMin(), vol.getMax()), 1300);
}
