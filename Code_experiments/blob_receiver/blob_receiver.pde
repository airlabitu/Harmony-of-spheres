import oscP5.*;
  
OscP5 oscP5;

Blob [] blobs;

void setup() {
  size(400,400);
  frameRate(25);
  oscP5 = new OscP5(this,6789);
}


void draw() {
  background(0);  
}


void oscEvent(OscMessage theOscMessage) {
  println("--- OSC MESSAGE RECEIVED ---");
  // Check if the address pattern is the right one
  if(theOscMessage.checkAddrPattern("/Blobs|X|Y|ID|SIZE|")==true) {
    println("AddressPattern matched:", theOscMessage.addrPattern());
    // check if the typetag is the right one
    String typeTag = "";
    for (int i = 0; i < theOscMessage.typetag().length(); i++) typeTag += "i";
    if(theOscMessage.checkTypetag(typeTag)) {
      println("TypeTag matched:", theOscMessage.typetag());
      blobs = new Blob[theOscMessage.typetag().length()/4];
      println("Blobs length: ", blobs.length);
      for (int i = 0, j = 0; i <= theOscMessage.typetag().length()-4; i+=4, j++){
        int x, y, id, size;
        x = theOscMessage.get(i).intValue();
        y = theOscMessage.get(i+1).intValue();
        id = theOscMessage.get(i+2).intValue();
        size = theOscMessage.get(i+3).intValue();
        
        blobs[j] = new Blob(x, y, id, size);
        println("X: ", x, "Y: ", y, "ID: ", id, "Size: ", size);
      }
    }
  }
  println("----------------------------");
  println();

}


class Blob{
  int x, y, id;
  float size;
  
  Blob (int x_, int y_, int id_, int size_){
    x = x_;
    y = y_;
    id = id_;
    size = size_;
  }
}
