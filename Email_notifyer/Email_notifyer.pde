// Daniel Shiffman example modified by: AIR LAB ITU, Halfdan Hauch Jensen
//
// http://www.shiffman.net
// https://www.airlab.itu.dk

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

long kinectAlertTimer = 0;
long kinectLastAlertTime = -1000000000;
long soundAlertTimer = 0;
long soundLastAlertTime = -1000000000;
int minutesBeforeAlert = 1;
int minutesBetweenAlerts = 15;
int interval = 1000*60*minutesBeforeAlert;
//int interval = 5000; // test intervaæ
int timeBetweenAlerts = 1000*60*minutesBetweenAlerts; // 
String alerts = "";

long kinectSecSinceLastAlert;
long kinectMinSinceLastAlert;
  
long soundSecSinceLastAlert;
long soundMinSinceLastAlert;


void setup() {
  
  size(400, 800);
  frameRate(1);
  oscP5 = new OscP5(this,11011);
  stroke(255);
  fill(255);
  
}

void draw(){
  if (millis() > soundAlertTimer + interval && (millis() - soundLastAlertTime) > timeBetweenAlerts){
    println(year() + "/" + month() +"/" + day() + " - " + hour() + ":" + minute() + ":" + second() + " : Email alert - Sound is down");
    soundAlertTimer = millis(); // prospone alert
    soundLastAlertTime = soundAlertTimer;
    log("HoS Alert: Sound is down", "email_log_.txt");
    alerts = getLogString("HoS Alert: Sound is down")+alerts;
    sendMail("HoS alert!", "Alert: Sound is down");
   }
   
  if (millis() > kinectAlertTimer + interval && (millis() - kinectLastAlertTime) > timeBetweenAlerts){
    println(year() + "/" + month() +"/" + day() + " - " + hour() + ":" + minute() + ":" + second() + " : Email alert - Kinect is down");
    kinectAlertTimer = millis(); // prospone alert
    kinectLastAlertTime = kinectAlertTimer;
    log("HoS Alert: Kinect is down", "email_log_.txt");
    alerts = getLogString("HoS Alert: Kinect is down")+alerts;
    sendMail("HoS alert!", "Alert: Kinect is down");
  }
  background(0);
  
  
  kinectSecSinceLastAlert = floor((millis()-kinectLastAlertTime)/1000);
  kinectMinSinceLastAlert = floor(kinectSecSinceLastAlert/60);
  
  soundSecSinceLastAlert = floor((millis()-soundLastAlertTime)/1000);
  soundMinSinceLastAlert = floor(soundSecSinceLastAlert/60);
  
  //text("Time since last Kinect alert: " + prependZero((int)(secondsSinceLastKinectAlert/60)) + ":" + prependZero((int)(secondsSinceLastKinectAlert%60)), 50, 100);
  text("Pause between alerts: " + minutesBetweenAlerts + " (min)", 20, 40);
  text("Alert trigger time: " + minutesBeforeAlert + " (min)", 20, 70);
  text("- NB: resets with every prospone message (OSC)", 30, 85);
  
  text("Time since last Kinect alert: " + (kinectMinSinceLastAlert/60/24) + " (days) " + prependZero((kinectMinSinceLastAlert/60)%24) + ":" + prependZero(kinectMinSinceLastAlert%60) + ":" + prependZero(kinectSecSinceLastAlert%60) + " (h:m:s)", 20, 125);
  text("Time before next Kinect alert: " + (millisToMinHour((int)max(kinectAlertTimer+interval-millis(), 0))), 20, 145);
  
  text("Time since last Sound alert: " + (soundMinSinceLastAlert/60/24) + " (days) " + prependZero((soundMinSinceLastAlert/60)%24) + ":" + prependZero(soundMinSinceLastAlert%60) + ":" + prependZero(soundSecSinceLastAlert%60) + " (h:m:s)", 20, 175);
  text("Time before next Sound alert: " + (millisToMinHour((int)max(soundAlertTimer+interval-millis(), 0))), 20, 195);
  
  text("[LOG]", 20, 240);
  line(20,250, width-20, 250);
  text(alerts, 20, 270);
}


void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  if(theOscMessage.checkAddrPattern("/KinectAlive")) {
    /* check if the typetag is the right one. */
    //if(theOscMessage.checkTypetag("s")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      //String value = theOscMessage.get(0).stringValue();
      //println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
      //println(" value: "+value);
      kinectAlertTimer = millis();
      return;
    //}  
  }
  
  else if(theOscMessage.checkAddrPattern("/SoundAlive")) {
    /* check if the typetag is the right one. */
    //if(theOscMessage.checkTypetag("s")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      //String value = theOscMessage.get(0).stringValue();
      //println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
      //println(" value: "+value);
      soundAlertTimer = millis();
      return;
    //}  
  }
  
}

void log(String log, String file){
  String [] previousLogs = loadStrings(file);
  String [] logText = {""+day()+"/"+prependZero(month())+"/"+year()+"-"+hour()+":"+prependZero(minute())+":"+prependZero(second()) +" : "+log};
  if (previousLogs != null) saveStrings(file, append(previousLogs, logText[0]));
  else saveStrings(file, logText);
}

String getLogString(String log){
  String logText = ""+day()+"/"+prependZero(month())+"/"+year()+"-"+hour()+":"+prependZero(minute())+":"+prependZero(second()) +" : "+log+"\n";
  return logText;
}

String prependZero(long number){
  if (number > 9) return ""+number;
  else return "0"+number;
}

String millisToMinHour(int millis_){
  int seconds = floor(millis_/1000);
  int minutes = floor(seconds/60);
  seconds = seconds%60;
  return prependZero((int)minutes)+":"+prependZero((int)seconds);
}
