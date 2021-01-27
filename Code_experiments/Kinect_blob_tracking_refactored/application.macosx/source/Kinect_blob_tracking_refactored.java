import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import org.openkinect.freenect.*; 
import org.openkinect.processing.*; 
import oscP5.*; 
import netP5.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Kinect_blob_tracking_refactored extends PApplet {

// This code is made by Halfdan Hauch Jensen (halj@itu.dk) at AIR LAB ITU
// The code is using Daniel Shiffmans blob detection class, with a few alterations.

// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/o1Ob28sF0N8


// ToDo

// Tjek og implementer bedre performance - e.g. clear video/kinect/video objekter efter mode change

// Test med Kinect 







 
Kinect kinect;
Movie simulationVideo;
Capture webCam;

Tracker t = new Tracker();

OscP5 oscP5;
NetAddress myRemoteLocation;
String [] oscInfo;

int inputMode = 1; // 0 = kinect | 1 = webCam | 2 = video file simulation 

boolean textInfo = true;
boolean drawBlobs = true;
boolean sendingOSC = false;

String simulationVideoFile;

// IGNORE AREAS
int pressX, pressY;
int releaseX, releaseY;
int dragState = -1;

boolean loading = false; // load settings flag

String errorString = "";

public void setup() {
  
  frameRate(25);
  loadSettings("data/default_settings.txt"); // load default settings from file
  setInputMode(inputMode);
}


public void draw() {

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


public void drawInfo() {
  rectMode(CORNER);
  textAlign(LEFT);
  textSize(15);
  stroke(255);
  int firstCol = 110, secondCol = 300, thirdCol = 420;
  int firstRow = 65, rowStep = 20;
  
  String [] inputModes = {"Kinect", "Webcam", "Simulation"};

  if (textInfo) {
    int rowNumber = 1;
    fill(0, 180);
    rect(firstCol-20, firstRow-10, 460, 370);
    fill(255);
    text("Min depth :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getMinDepth() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (1) / (2)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Max depth :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getMaxDepth() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (3) / (4)", thirdCol, firstRow+rowStep*rowNumber);
    
    if (inputMode == 1){
      rowNumber++;
      text("Track color :", firstCol, firstRow+rowStep*rowNumber);   
      text("[" + PApplet.parseInt(red(t.getTrackColor()))+","+PApplet.parseInt(green(t.getTrackColor()))+","+PApplet.parseInt(blue(t.getTrackColor())) + "]", secondCol, firstRow+rowStep*rowNumber);  
      text("click", thirdCol, firstRow+rowStep*rowNumber);
      rowNumber++;
      text("Color threshold :", firstCol, firstRow+rowStep*rowNumber);   
      text("[" + t.getThreshold() + "]", secondCol, firstRow+rowStep*rowNumber);  
      text("adjust (5) / (6)", thirdCol, firstRow+rowStep*rowNumber);
    }
    rowNumber++;
    text("Dist threshold :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getDistThreshold() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (7) / (8)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Min blob size :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + t.getMinBlobSize() + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("adjust (9) / (0)", thirdCol, firstRow+rowStep*rowNumber);
    
    rowNumber++;
    String nestedBlobsString = "yes";
    if (!t.getNestedBlobFilter()) nestedBlobsString = "no";
    text("Remove nested blobs :", firstCol, firstRow+rowStep*rowNumber);   
    text("[" + nestedBlobsString + "]", secondCol, firstRow+rowStep*rowNumber);  
    text("toggle (n)", thirdCol, firstRow+rowStep*rowNumber);
    
    rowNumber+=2;
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
    String sendingOscState = "yes";
    if (!sendingOSC) sendingOscState = "no";
    text("Sending OSC :", firstCol, firstRow+rowStep*rowNumber);
    text("[" + sendingOscState + "]", secondCol, firstRow+rowStep*rowNumber);
    text("toggle (o)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber+=2;
    text("Load & save settings :", firstCol, firstRow+rowStep*rowNumber);   
    text("press (l) / (s)", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber+=2;
    //text("Ignore areas :", firstCol, firstRow+rowStep*rowNumber); 
    //rowNumber++;
    text("Create ignore area :", firstCol, firstRow+rowStep*rowNumber);
    text("click & drag", thirdCol, firstRow+rowStep*rowNumber);
    rowNumber++;
    text("Delete ignore area :", firstCol, firstRow+rowStep*rowNumber);
    text("right click", thirdCol, firstRow+rowStep*rowNumber);
    if (inputMode == 2){ // Simulation
      rowNumber+=2;
      text("Load new video :", firstCol, firstRow+rowStep*rowNumber);
      text("press (v)", thirdCol, firstRow+rowStep*rowNumber);
    }
  }
  
  textAlign(CENTER);
  
  // upper left info box
  fill(0, 150);
  rect(0, 0, 70, 30);
  fill(255);
  text("FPS: " + PApplet.parseInt(frameRate), 35, 20);
  
  // upper cernter info box
  fill(0, 150);
  rect(640/2-100/2, 0, 100, 30);
  fill(255);
  text("Blobs: " + t.getNrOfBlobs(), 640/2, 20);
  
  // upper right corner
  fill(0, 150);
  rect(width-100, 0, 100, 30);
  fill(255);
  text(inputModes[inputMode], width-50, 20);
  
  // lower left info box
  fill(0, 150);
  rect(0, height-30, 170, 30);
  fill(255);
  if (textInfo) text("press 't' to close info", 85, height-10);
  else text("press 't' to open info", 85, height-10);
  
  // lower right info box
  if (errorString.length() > 0) {
    fill(0, 150);
    rect(width-200, height-30, 200, 30);
    fill(255, 0, 0);
    //textAlign(RIGHT);
    text(errorString, width-100, height-10);
  }
}

// --- Load and Save funcrions ---
public void saveSettingsCallback(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Save to file " + selection.getAbsolutePath());
    String [] settings = new String [12];
    settings[0] = ""+t.getMinDepth();
    settings[1] = ""+t.getMaxDepth();
    settings[2] = ""+t.getThreshold();
    settings[3] = ""+t.getDistThreshold();
    settings[4] = ""+drawBlobs;
    settings[5] = "ignore areas:"+t.ignoreAreasToString();
    settings[6] = ""+inputMode;
    settings[7] = ""+t.getMinBlobSize();
    settings[8] = ""+oscInfo[0]+","+oscInfo[1]+","+oscInfo[2];
    settings[9] = ""+sendingOSC;
    settings[10] = simulationVideoFile;
    settings[11] = ""+t.getNestedBlobFilter();
    saveStrings(selection.getAbsolutePath(), settings);
  }
}

public void loadSettingsCallback(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    loading = false; // remove flag if dialogue closed without loading
  } else {
    println("Load file " + selection.getAbsolutePath());
    loadSettings(selection.getAbsolutePath());
  }
}

public void loadSimulationVideoCallback(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    loading = false; // remove flag if dialogue closed without loading
  } else {
    println("Loading simulation video file " + selection.getAbsolutePath());
    simulationVideoFile = selection.getAbsolutePath();
    simulationVideo = new Movie(this, simulationVideoFile);
    simulationVideo.loop();
    t.setTrackColor(color(255));
    //loadSettings(selection.getAbsolutePath());
  }
}

public void loadSettings(String path) {
  t.clearIgnoreAreas();
  String [] settings = loadStrings(path);
  t.setMinDepth(PApplet.parseInt(settings[0]));
  t.setMaxDepth(PApplet.parseInt(settings[1]));
  t.setThreshold(PApplet.parseFloat(settings[2]));
  t.setDistThreshold(PApplet.parseFloat(settings[3]));
  drawBlobs = PApplet.parseBoolean(settings[4]);
  String[] ignoreList = split(settings[5], '|');
  if (ignoreList.length > 1){
    println("areas in the list");
    for (int i = 1; i < ignoreList.length; i++){
      String[] tempIgnoreArea = split(ignoreList[i], ',');
      if (tempIgnoreArea.length == 3){
        println("TIA: " + tempIgnoreArea.length);
        t.addIgnoreArea(PApplet.parseInt(tempIgnoreArea[0]), PApplet.parseInt(tempIgnoreArea[1]), PApplet.parseInt(tempIgnoreArea[2]));
      }
      else println("ERROR in ignore area load - string split array length : " + tempIgnoreArea.length);      
    }
  }
  else println("no ignore areas to load");
  inputMode = PApplet.parseInt(settings[6]);
  t.setMinBlobSize(PApplet.parseInt(settings[7]));
  oscInfo = split(settings[8], ',');
  oscP5 = new OscP5(this, PApplet.parseInt(oscInfo[1]));
  myRemoteLocation = new NetAddress(oscInfo[0], PApplet.parseInt(oscInfo[2]));
  sendingOSC = PApplet.parseBoolean(settings[9]);
  simulationVideoFile = settings[10];
  loadSimulationVideo();
  t.setNestedBlobFilter(PApplet.parseBoolean(settings[11]));
  loading = false; // flag loading process done
  
}


// --- key commands ---
public void keyPressed() {

  if (key == '1') {
    t.decreaseMinDepth(5);
  } 
  else if (key == '2') {
    t.increaseMinDepth(5);
  } 
  else if (key == '3') {
    t.decreaseMaxDepth(5);
  } 
  else if (key =='4') {
    t.increaseMaxDepth(5);
  } 
  else if (key == '5') {
    if (inputMode == 1) t.decreaseThreshold(5);
  } 
  else if (key == '6') {
    if (inputMode == 1) t.increaseThreshold(5);
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
  else if (key == 'o') {
    sendingOSC=!sendingOSC;
  }
  else if (key == 'v') {
    if (inputMode == 2) {
      selectInput("Select a simulation video to load:", "loadSimulationVideoCallback");
    }
  }  
  else if (key == 'n') {
    t.setNestedBlobFilter(!t.getNestedBlobFilter());
  }
}



public void mousePressed() {
  if (mouseButton == LEFT) {
    pressX = mouseX;
    pressY = mouseY;
    releaseX = mouseX; // make release the same as press to clear old data
    releaseY = mouseY;
    dragState = 0;
  }
}

public void mouseDragged() {
  if (mouseButton == LEFT) {
    releaseX = mouseX;
    releaseY = mouseY;
    dragState = 1;
  }
}

public void mouseReleased() {
  if (mouseButton == LEFT){
    if (inputMode == 1) t.setTrackColor(webCam.get(mouseX, mouseY));
    if (dragState == 1 && dist(pressX, pressY, releaseX, releaseY) > 5) {
      t.addIgnoreArea(pressX, pressY, PApplet.parseInt(dist(pressX, pressY, releaseX, releaseY)));
      //t.ignoreAreas.add(new Area(pressX, pressY, int(dist(pressX, pressY, releaseX, releaseY)))); // move inside tracker class
      dragState = 2;
    }
  }
  else if (mouseButton == RIGHT) {
    t.deleteIgnoreArea(mouseX, mouseY);
  }
}

public void showIgnoreCircle() {
  if (!mousePressed) return; // no need to draw is the mouse isn't pressed
  noFill();
  if (dragState == 0 || dragState == 1) {
    stroke(0, 255, 0);
    float size = max(5, dist(pressX, pressY, releaseX, releaseY));
    circle(pressX, pressY, size*2);
  }
}



public float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


public float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

public void movieEvent(Movie m) {
  m.read();
}

public void setInputMode(int mode){
  
  if (kinect != null){
    if (kinect.numDevices() != 0) {
      kinect.stopDepth();
      //kinect = null;
      //kinect.enableColorDepth(false);
      //kinect.enableIR(false);
      
    }
  }
  if (webCam != null) webCam.stop();
  if (simulationVideo != null) simulationVideo.stop();
  //kinect = null;
  if (mode == 0) {
    if (kinect == null) kinect = new Kinect(this);
    if (kinect.numDevices() > 0) kinect.initDepth();
    t.setTrackColor(color(255)); // set tcack color back to white, in case it was changed by user in webcam input mode
  } 
  else if (mode == 1) {
    String[] cameras = Capture.list();
    println("Available cameras:");
    printArray(cameras);
    webCam = new Capture(this, 640, 480, cameras[0]);
    webCam.start();
  } 
  else if (mode == 2) {
    loadSimulationVideo();
  }
}

public void sendBlobsOsc(){
  
  OscMessage myMessage = new OscMessage("/Blobs|X|Y|MIN_D|ID|SIZE|");
  Blob[] blobs = t.getBlobs();
  boolean blobsAdded = false;
  for (Blob b : blobs){
    //println(b.getCenter().x, b.getCenter().y, b.id);
    myMessage.add(PApplet.parseInt(b.getCenter().x)); // add position x ,y
    myMessage.add(PApplet.parseInt(b.getCenter().y));
    myMessage.add(PApplet.parseInt(b.getMinDepth())); // add depth at nearest pixel
    myMessage.add(b.id); // add blob ID
    myMessage.add(PApplet.parseInt(b.size())); // add blob size (w*h)
    blobsAdded = true;
  }  
  if (blobsAdded) oscP5.send(myMessage, myRemoteLocation); // send the message if any blobs where added to the OSC message
}

public void loadSimulationVideo(){
  simulationVideo = new Movie(this, simulationVideoFile);
  simulationVideo.loop();
  t.setTrackColor(color(255)); // set tcack color back to white, in case it was changed by user in webcam input mode
}

class Area{
  int x, y, radius;
  
  Area(int x_, int y_, int radius_){
    x = x_;
    y = y_;
    radius = radius_;
  }
  
  public void show(){
    noFill();
    stroke(255, 0, 0);
    circle(x, y, radius*2);
  }
  
  public boolean isInside(int x2, int y2){
    if (dist(x, y, x2, y2) < radius) return true;
    return false;
  }
}


class Blob implements Comparable<Blob> {
  float minx;
  float miny;
  float maxx;
  float maxy;
  
  boolean nested = false;

  int id = 0;

  int lifespan;// = maxLife;
  
  int lifetime;

  boolean taken = false;
  
  int maxLife;
  float distThreshold;
  
  ArrayList<DepthPixel> pixelList;
  DepthPixel minDepth;

  Blob(float x, float y, int maxLife_, float distThreshold_) {
    lifetime = 0;
    maxLife = maxLife_;
    distThreshold = distThreshold_;
    
    lifespan = maxLife;
    
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
    
    pixelList = new ArrayList<DepthPixel>();
    minDepth = new DepthPixel(-1, -1, 999999999);
    
  }
  
  Blob (){ // simple constructor for copying 
  } 

  public boolean checkLife() {
    lifespan--; 
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }


  public void show() {
    stroke(255,105,204);
    fill(255, lifespan);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);

    textAlign(CENTER);
    textSize(15);
    fill(255,105,204);
    text(id, minx + (maxx-minx)*0.5f, maxy - 10);
    textSize(15);
    //text(lifespan, minx + (maxx-minx)*0.5, miny - 10);
    //println("ID", id, "pixelList size", pixelList.size());
    //println("minDepth", minDepth.depth, "X", minDepth.x, "Y", minDepth.y);
    if (minDepth != null){
      fill(255,0,0);
      noStroke();
      ellipse(minDepth.x, minDepth.y, 10, 10);
      //fill(255,105,204);
      //stroke(255,105,204);
    }
  }
  
  public void showPixels(){
    //println("PLS:", pixelList.size());
    for (DepthPixel dp : pixelList){
      //println("SH");
      fill(255, 0,0);
      ellipse(dp.x, dp.y, 5, 5);
    }
  }
  
  public void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);    
  }
  
  public void add(float x, float y, int depth) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
    pixelList.add(new DepthPixel(x, y, depth));
    //minDepth.depth = depth;
    if (depth < minDepth.depth) minDepth = new DepthPixel(x, y, depth);
  }
  
  public void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
    lifespan = maxLife;
    pixelList = other.pixelList;
    minDepth = other.minDepth;
    
    // NB: we might need to add the nested attribute here, and maybe other stuff as well
  }

  public float size() {
    return (maxx-minx)*(maxy-miny);
  }

  public PVector getCenter() {
    float x = (maxx - minx)* 0.5f + minx;
    float y = (maxy - miny)* 0.5f + miny;
    return new PVector(x, y);
  }
  
  public float getMinDepth(){
    return minDepth.depth;
  }

  public boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
  
  // This method is required due to implementing Comparable
  public int compareTo(Blob cb) {
        return floor(cb.size())-floor(size());//(int) Math.signum(size - cb.size);
  }
  
  public boolean isInside(float minx_, float miny_, float maxx_, float maxy_){
    if (minx <= minx_ && miny <= miny_ && maxx >= maxx_ && maxy >= maxy_) {
      /*
      println();
      println("stroke(0, 255, 0);");
      println("rect(", minx, ",", miny, ",", maxx, ",", maxy, ");");
      println("stroke(255,0,0);");
      println("rect(",minx_, ",", miny_, ",", maxx_, ",", maxy_, ");");
      println();
      */
      return true;
    }
    return false;
  }
  
  public Blob getCopy(){
    Blob b = new Blob();
    
    b.nested = nested;

    b.id = id;
    
    b.lifetime = lifetime;
    b.maxLife = maxLife;
    b.distThreshold = distThreshold;
    
    b.lifespan = lifespan;
    
    b.minx = minx;
    b.miny = miny;
    b.maxx = maxx;
    b.maxy = maxy;
    
    b.pixelList = new ArrayList<DepthPixel>();
    for (DepthPixel dp : pixelList){
      b.pixelList.add(dp.getCopy());
    }
    
    b.minDepth = new DepthPixel(minDepth.x, minDepth.y, minDepth.depth);
    
    return b;
  }
}
class DepthPixel{
  float x, y, depth;
  
