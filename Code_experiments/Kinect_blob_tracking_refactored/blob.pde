

class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;

  int id = 0;

  int lifespan;// = maxLife;

  boolean taken = false;
  
  int maxLife;
  float distThreshold;

  Blob(float x, float y, int maxLife_, float distThreshold_) {
    
    maxLife = maxLife_;
    distThreshold = distThreshold_;
    
    lifespan = maxLife;
    
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  boolean checkLife() {
    lifespan--; 
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }


  void show() {
    stroke(255,105,204);
    fill(255, lifespan);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minx, miny, maxx, maxy);

    textAlign(CENTER);
    textSize(15);
    fill(255,105,204);
    text(id, minx + (maxx-minx)*0.5, maxy - 10);
    textSize(15);
    //text(lifespan, minx + (maxx-minx)*0.5, miny - 10);
  }


  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
    lifespan = maxLife;
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }

  PVector getCenter() {
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;    
    return new PVector(x, y);
  }

  boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}