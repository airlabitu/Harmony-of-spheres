
Triangle t;
void setup(){
  size(640, 480);
  //t = new Triangle(100, 200, 100.0, 75);
  noStroke();
//stroke(255);
  //noFill();
  background(0);
  for (float i = 255; i > 100; i--){
    t = new Triangle(100, 200);
    t.setScale(i);
    t.setRotation(75);
    t.setCenter(width/2,height/2);
    //stroke(i, 0, 0);
    fill(255-i, 0, 0);
    t.display();
  }
  
  
  
}

void draw(){
  //background(0);
  //t.setCenter(mouseX, mouseY);
  
  //t.display();
  
}
