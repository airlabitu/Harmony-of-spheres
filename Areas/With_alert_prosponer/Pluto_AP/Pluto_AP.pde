// This is the template sketch for the HoS project planet sound sketches
// Volumen is going from low to high, the effects: Delay, Envelope, Rate are all implemented into the sphere class
// This happens when a user enters the sphere circle, and is adjusted according to distance from user blob center to sphere cente

import oscP5.*;
import processing.sound.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

Sphere [] spheres;

boolean simulate = false;
int millisToFadeInside = 300;
int millisToFadeOutside = 1000;
int millisToFadeNoBlobs = 5000;

boolean groupsEnabled = false;

// alert prosponer
OscAlertProsponer soundAlertProsponer;

void setup() {
  size(640, 480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this, 6789);
  spheres = new Sphere [9];

  // turn off sounds
  spheres[0] = new Sphere(165, 45, 90, "1.wav", this, 1, 2);
  spheres[1] = new Sphere(341, 60, 90, "2.wav", this, 2, 4);
  spheres[2] = new Sphere(512, 58, 90, "3.wav", this, 3, 3);
  spheres[3] = new Sphere(168, 221, 90, "4.wav", this, 4, 3);
  spheres[4] = new Sphere(338, 225, 90, "5.wav", this, 5, 1);
  spheres[5] = new Sphere(503, 225, 90, "6.wav", this, 6, 4);
  spheres[6] = new Sphere(167, 388, 90, "7.wav", this, 7, 4);
  spheres[7] = new Sphere(335, 390, 90, "8.wav", this, 8, 3);
  spheres[8] = new Sphere(505, 394, 90, "9.wav", this, 9, 2);
  
  //old mapping
  /*spheres[0] = new Sphere(489, 93, 90, "1.wav", this, 1, 2);
  spheres[1] = new Sphere(319, 104, 90, "2.wav", this, 2, 4);
  spheres[2] = new Sphere(143, 98, 90, "3.wav", this, 3, 3);
  spheres[3] = new Sphere(489, 250, 90, "4.wav", this, 4, 3);
  spheres[4] = new Sphere(321, 250, 90, "5.wav", this, 5, 1);
  spheres[5] = new Sphere(147, 255, 90, "6.wav", this, 6, 4);
  spheres[6] = new Sphere(500, 407, 90, "7.wav", this, 7, 4);
  spheres[7] = new Sphere(325, 410, 90, "8.wav", this, 8, 3);
  spheres[8] = new Sphere(149, 408, 90, "9.wav", this, 9, 2);*/

  for (Sphere s : spheres) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    //s.rate.setMinMax(0.92, 1.0);
    //s.rate.reverse(true);    
    
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
  
  }
  
  // alert prosponer
  soundAlertProsponer = new OscAlertProsponer(oscP5, "127.0.0.1", 11011, "/SoundAlive");
  soundAlertProsponer.isActive = true;
}


void draw() {
  background(0);

  for (Sphere s : spheres) {
    s.show(255, 255, 255);
    s.update();
    if (simulate) mouseInteraction(s, spheres, "LINEAR_FADE");
    else blobsInteraction(s, spheres, "LINEAR_FADE");
  }
  fill(0, 0, 255);
  text("Simulate: " + simulate, 50, height -10);
  
  // update alert prosponer
  soundAlertProsponer.update();
}
