import oscP5.*;
  
OscP5 oscP5;

Blob [] blobs;

int framesSinceLastOscMessage = 0;

void setup() {
  size(640,480);
  frameRate(25);
  oscP5 = new OscP5(this,6789);
}


void draw() {
  background(0);
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
