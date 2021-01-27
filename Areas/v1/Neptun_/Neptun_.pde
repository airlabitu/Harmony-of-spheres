// This is the template sketch for the HoS project planet sound sketches
// Volumen is going from low to high
// This happens when a user enters the sphere circle, and is adjusted according to distance from user blob center to sphere cente

import oscP5.*;
import processing.sound.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

Sphere [] spheres;

Delay [] delays;

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
  }
  
  delays = new Delay[spheres.length];
  
  for (int i = 0; i < delays.length; i++){
    delays[i] = new Delay(this);
  }
  
  delays[0].process(spheres[0].track, 0.1); // second value is the default "tape" the delay has
  delays[1].process(spheres[1].track, 0.2); // second value is the default "tape" the delay has
  delays[2].process(spheres[2].track, 0.3); // second value is the default "tape" the delay has
  delays[3].process(spheres[3].track, 0.4); // second value is the default "tape" the delay has
  delays[4].process(spheres[4].track, 0.5); // second value is the default "tape" the delay has
  delays[5].process(spheres[5].track, 0.6); // second value is the default "tape" the delay has
  delays[6].process(spheres[6].track, 0.7); // second value is the default "tape" the delay has
  delays[7].process(spheres[7].track, 0.8); // second value is the default "tape" the delay has
  delays[8].process(spheres[8].track, 0.9); // second value is the default "tape" the delay has
  
  /*for (int i = 0; i < delays.length; i++){
    delays[i] = new Delay(this);
    delays[i].process(spheres[i].track, 0.8); // second value is the default "tape" the delay has
  }*/
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
  if (dist < s.radius) s.vol.setVal(map(dist, 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis 
  else s.vol.setVal(0, millisToFadeOutside); // shift to min over 100 milllis
  delays[s.getId()-1].feedback(map(s.vol.getVal(), 0, 1, 0.3, 0.8));
  //delays[s.getId()-1].feedback(0.5);
  //delays[s.getId()-1].time(map(s.vol.getVal(), 0, 1, 0.0, 2.0));
}


// key for toggling mouse simulation
void keyPressed() {
  if (key == 's') simulate = !simulate;
}
