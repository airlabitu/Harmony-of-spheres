class Triangle{
  PVector center;
  PVector scale;
  float rotation;
  color c;
  
  //Triangle(int x, int y, float scale_, int rotation_){
  Triangle(int x, int y){
    center = new PVector(x, y);
    //scale = new PVector(scale_, 0);
    //rotation = rotation_;
    //scale.rotate(radians(rotation));
    
  }
  
  void setScale(float scale_){
    scale = new PVector(scale_, 0);
  }
  
  void setRotation(float rotation_){
    rotation = rotation_;
    scale.rotate(radians(rotation));
  }
   
  void setCenter(int x, int y){
    center.x = x;
    center.y = y;
  }
  
  void display(){
    
    
    scale.rotate(radians(120));
    PVector c1 = new PVector(scale.x, scale.y);
    scale.rotate(radians(120));
    PVector c2 = new PVector(scale.x, scale.y);
    scale.rotate(radians(120));
    PVector c3 = new PVector(scale.x, scale.y);
    triangle(c1.x+center.x, c1.y+center.y, c2.x+center.x, c2.y+center.y, c3.x+center.x, c3.y+center.y);
    //println(c1.x, c1.y, c2.x, c2.y, c3.x, c3.y);
    
  }
  
  
}
