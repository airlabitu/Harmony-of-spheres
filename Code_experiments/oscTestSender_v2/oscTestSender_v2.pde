
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress emailNotifyerLocation;

OscAlertProsponer kinectAlertProsponer;
OscAlertProsponer soundAlertProsponer;
           
void setup() {
  size(400,400);
  frameRate(25);
  oscP5 = new OscP5(this,12000);
  emailNotifyerLocation = new NetAddress("127.0.0.1", 11011);
  textSize(30);
  textAlign(CENTER);
  
  kinectAlertProsponer = new OscAlertProsponer(oscP5, emailNotifyerLocation, "/KinectAlive");
  soundAlertProsponer = new OscAlertProsponer(oscP5, emailNotifyerLocation, "/SoundAlive");
  kinectAlertProsponer.isActive = true;
  kinectAlertProsponer.messageString = "Kinect is alive";
  soundAlertProsponer.messageString = "Sound is alive";
}

void draw() {
  background(0);
  
  // draw GUI stuff
  stroke(255);
  fill(0);
  if (kinectAlertProsponer.isActive) fill(0,255,0);
  rect(0,0,width/2, height);
  fill(0);
  if (soundAlertProsponer.isActive) fill(0,0,255);
  rect(width/2,0,width/2, height);
  fill(255);
  text("Kinect", width/4, height/2);
  text("Sound", width/4*3, height/2);
  
  // update alert prosponers
  kinectAlertProsponer.update();
  soundAlertProsponer.update();
}


void mouseReleased(){
  // set alert prosponer states
  if (mouseX < width/2) kinectAlertProsponer.isActive = !kinectAlertProsponer.isActive;
  if (mouseX >= width/2) soundAlertProsponer.isActive = !soundAlertProsponer.isActive;
}
