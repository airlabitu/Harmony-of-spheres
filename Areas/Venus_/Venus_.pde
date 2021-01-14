

// Sound manipulation
// Playback of sounds is reversed, this is handled in the soundfile. Volumen going from low to high
// This happens when a user enters the sphere circle, and is adjusted according to distanve from user blob center to sphere cente

import oscP5.*;
import processing.sound.*;

OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

//Minim minim;
//AudioPlayer [] tracks;
Sphere [] spheres;

float minGain = 0.001;
float maxGain = 1.0;

boolean simulate = false;

void setup() {
  size(640,480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this,6789);
  new SoundFile(this, "1.wav");
  //minim = new Minim(this);
  spheres = new Sphere [9];
  
  
  // turn off sounds
  
  spheres[0] = new Sphere(100, 100, 150, "1.wav", this);
  
  spheres[1] = new Sphere(300, 100, 100, "2.wav", this);
  
  spheres[2] = new Sphere(500, 100, 150, "3.wav", this);
  
  spheres[3] = new Sphere(100, 250, 100, "4.wav", this);

  spheres[4] = new Sphere(300, 250, 200, "5.wav", this);
  
  spheres[5] = new Sphere(500, 250, 100, "6.wav", this);
  
  spheres[6] = new Sphere(100, 400, 150, "7.wav", this);
  
  spheres[7] = new Sphere(300, 400, 100, "8.wav", this);
  
  spheres[8] = new Sphere(500, 400, 100, "9.wav", this);
  
  
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
    //s.track.setGain(minGain);
    s.track.amp(minGain);
    //s.setVol(minGain, 500);
    s.track.loop();
    //s.track.setGain(minGain);
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
  /*
  for (Sphere s : spheres){
    s.show();
    s.update();
    if (simulate) mouseInteraction(s);
    else blobsInteraction(s);
  }
  */
  
  spheres[0].show();
  spheres[0].update();
  if (simulate) mouseInteraction(spheres[0]);
  else blobsInteraction(spheres[0]);
  
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
    
    s.setVol(0, 1000);
    println("Vol:", s.getVol());
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
  if (dist < s.radius) s.setVol(map(dist, 0, s.radius, maxGain, minGain), 5000);   // shift over 100 millis 
  else s.setVol(0, 5000); // shift to max over 100 milllis 
  
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
  SoundFile track;
  float vol;
  float targetVol;
  float volIncrement;
  float incrementDir = 0;
  
  Sphere(int x_, int y_, int radius_, String filename, PApplet pa){
    x = x_;
    y = y_;
    radius = radius_;
    track = new SoundFile(pa, filename);
  }
  
  void update(){
    vol += volIncrement*incrementDir;
    if (vol < targetVol && incrementDir < 0){
      vol = targetVol;
      incrementDir = 0;
    }
    else if (vol > targetVol && incrementDir > 0){
      vol = targetVol;
      incrementDir = 0;
    }
    //track.amp(vol);
    
    //volIncrement = 
    //if ()
  }
  
  void setVol(float v, int time){
    if (frameRate == 0) return; // do nothing at very low frame rate to avoid division by zero error
    println("Before:", "TV:", targetVol, "V:", vol, "ID:", incrementDir, "VI:", volIncrement);
    targetVol = v;
    float millisPrFrame = 1000/frameRate; 
    volIncrement = 0.0001*(time/millisPrFrame);
    println(vol, v, time, millisPrFrame, time/millisPrFrame, volIncrement);
    
    if (targetVol > vol) incrementDir = -1;
    else if (targetVol < vol) incrementDir = 1;
    else incrementDir = 0;
    //println("After:", "TV:", targetVol, "V:", vol, "ID:", incrementDir, "VI:", volIncrement, "MPF:", millisPrFrame);
    //track.amp(v);
    //vol = v;
  }
  
  float getVol(){
    return vol;
  }
  
  void show(){
    noFill();
    if (vol > minGain) fill(255, map(vol, minGain, maxGain, 0, 150));
    stroke(255);
    ellipse(x, y, radius*2, radius*2);
    fill(0,255,0);
    text(vol, x, y+5);
  }
}

void keyPressed(){
  if (key == 's') simulate = !simulate;
}
