// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/o1Ob28sF0N8


// ToDo
// Lav visninger og info
  // herunder forskellige billedvisninger, blob overlay, tekstinfo
// (Lav således at man kan lave standard blob detection på farvebillede som Shifmann havde tiltænkt det)


//import processing.video.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Tracker t = new Tracker(this);

int image = 0;
boolean textInfo = true;
boolean drawBlobs = true;

void setup() {
  size(640,480);
  
}


void draw() {
  background(0);
  
  // update tracker
  // get blobs from tracker
  // draw tracking image / information (maybe)
  // do stuff with the blob list
  
  // Draw the raw image
  t.detectBlobs();
  image(t.getTrackerImage(image), 0, 0);
  //image(t.getTrackerImage(1), 640, 0);
  //image(kinect.getDepthImage(), 0, 0);
  if (drawBlobs) t.showBlobs();
  if (textInfo){
    
    fill(0);
    rect(80, 130, 460, 240);
    textSize(15);
    textAlign(LEFT);
    fill(255);
    text("Min depth : " + t.getMinDepth() + " decrease (1) / increase (2)", 100, 160);
    text("Max depth : " + t.getMaxDepth() + " decrease (3) / increase (4)", 100, 180);
    text("Threshold : " + t.getThreshold() + " decrease (5) / increase (6)", 100, 200);
    text("Dist threshold : " + t.getDistThreshold() + " decrease (7) / increase (8)", 100, 220);
  }

  
  /*
  fill(255,0,0);
  textSize(15);
  textAlign(LEFT);

  //text("TILT: " + angle, 700, 500);
  text("THRESHOLD: [" + t.getMinDepth() + ", " + t.getMaxDepth() + "]", 700, 530);
  
  
  
  //video.loadPixels();
  //image(video, 0, 0);

 




  

  textAlign(LEFT);
  fill(0, 255,0);
  //text(currentBlobs.size(), width-10, 40);
  //text(blobs.size(), width-10, 80);
  textSize(15);
  text("color threshold: " + t.getThreshold(), 700, 600);  
  text("distance threshold: " + t.getDistThreshold(), 700, 630);
  */
  
}

void keyPressed() {

  
  if (key == CODED) {
    if (keyCode == UP) {
      //angle++;
    } else if (keyCode == DOWN) {
      //angle--;
    }
    //angle = constrain(angle, 0, 30);
    //kinect.setTilt(angle);
  } 
  else if (key == '1') {
    t.decreaseMinDepth(5);//minDepth = constrain(minDepth+10, 0, maxDepth);
  } 
  else if (key == '2') {
    t.increaseMinDepth(5);// = constrain(minDepth-10, 0, maxDepth);
  } 
  else if (key == '3') {
    t.decreaseMaxDepth(5);//maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } 
  else if (key =='4') {
    t.increaseMaxDepth(5);//maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
  else if (key == '5') {
    t.decreaseThreshold(5);
  } 
  else if (key == '6') {
    t.increaseThreshold(5);
  }
  else if (key == '7') {
    t.decreaseDistThreshold(5);
  } 
  else if (key == '8') {
    t.increaseDistThreshold(5);
  }
  
  else if (key == 'i') {
    image++;
    if (image == 2) image = 0;
  }
  else if (key == 't') {
    textInfo=!textInfo;
  }
    else if (key == 'b') {
    drawBlobs=!drawBlobs;
  }
  
}




float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
