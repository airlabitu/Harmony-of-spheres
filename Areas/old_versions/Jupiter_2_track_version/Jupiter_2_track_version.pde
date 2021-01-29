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
int millisToFadeOutside = 2000;
int millisToFadeNoBlobs = 5000;

float globalMax;

void setup() {
  size(640, 480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this, 6789);
  spheresClean = new Sphere [9];
  spheresFX = new Sphere [9];

  // turn off sounds
  spheresFX[0] = new Sphere(100, 100, 75, "martha_med_fx/1.wav", this, 1, 2);
  spheresFX[1] = new Sphere(300, 100, 75, "martha_med_fx/2.wav", this, 2, 4);
  spheresFX[2] = new Sphere(500, 100, 75, "martha_med_fx/3.wav", this, 3, 3);
  spheresFX[3] = new Sphere(100, 250, 75, "martha_med_fx/4.wav", this, 4, 3);
  spheresFX[4] = new Sphere(300, 250, 75, "martha_med_fx/5.wav", this, 5, 1);
  spheresFX[5] = new Sphere(500, 250, 75, "martha_med_fx/6.wav", this, 6, 4);
  spheresFX[6] = new Sphere(100, 400, 75, "martha_med_fx/7.wav", this, 7, 4);
  spheresFX[7] = new Sphere(300, 400, 75, "martha_med_fx/8.wav", this, 8, 3);
  spheresFX[8] = new Sphere(500, 400, 75, "martha_med_fx/9.wav", this, 9, 2);
  
  spheresClean[0] = new Sphere(100, 100, 75, "martha_uden_fx/1.wav", this, 1, 2);
  spheresClean[1] = new Sphere(300, 100, 75, "martha_uden_fx/2.wav", this, 2, 4);
  spheresClean[2] = new Sphere(500, 100, 75, "martha_uden_fx/3.wav", this, 3, 3);
  spheresClean[3] = new Sphere(100, 250, 75, "martha_uden_fx/4.wav", this, 4, 3);
  spheresClean[4] = new Sphere(300, 250, 75, "martha_uden_fx/5.wav", this, 5, 1);
  spheresClean[5] = new Sphere(500, 250, 75, "martha_uden_fx/6.wav", this, 6, 4);
  spheresClean[6] = new Sphere(100, 400, 75, "martha_uden_fx/7.wav", this, 7, 4);
  spheresClean[7] = new Sphere(300, 400, 75, "martha_uden_fx/8.wav", this, 8, 3);
  spheresClean[8] = new Sphere(500, 400, 75, "martha_uden_fx/9.wav", this, 9, 2);
  
  globalMax = spheresClean[0].vol.getMax();
  
  for (Sphere s : spheresFX) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    //s.enableEnvelope(this); // ###envelope
    //s.enableRate(); // ### rate
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
  }
  for (Sphere s : spheresClean) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    //s.enableEnvelope(this); // ###envelope
    //s.enableRate(); // ### rate
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
  }
}


void draw() {
  background(0);

  for (Sphere s : spheresFX) {
    s.show();
    s.update();
    if (simulate) mouseInteraction(s, "FX");
    else blobsInteraction(s, "FX");
  }
  for (Sphere s : spheresClean) {
    s.show();
    s.update();
    if (simulate) mouseInteraction(s, "Clean");
    else blobsInteraction(s, "Clean");
  }
  fill(0, 0, 255);
  text("Simulate: " + simulate, 50, height -10);
}


void oscEvent(OscMessage theOscMessage) {
  println("--- OSC MESSAGE RECEIVED ---");
  // Check if the address pattern is the right one
  if (theOscMessage.checkAddrPattern("/Blobs|X|Y|MIN_DEPTH|ID|NR_OF_PIXELS|")==true) {
    println("AddressPattern matched:", theOscMessage.addrPattern());
    // check if the typetag is the right one
    String typeTag = "";
    for (int i = 0; i < theOscMessage.typetag().length(); i++) typeTag += "i";
    if (theOscMessage.checkTypetag(typeTag)) {
      println("TypeTag matched:", theOscMessage.typetag());
      blobs = new Blob[theOscMessage.typetag().length()/5];
      println("Blobs length: ", blobs.length);
      for (int i = 0, j = 0; i <= theOscMessage.typetag().length()-5; i+=5, j++) {
        int x, y, blobMinDepth, id, nrOfPixels__;
        x = theOscMessage.get(i).intValue();
        y = theOscMessage.get(i+1).intValue();
        blobMinDepth = theOscMessage.get(i+2).intValue();
        id = theOscMessage.get(i+3).intValue();
        nrOfPixels__ = theOscMessage.get(i+4).intValue();

        blobs[j] = new Blob(x, y, blobMinDepth, id, nrOfPixels__);
        println("X: ", x, "Y: ", y, "Min Depth", blobMinDepth, "ID: ", id, "Pixels: ", nrOfPixels__);
      }
      framesSinceLastOscMessage = 0;
    }
  }
  println("----------------------------");
  println();
}

