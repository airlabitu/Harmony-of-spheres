class Area{
  int x, y, radius;
  
  Area(int x_, int y_, int radius_){
    x = x_;
    y = y_;
    radius = radius_;
  }
  
  void show(){
    noFill();
    stroke(255, 0, 0);
    circle(x, y, radius*2);
  }
}
