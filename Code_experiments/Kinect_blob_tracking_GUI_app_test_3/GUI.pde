int inputMode = 1; // 0 = kinect | 1 = webCam | 2 = video file simulation   // // set in settings file & UI

boolean textInfo = true; // only set in code
boolean drawBlobs = true; // set in settings file & UI
boolean sendingOSC = false; // set in settings file & UI
boolean disableSimulation = false; // set in settings file

String simulationVideoFile; // set in settings file & UI

// IGNORE AREAS
int pressX, pressY;
int releaseX, releaseY;
int dragState = -1;

boolean loading = false; // load settings flag

String errorString = "";



void drawInfo() {
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
      text("[" + int(red(t.getTrackColor()))+","+int(green(t.getTrackColor()))+","+int(blue(t.getTrackColor())) + "]", secondCol, firstRow+rowStep*rowNumber);  
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
  text("FPS: " + int(frameRate), 35, 20);
  
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
void saveSettingsCallback(File selection) {
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
    settings[12] = ""+disableSimulation;
    settings[13] = ""+exit_on_kinect_error;
    settings[14] = ""+logsEnabled;
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

void loadSimulationVideoCallback(File selection) {
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

void loadSettings(String path) {
  t.clearIgnoreAreas();
  String [] settings = loadStrings(path);
  t.setMinDepth(int(settings[0]));
  t.setMaxDepth(int(settings[1]));
  t.setThreshold(float(settings[2]));
  t.setDistThreshold(float(settings[3]));
  drawBlobs = boolean(settings[4]);
  String[] ignoreList = split(settings[5], '|');
  if (ignoreList.length > 1){
    println("areas in the list");
    for (int i = 1; i < ignoreList.length; i++){
      String[] tempIgnoreArea = split(ignoreList[i], ',');
      if (tempIgnoreArea.length == 3){
        println("TIA: " + tempIgnoreArea.length);
        t.addIgnoreArea(int(tempIgnoreArea[0]), int(tempIgnoreArea[1]), int(tempIgnoreArea[2]));
      }
      else println("ERROR in ignore area load - string split array length : " + tempIgnoreArea.length);      
    }
  }
  else println("no ignore areas to load");
  inputMode = int(settings[6]);
  t.setMinBlobSize(int(settings[7]));
  oscInfo = split(settings[8], ',');
  oscP5 = new OscP5(this, int(oscInfo[1]));
  myRemoteLocation = new NetAddress(oscInfo[0], int(oscInfo[2]));
  sendingOSC = boolean(settings[9]);
  simulationVideoFile = settings[10];
  //loadSimulationVideo();
  setInputMode(inputMode);
  t.setNestedBlobFilter(boolean(settings[11]));
  disableSimulation = boolean(settings[12]);
  exit_on_kinect_error = boolean(settings[13]);
  logsEnabled = boolean(settings[14]);
  loading = false; // flag loading process done
  
}


// --- key commands ---
void keyPressed() {

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



void mousePressed() {
  if (mouseButton == LEFT) {
    pressX = mouseX;
    pressY = mouseY;
    releaseX = mouseX; // make release the same as press to clear old data
    releaseY = mouseY;
    dragState = 0;
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    releaseX = mouseX;
    releaseY = mouseY;
    dragState = 1;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT){
    if (inputMode == 1) t.setTrackColor(webCam.get(mouseX, mouseY));
    if (dragState == 1 && dist(pressX, pressY, releaseX, releaseY) > 5) {
      t.addIgnoreArea(pressX, pressY, int(dist(pressX, pressY, releaseX, releaseY)));
      //t.ignoreAreas.add(new Area(pressX, pressY, int(dist(pressX, pressY, releaseX, releaseY)))); // move inside tracker class
      dragState = 2;
    }
  }
  else if (mouseButton == RIGHT) {
    t.deleteIgnoreArea(mouseX, mouseY);
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


void setInputMode(int mode){
  
  if (kinect != null){
    if (kinect.numDevices() != 0) {
      kinect.stopDepth();
    }
  }
  if (webCam != null) webCam.stop();
  if (simulationVideo != null) simulationVideo.stop();
  //kinect = null;
  if (mode == 0) {
    kinectFrameZero = 0; // reset frame zero to detect if kinect boots up correctly
    if (debug) println("Starting kinect");
    if (logsEnabled) log("Starting kinect", logFile);
    if (kinect == null) kinect = new Kinect(this);
    if (kinect.numDevices() > 0) {
      kinect.initDepth();
      if (debug) println("Initiating kinect depth: kinect.initDepth()");
      if (logsEnabled) log("Initiating kinect depth: kinect.initDepth()", logFile);
    }
    else {
      if (debug) println("Kinect number of devices 0 or less");
      if (logsEnabled) log("Kinect number of devices 0 or less", logFile);
    }
    if (kinect == null) {
      if (logsEnabled) log("Kinect null", logFile);
      if (debug) println("Kinect null");
    }
    t.setTrackColor(color(255)); // set tcack color back to white, in case it was changed by user in webcam input mode
  } 
  else if (mode == 1) {
    if (debug) println("Starting webcam");
    if (logsEnabled) log("Starting webcam", logFile);
    String[] cameras = Capture.list();
    if (debug) println("Available cameras:");
    if (debug) printArray(cameras);
    if (cameras == null) println("cameras null");
    println("cameras.length:", cameras.length);
    //if (cameras.length < 1) webcamDetected = false;
    if (webcamDetected){
      webCam = new Capture(this, 640, 480, cameras[0]);
      webCam.start();
    }
  } 
  else if (mode == 2) {
    if (debug) println("Starting video simulation");
    if (logsEnabled) log("Starting video simulation", logFile);
    loadSimulationVideo();
  }
}

void loadSimulationVideo(){
  if (!disableSimulation){
    simulationVideo = new Movie(this, simulationVideoFile);
    simulationVideo.loop();
    t.setTrackColor(color(255)); // set tcack color back to white, in case it was changed by user in webcam input mode
  }
  else {
    if (debug) println("Video simulation disabled");
    if (logsEnabled) log("Video simullation disabled", logFile);
  }
}