  DepthPixel(float x_, float y_, float depth_){
    x = x_;
    y = y_;
    depth = depth_;
  }
  
  public DepthPixel getCopy(){
    return new DepthPixel(x, y, depth);
  }
}
class Tracker{
  
  //Kinect kinect;
  
  // Depth image
  PImage trackerDataMap;
  int [] rawDepthData;
  private int minDepth =  60; // 60
  int maxDepth = 1000; //1000;
  //float angle;
  
  int blobCounter = 0;
  
  int maxLife = 0; // original value 50
  int minBlobSize = 500; // area : h*w of blob
  
  int trackColor; 
  float threshold = 40;
  float distThreshold = 50;
  
  ArrayList<Area> ignoreAreas = new ArrayList<Area>();
  
  ArrayList<Blob> blobs = new ArrayList<Blob>();
  ArrayList<Blob> blobsFiltered = new ArrayList<Blob>();
  boolean nestedBlobsFilter = true;
  
  //Tracker(PApplet this_){
  Tracker(){
    trackColor = color(255);
    //kinect = new Kinect(this_);
    //kinect.initDepth();
    //angle = kinect.getTilt();
    //trackerDataMap = new PImage(kinect.width, kinect.height);
    trackerDataMap = new PImage(640,480);
  }
  
  public void detectBlobs(int [] rawDepthData_){
    rawDepthData = rawDepthData_;    
    if (loading) return;
    // alter input image based on threshold, needed for altering the Shiffmann code to work with Kinect images instead
    // Threshold the depth image
    //int[] rawDepth = kinect.getRawDepth();
    for (int i=0; i < rawDepthData.length; i++) {
      if (rawDepthData[i] >= minDepth && rawDepthData[i] <= maxDepth) {
        trackerDataMap.pixels[i] = color(255);
      } 
      else {
        trackerDataMap.pixels[i] = color(0);
      }
    }
    findBlobs(); // run blob finder
    blobsFiltered = copyBlobsList();
    //println("blobs size", blobs.size(), "blobsFiltered size", blobsFiltered.size());
    //removeNestedBlobs();
    if (nestedBlobsFilter) removeNestedBlobs();
    
  }
  
