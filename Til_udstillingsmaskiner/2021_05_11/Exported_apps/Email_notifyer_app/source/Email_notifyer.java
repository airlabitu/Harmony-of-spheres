import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import javax.mail.*; 
import javax.mail.internet.*; 
import java.util.*; 
import javax.mail.Authenticator; 
import javax.mail.PasswordAuthentication; 

import javax.activation.*; 
import com.sun.activation.registries.*; 
import com.sun.activation.viewers.*; 
import javax.mail.*; 
import javax.mail.event.*; 
import javax.mail.search.*; 
import javax.mail.internet.*; 
import com.sun.mail.util.*; 
import com.sun.mail.handlers.*; 
import com.sun.mail.pop3.*; 
import com.sun.mail.iap.*; 
import com.sun.mail.imap.*; 
import com.sun.mail.imap.protocol.*; 
import com.sun.mail.smtp.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Email_notifyer extends PApplet {

// Daniel Shiffman example modified by: AIR LAB ITU, Halfdan Hauch Jensen
//
// http://www.shiffman.net
// https://www.airlab.itu.dk




OscP5 oscP5;
NetAddress myRemoteLocation;





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


public void setup() {
  
  
  frameRate(1);
  oscP5 = new OscP5(this,11011);
  stroke(255);
  fill(255);
  
}

public void draw(){
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


public void oscEvent(OscMessage theOscMessage) {
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

public void log(String log, String file){
  String [] previousLogs = loadStrings(file);
  String [] logText = {""+day()+"/"+prependZero(month())+"/"+year()+"-"+hour()+":"+prependZero(minute())+":"+prependZero(second()) +" : "+log};
  if (previousLogs != null) saveStrings(file, append(previousLogs, logText[0]));
  else saveStrings(file, logText);
}

public String getLogString(String log){
  String logText = ""+day()+"/"+prependZero(month())+"/"+year()+"-"+hour()+":"+prependZero(minute())+":"+prependZero(second()) +" : "+log+"\n";
  return logText;
}

public String prependZero(long number){
  if (number > 9) return ""+number;
  else return "0"+number;
}

public String millisToMinHour(int millis_){
  int seconds = floor(millis_/1000);
  int minutes = floor(seconds/60);
  seconds = seconds%60;
  return prependZero((int)minutes)+":"+prependZero((int)seconds);
}
// Simple Authenticator          
  
  // Careful, this is terribly unsecure!!




public class Auth extends Authenticator {

  public Auth() {
    super();
  }
  
  // Email account to use for authentication
  public PasswordAuthentication getPasswordAuthentication() {
    String username, password;
    username = "air-noreply@itu.dk";
    password = "cfh#xXqU";
    System.out.println("authenticating. . ");
    return new PasswordAuthentication(username, password);
  }
}
// Example functions that send mail (smtp)


// A function to send mail

public void sendMail(String subject, String body) {
  // Create a session
  String host = "smtp.office365.com"; // set smtp server to use  ---  e.g. "smtp.office365.com"
  Properties props=new Properties();

  // SMTP Session
  props.put("mail.transport.protocol", "smtp");
  props.put("mail.smtp.host", host);
  props.put("mail.smtp.port", "587"); // set smtp port to use  ---  e.g. "587" for office365 
  props.put("mail.smtp.auth", "true");
  props.put("mail.smtp.starttls.enable","true"); // We need TTLS, which gmail / office365 mails requires

  // Create a session
  Session session = Session.getDefaultInstance(props, new Auth());

  try
  {
    
    MimeMessage message = new MimeMessage(session); // Make a new message

    message.setFrom(new InternetAddress("air-noreply@itu.dk", "HoS Email Notifyer")); // From

    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse("halj@itu.dk", false)); // To
    
    InternetAddress ia [] = {new InternetAddress("air-noreply@itu.dk", "HoS Email Notifyer")};
    message.setReplyTo(ia); // Reply to

    message.setSubject(subject); // Subject text
    message.setText(body); // Body text

    Transport.send(message); // Send the message
    println("Mail sent!");
  }
  catch(Exception e) // Exception handling
  {
    e.printStackTrace();
  }

}
  public void settings() {  size(400, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Email_notifyer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
