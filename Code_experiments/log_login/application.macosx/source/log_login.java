import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class log_login extends PApplet {
  public void setup() {
String [] previousLogs = loadStrings("log.txt");
String [] logText = {"login at: " + day()+"/"+month()+"/"+year()+":"+hour()+":"+minute()+":"+second()};
if (previousLogs != null) saveStrings("log.txt", append(previousLogs, logText[0]));
else saveStrings("log.txt", logText);
exit();
    noLoop();
  }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "log_login" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