  /*
  void detectBlobs(){
    
    // alter input image based on threshold, needed for altering the Shiffmann code to work with Kinect images instead
    // Threshold the depth image
    int[] rawDepth = kinect.getRawDepth();
    for (int i=0; i < rawDepth.length; i++) {
      if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
        //depthImg.pixels[i] = color(255);
        trackerDataMap.pixels[i] = color(255);
      } 
      else {
        //depthImg.pixels[i] = color(0);
        trackerDataMap.pixels[i] = color(0);
      }
    }
    findBlobs(); // run blob finder
  }
  */
  
  
  // overloaded function for simulation purpose
  public void detectBlobs(PImage videoFrame){
    if (loading) return;
    trackerDataMap = videoFrame;
    findBlobs(); // run blob finder
    blobsFiltered = copyBlobsList(); // overwrite with original blob list
    if (nestedBlobsFilter) removeNestedBlobs();
  }
  
  
  public void findBlobs(){
    
    ArrayList<Blob> currentBlobs = new ArrayList<Blob>();
  
    // Begin loop to walk through every pixel
    for (int x = 0; x < trackerDataMap.width; x++ ) {
      for (int y = 0; y < trackerDataMap.height; y++ ) {
        
        if (isIgnored(x, y)) continue; // procees to next pixel if this one is in a ignored area
        
        int loc = x + y * trackerDataMap.width;
        // What is current color
        int currentColor = trackerDataMap.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
        float r2 = red(trackColor);
        float g2 = green(trackColor);
        float b2 = blue(trackColor);
  
        float d = distSq(r1, g1, b1, r2, g2, b2); 
  
        if (d < threshold*threshold) {
  
          boolean found = false;
          for (Blob b : currentBlobs) {
            if (b.isNear(x, y)) {
              
              if (inputMode == 0) b.add(x, y, rawDepthData[loc]);
              else b.add(x, y);
              found = true;
              break;
            }
          }
  
          if (!found) {
            Blob b = new Blob(x, y, maxLife, distThreshold); // here we might need to add depth pixel data as well
            currentBlobs.add(b);
          }
        }
      }
    }
    
    // remove too small blobs
    for (int i = currentBlobs.size()-1; i >= 0; i--) {
      if (currentBlobs.get(i).size() < minBlobSize) {
        currentBlobs.remove(i);
      }
    }
  
    // There are no blobs!
    if (blobs.isEmpty() && currentBlobs.size() > 0) {
      println("Adding blobs!");
      for (Blob b : currentBlobs) {
        b.id = blobCounter;
        blobs.add(b);
        blobCounter++;
      }
    } 
    else if (blobs.size() <= currentBlobs.size()) {
      // Match whatever blobs you can match
      for (Blob b : blobs) {
        float recordD = 1000;
        Blob matched = null;
        for (Blob cb : currentBlobs) {
          PVector centerB = b.getCenter();
          PVector centerCB = cb.getCenter();         
          float d = PVector.dist(centerB, centerCB);
          if (d < recordD && !cb.taken) {
            recordD = d; 
            matched = cb;
          }
        }
        matched.taken = true;
        b.become(matched);
      }
  
      // Whatever is leftover make new blobs
      for (Blob b : currentBlobs) {
        if (!b.taken) {
          b.id = blobCounter;
          blobs.add(b);
          blobCounter++;
        }
      }
    } 
    else if (blobs.size() > currentBlobs.size()) {
      for (Blob b : blobs) {
        b.taken = false;
      }
  
  
      // Match whatever blobs you can match
      for (Blob cb : currentBlobs) {
        float recordD = 1000;
        Blob matched = null;
        for (Blob b : blobs) {
          PVector centerB = b.getCenter();
          PVector centerCB = cb.getCenter();         
          float d = PVector.dist(centerB, centerCB);
          if (d < recordD && !b.taken) {
            recordD = d; 
            matched = b;
          }
        }
        if (matched != null) {
          matched.taken = true;
          // Resetting the lifespan here is no longer necessary since setting `lifespan = maxLife;` in the become() method in Blob.pde
          // matched.lifespan = maxLife;
          matched.become(cb);
        }
      }
  
      for (int i = blobs.size() - 1; i >= 0; i--) {
        Blob b = blobs.get(i);
        //b.lifetime++;
        if (!b.taken) {
          if (b.checkLife()) {
            blobs.remove(i);
          }
        }
      }
    }
    // update lifetime for all blobs
    /*
    for (Blob b : blobs) {
      b.lifetime = b.lifetime+1;
    }
    */
  }
  
  
  // retrieve image (trackerDataMap) from tracker
  public PImage getTrackerImage(){
      trackerDataMap.updatePixels();
      return trackerDataMap;
  }
  
  
  // Draw all blobs
  public void showBlobs(/*boolean showPixels*/){
    //println("showBlobs blobs size", blobs.size());
    for (Blob b : blobsFiltered) {
      b.show();
      //if (showPixels) b.showPixels();
    }
    //println();
  }
  
