class Sphere{
  int x, y, radius;
  SoundFile track;
  float targetVol;
  float volIncrement;
  float incrementDir = 0;
  ValueFader vol;
  int group;
  int id;
  
  Sphere(int x_, int y_, int radius_, String filename, PApplet pa, int id_, int group_){
    x = x_;
    y = y_;
    radius = radius_;
    track = new SoundFile(pa, filename);
    vol = new ValueFader();
    vol.setMinMax(0,1);
    id = id_;
    group = group_;
  }
  
  void update(){
    vol.update();
    track.amp(vol.getVal());
  }
  
  void show(){
    noFill();
    if (vol.getVal() > vol.getMin()) fill(255, map(vol.getVal(), vol.getMin(), vol.getMax(), 0, 150));
    stroke(255);
    ellipse(x, y, radius*2, radius*2);
    fill(0,255,0);
    text("Vol: " + vol.getVal(), x, y-20);
    text("ID: " + id, x, y);    
    text("Group: " + group, x, y+20); 
  }
  
  int getGroup(){
    return group;
  }
  
  int getId(){
    return id;
  }
}
