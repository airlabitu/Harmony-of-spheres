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

boolean simulate = true;

void setup() {
  size(640,480);
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this,6789);
  
  minim = new Minim(this);
  spheres = new Sphere [9];
  
  
  
  spheres[0] = new Sphere(100, 100, 200, "hannah_1.mp3");
  
  spheres[1] = new Sphere(300, 100, 200, "hannah_2.mp3");
  
  spheres[2] = new Sphere(500, 100, 200, "hannah_3.mp3");
  
  spheres[3] = new Sphere(100, 250, 200, "hannah_4.mp3");

  spheres[4] = new Sphere(300, 250, 200, "hannah_5.mp3");
  
  spheres[5] = new Sphere(500, 250, 200, "hannah_6.mp3");
  
  spheres[6] = new Sphere(100, 400, 200, "hannah_7.mp3");
  
  spheres[7] = new Sphere(300, 400, 200, "hannah_8.mp3");
  
  spheres[8] = new Sphere(500, 400, 200, "hannah_9.mp3");
  
  for (Sphere s : spheres){
    s.track.setGain(minGain);
    s.track.loop();
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
  }
  if (simulate) mouseSimulation();
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

void mouseSimulation(){
  fill(0,255,0);
  ellipse(mouseX, mouseY, 20, 20);
  
  for (Sphere s : spheres){
    int d = (int)dist(mouseX, mouseY, s.x, s.y);
    if (d < s.radius) s.track.shiftGain(s.track.getGain(), map(d, 0, s.radius, minGain, maxGain), 100);    
    else s.track.shiftGain(s.track.getGain(), maxGain, 100);
    
    //s.track.setVolume((int)dist(mouseX, mouseY, s.x, s.y));
    
  }
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
    if (track.getGain() > minGain) fill(255, map(track.getGain(), minGain, maxGain, 0, 255));
    stroke(255);
    ellipse(x, y, radius*2, radius*2);
    fill(0,255,0);
    text(track.getGain(), x, y+5);
  }
}