  public void removeNestedBlobs(){
    Collections.sort(blobsFiltered); // sorts blobs by size, largest first
    for (int i = 0; i < blobsFiltered.size(); i++){
      for (int j = 0; j < blobsFiltered.size(); j++){
        if (i != j){
          if (blobsFiltered.get(i).isInside(blobsFiltered.get(j).minx, blobsFiltered.get(j).miny, blobsFiltered.get(j).maxx, blobsFiltered.get(j).maxy)){
            //println("Blob removed", "index", j, "id", blobs.get(j).id);
            //blobs.remove(j);
            blobsFiltered.get(j).nested = true; // flag for deletion
          }
          //else blobs.get(j).nested = false; // flag for deletion
        }  
      }
      
    }
    for (int i = blobsFiltered.size()-1; i > 0; i--){ // traverse in reverse and delete. In order to avoid errors due to list length changing while traversing.
      if (blobsFiltered.get(i).nested) {
        //getBlobFromId(blobsFiltered.get(i).id).lifetime = 0;
        blobsFiltered.remove(i);
      }
    }
  }
  
  /*
  // not ready for use
  void removeNewBlobs(){
    println();
    for (int i = blobsFiltered.size()-1; i > 0; i--){
      //blobsFiltered.get(i).lifetime = blobsFiltered.get(i).lifetime +1;
      print("ID", blobsFiltered.get(i).id, "Lifetime", blobsFiltered.get(i).lifetime);
      if (blobsFiltered.get(i).lifetime < 50) {
        //println("remove new blob with id", blobsFiltered.get(i).id, "and lifetime", blobsFiltered.get(i).lifetime);
        print(" REMOVED");
        blobsFiltered.remove(i);
      }
      println();
      //if (blobs.get(i).lifetime < 20) blobs
      //if (blobs.get(i).maxLife - blobs.get(i).lifespan < 10) blobs.remove(i); 
    }
  }
  */
  
