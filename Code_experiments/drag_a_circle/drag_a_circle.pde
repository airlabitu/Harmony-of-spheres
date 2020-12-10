
int pressX, pressY;
int releaseX, releaseY;
int dragState = 0;

void setup(){
  size(400, 400);
  noFill();
}

void draw() {

  background(0);
  creatingCircle();
}

void creatingCircle(){
    if (dragState == 0){
    stroke(255,0,0);
    circle(pressX, pressY, 10);
  }
  if (dragState == 1){
    stroke(255,0,0);
    circle(pressX, pressY, 10);
    stroke(0,255,0);
    circle(pressX, pressY, dist(pressX, pressY, releaseX, releaseY)*2);
  }
  /*
  if (dragState == 2){
    stroke(0,0,255);
    circle(pressX, pressY, dist(pressX, pressY, releaseX, releaseY)*2);    
  }
  */
}

void mousePressed(){
    pressX = mouseX;
    pressY = mouseY;
    println("PRESSED");
    dragState = 0;
  
}

void mouseDragged(){
  releaseX = mouseX;
  releaseY = mouseY;

  //println("dragged");
  dragState = 1;
}

void mouseReleased(){
    dragState = 2;
    println("RELEASED");
    println("CIRCLE CREATED");
}
