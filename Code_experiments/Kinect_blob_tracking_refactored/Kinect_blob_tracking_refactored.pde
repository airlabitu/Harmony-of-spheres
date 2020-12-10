// This code is made by Halfdan Hauch Jensen (halj@itu.dk) at AIR LAB ITU
// The code is using Daniel Shiffmans blob detection class, with a few alterations.

// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/o1Ob28sF0N8


// ToDo
// Lav "blind spot" interface
  // control tracker / ignore setting flow
  // fix concurrent modification exception line 193 i tracker
  // lav state / controls til blind spots
  // test med kinect

// Lav OSC output interface
// set IP i settingsfil
// Enable disable i textInfo interface
// (Lav således at man kan lave standard blob detection på farvebillede som Shifmann havde tiltænkt det)
import processing.video.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;
Movie simulationVideo;
Capture webCam;

//Tracker t = new Tracker(this);
Tracker t = new Tracker();

int inputMode = 2; // 0 = kinect | 1 = webCam | 2 = video file simulation 

int image = 0;
boolean textInfo = true;
boolean drawBlobs = true;

// IGNORE AREAS
int pressX, pressY;
int releaseX, releaseY;
int dragState = -1;
boolean ignoreMode = true; // create ignore areas flag

boolean loading = false; // load settings flag

void setup() {
  size(640, 480);

  if (inputMode == 0) {
    kinect = new Kinect(this);
    kinect.initDepth();
  } else if (inputMode == 1) {
    String[] cameras = Capture.list();
    println("Available cameras:");
    printArray(cameras);
    webCam = new Capture(this, 640, 480, cameras[0]);
    webCam.start();
  } else if (inputMode == 2) {
    simulationVideo = new Movie(this, "multiuser.mp4");
    simulationVideo.loop();
  }

  loadSettings("data/settings10.txt"); // load default settings from file
}


void draw() {
  //background(0);
  //t.detectBlobs(); // update the tracker

  if (inputMode == 1 && webCam.available()) {
    webCam.read();
  }

  if (inputMode == 0) t.detectBlobs(kinect.getRawDepth());
  else if (inputMode == 1) t.detectBlobs(webCam);
  else if (inputMode == 2) t.detectBlobs(simulationVideo);
  if (image == 0) image(t.getTrackerImage(), 0, 0); // display the image from the tracker
  else if (image == 1) image(kinect.getDepthImage(), 0, 0);
  if (drawBlobs) t.showBlobs(); // display tracked blobs
  drawInfo(); // on screen text info
  
  if (ignoreMode){
    if (mousePressed) showIgnoreCircle();
    t.showIgnoreAreas();
    
    /*
    for (int i = 0; i < t.ignoreAreas.size(); i++){
      
      ignoreAreas.get(i).show();
    }
    */
  }
  //println(frameRate);
}


void drawInfo() {
  rectMode(CORNER);
  textAlign(LEFT);
  textSize(15);
  stroke(255);
  int firstCol = 90, secondCol = 280, thirdCol = 400;
  int firstRow = 130, rowStep = 20;

  if (textInfo) {    
    fill(0, 150);
    rect(firstCol-20, firstRow-20, 460, 250);
    fill(255);
    text("Min depth :", firstCol, firstRow+rowStep*1);   
    text("[" + t.getMinDepth() + "]", secondCol, firstRow+rowStep*1);  
    text("adjust (1) / (2)", thirdCol, firstRow+rowStep*1);
    text("Max depth :", firstCol, firstRow+rowStep*2);   
    text("[" + t.getMaxDepth() + "]", secondCol, firstRow+rowStep*2);  
    text("adjust (3) / (4)", thirdCol, firstRow+rowStep*2);
    text("Threshold :", firstCol, firstRow+rowStep*3);   
    text("[" + t.getThreshold() + "]", secondCol, firstRow+rowStep*3);  
    text("adjust (5) / (6)", thirdCol, firstRow+rowStep*3);
    text("Dist threshold :", firstCol, firstRow+rowStep*4);   
    text("[" + t.getDistThreshold() + "]", secondCol, firstRow+rowStep*4);  
    text("adjust (7) / (8)", thirdCol, firstRow+rowStep*4);

    String imageString = "tracker";
    if (image == 1) imageString = "kinect";
    text("Image :", firstCol, firstRow+rowStep*6);   
    text("[" + imageString + "]", secondCol, firstRow+rowStep*6);  
    text("toggle (i)", thirdCol, firstRow+rowStep*6);

    String drawBlobsString = "yes";
    if (!drawBlobs) drawBlobsString = "no";
    text("Blobs overlay :", firstCol, firstRow+rowStep*7);   
    text("[" + drawBlobsString + "]", secondCol, firstRow+rowStep*7);  
    text("toggle (b)", thirdCol, firstRow+rowStep*7);

    text("Load & save settings :", firstCol, firstRow+rowStep*9);   
    text("press (l) / (s)", thirdCol, firstRow+rowStep*9);
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
    String [] settings = new String [7];
    settings[0] = ""+t.minDepth;
    settings[1] = ""+t.maxDepth;
    settings[2] = ""+t.threshold;
    settings[3] = ""+t.distThreshold;
    settings[4] = ""+image;
    settings[5] = ""+drawBlobs;
    settings[6] = "ignore areas:"+t.ignoreAreasToString();
    /*
    for (Area a : t.ignoreAreas){ // make ignoreAreasToString() inside tracker class instead
      settings[6] += "|"+a.x+","+a.y+","+a.radius;
    }
    */
    saveStrings(selection.getAbsolutePath(), settings);
  }
}

