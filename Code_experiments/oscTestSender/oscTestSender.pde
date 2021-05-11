/**
 * oscP5parsing by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an
 * alternative and more convenient way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

boolean kinectState, soundState;
long timer;
int interval = 5000;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",11011);
  textSize(30);
  textAlign(CENTER);
}

void draw() {
  background(0);
  stroke(255);
  fill(0);
  if (kinectState) fill(0,255,0);
  rect(0,0,width/2, height);
  fill(0);
  if (soundState) fill(0,0,255);
  rect(width/2,0,width/2, height);
  fill(255);
  text("Kinect", width/4, height/2);
  text("Sound", width/4*3, height/2);
  
  
  if (millis() > timer + interval){
    timer = millis();
    //println("send osc");
    sendOsc(kinectState, soundState); 
  }
}


void mouseReleased(){
  if (mouseX < width/2) kinectState = !kinectState;
  if (mouseX >= width/2) soundState = !soundState;
}


void keyReleased(){
  
  if (key == 's'){
    /* create a new osc message object */
    OscMessage myMessage = new OscMessage("/SoundAlive");
    
    myMessage.add("Sound is alive"); /* add an int to the osc message */
  
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation); 
    
  }
  
  else if (key == 'k'){
    /* create a new osc message object */
    OscMessage myMessage = new OscMessage("/KinectAlive");
    
    myMessage.add("Kinect is alive"); /* add an int to the osc message */
  
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation); 
    
  }
  
}

void sendOsc(boolean kinect, boolean sound){
  if (kinect){
     //println("send OSC kinect");
     OscMessage myMessage = new OscMessage("/KinectAlive");
     myMessage.add("Kinect is alive"); /* add an int to the osc message */
     oscP5.send(myMessage, myRemoteLocation); 
     
  }
  if (sound){
    //println("send OSC sound");
    OscMessage myMessage = new OscMessage("/SoundAlive");
    myMessage.add("Sound is alive"); /* add an int to the osc message */
    oscP5.send(myMessage, myRemoteLocation);
  }
}