  // checks if a given pixel is in a ignore area
  public boolean isIgnored(int x, int y){
      for (Area a : ignoreAreas){
        if (distSq(a.x, a.y, x, y) < a.radius*a.radius) return true;  
      }
      return false;
  }
  
  // drasw ignore areas
  public void showIgnoreAreas(){
    for (Area ia : ignoreAreas){
      ia.show();
    }
  }
  
  
  // --- GETTERS, SETTERS, CONTROLS, SETTINGS ---
  
  public Blob [] getBlobs(){
    // use filters here
    Blob[] array = new Blob[t.blobsFiltered.size()];
    array = t.blobsFiltered.toArray(array);
    if (!nestedBlobsFilter) {
      array = new Blob[t.blobs.size()];
      array = t.blobs.toArray(array);
    }
    return array;
  }
  
  public void setThreshold(float threshold_){
    threshold = threshold_;
  }
  
  public float getThreshold(){
    return threshold;
  }
  
  public void increaseThreshold(int step){
    threshold += step;
  }
  public void decreaseThreshold(int step){
    threshold -= step;
  }
  
  public void setDistThreshold(float distThreshold_){
    distThreshold = distThreshold_;
    for (int i = 0; i < blobs.size(); i++){
      blobs.get(i).distThreshold = distThreshold;
    }
  }
  
