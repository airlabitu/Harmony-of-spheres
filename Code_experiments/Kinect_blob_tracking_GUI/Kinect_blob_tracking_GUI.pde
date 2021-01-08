// This code is made by Halfdan Hauch Jensen (halj@itu.dk) at AIR LAB ITU
// The code is using Daniel Shiffmans blob detection class, with a few alterations.

// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/o1Ob28sF0N8


// ToDo
  // Tjek og implementer bedre performance - e.g. clear video/kinect/video objekter efter mode change
  // Test med Kinect 

import processing.video.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import oscP5.*;
import netP5.*;
import java.util.*;
 
Kinect kinect;
Movie simulationVideo;
Capture webCam;

Tracker t = new Tracker();

OscP5 oscP5;
NetAddress myRemoteLocation;
String [] oscInfo;

void setup() {
  size(640, 480);
  frameRate(25);
  loadSettings("data/default_settings.txt"); // load default settings from file
  setInputMode(inputMode);
}


void draw() {

  if (inputMode == 0) {
    if (kinect != null && kinect.numDevices() != 0) t.detectBlobs(kinect.getRawDepth());
    else errorString = "No Kinect connected";
  }
  else if (inputMode == 1){
    if(webCam != null){
      if (webCam.available()){
        webCam.read();
        t.detectBlobs(webCam);
      }
    }
    else {
      errorString = "No webcam avaliable";
    }
  }
  else if (inputMode == 2) t.detectBlobs(simulationVideo);
  
  if (sendingOSC && t.getNrOfBlobs() > 0) sendBlobsOsc(); // send blobs over OSC if there is any blobs to send
  
  image(t.getTrackerImage(), 0, 0); // display the image from the tracker

  if (drawBlobs) t.showBlobs(/*true*/); // display tracked blobs
  drawInfo(); // on screen text info
 
  if (mousePressed && mouseButton == LEFT) showIgnoreCircle();
  
  t.showIgnoreAreas();
  
  errorString = "";
}

float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void movieEvent(Movie m) {
  m.read();
}

void sendBlobsOsc(){
  
  OscMessage myMessage = new OscMessage("/Blobs|X|Y|MIN_DEPTH|ID|NR_OF_PIXELS|");
  Blob[] blobs = t.getBlobs();
  boolean blobsAdded = false;
  for (Blob b : blobs){
    //println(b.getCenter().x, b.getCenter().y, b.id);
    myMessage.add(int(b.getCenter().x)); // add position x ,y
    myMessage.add(int(b.getCenter().y));
    myMessage.add(int(b.getMinDepth())); // add depth at nearest pixel
    myMessage.add(b.id); // add blob ID
    myMessage.add(int(b.getNrOfPixels())); // add blob nr of pixels
    blobsAdded = true;
  }  
  if (blobsAdded) oscP5.send(myMessage, myRemoteLocation); // send the message if any blobs where added to the OSC message
}
