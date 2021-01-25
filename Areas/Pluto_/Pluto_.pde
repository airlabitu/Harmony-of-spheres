// Sound manipulation
// Playback speed going from normal spped to slow, together with volumen going from low to high
// This happens when a user enters the sphere circle, and is adjusted according to distanve from user blob center to sphere center

import oscP5.*;
import processing.sound.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;
boolean debug = false;

Sphere [] spheres;

boolean simulate = false;
int millisToFadeInside = 300;
int millisToFadeOutside = 300;
int millisToFadeNoBlobs = 5000;

void setup() {
  size(640,480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this,6789);
  spheres = new Sphere [9];
  
  // turn off sounds
  spheres[0] = new Sphere(100, 100, 100, "1.wav", this);
  spheres[1] = new Sphere(300, 100, 100, "2.wav", this);
  spheres[2] = new Sphere(500, 100, 100, "3.wav", this);
  spheres[3] = new Sphere(100, 250, 100, "4.wav", this);
  spheres[4] = new Sphere(300, 250, 100, "5.wav", this);
  spheres[5] = new Sphere(500, 250, 100, "6.wav", this);
  spheres[6] = new Sphere(100, 400, 100, "7.wav", this);
  spheres[7] = new Sphere(300, 400, 100, "8.wav", this);
  spheres[8] = new Sphere(500, 400, 100, "9.wav", this);
  
  for (Sphere s : spheres){
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
  }
}


void draw() {
  background(0);
  
  for (Sphere s : spheres){
    s.show();    
    s.update();
    if (simulate) mouseInteraction(s);
    else blobsInteraction(s);
  }
  fill(0,0,255);
  text("Simulate: " + simulate, 50, height -10); 
}


void oscEvent(OscMessage theOscMessage) {
  if (debug) println("--- OSC MESSAGE RECEIVED ---");
  // Check if the address pattern is the right one
  if(theOscMessage.checkAddrPattern("/Blobs|X|Y|MIN_DEPTH|ID|NR_OF_PIXELS|")==true) {
    if (debug)  println("AddressPattern matched:", theOscMessage.addrPattern());
    // check if the typetag is the right one
    String typeTag = "";
    for (int i = 0; i < theOscMessage.typetag().length(); i++) typeTag += "i";
    if(theOscMessage.checkTypetag(typeTag)) {
      if (debug)  println("TypeTag matched:", theOscMessage.typetag());
      blobs = new Blob[theOscMessage.typetag().length()/5];
      if (debug) println("Blobs length: ", blobs.length);
      for (int i = 0, j = 0; i <= theOscMessage.typetag().length()-5; i+=5, j++){
        int x, y, blobMinDepth, id, nrOfPixels__;
        x = theOscMessage.get(i).intValue();
        y = theOscMessage.get(i+1).intValue();
        blobMinDepth = theOscMessage.get(i+2).intValue();
        id = theOscMessage.get(i+3).intValue();
        nrOfPixels__ = theOscMessage.get(i+4).intValue();
        
        blobs[j] = new Blob(x, y, blobMinDepth, id, nrOfPixels__);
        if (debug) println("X: ", x, "Y: ", y, "Min Depth", blobMinDepth, "ID: ", id, "Pixels: ", nrOfPixels__);
      }
      framesSinceLastOscMessage = 0;
    }
  }
  if (debug) println("----------------------------");
  if (debug) println();

}

void mouseInteraction(Sphere s){
  fill(0,255,0);
  ellipse(mouseX, mouseY, 20, 20);
  int d = (int)dist(mouseX, mouseY, s.x, s.y);
  soundManipulation(s, d);
}

void blobsInteraction(Sphere s){
  if (framesSinceLastOscMessage > 25) {
    blobs = null;
    
    s.vol.setVal(s.vol.getMin(), millisToFadeNoBlobs);
  }
  if (blobs != null){
    int minDist = 999999999;
    for (Blob b : blobs){
      if (b != null){
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

void soundManipulation(Sphere s, int dist){
  // turn off
  if (dist < s.radius) s.vol.setVal(map(dist, 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis 
  else s.vol.setVal(s.vol.getMin(), millisToFadeOutside); // shift to min over 100 milllis 
  //s.track.amp(s.vol.getVal());
  //s.track.rate(constrain(1-s.vol.getVal(), 0.2, 0.5));
  s.track.rate(1-map(s.vol.getVal(), 0, 1, 0, 0.4));
}

// key for toggling mouse simulation
void keyPressed(){
  if (key == 's') simulate = !simulate;
  if (key == 'd') debug = !debug;
}
