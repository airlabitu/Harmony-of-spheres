/*
  Make a static grain
  Start a fast fade down to min vol at mouse released
  When fade reached set grain to new value, and start a fade up to max vol
*/

import processing.sound.*;

int grainState = 0; // | 0: ready | 1: fade down | 2: jump | 3: fade up |

SoundFile track;
ValueFader vol;

long grainTimer = 0;
int grainInterval = 3000;

float volAtGrainStart;

void setup(){
  size(400, 400);
  track = new SoundFile(this, "1.wav");
  track.play();
  vol = new ValueFader();
  vol.setVal(0.5, 100);
  vol.setMinMax(-0.5, 0.9);
  println("Duration", track.duration());
  
}

void draw(){
  
  background(0);
  vol.update();
  track.amp(vol.getVal());
  text(vol.getVal(), 200, 200);
  text(track.position(), 200, 300);
  //println("Vol", vol.getVal());
  
  if (millis() > grainTimer + grainInterval && grainState == 0){
    grainState = 1;
    println("shift to state 1");
    volAtGrainStart = vol.getVal();
    vol.setVal(vol.getMin(), 200);
    grainTimer = millis();
    float destination = random(0, track.duration()-2);
    println("next desatination:", destination);
    //track.pause();
    //track.jump(destination);
    //track.cue(destination);
    grainTimer = millis();
  }
  
  
  else if (grainState == 1){
    if (vol.getVal() == vol.getMin()){
      grainState = 2;
      println("shift to state 2");
    }
  }
  
  
  else if (grainState == 2){
    // jump
    float destination = random(0, track.duration());
    //track.pause();
    //track.jump(destination);
    track.cue(destination);
    println("jump to", destination);
    //track.play();
    //track.play();
    
    vol.setVal(volAtGrainStart, 200); // start fade up
    grainState = 3;
    println("shift to state 3");
  }
  
  else if (grainState == 3){
    if (vol.getVal() == volAtGrainStart){ // done with grain process
      grainState = 0;
      println("shift to state 0");
      //grainTimer = millis();
    }
  }
  
  
  if (!track.isPlaying()) track.play();
}

void mouseReleased(){
  vol.setVal(map(mouseX, 0, width, vol.getMin(), vol.getMax()), 1300);
}
