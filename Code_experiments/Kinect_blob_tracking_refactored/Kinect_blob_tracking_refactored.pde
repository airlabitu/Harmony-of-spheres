// This code is made by Halfdan Hauch Jense (halj@itu.dk) at AIR LAB ITU
// The code is using Daniel Shiffmans blob detection class, with a few alterations.

// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/o1Ob28sF0N8


// ToDo
// Bedre formatering af info
// Lav "blind spot" interface
// (Lav således at man kan lave standard blob detection på farvebillede som Shifmann havde tiltænkt det)

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Tracker t = new Tracker(this);

int image = 0;
boolean textInfo = true;
boolean drawBlobs = true;

void setup() {
  size(640,480);
}


void draw() {
  background(0);
  
  t.detectBlobs(); // update the tracker
  image(t.getTrackerImage(image), 0, 0); // display one of the images from the tracker
  if (drawBlobs) t.showBlobs(); // display tracked blobs
  drawInfo(); // on screen text info
}

void drawInfo(){
  stroke(255);
  if (textInfo){    
    fill(0);
    rect(90, 130, 460, 150);
    textSize(15);
    textAlign(LEFT);
    fill(255);
    text("Min depth :         [" + t.getMinDepth() + "]              decrease (1) / increase (2)", 110, 160);
    text("Max depth :        [" + t.getMaxDepth() + "]          decrease (3) / increase (4)", 110, 180);
    text("Threshold :         [" + t.getThreshold() + "]           decrease (5) / increase (6)", 110, 200);
    text("Dist threshold :   [" + t.getDistThreshold() + "]           decrease (7) / increase (8)", 110, 220);
    if (image == 0) text("Image :               [tracker]        toggel (i)", 110, 240);
    else if (image == 1) text("Image :               [kinect]         toggel (i)", 110, 240);
    if (drawBlobs) text("Blobs overlay :    [yes]              toggel (b)", 110, 260);
    else text("Blobs overlay :    [no]               toggel (b)", 110, 260);
  }
  fill(0);
  rect(0, height-30, 170, 30);
  fill(255);
  if (textInfo) text("press 't' to close info", 10, height-10);
  else text("press 't' to open info", 10, height-10);
}

void saveSettings(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Save to filke " + selection.getAbsolutePath());
    String [] settings = new String [6];
    settings[0] = ""+t.minDepth;
    settings[1] = ""+t.maxDepth;
    settings[2] = ""+t.threshold;
    settings[3] = ""+t.distThreshold;
    settings[4] = ""+image;
    settings[5] = ""+drawBlobs;
    saveStrings(selection.getAbsolutePath(), settings);
  }
}

void loadSettings(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Load file " + selection.getAbsolutePath());
    String [] settings = loadStrings(selection.getAbsolutePath());
    t.setMinDepth(int(settings[0]));
    t.setMaxDepth(int(settings[1]));
    t.setThreshold(float(settings[2]));
    t.setDistThreshold(float(settings[3]));
    image = int(settings[4]);
    drawBlobs = boolean(settings[5]);
  }
}

void keyPressed() {
  
  if (key == '1') {
    t.decreaseMinDepth(5);//minDepth = constrain(minDepth+10, 0, maxDepth);
  } 
  else if (key == '2') {
    t.increaseMinDepth(5);// = constrain(minDepth-10, 0, maxDepth);
  } 
  else if (key == '3') {
    t.decreaseMaxDepth(5);//maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } 
  else if (key =='4') {
    t.increaseMaxDepth(5);//maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
  else if (key == '5') {
    t.decreaseThreshold(5);
  } 
  else if (key == '6') {
    t.increaseThreshold(5);
  }
  else if (key == '7') {
    t.decreaseDistThreshold(5);
  } 
  else if (key == '8') {
    t.increaseDistThreshold(5);
  }
  else if (key == 'i') {
    image++;
    if (image == 2) image = 0;
  }
  else if (key == 't') {
    textInfo=!textInfo;
  }
  else if (key == 'b') {
    drawBlobs=!drawBlobs;
  }
  else if (key == 's') {
    selectOutput("Select a file to write to:", "saveSettings");
  }
  else if (key == 'l') {
    selectInput("Select a file to load from:", "loadSettings");
  }
  
}


float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