  public float getDistThreshold(){
    return distThreshold;
  }
  
  public void increaseDistThreshold(int step){
    distThreshold += step;
  }
  public void decreaseDistThreshold(int step){
    distThreshold -= step;
  }
  
  
  public int getMinDepth(){
    return minDepth;
  }
  public int getMaxDepth(){
    return maxDepth;
  }
  
  public void setMinDepth(int minDepth_){
    minDepth = constrain(minDepth_, 0, maxDepth);
  }
  public void setMaxDepth(int maxDepth_){
    maxDepth = constrain(maxDepth_, minDepth, 2047);
  }
  
  public void increaseMinDepth(int step){
    minDepth = constrain(minDepth+step, 0, maxDepth);
  }
  public void decreaseMinDepth(int step){
    minDepth = constrain(minDepth-step, 0, maxDepth);
  }
  
  public void increaseMaxDepth(int step){
    maxDepth = constrain(maxDepth+step, minDepth, 2047);
  }
  public void decreaseMaxDepth(int step){
    maxDepth = constrain(maxDepth-step, minDepth, 2047);
  }
  
  public void setTrackColor(int c){
    trackColor = c;
  }
  public int getTrackColor(){
    return trackColor;
  }
  public void increaseMinBlobSize(int step){
    minBlobSize+=step;
  }
  public void decreaseMinBlobSize(int step){
    minBlobSize-=step;
  }
  public int getMinBlobSize(){
    return minBlobSize;
  }
  public void setMinBlobSize(int size){
    minBlobSize = size;
  }
  
