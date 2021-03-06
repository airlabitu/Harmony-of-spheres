class ValueFader{
  
  float val = 0;
  float minVal = 0;
  float maxVal = 1;
  float fadeDir = 0;
  float increment;
  float targetVal;
  float lastTargetVal;
    
  void setVal(float targetVal_, float fadeTime){
    if (lastTargetVal == targetVal_) return;
    targetVal = targetVal_;
    lastTargetVal = targetVal;
    
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
