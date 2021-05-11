
import oscP5.*;

OscP5 oscP5;
OscAlertProsponer alertProsponer;
           
void setup() {
  frameRate(25);
  oscP5 = new OscP5(this,12012);
  alertProsponer = new OscAlertProsponer(oscP5, "127.0.0.1", 11011, "/KinectAlive");
  alertProsponer.isActive = true;
}

void draw() {  
  // update alert prosponer
  alertProsponer.update();
}
