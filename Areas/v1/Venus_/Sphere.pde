class Sphere{
  int x, y, radius;
  SoundFile track;
  float targetVol;
  float volIncrement;
  float incrementDir = 0;
  ValueFader vol;
  
  Sphere(int x_, int y_, int radius_, String filename, PApplet pa){
    x = x_;
    y = y_;
    radius = radius_;
    track = new SoundFile(pa, filename);
    vol = new ValueFader();
    vol.setMinMax(0,1);
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
    text(vol.getVal(), x, y+5);
  }
}
