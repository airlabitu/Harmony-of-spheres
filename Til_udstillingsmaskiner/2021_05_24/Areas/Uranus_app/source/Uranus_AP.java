import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import processing.sound.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Uranus_AP extends PApplet {

// This is the template sketch for the HoS project planet sound sketches
// Volumen is going from low to high, the effects: Delay, Envelope, Rate are all implemented into the sphere class
// This happens when a user enters the sphere circle, and is adjusted according to distance from user blob center to sphere cente




OscP5 oscP5;
Blob [] blobs;
int framesSinceLastOscMessage = 0;

Sphere [] spheres;

boolean simulate = false;
int millisToFadeInside = 300;
int millisToFadeOutside = 2000;
int millisToFadeNoBlobs = 5000;

boolean groupsEnabled = false;

// alert prosponer
OscAlertProsponer soundAlertProsponer;

public void setup() {
  
  frameRate(25);
  textAlign(CENTER);
  oscP5 = new OscP5(this, 6789);
  spheres = new Sphere [9];

  // turn off sounds
  spheres[0] = new Sphere(500, 100, 75, "1.wav", this, 1, 2);
  spheres[1] = new Sphere(300, 100, 75, "2.wav", this, 2, 4);
  spheres[2] = new Sphere(100, 100, 75, "3.wav", this, 3, 3);
  spheres[3] = new Sphere(500, 250, 75, "4.wav", this, 4, 3);
  spheres[4] = new Sphere(300, 250, 75, "5.wav", this, 5, 1);
  spheres[5] = new Sphere(100, 250, 75, "6.wav", this, 6, 4);
  spheres[6] = new Sphere(500, 400, 75, "7.wav", this, 7, 4);
  spheres[7] = new Sphere(300, 400, 75, "8.wav", this, 8, 3);
  spheres[8] = new Sphere(100, 400, 75, "9.wav", this, 9, 2);

  for (Sphere s : spheres) {
    s.track.loop();
    s.track.amp(s.vol.getMin());
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside);
    
    //s.enableDelay(this, 0.3); // 0.3 is the delay tape // ###delay
    s.enableRate(); // ### rate
    s.rate.setMinMax(0.92f, 1.0f);
    //s.rate.reverse(true);    
    
    if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside);
  
  }
  
  // alert prosponer
  soundAlertProsponer = new OscAlertProsponer(oscP5, "127.0.0.1", 11011, "/SoundAlive");
  soundAlertProsponer.isActive = true;
}


