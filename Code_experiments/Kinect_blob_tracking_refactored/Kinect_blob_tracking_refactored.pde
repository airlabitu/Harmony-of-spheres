// This code is made by Halfdan Hauch Jensen (halj@itu.dk) at AIR LAB ITU
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
  loadSettings("data/settings.txt"); // load default settings from file
}


void draw() {
  background(0);
  
  t.detectBlobs(); // update the tracker
  image(t.getTrackerImage(image), 0, 0); // display one of the images from the tracker
  if (drawBlobs) t.showBlobs(); // display tracked blobs
  drawInfo(); // on screen text info
}

void drawInfo(){
  rectMode(CORNER);
  textAlign(LEFT);
  textSize(15);
  stroke(255);
  int firstCol = 90, secondCol = 280, thirdCol = 400;
  int firstRow = 130, rowStep = 20;
  
  if (textInfo){    
    fill(0, 150);
    rect(firstCol-20, firstRow-20, 460, 250);
    fill(255);
    text("Min depth :", firstCol, firstRow+rowStep*1);   text("[" + t.getMinDepth() + "]", secondCol, firstRow+rowStep*1);  text("adjust (1) / (2)", thirdCol, firstRow+rowStep*1);
    text("Max depth :", firstCol, firstRow+rowStep*2);   text("[" + t.getMaxDepth() + "]", secondCol, firstRow+rowStep*2);  text("adjust (3) / (4)", thirdCol, firstRow+rowStep*2);
    text("Threshold :", firstCol, firstRow+rowStep*3);   text("[" + t.getThreshold() + "]", secondCol, firstRow+rowStep*3);  text("adjust (5) / (6)", thirdCol, firstRow+rowStep*3);
    text("Dist threshold :", firstCol, firstRow+rowStep*4);   text("[" + t.getDistThreshold() + "]", secondCol, firstRow+rowStep*4);  text("adjust (7) / (8)", thirdCol, firstRow+rowStep*4);
    
    String imageString = "tracker";
    if (image == 1) imageString = "kinect";
    text("Image :", firstCol, firstRow+rowStep*6);   text("[" + imageString + "]", secondCol, firstRow+rowStep*6);  text("toggle (i)", thirdCol, firstRow+rowStep*6);
    
    String drawBlobsString = "yes";
    if (!drawBlobs) drawBlobsString = "no";
    text("Blobs overlay :", firstCol, firstRow+rowStep*7);   text("[" + drawBlobsString + "]", secondCol, firstRow+rowStep*7);  text("toggle (b)", thirdCol, firstRow+rowStep*7);
    
    text("Load & save settings :", firstCol, firstRow+rowStep*9);   text("press (l) / (s)", thirdCol, firstRow+rowStep*9);

  }
  fill(0, 150);
  rect(0, height-30, 170, 30);
  fill(255);
  if (textInfo) text("press 't' to close info", 10, height-10);
  else text("press 't' to open info", 10, height-10);
}

// --- Load and Save funcrions ---
void saveSettingsCallback(File selection) {
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

void loadSettingsCallback(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Load file " + selection.getAbsolutePath());
    loadSettings(selection.getAbsolutePath());
  }
}

void loadSettings(String path){
    String [] settings = loadStrings(path);
    t.setMinDepth(int(settings[0]));
    t.setMaxDepth(int(settings[1]));
    t.setThreshold(float(settings[2]));
    t.setDistThreshold(float(settings[3]));
    image = int(settings[4]);
    drawBlobs = boolean(settings[5]);
}


// --- key commands ---
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
    selectOutput("Select a file to write to:", "saveSettingsCallback");
  }
  else if (key == 'l') {
    selectInput("Select a file to load from:", "loadSettingsCallback");
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
