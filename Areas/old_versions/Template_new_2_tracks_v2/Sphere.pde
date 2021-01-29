class Sphere{
  int x, y, radius, xMove, yMove;
  SoundFile trackA;
  SoundFile trackB;
  float targetVol;
  float volIncrement;
  float incrementDir = 0;
  ValueFader vol;
  ValueFader delayVal;
  int group;
  int id;
  Delay delay;
  boolean delayEnabled;
  Envelope envelope;
  //ValueFader envelopeDuration; // ###envDev
  boolean envelopeEnabled;
  boolean rateEnabled;
  ValueFader rate;
  
  Sphere(int x_, int y_, int radius_, String track_A_Filename, PApplet pa_, int id_, int group_){
    x = x_;
    y = y_;
    radius = radius_;
    trackA = new SoundFile(pa_, track_A_Filename);
    vol = new ValueFader();
    vol.setMinMax(0.00001,1);
    delayVal = new ValueFader();
    delayVal.setMinMax(0.3, 0.8); 
    //envelopeDuration = new ValueFader(); // ###envDev
    //envelopeDuration.setMinMax(100, 1500); ###envDev
    rate = new ValueFader();
    rate.setMinMax(0.6, 1.0);
    id = id_;
    group = group_;
  }
  
  Sphere(int x_, int y_, int radius_, String trackA_Filename_, String trackB_Filename_, PApplet pa_, int id_, int group_){
    x = x_;
    y = y_;
    radius = radius_;
    trackA = new SoundFile(pa_, trackA_Filename_);
    trackB = new SoundFile(pa_, trackB_Filename_);
    vol = new ValueFader();
    vol.setMinMax(0.00001, 1);
    delayVal = new ValueFader();
    delayVal.setMinMax(0.3, 0.8); 
    //envelopeDuration = new ValueFader(); // ###envDev
    //envelopeDuration.setMinMax(100, 1500); ###envDev
    rate = new ValueFader();
    rate.setMinMax(0.6, 1.0);
    id = id_;
    group = group_;
  }
  
  void enableDelay(PApplet pa_, float tape_){
    delay = new Delay(pa_);
    delay.process(trackA, tape_);
    delayEnabled = true;
  }
  
  void enableEnvelope(PApplet pa_){
    envelope = new Envelope(pa_, trackA);
    envelopeEnabled = true;
  }
  
  void enableRate(){
    rateEnabled = true;
  }
  
  void update(){
    vol.update();
    trackA.amp(vol.getVal());
    if (delayEnabled) { // ### delay
      delayVal.update();
      delay.feedback(delayVal.getVal());
    }
    /* ###envDev
    if (envelopeEnabled){
      envelopeDuration.update();
      envelope.setDuration((int)envelopeDuration.getVal());
    }
    */
    if (rateEnabled) {
      rate.update();
      trackA.rate(rate.getVal());
    }
  }
  
  void show(){
    noFill();
    if (vol.getVal() > vol.getMin()) fill(255, map(vol.getVal(), vol.getMin(), vol.getMax(), 0, 150));
    stroke(255);
    ellipse(x, y, radius*2, radius*2);
    fill(0,255,0);
    if (rateEnabled) text("Rate: " + nf(rate.getVal(), 0, 2), x+xMove, y-30+yMove);
    if (envelopeEnabled) text("Env: " + nf(envelope.duration, 0, 2), x+xMove, y-15+yMove);
    //if (envelopeEnabled) text("Env: " + nf(envelope.getVal(), 0, 2), x, y-60);
    if (delayEnabled) text("Delay: " + nf(delayVal.getVal(), 0, 2), x+xMove, y+yMove);
    text("Vol: " + nf(vol.getVal(), 0, 2), x+xMove, y+15+yMove);
    text("ID: " + id, x+xMove, y+30+yMove);    
    text("Group: " + group, x+xMove, y+45+yMove); 
    text("MinMax: " + nf(vol.getMin(), 0, 3)+" "+nf(vol.getMax(),0, 3), x+xMove, y+60+yMove);  // ### test
  
  }
  
  int getGroup(){
    return group;
  }
  
  int getId(){
    return id;
  }
}
