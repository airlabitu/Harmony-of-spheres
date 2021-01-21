/**
 * This sketch shows how to use envelopes and oscillators. Envelopes are pre-defined
 * amplitude distributions over time. The sound library provides an ASR envelope which
 * stands for attack, sustain, release. The amplitude first rises, then sustains at the
 * maximum level and decays slowly, all depending on the pre-defined length of the three
 * time segments.
 *
 *      .________
 *     .          ---
 *    .              --- 
 *   .                  ---
 *   A       S        R 
 */

import processing.sound.*;

SoundFile s1;

Envelope env;

boolean positionEnabled = false;




void setup() {
  size(640, 360);
  //s1 = new SoundFile(this, "hannah_8.wav");//"1.wav");
  //s1 = new SoundFile(this, "hannah_7.wav");//"1.wav");
  s1 = new SoundFile(this, "hannah_9.wav");//"1.wav");
  
  s1.loop();
  env = new Envelope(this, s1);
  stroke(255);
}

void draw() {
  float position = map(mouseX, 0, width, 0, s1.duration());
  env.setDuration((int)map(mouseY, 0, height, 10, 1500));
  if (positionEnabled) env.update(position);
  else env.update();
  
  background(0);
  line(0, mouseY, width, mouseY);
  line(mouseX, 0, mouseX, height);
  
  text("position: " + nf(s1.position() , 0, 2) + " --- follow mouse: " + positionEnabled, 10, height-20);
  text("duration: " + env.duration, 10, height-40);
  text("duration: " + env.duration, 10, height-40);
  text("attackTime: " + env.attackTime, 10, height-60);
  text("sustainTime: " + env.sustainTime, 10, height-80);
  text("sustainLevel: " + env.sustainLevel, 10, height-100);
  text("releaseTime: " + env.releaseTime, 10, height-120);
  
}

void mouseReleased(){
  positionEnabled = ! positionEnabled;
}