void loadSettingsCallback(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    loading = false; // remove flag if dialogue closed without loading
  } else {
    println("Load file " + selection.getAbsolutePath());
    loadSettings(selection.getAbsolutePath());
  }
}

void loadSettings(String path) {
  t.clearIgnoreAreas();
  //t.ignoreAreas.clear(); // make function inside tracker class instead
  String [] settings = loadStrings(path);
  t.setMinDepth(int(settings[0]));
  t.setMaxDepth(int(settings[1]));
  t.setThreshold(float(settings[2]));
  t.setDistThreshold(float(settings[3]));
  image = int(settings[4]);
  drawBlobs = boolean(settings[5]);
  String[] ignoreList = split(settings[6], '|');
  println(settings[6]);
  println(ignoreList.length);
  printArray(ignoreList);
  
  if (ignoreList.length > 1){
    println("areas in the list");
    for (int i = 1; i < ignoreList.length; i++){
      String[] tempIgnoreArea = split(ignoreList[i], ',');
      if (tempIgnoreArea.length == 3){
        //for (int j = 0; j < tempIgnoreArea.length; j++){
          println("TIA: " + tempIgnoreArea.length);
          t.addIgnoreArea(int(tempIgnoreArea[0]), int(tempIgnoreArea[1]), int(tempIgnoreArea[2]));
          //t.ignoreAreas.add(new Area(int(tempIgnoreArea[0]), int(tempIgnoreArea[1]), int(tempIgnoreArea[2]))); //  make function inside tracker class
        //}
      }
      else println("ERROR in ignore area load - string split array length : " + tempIgnoreArea.length);
      
      //ignoreAreas.add(new Area(int(ignoreList[i]), int(ignoreList[i+1]), int(ignoreList[i+2])));
    }
  }
  else println("no ignore areas to load");
  
  loading = false; // flag loading process done 
  
}


// --- key commands ---
void keyPressed() {

  if (key == '1') {
    t.decreaseMinDepth(5);//minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == '2') {
    t.increaseMinDepth(5);// = constrain(minDepth-10, 0, maxDepth);
  } else if (key == '3') {
    t.decreaseMaxDepth(5);//maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='4') {
    t.increaseMaxDepth(5);//maxDepth = constrain(maxDepth-10, minDepth, 2047);
  } else if (key == '5') {
    t.decreaseThreshold(5);
  } else if (key == '6') {
    t.increaseThreshold(5);
  } else if (key == '7') {
    t.decreaseDistThreshold(1);
  } else if (key == '8') {
    t.increaseDistThreshold(1);
  } else if (key == 'i') {
    image++;
    if (image == 2) image = 0;
  } else if (key == 't') {
    textInfo=!textInfo;
  } else if (key == 'b') {
    drawBlobs=!drawBlobs;
  } else if (key == 's') {
    selectOutput("Select a file to write to:", "saveSettingsCallback");
  } else if (key == 'l') {
    loading = true; 
    selectInput("Select a file to load from:", "loadSettingsCallback");
  }
}



void mousePressed() {
  if (ignoreMode) {
    pressX = mouseX;
    pressY = mouseY;
    releaseX = mouseX; // make release the same as press to clear old data
    releaseY = mouseY;
    dragState = 0;
  }
}

void mouseDragged() {
  if (ignoreMode) {
    releaseX = mouseX;
    releaseY = mouseY;
    dragState = 1;
  }
}

void mouseReleased() {
  if (inputMode == 1) t.setTrackColor(webCam.get(mouseX, mouseY));
  if (ignoreMode && dragState == 1 && dist(pressX, pressY, releaseX, releaseY) > 5) {
    t.addIgnoreArea(pressX, pressY, int(dist(pressX, pressY, releaseX, releaseY)));
    //t.ignoreAreas.add(new Area(pressX, pressY, int(dist(pressX, pressY, releaseX, releaseY)))); // move inside tracker class
    dragState = 2;
  }
}

void showIgnoreCircle() {
  if (!mousePressed) return; // no need to draw is the mouse isn't pressed
  noFill();
  if (dragState == 0 || dragState == 1) {
    stroke(0, 255, 0);
    float size = max(5, dist(pressX, pressY, releaseX, releaseY));
    circle(pressX, pressY, size*2);
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

void movieEvent(Movie m) {
  m.read();
}
