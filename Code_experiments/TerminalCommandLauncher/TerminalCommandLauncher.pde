/*
  Processing sketch for running Text-To-Speech odule of installation: The Social Megaphone Experiment, by UNMAKE
  http://unmake.dk/
  written by: Halfdan Hauch Jensen
  26/6-2015
  halfdan@unmake.dk
*/

String call1; // text string for storing speech data
int voiceIndex = 0;
int voiceSpeed = 180;

boolean mode = false; // false=manual, true=automatic
int buttonDiam = 70;
int updateX = buttonDiam/2+20;
int updateY = 60;
int playX = updateX+100;
int playY = 60;
int modeX = playX+100;
int modeY = 60;

long timer;
int interval = 5000;
int betweenDelay = 1000*60*5;
int pauseDelay = betweenDelay+1000*60*5;

void setup() {
  size(700, 700);
  frameRate(25);
  ellipseMode(CENTER);
  call1 = getData();
}

void draw() {
  background(0);
  ellipse(modeX, modeY, buttonDiam, buttonDiam);
  if (!mode){
    ellipse(updateX, updateY, buttonDiam, buttonDiam);
    ellipse(playX, playY, buttonDiam, buttonDiam);
    fill(0,0,255);
    text("manual", modeX-buttonDiam*0.32, modeY);
    text("play", playX-buttonDiam*0.2, playY);
    text("update", updateX-buttonDiam*0.3, updateY);
    fill(255);
  }
  else {
    fill(0,0,255);
    text("auto", modeX-buttonDiam*0.2, modeY);
    fill(255);
    text("time till next: "+((timer+interval-millis())/1000), 200, 20);
    
    if (millis()>timer+interval){
      timer=millis();
      call1 = getData();
      interval = (call1.length()*82)+betweenDelay;
      TextToSpeech.say(call1, TextToSpeech.voices[voiceIndex], voiceSpeed);
    }
  }
  // help text
  fill(255);
  text("Voice " + TextToSpeech.voices[voiceIndex] + " speed " + voiceSpeed, 10, 20);
  text(call1, 10, 100, width-20, height-20);
}

void mouseReleased() {

  if (!mode){
    if (dist(mouseX, mouseY, updateX, updateY)<buttonDiam/2) {
      //strings = loadStrings("http://socialmegaphone.dk/extract_module/db_get.php?PST=48048565121747547780989");
      call1 = getData();//strings[4];
      fill(255,0,0);
    }
    if (dist(mouseX, mouseY, playX, playY)<buttonDiam/2) {
      TextToSpeech.say(call1, TextToSpeech.voices[voiceIndex], voiceSpeed);
    }
  }  
  
  if (dist(mouseX, mouseY, modeX, modeY)<buttonDiam/2) {
    mode=!mode;
    if (mode) timer=millis()-interval+10000;
  }
}

// --- method for retriving text ---
String getData(){
  String [] strings = loadStrings("http://socialmegaphone.dk/extract_module/db_get.php?PST=48048565121747547780989");
  String data = "";
  for (int i = 0; i < strings.length; i++){
    if (i > 0) println("extra lines: " + i);
    data+=" "+strings[i];
  }
  return data;
}