void mouseInteraction(Sphere s, String type) {
  fill(0, 255, 0);
  ellipse(mouseX, mouseY, 20, 20);
  int d = (int)dist(mouseX, mouseY, s.x, s.y);
  soundManipulation(s, d, type);
}

void blobsInteraction(Sphere s, String type) {
  if (framesSinceLastOscMessage > 25) {
    blobs = null;

    s.vol.setVal(s.vol.getMin(), millisToFadeNoBlobs);
  }
  if (blobs != null) {
    int minDist = 999999999;
    for (Blob b : blobs) {
      if (b != null) {
        int thisDist = (int)dist(b.x, b.y, s.x, s.y);
        if (thisDist < minDist) minDist = thisDist; 

        fill(map(b.minDepth, 0, 2047, 255, 0));
        ellipse(b.x, b.y, 50, 50);
      }
    }
    if (minDist != 999999999) {
      soundManipulation(s, minDist, type);
    }
  }
  framesSinceLastOscMessage++;
}

void soundManipulation(Sphere s, int dist, String type) {
  // turn off
  if (dist < s.radius) {
    if (type.equals("FX")){
      float max = map(dist, 0, s.radius, s.vol.getMin(), globalMax); 
      s.vol.setMinMax(s.vol.getMin(), max);
      s.vol.setVal(map(constrain(dist, s.radius*0.9, s.radius), 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis
    }
    else if (type.equals("Clean")) s.vol.setVal(map(dist, 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis
    
    if (s.delayEnabled) s.delayVal.setVal(map(dist, 0, s.radius, s.delayVal.getMax(), s.delayVal.getMin()), millisToFadeInside);
    if (s.envelopeEnabled){
      float position = map(dist, 0, s.radius, 0, s.track.duration()); // interactive cue point
      //float position = random(0, s.track.duration()); // random cue point
      s.envelope.setDuration((int)map(dist, 0, s.radius, 100, 1500)); 
      s.envelope.update(position); // (a) set random or interactive cue point 
      //s.envelope.update(); // (b) set regular cue (follows time) 
    }
    if (s.rateEnabled) s.rate.setVal(map(dist, 0, s.radius, s.rate.getMin(), s.rate.getMax()), millisToFadeInside); 
  }
  else {
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside); // shift to min
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside); 
    //###envDev --- missing here!
    if (s.rateEnabled) s.rate.setVal(s.rate.getMin(), millisToFadeOutside);
  }
}

void soundManipulationClean(Sphere s, int dist) {
  // turn off
  if (dist < s.radius) {
    s.vol.setVal(map(dist, 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis
    if (s.delayEnabled) s.delayVal.setVal(map(dist, 0, s.radius, s.delayVal.getMax(), s.delayVal.getMin()), millisToFadeInside);
    if (s.envelopeEnabled){
      float position = map(dist, 0, s.radius, 0, s.track.duration()); // interactive cue point
      //float position = random(0, s.track.duration()); // random cue point
      s.envelope.setDuration((int)map(dist, 0, s.radius, 100, 1500)); 
      s.envelope.update(position); // (a) set random or interactive cue point 
      //s.envelope.update(); // (b) set regular cue (follows time) 
    }
    if (s.rateEnabled) s.rate.setVal(map(dist, 0, s.radius, s.rate.getMax(), s.rate.getMin()), millisToFadeInside); 
  }
  else {
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside); // shift to min
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside); 
    //###envDev --- missing here!
    if (s.rateEnabled) s.rate.setVal(s.rate.getMin(), millisToFadeOutside);
  }
}


// key for toggling mouse simulation
void keyPressed() {
  if (key == 's') simulate = !simulate;
}