public void draw() {
  background(0);

  for (Sphere s : spheres) {
    s.show(255, 255, 255);
    s.update();
    if (simulate) mouseInteraction(s, spheres, "LINEAR_FADE");
    else blobsInteraction(s, spheres, "LINEAR_FADE");
  }
  fill(0, 0, 255);
  text("Simulate: " + simulate, 50, height -10);
  
  // update alert prosponer
  soundAlertProsponer.update();
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
public void oscEvent(OscMessage theOscMessage) {
  println("--- OSC MESSAGE RECEIVED ---");
  // Check if the address pattern is the right one
  if (theOscMessage.checkAddrPattern("/Blobs|X|Y|MIN_DEPTH|ID|NR_OF_PIXELS|")==true) {
    println("AddressPattern matched:", theOscMessage.addrPattern());
    // check if the typetag is the right one
    String typeTag = "";
    for (int i = 0; i < theOscMessage.typetag().length(); i++) typeTag += "i";
    if (theOscMessage.checkTypetag(typeTag)) {
      println("TypeTag matched:", theOscMessage.typetag());
      blobs = new Blob[theOscMessage.typetag().length()/5];
      println("Blobs length: ", blobs.length);
      for (int i = 0, j = 0; i <= theOscMessage.typetag().length()-5; i+=5, j++) {
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

public void mouseInteraction(Sphere s, Sphere [] s_array, String type) {
  fill(0, 255, 0);
  ellipse(mouseX, mouseY, 20, 20);
  int d = (int)dist(mouseX, mouseY, s.x, s.y);
  soundManipulation(s, s_array, d, type);
}

public void blobsInteraction(Sphere s, Sphere [] s_array, String type) {
  if (framesSinceLastOscMessage > 25) {
    blobs = null;

    s.vol.setVal(s.vol.getMin(), millisToFadeNoBlobs);
  }
  if (blobs != null) {
    int minDist = 999999999;
    for (Blob b : blobs) {
      if (b != null) {
        int thisDist = (int)dist(b.x, b.y, s.x, s.y);
        if (thisDist < minDist) minDist = thisDist; 

        fill(map(b.minDepth, 0, 2047, 255, 0));
        ellipse(b.x, b.y, 50, 50);
      }
    }
    if (minDist != 999999999) {
      soundManipulation(s, s_array, minDist, type);
    }
  }
  framesSinceLastOscMessage++;
}

public void soundManipulation(Sphere s, Sphere [] s_array, int dist, String type) {
  // turn off
  float center = 0.2f;
  if (type.equals("SINUS_FADE")){
    noFill();
    circle(s.x, s.y, (s.radius*center)*2);
  }
  if (dist < s.radius) {
    // control sphere 's'
    if (type.equals("SINUS_FADE")) s.vol.setVal(sin(map(constrain(dist, s.radius*center, s.radius), s.radius*center, s.radius, 0, PI))*s.vol.getMax(), millisToFadeInside);   // shift over 100 millis      
    else if (type.equals("LINEAR_FADE")) s.vol.setVal(map(dist, 0, s.radius, s.vol.getMax(), s.vol.getMin()), millisToFadeInside);   // shift over 100 millis
    
    // GROUPS
    if (groupsEnabled){
      for (Sphere sp : s_array){ // groups  
        // set all others like id '5'
        if (s.getId() == 5){
          if (s.getId() != sp.getId()){
            sp.vol.setVal(s.vol.getVal(), millisToFadeInside);
            if (sp.rateEnabled) sp.rate.setVal(map(dist, 0, sp.radius, sp.rate.getMax(), sp.rate.getMin()), millisToFadeInside); 
          }
        }
        // control all in group with sphere 's' like it
        else if (s.getId() != sp.getId() && s.getGroup() == sp.getGroup()){
          sp.vol.setVal(s.vol.getVal(), millisToFadeInside);
          if (sp.rateEnabled) sp.rate.setVal(map(dist, 0, sp.radius, sp.rate.getMax(), sp.rate.getMin()), millisToFadeInside); 
          
        }
      }
    }
    
    //if (s.delayEnabled) s.delayVal.setVal(map(dist, 0, s.radius, s.delayVal.getMax(), s.delayVal.getMin()), millisToFadeInside);
    if (s.rateEnabled) s.rate.setVal(map(dist, 0, s.radius, s.rate.getMax(), s.rate.getMin()), millisToFadeInside); 
  }
  else {
    s.vol.setVal(s.vol.getMin(), millisToFadeOutside); // shift to min
    //if (s.delayEnabled) s.delayVal.setVal(s.delayVal.getMin(), millisToFadeOutside); 
    if (s.rateEnabled) s.rate.setVal(s.rate.getMin(), millisToFadeOutside);
  }
}

// key for toggling mouse simulation
public void keyPressed() {
  if (key == 's') simulate = !simulate;
}


class OscAlertProsponer{
  boolean isActive;
  long timer;
  int interval;
  String addressPattern;

  OscP5 osc;
  NetAddress emailNotifyerLocation;
  
  OscAlertProsponer(OscP5 osc_, String ip_, int port_, String addressPattern_){
    emailNotifyerLocation = new NetAddress(ip_, port_);
    interval = 5000; // default updating frequincy
    addressPattern = addressPattern_;
    osc = osc_;
  }
  
  public void update(){
    if (millis() > timer + interval){
      timer = millis();
      prosponeAlert(); 
    }
  }
  
  public void prosponeAlert(){
    if (isActive){
      OscMessage myMessage = new OscMessage(addressPattern);
      //println("Message:", myMessage.addrPattern());
      osc.send(myMessage, emailNotifyerLocation);
    }
    else println("Alert not active", addressPattern);
  }
  
}
class Sphere{
  int x, y, radius, xMove, yMove;
  SoundFile track;
  float targetVol;
  float volIncrement;
  float incrementDir = 0;
  ValueFader vol;
  ValueFader delayVal;
  int group;
  int id;
  Delay delay;
  boolean delayEnabled;
  boolean envelopeEnabled;
  boolean rateEnabled;
  ValueFader rate;
  
  Sphere(int x_, int y_, int radius_, String track_, PApplet pa_, int id_, int group_){
    x = x_;
    y = y_;
    radius = radius_;
    track = new SoundFile(pa_, track_);
    vol = new ValueFader();
    vol.setMinMax(0.00001f,1);
    delayVal = new ValueFader();
    delayVal.setMinMax(0.3f, 0.8f); 
    rate = new ValueFader();
    rate.setMinMax(0.6f, 1.0f);
    id = id_;
    group = group_;
  }
  
  public void enableDelay(PApplet pa_, float tape_){
    delay = new Delay(pa_);
    delay.process(track, tape_);
    delayEnabled = true;
  }
  
  public void enableRate(){
    rateEnabled = true;
  }
  
  public void update(){
    vol.update();
    track.amp(vol.getVal());
    if (delayEnabled) {
      delayVal.update();
      delay.feedback(delayVal.getVal());
    }
    if (rateEnabled) {
      rate.update();
      track.rate(rate.getVal());
    }
  }
  
  public void show(int red, int green, int blue){
    noFill();
    if (vol.getVal() > vol.getMin()) fill(red, green, blue, map(vol.getVal(), vol.getMin(), vol.getMax(), 0, 150));
    stroke(255);
    ellipse(x, y, radius*2, radius*2);
    fill(0,255,0);
    if (rateEnabled) text("Rate: " + nf(rate.getVal(), 0, 2), x+xMove, y-30+yMove);
    if (delayEnabled) text("Delay: " + nf(delayVal.getVal(), 0, 2), x+xMove, y-15+yMove);
    text("Vol: " + nf(vol.getVal(), 0, 2), x+xMove, y+yMove);
    text("ID: " + id, x+xMove-30, y+30+yMove);    
    //text("Group: " + group, x+xMove+30, y+30+yMove); 
  
  }
  
  public int getGroup(){
    return group;
  }
  
  public int getId(){
    return id;
  }
}
class ValueFader{
  
  float val = 0;
  float minVal = 0;
  float maxVal = 1;
  float fadeDir = 0;
  float increment;
  float targetVal;
  float lastTargetVal;
  boolean reverse;
    
  public void setVal(float targetVal_, float fadeTime){
    
    // prevent exponentiel fade 
    if (lastTargetVal == targetVal_) return;
    lastTargetVal = targetVal_;
    
    // reverse
    targetVal = constrain(targetVal_, minVal, maxVal);
    if (reverse) targetVal = map(targetVal, minVal, maxVal, maxVal, minVal);
    
    // prevents division by zero
    if (frameRate == 0) frameRate = 1;
    if (fadeTime == 0) fadeTime = 1; 
    
    float millisPrFrame = 1000/frameRate; // calculate millis/frame or millis between frames
    float dist = abs(val-targetVal);
    increment = dist/fadeTime; // calculate increment / millis
    increment = increment*millisPrFrame; // calculate increment / frame
    if (targetVal > val) fadeDir = 1;
    else if (targetVal < val) fadeDir = -1;
    else fadeDir = 0;
  }
  
  public float getVal(){
    return val;
  }
  
  public float getMin(){
    return minVal;
  }
  
  public float getMax(){
    return maxVal;
  }
  
  public void reverse(boolean r_){
    reverse = r_;
    setVal(getVal(),1);
  }

  public void setMinMax(float minVal_, float maxVal_){
    minVal = minVal_;
    maxVal = maxVal_;
    val = constrain(val, minVal, maxVal);
  }
  
  // needs to be called every frame
  public void update(){
    val = constrain(val+increment*fadeDir, minVal, maxVal);
    if (fadeDir < 0) val = max(val, targetVal);
    else if (fadeDir > 0) val = min(val, targetVal);
  }
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Uranus_AP" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
