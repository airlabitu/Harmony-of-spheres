
class OscAlertProsponer{
  boolean isActive;
  long timer;
  int interval;
  String addressPattern;
  String messageString;

  OscP5 osc;
  NetAddress remoteLocation;
  
  OscAlertProsponer(OscP5 osc_, NetAddress netAddress_, String addressPattern_){
    remoteLocation = netAddress_;
    interval = 5000; // default updating frequincy
    messageString = "default message"; // default message
    addressPattern = addressPattern_;
    osc = osc_;
  }
  
  void update(){
    if (millis() > timer + interval){
      timer = millis();
      prosponeAlert(); 
    }
  }
  
  void prosponeAlert(){
    if (isActive){
      OscMessage myMessage = new OscMessage(addressPattern);
      println("Message:", myMessage.addrPattern(), messageString);
      myMessage.add(messageString);
      osc.send(myMessage, remoteLocation);
    }
    else println("Alert not active", addressPattern, messageString);
  }
  
}
