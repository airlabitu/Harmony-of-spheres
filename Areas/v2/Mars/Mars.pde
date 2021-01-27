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

void setup() {
  size(640, 480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this, 6789);
  spheres = new Sphere [9];

  // Uranus
  spheres[0] = new Sphere(100, 100, 75, "1.wav", this, 1, -1);
  spheres[0].track.loop();
  spheres[0].track.amp(spheres[0].vol.getMin());
  spheres[0].vol.setVal(spheres[0].vol.getMin(), millisToFadeOutside);
  spheres[0].enableRate(); // ### rate
  spheres[0].rate.setMinMax(0.92, 1.0);
    
  // Pluto
  spheres[1] = new Sphere(300, 100, 75, "2.wav", this, 2, -2);
  spheres[1].track.loop();
  spheres[1].track.amp(spheres[1].vol.getMin());
  spheres[1].vol.setVal(spheres[1].vol.getMin(), millisToFadeOutside);
  spheres[1].enableRate(); // ### rate
  
  // Neptun
  spheres[2] = new Sphere(500, 100, 75, "3.wav", this, 3, 1);
  spheres[2].track.loop();
  spheres[2].track.amp(spheres[2].vol.getMin());
  spheres[2].vol.setVal(spheres[2].vol.getMin(), millisToFadeOutside);
  spheres[2].enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
  spheres[2].delayVal.setVal(0.5, 1); // ### delay value must be between 0.3 and 0.8, or min max must be changed
  
  // Saturn - sound within a sound effect made in soundfile
  spheres[3] = new Sphere(100, 250, 75, "4.wav", this, 4, 1);
  spheres[3].track.loop();
  spheres[3].track.amp(spheres[3].vol.getMin());
  spheres[3].vol.setVal(spheres[3].vol.getMin(), millisToFadeOutside);
  spheres[3].enableRate(); // ### rate
  spheres[3].rate.setMinMax(0.92, 1.0);
  
  // Mars - All sounds effects made in soundfile 
  spheres[4] = new Sphere(300, 250, 75, "5.wav", this, 5, -5);
  spheres[4].track.loop();
  spheres[4].track.amp(spheres[4].vol.getMin());
  spheres[4].vol.setVal(spheres[4].vol.getMin(), millisToFadeOutside);
  
  // Venus
  spheres[5] = new Sphere(500, 250, 75, "6.wav", this, 6, -6);
  spheres[5].track.loop();
  spheres[5].track.amp(spheres[5].vol.getMin());
  spheres[5].vol.setVal(spheres[5].vol.getMin(), millisToFadeOutside);
  spheres[5].enableRate(); // ### rate
  spheres[5].rate.setMinMax(0.92, 1.0);
  
  // Merkur
  spheres[6] = new Sphere(100, 400, 75, "7.wav", this, 7, -7);
  spheres[6].track.loop();
  spheres[6].track.amp(spheres[6].vol.getMin());
  spheres[6].vol.setVal(spheres[6].vol.getMin(), millisToFadeOutside);
  spheres[6].enableRate(); // ### rate
  spheres[6].rate.setMinMax(0.92, 1.0);
  
  // Jorden
  spheres[7] = new Sphere(300, 400, 75, "8.wav", this, 8, 1);
  spheres[7].track.loop();
  spheres[7].track.amp(spheres[7].vol.getMin());
  spheres[7].vol.setVal(spheres[7].vol.getMin(), millisToFadeOutside);
  spheres[7].enableRate(); // ### rate
  spheres[7].rate.setMinMax(0.92, 1.0);
  
  // Jupiter
  spheres[8] = new Sphere(500, 400, 75, "9.wav", this, 9, -9);
  spheres[8].track.loop();
  spheres[8].track.amp(spheres[8].vol.getMin());
  spheres[8].vol.setVal(spheres[8].vol.getMin(), millisToFadeOutside);
  spheres[8].enableRate(); // ### rate
  spheres[8].rate.setMinMax(0.92, 1.0);
}


void draw() {
  background(0);

  for (Sphere s : spheres) {
    s.show();
    s.update();
    if (simulate) mouseInteraction(s);
    else blobsInteraction(s);
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

void mouseInteraction(Sphere s) {
  fill(0, 255, 0);
  ellipse(mouseX, mouseY, 20, 20);
  int d = (int)dist(mouseX, mouseY, s.x, s.y);
  soundManipulation(s, d);
}

void blobsInteraction(Sphere s) {
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
      soundManipulation(s, minDist);
    }
  }
  framesSinceLastOscMessage++;
}

void soundManipulation(Sphere s, int dist) {
  // turn off
  if (dist < s.radius) {
    s.vol.setVal(map(dist, 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis
    for (Sphere sp : spheres){ // groups
      if (s.getId() == 8){
        if (s.getId() != sp.getId() && s.getGroup() == sp.getGroup()){
          sp.vol.setVal(s.vol.getVal(), millisToFadeInside);
          if (sp.rateEnabled) sp.rate.setVal(map(dist, 0, sp.radius, sp.rate.getMin(), sp.rate.getMax()), millisToFadeInside); 
        
        }
      }
      else if (s.getId() == 5){
        if (s.getId() != sp.getId()){
          sp.vol.setVal(s.vol.getVal(), millisToFadeInside);
          if (sp.rateEnabled) sp.rate.setVal(map(dist, 0, sp.radius, sp.rate.getMin(), sp.rate.getMax()), millisToFadeInside); 
        
        }
      }
    }
    //if (s.delayEnabled) s.delayVal.setVal(map(dist, 0, s.radius, s.delayVal.getMax(), s.delayVal.getMin()), millisToFadeInside);
    if (s.envelopeEnabled){
      //s.envelopeDuration.setVal(map(dist, 0, s.radius, s.envelopeDuration.getMin(), s.envelopeDuration.getMax()),millisToFadeInside); // ###envDev
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
    //if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside); 
    //###envDev --- missing here!
    if (s.rateEnabled) s.rate.setVal(s.rate.getMin(), millisToFadeOutside);
  }
}


// key for toggling mouse simulation
void keyPressed() {
  if (key == 's') simulate = !simulate;
}
