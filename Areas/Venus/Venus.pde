// Sound manipulation
// Playback of sounds is reversed, this is handled in the soundfile. Volumen going from low to high
// This happens when a user enters the sphere circle, and is adjusted according to distanve from user blob center to sphere cente

import oscP5.*;
import ddf.minim.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

Minim minim;
//AudioPlayer [] tracks;
Sphere [] spheres;

int minGain = -80;
int maxGain = 5;

boolean simulate = false;

void setup() {
  size(640,480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this,6789);
  
  minim = new Minim(this);
  spheres = new Sphere [9];
  
  
  // turn off sounds
  
  spheres[0] = new Sphere(100, 100, 150, "1.mp3");
  
  spheres[1] = new Sphere(300, 100, 100, "2.mp3");
  
  spheres[2] = new Sphere(500, 100, 150, "3.mp3");
  
  spheres[3] = new Sphere(100, 250, 100, "4.mp3");

  spheres[4] = new Sphere(300, 250, 200, "5.mp3");
  
  spheres[5] = new Sphere(500, 250, 100, "6.mp3");
  
  spheres[6] = new Sphere(100, 400, 150, "7.mp3");
  
  spheres[7] = new Sphere(300, 400, 100, "8.mp3");
  
  spheres[8] = new Sphere(500, 400, 100, "9.mp3");
  
  
  // turn on sounds
  /*
  spheres[0] = new Sphere(100, 100, 200, "1.mp3");
  
  spheres[1] = new Sphere(300, 100, 150, "2.mp3");
  
  spheres[2] = new Sphere(500, 100, 200, "3.mp3");
  
  spheres[3] = new Sphere(100, 250, 150, "4.mp3");

  spheres[4] = new Sphere(300, 250, 250, "5.mp3");
  
  spheres[5] = new Sphere(500, 250, 150, "6.mp3");
  
  spheres[6] = new Sphere(100, 400, 200, "7.mp3");
  
  spheres[7] = new Sphere(300, 400, 150, "8.mp3");
  
  spheres[8] = new Sphere(500, 400, 150, "9.mp3");
  */
  for (Sphere s : spheres){
    s.track.setGain(minGain);
    s.track.loop();
    s.track.setGain(minGain);
  }
  
  //tracks = new AudioPlayer [9]; 
  
  /*
  for (int i = 0; i < tracks.length; i++){
    tracks[i] = minim.loadFile("hannah_"+(i+1)+".mp3", 2048);
    tracks[i].loop();
  }
  */
}


void draw() {
  background(0);
  
  for (Sphere s : spheres){
    s.show();
    if (simulate) mouseInteraction(s);
    else blobsInteraction(s);
  }
  
  fill(0,0,255);
  text("Simulate: " + simulate, 50, height -10); 
  /*
  if (simulate) mouseSimulation();
  else{
    if (framesSinceLastOscMessage > 25) blobs = null;
    if (blobs != null){
      for (Blob b : blobs){
        if (b != null){
          fill(map(b.minDepth, 0, 2047, 255, 0));
          ellipse(b.x, b.y, 50, 50);
        }
      }
    }
    framesSinceLastOscMessage++;
  }
  */
}


void oscEvent(OscMessage theOscMessage) {
  println("--- OSC MESSAGE RECEIVED ---");
  // Check if the address pattern is the right one
  if(theOscMessage.checkAddrPattern("/Blobs|X|Y|MIN_DEPTH|ID|NR_OF_PIXELS|")==true) {
    println("AddressPattern matched:", theOscMessage.addrPattern());
    // check if the typetag is the right one
    String typeTag = "";
    for (int i = 0; i < theOscMessage.typetag().length(); i++) typeTag += "i";
    if(theOscMessage.checkTypetag(typeTag)) {
      println("TypeTag matched:", theOscMessage.typetag());
      blobs = new Blob[theOscMessage.typetag().length()/5];
      println("Blobs length: ", blobs.length);
      for (int i = 0, j = 0; i <= theOscMessage.typetag().length()-5; i+=5, j++){
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

void mouseInteraction(Sphere s){
  fill(0,255,0);
  ellipse(mouseX, mouseY, 20, 20);
  int d = (int)dist(mouseX, mouseY, s.x, s.y);
  soundManipulation(s, d);
  //for (Sphere s : spheres){
  
    //int d = (int)dist(mouseX, mouseY, s.x, s.y);
    //if (d < s.radius) s.track.shiftGain(s.track.getGain(), map(d, 0, s.radius, minGain, maxGain), 100);   // shift over 100 millis 
    //else s.track.shiftGain(s.track.getGain(), maxGain, 100); // shift to max over 100 milllis    
  //}
  
}

void blobsInteraction(Sphere s){
  if (framesSinceLastOscMessage > 25) {
    blobs = null;
    s.track.shiftGain(s.track.getGain(), minGain, 2000);
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
      //if (minDist < s.radius) s.track.shiftGain(s.track.getGain(), map(minDist, 0, s.radius, minGain, maxGain), 100);   // shift over 100 millis 
      //else s.track.shiftGain(s.track.getGain(), maxGain, 100); // shift to max over 100 milllis   
    }
  }
  framesSinceLastOscMessage++;
}

void soundManipulation(Sphere s, int dist){
  //int d = (int)dist(mouseX, mouseY, s.x, s.y);
  // turn off
  if (dist < s.radius) s.track.shiftGain(s.track.getGain(), map(dist, 0, s.radius, minGain, maxGain), 100);   // shift over 100 millis 
  else s.track.shiftGain(s.track.getGain(), maxGain, 100); // shift to max over 100 milllis 
  
  /*
  // turn on
  if (dist < s.radius) s.track.shiftGain(s.track.getGain(), map(dist, 0, s.radius, maxGain, minGain), 100);   // shift over 100 millis 
  else s.track.shiftGain(s.track.getGain(), minGain, 100); // shift to max over 100 milllis 
  */
}

class Blob{
  int x, y, minDepth, id;
  float nrOfPixels;
  
  Blob (int x_, int y_, int minDepth_, int id_, int nrOfPixels_){
    x = x_;
    y = y_;
    minDepth = minDepth_;
    id = id_;
    nrOfPixels = nrOfPixels_;
  }
}

class Sphere{
  int x, y, radius;
  AudioPlayer track;
  
  Sphere(int x_, int y_, int radius_, String filename){
    x = x_;
    y = y_;
    radius = radius_;
    track = minim.loadFile(filename, 2048);
  }
  
  void show(){
    noFill();
    if (track.getGain() > minGain) fill(255, map(track.getGain(), minGain, maxGain, 0, 150));
    stroke(255);
    ellipse(x, y, radius*2, radius*2);
    fill(0,255,0);
    text(track.getGain(), x, y+5);
  }
}

void keyPressed(){
  if (key == 's') simulate = !simulate;
}
