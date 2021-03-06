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
int millisToFadeOutside = 2000;
int millisToFadeNoBlobs = 5000;

boolean groupsEnabled = false;

void setup() {
  size(640, 480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this, 6789);
  spheres = new Sphere [9];

  // turn off sounds
  spheres[0] = new Sphere(100, 100, 75, "1.wav", this, 1, 2);
  spheres[1] = new Sphere(300, 100, 75, "2.wav", this, 2, 4);
  spheres[2] = new Sphere(500, 100, 75, "3.wav", this, 3, 3);
  spheres[3] = new Sphere(100, 250, 75, "4.wav", this, 4, 3);
  spheres[4] = new Sphere(300, 250, 75, "5.wav", this, 5, 1);
  spheres[5] = new Sphere(500, 250, 75, "6.wav", this, 6, 4);
  spheres[6] = new Sphere(100, 400, 75, "7.wav", this, 7, 4);
  spheres[7] = new Sphere(300, 400, 75, "8.wav", this, 8, 3);
  spheres[8] = new Sphere(500, 400, 75, "9.wav", this, 9, 2);

  for (Sphere s : spheres) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    s.rate.setMinMax(0.92, 1.0);
    //s.rate.reverse(true);    
    
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
  
  }
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
}
