class Envelope{

  
  Env env;
  // Times and levels for the ASR envelope
  float attackTime; // 0.001
  float sustainTime; // 0.004
  float sustainLevel; // 0.3
  float releaseTime; // 0.2

  int duration;

  // This variable stores the point in time when the next note should be triggered
  int trigger; 
  
  SoundFile track;
    
  Envelope(PApplet pa, SoundFile sf_){
    attackTime = 0.1; // 0.001
    sustainTime = 0.4; // 0.004
    sustainLevel = 1.3; // 0.3
    releaseTime = 0.2; // 0.2

    duration = 500; 
    
    // Create the envelope 
    env = new Env(pa);
    
    trigger = millis();
    
    track = sf_;
  }
  
  void update(float pos){
    if ((millis() > trigger)) {
      track.cue(pos);
      env.play(track, attackTime, sustainTime, sustainLevel, releaseTime);
      trigger = millis() + duration;
    }
  }
  
  void update(){
    if ((millis() > trigger)) {
      env.play(track, attackTime, sustainTime, sustainLevel, releaseTime);
      trigger = millis() + duration;
    }
  }
  
  void setDuration(int duration_){
    duration = duration_;
  }
  
  void setAttackTime(float at){
    attackTime = at;
  }
  
  void setSustainTime(float st){
    sustainTime = st;
  } 
  
  void setSustainLevel(float sl){
    sustainLevel = sl;
  }
  
  void setRelaseTime(float rl){
    releaseTime = rl;
  }
  
  
}