  // add area to be ignored by tracker
  public void addIgnoreArea(int x, int y, int radius){
    ignoreAreas.add(new Area(x, y, radius));  
  }
  // delete ignore area
  public void deleteIgnoreArea(int x, int y){
    for (int i = 0; i < ignoreAreas.size(); i++){
      if (ignoreAreas.get(i).isInside(x, y)) {
        ignoreAreas.remove(i);
      }
    }
  }
  
  public int getNrOfBlobs(){
    if (nestedBlobsFilter) return blobsFiltered.size();
    else return blobs.size();
  }
  
  // clear all ingore areas in the list
  public void clearIgnoreAreas(){
    ignoreAreas.clear();  
  }
  
  // gives string version of ignoreAreas list
  public String ignoreAreasToString(){
    String output = "";
    for (Area a : t.ignoreAreas){ // ### make ignoreAreasToString() inside tracker class instead
      output += "|"+a.x+","+a.y+","+a.radius;
    }
    return output;
  }
  
  public void printBlobsList(){
    for (Blob b : blobs){
      println(b.getCenter().x, b.getCenter().y, b.id, b.size());
    }
  }
  
  public ArrayList<Blob> copyBlobsList(){
    ArrayList<Blob> blobsList = new ArrayList<Blob>();
    for (Blob b : blobs){
      blobsList.add(b.getCopy());
    }
    return blobsList;
  }
  
  
  public Blob getBlobFromId(int id_){
    for (Blob b : blobs){
      if (id_ == b.id) return b;
    }
    return null;
  }
  
  public void setNestedBlobFilter(boolean nestedBlobsFilter_){
    nestedBlobsFilter = nestedBlobsFilter_;
  }
  
  public boolean getNestedBlobFilter(){
    return nestedBlobsFilter;
  }
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Kinect_blob_tracking_refactored" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
