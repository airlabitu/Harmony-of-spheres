// This code is made by Halfdan Hauch Jensen at AIR LAB ITU, halj@itu.dk / https://airlab.itu.dk
// The code is an example of how to fade between two values over time. 
// It was first made for volume control with the Sound library that seems to be missing this feature.

ValueFader vf;

float tg;
float ft;

void setup(){
  size(600, 200);
  frameRate(25);
  
  vf = new ValueFader();
  vf.setMinMax(-200, 200);
  //vf.reverse(true);
  
}

void draw(){
  background(0);
  
  tg = map(mouseX, 0, width, vf.getMin(), vf.getMax());
  ft = map(mouseY, 0, height, 0, 10000);
  text("Val: "+ nf(vf.getVal(), 0, 3), 10, 15);
  text("Target val: "+ nf(tg, 0, 3), 10, 40);
  text("Fade time: "+ round(ft), 10, 55);
  
  vf.update(); // updates the value fader every frame
}

void mouseReleased(){
  vf.setVal(tg, ft);
  
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
    
  void setVal(float targetVal_, float fadeTime){
    
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
  
  float getVal(){
    return val;
  }
  
  float getMin(){
    return minVal;
  }
  
  float getMax(){
    return maxVal;
  }
  
  void reverse(boolean r_){
    reverse = r_;
    setVal(getVal(), 1);
  }

  void setMinMax(float minVal_, float maxVal_){
    minVal = minVal_;
    maxVal = maxVal_;
    val = constrain(val, minVal, maxVal);
  }
  
  // needs to be called every frame
  void update(){
    val = constrain(val+increment*fadeDir, minVal, maxVal);
    if (fadeDir < 0) val = max(val, targetVal);
    else if (fadeDir > 0) val = min(val, targetVal);
  }
}
