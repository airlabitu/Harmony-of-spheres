// This code is made by Halfdan Hauch Jensen (halj@itu.dk) at AIR LAB ITU
// The code is using Daniel Shiffmans blob detection class, with a few alterations.

// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/o1Ob28sF0N8


// ToDo

// Tjek og implementer bedre performance - e.g. clear video/kinect/video objekter efter mode change

// Fiks nestede blobs

// Test med Kinect

// minBlobSize i controls / infoText

// tekst for ...

// save/load
  // change to setters and getters

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

int inputMode = 1; // 0 = kinect | 1 = webCam | 2 = video file simulation 

//int image = 0;
boolean textInfo = true;
boolean drawBlobs = true;

// IGNORE AREAS
int pressX, pressY;
int releaseX, releaseY;
int dragState = -1;
boolean ignoreMode = true; // create ignore areas flag

boolean loading = false; // load settings flag

String errorString = "";

void setup() {
  size(640, 480);
  loadSettings("data/default_settings.txt"); // load default settings from file
  setInputMode(inputMode); 
}


void draw() {
  //background(0);
  //t.detectBlobs(); // update the tracker
  
  /*
  if (inputMode == 1 && webCam != null && webCam.available()) {
    webCam.read();
  }
  */
  //println(inputMode);
  if (inputMode == 0) {
    if (kinect != null && kinect.numDevices() != 0) t.detectBlobs(kinect.getRawDepth());
    else errorString = "No Kinect connected";
  }
  else if (inputMode == 1){
    if(webCam != null){
      if (webCam.available()){
        webCam.read();
        t.detectBlobs(webCam);
        println("w");
      }
    }
    else {
      errorString = "No webcam avaliable";
      println("e");
    }
  }
  else if (inputMode == 2) t.detectBlobs(simulationVideo);
  
  image(t.getTrackerImage(), 0, 0); // display the image from the tracker
  /*
  if (image == 0) image(t.getTrackerImage(), 0, 0); // display the image from the tracker
  else if (image == 1 && inputMode == 0) image(kinect.getDepthImage(), 0, 0);
  else background(255,50,50);
  */
  if (drawBlobs) t.showBlobs(); // display tracked blobs
  drawInfo(); // on screen text info
  
  if (ignoreMode){
    if (mousePressed) showIgnoreCircle();
    t.showIgnoreAreas();
    
  }
  
  errorString = "";
}


void drawInfo() {
  rectMode(CORNER);
  textAlign(LEFT);
  textSize(15);
  stroke(255);
  int firstCol = 90, secondCol = 280, thirdCol = 400;
  int firstRow = 130, rowStep = 20;

  if (textInfo) {
    int rowNumber = 1;
    fill(0, 150);
    rect(firstCol-20, firstRow-20, 460, 250);
    fill(255);
    text("Min depth :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getMinDepth() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (1) / (2)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Max depth :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getMaxDepth() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (3) / (4)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Color threshold :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getThreshold() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (5) / (6)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Dist threshold :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getDistThreshold() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (7) / (8)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Min blob size :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getMinBlobSize() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (9) / (0)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber+=2;
  
    /*
    String imageString = "tracker";
    if (image == 1) imageString = "kinect";
    text("Image :", firstCol, firstRow+rowStep*6);   
    text("[" + imageString + "]", secondCol, firstRow+rowStep*6);  
    text("toggle (i)", thirdCol, firstRow+rowStep*6);
    */
    
    String [] inputModes = {"Kinect", "Webcam", "Simulation"};
    text("Input mode :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + inputModes[inputMode] + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("change (m)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    String drawBlobsString = "yes";
    if (!drawBlobs) drawBlobsString = "no";
    text("Blobs overlay :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + drawBlobsString + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("toggle (b)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber+=2;
    text("Load & save settings :", firstCol, firstRow+rowStep*rowNumber);   
    text("press (l) / (s)", thirdCol, firstRow+rowStep*rowNumber);
  }
  fill(0, 150);
  rect(0, height-30, 170, 30);
  fill(255);
  if (textInfo) text("press 't' to close info", 10, height-10);
  else text("press 't' to open info", 10, height-10);
  if (errorString.length() > 0) {
    fill(0, 150);
    rect(width-200, height-30, 200, 30);
    fill(255);
    textAlign(RIGHT);
    text(errorString, width-20, height-10);
    
  }
}

// --- Load and Save funcrions ---
void saveSettingsCallback(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Save to filke " + selection.getAbsolutePath());
    String [] settings = new String [8];
    settings[0] = ""+t.minDepth;
    settings[1] = ""+t.maxDepth;
    settings[2] = ""+t.threshold;
    settings[3] = ""+t.distThreshold;
    //settings[4] = ""+image;
    settings[4] = ""+drawBlobs;
    settings[5] = "ignore areas:"+t.ignoreAreasToString();
    settings[6] = ""+inputMode;
    settings[7] = ""+t.getMinBlobSize();
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
  //image = int(settings[4]);
  drawBlobs = boolean(settings[4]);
  String[] ignoreList = split(settings[5], '|');
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
  inputMode = int(settings[6]);
  t.setMinBlobSize(int(settings[7]));
  
  loading = false; // flag loading process done 
  
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
    t.decreaseDistThreshold(1);
  } 
  else if (key == '8') {
    t.increaseDistThreshold(1);
  }
  else if (key == '9') {
    t.decreaseMinBlobSize(100);
  } 
  else if (key == '0') {
    t.increaseMinBlobSize(100);
  }
  /*
  else if (key == 'i') {
    image++;
    if (image == 2) image = 0;
  }
  */
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
    loading = true; 
    selectInput("Select a file to load from:", "loadSettingsCallback");
  }
  else if (key == 'm') {
    inputMode++;
    if (inputMode > 2) inputMode = 0;
    setInputMode(inputMode);
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

void setInputMode(int mode){
  
  if (kinect != null && kinect.numDevices() != 0) kinect.stopDepth();
  if (webCam != null) webCam.stop();
  if (simulationVideo != null) simulationVideo.stop();
  //kinect = null;
  if (mode == 0) {
    kinect = new Kinect(this);
    if (kinect.numDevices() > 0) kinect.initDepth();
  } 
  else if (mode == 1) {
    String[] cameras = Capture.list();
    println("Available cameras:");
    printArray(cameras);
    webCam = new Capture(this, 640, 480, cameras[0]);
    webCam.start();
  } 
  else if (mode == 2) {
    simulationVideo = new Movie(this, "stresstest.mp4");
    simulationVideo.loop();
  }
}
