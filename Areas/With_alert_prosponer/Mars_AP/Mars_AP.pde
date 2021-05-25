// This is the template sketch for the HoS project planet sound sketches
// Volumen is going from low to high, the effects: Delay, Envelope, Rate are all implemented into the sphere class
// This happens when a user enters the sphere circle, and is adjusted according to distance from user blob center to sphere cente

import oscP5.*;
import processing.sound.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

Sphere [] spheresFX;
Sphere [] spheresClean;

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
  spheresClean = new Sphere [9];
  spheresFX = new Sphere [9];
  
  // create spheres
  
  // Uranus
  spheresFX[0] = new Sphere(143, 98, 90, "with_fx/1.wav", this, 1, -1);
  spheresFX[0].track.loop();
  spheresFX[0].track.amp(spheresFX[0].vol.getMin());
  spheresFX[0].vol.setVal(spheresFX[0].vol.getMin(), millisToFadeOutside);
  spheresFX[0].enableRate(); // ### rate
  spheresFX[0].rate.setMinMax(0.92, 1.0);
  spheresClean[0] = new Sphere(143, 98, 90, "without_fx/1.wav", this, 1, -1);
  spheresClean[0].track.loop();
  spheresClean[0].track.amp(spheresClean[0].vol.getMin());
  spheresClean[0].vol.setVal(spheresClean[0].vol.getMin(), millisToFadeOutside);
  spheresClean[0].enableRate(); // ### rate
  spheresClean[0].rate.setMinMax(0.92, 1.0);
  
  // Pluto
  spheresFX[1] = new Sphere(319, 104, 90, "with_fx/2.wav", this, 2, -2);
  spheresFX[1].track.loop();
  spheresFX[1].track.amp(spheresFX[1].vol.getMin());
  spheresFX[1].vol.setVal(spheresFX[1].vol.getMin(), millisToFadeOutside);
  spheresFX[1].enableRate(); // ### rate
  spheresFX[1].rate.reverse(true);
  spheresClean[1] = new Sphere(319, 104, 90, "without_fx/2.wav", this, 2, -2);
  spheresClean[1].track.loop();
  spheresClean[1].track.amp(spheresClean[1].vol.getMin());
  spheresClean[1].vol.setVal(spheresClean[1].vol.getMin(), millisToFadeOutside);
  spheresClean[1].enableRate(); // ### rate
  spheresClean[1].rate.reverse(true);
  
  // Neptun
  spheresFX[2] = new Sphere(489, 93, 90, "with_fx/3.wav", this, 3, 1);
  spheresFX[2].track.loop();
  spheresFX[2].track.amp(spheresFX[2].vol.getMin());
  spheresFX[2].vol.setVal(spheresFX[2].vol.getMin(), millisToFadeOutside);
  spheresFX[2].enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
  spheresFX[2].delayVal.setVal(0.5, 1); // ### delay value must be between 0.3 and 0.8, or min max must be changed
  spheresFX[2].enableRate(); // ### rate
  spheresFX[2].rate.setMinMax(0.92, 1.0);
  spheresClean[2] = new Sphere(489, 93, 90, "without_fx/3.wav", this, 3, 1);
  spheresClean[2].track.loop();
  spheresClean[2].track.amp(spheresClean[2].vol.getMin());
  spheresClean[2].vol.setVal(spheresClean[2].vol.getMin(), millisToFadeOutside);
  spheresClean[2].enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
  spheresClean[2].delayVal.setVal(0.5, 1); // ### delay value must be between 0.3 and 0.8, or min max must be changed
  spheresClean[2].enableRate(); // ### rate
  spheresClean[2].rate.setMinMax(0.92, 1.0);
  
  // Saturn
  spheresFX[3] = new Sphere(147, 255, 90, "with_fx/4.wav", this, 4, 1);
  spheresFX[3].track.loop();
  spheresFX[3].track.amp(spheresFX[3].vol.getMin());
  spheresFX[3].vol.setVal(spheresFX[3].vol.getMin(), millisToFadeOutside);
  spheresFX[3].enableRate(); // ### rate
  spheresFX[3].rate.setMinMax(0.92, 1.0);
  spheresClean[3] = new Sphere(147, 255, 90, "without_fx/4.wav", this, 4, 1);
  spheresClean[3].track.loop();
  spheresClean[3].track.amp(spheresClean[3].vol.getMin());
  spheresClean[3].vol.setVal(spheresClean[3].vol.getMin(), millisToFadeOutside);
  spheresClean[3].enableRate(); // ### rate
  spheresClean[3].rate.setMinMax(0.92, 1.0);
  
  // Mars
  spheresFX[4] = new Sphere(321, 250, 90, "with_fx/5.wav", this, 5, -5);
  spheresFX[4].track.loop();
  spheresFX[4].track.amp(spheresFX[4].vol.getMin());
  spheresFX[4].vol.setVal(spheresFX[4].vol.getMin(), millisToFadeOutside);
  spheresFX[4].enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
  spheresFX[4].delayVal.setVal(0.5, 1); // ### delay value must be between 0.3 and 0.8, or min max must be changed
  spheresFX[4].enableRate(); // ### rate
  spheresFX[4].rate.reverse(true);
  spheresClean[4] = new Sphere(321, 250, 90, "without_fx/5.wav", this, 5, -5);
  spheresClean[4].track.loop();
  spheresClean[4].track.amp(spheresClean[4].vol.getMin());
  spheresClean[4].vol.setVal(spheresClean[4].vol.getMin(), millisToFadeOutside);
  spheresClean[4].enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
  spheresClean[4].delayVal.setVal(0.5, 1); // ### delay value must be between 0.3 and 0.8, or min max must be changed
  spheresClean[4].enableRate(); // ### rate
  spheresClean[4].rate.reverse(true);
  
  // Jupiter
  spheresFX[5] = new Sphere(489, 250, 90, "with_fx/6.wav", this, 6, -6);
  spheresFX[5].track.loop();
  spheresFX[5].track.amp(spheresFX[5].vol.getMin());
  spheresFX[5].vol.setVal(spheresFX[5].vol.getMin(), millisToFadeOutside);
  spheresFX[5].enableRate(); // ### rate
  spheresFX[5].rate.setMinMax(0.92, 1.0);
  spheresClean[5] = new Sphere(489, 250, 90, "without_fx/6.wav", this, 6, -6);
  spheresClean[5].track.loop();
  spheresClean[5].track.amp(spheresClean[5].vol.getMin());
  spheresClean[5].vol.setVal(spheresClean[5].vol.getMin(), millisToFadeOutside);
  spheresClean[5].enableRate(); // ### rate
  spheresClean[5].rate.setMinMax(0.92, 1.0);
  
  // Merkur
  spheresFX[6] = new Sphere(149, 408, 90, "with_fx/7.wav", this, 7, -7);
  spheresFX[6].track.loop();
  spheresFX[6].track.amp(spheresFX[6].vol.getMin());
  spheresFX[6].vol.setVal(spheresFX[6].vol.getMin(), millisToFadeOutside);
  spheresFX[6].enableRate(); // ### rate
  spheresFX[6].rate.setMinMax(0.92, 1.0);
  spheresClean[6] = new Sphere(149, 408, 90, "without_fx/7.wav", this, 7, -7);
  spheresClean[6].track.loop();
  spheresClean[6].track.amp(spheresClean[6].vol.getMin());
  spheresClean[6].vol.setVal(spheresClean[6].vol.getMin(), millisToFadeOutside);
  spheresClean[6].enableRate(); // ### rate
  spheresClean[6].rate.setMinMax(0.92, 1.0);
  
  // Jorden
  spheresFX[7] = new Sphere(325, 410, 90, "with_fx/8.wav", this, 8, 1);
  spheresFX[7].track.loop();
  spheresFX[7].track.amp(spheresFX[7].vol.getMin());
  spheresFX[7].vol.setVal(spheresFX[7].vol.getMin(), millisToFadeOutside);
  spheresFX[7].enableRate(); // ### rate
  spheresFX[7].rate.setMinMax(0.92, 1.0);
  spheresClean[7] = new Sphere(325, 410, 90, "without_fx/8.wav", this, 8, 1);
  spheresClean[7].track.loop();
  spheresClean[7].track.amp(spheresClean[7].vol.getMin());
  spheresClean[7].vol.setVal(spheresClean[7].vol.getMin(), millisToFadeOutside);
  spheresClean[7].enableRate(); // ### rate
  spheresClean[7].rate.setMinMax(0.92, 1.0);
  
  // Venus
  spheresFX[8] = new Sphere(500, 407, 90, "with_fx/9.wav", this, 9, -9);
  spheresFX[8].track.loop();
  spheresFX[8].track.amp(spheresFX[8].vol.getMin());
  spheresFX[8].vol.setVal(spheresFX[8].vol.getMin(), millisToFadeOutside);
  spheresFX[8].enableRate(); // ### rate
  spheresFX[8].rate.setMinMax(0.92, 1.0);
  spheresClean[8] = new Sphere(500, 407, 90, "without_fx/9.wav", this, 9, -9);
  spheresClean[8].track.loop();
  spheresClean[8].track.amp(spheresClean[8].vol.getMin());
  spheresClean[8].vol.setVal(spheresClean[8].vol.getMin(), millisToFadeOutside);
  spheresClean[8].enableRate(); // ### rate
  spheresClean[8].rate.setMinMax(0.92, 1.0);
  
  // turn down the max vol of all the clean
  for (int i = 0; i < spheresClean.length; i++){
    spheresClean[i].vol.setMinMax(0.00001, 0.6); // ### 2-track : 
  }
  
  // prevent text overlap
  for (int i = 0; i < spheresFX.length; i++){
    spheresFX[i].yMove = -20;
    spheresClean[i].yMove = 20;
  }
  
  /*
  // settings for FX sounds
  for (Sphere s : spheresFX) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    s.rate.setMinMax(0.92,1.0); // ### rare
    //s.rate.reverse(true);
    if (s.delayEnabled) s.delayVal.setVal(0.5, 1);
    //if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
    
  }
  
  // settings for clean sounds
  for (Sphere s : spheresClean) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    s.rate.setMinMax(0.92,1.0); // ### rare
    //s.rate.reverse(true);
    if (s.delayEnabled) s.delayVal.setVal(0.5, 1);
    //if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
    s.vol.setMinMax(0.00001, 0.6); // ### 2-track : turn down the max of the clean
  }
  */
  
  // alert prosponer
  soundAlertProsponer = new OscAlertProsponer(oscP5, "127.0.0.1", 11011, "/SoundAlive");
  soundAlertProsponer.isActive = true;
}


void draw() {
  background(0);

  
  for (Sphere s : spheresFX) {
    s.show(0, 255, 0);
    s.update();
    if (simulate) mouseInteraction(s, spheresFX, "LINEAR_FADE");
    else blobsInteraction(s, spheresFX, "LINEAR_FADE");
  }
  
  for (Sphere s : spheresClean) {
    s.show(0, 0, 255);
    s.update();
    if (simulate) mouseInteraction(s, spheresClean, "SINUS_FADE");
    else blobsInteraction(s, spheresClean, "SINUS_FADE");
  }
  
  fill(0, 0, 255);
  text("Simulate: " + simulate, 50, height -10);
  
  // update alert prosponer
  soundAlertProsponer.update();
}
