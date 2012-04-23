

class Swing {
  
  int no;
  float x;
  float y;
  int len = 50;
  int w = 10;
  
  // data
  int amp;
  int active;
  int sync;
  int cont;
  
  boolean high;
  
  Swing(int n) {
    no = n;
    init();
  }
  
  void setXY(int xx, int yy) {
    x = xx;
    y = yy;
  }
  
  void init() {
    amp = 0;
    active = 0;
    sync = 0;
    cont = 0;
    high = false;
  }
  
  void draw() {
    pushMatrix();
    translate(x,y);
    if(high) {
      high = false;
      fill(255,255,0);
    } else if (active==1) {
      fill(0);
    } else {
      fill(100);
    }
    
    noStroke();
    float rad = ((amp) / 180.0) * PI;
    rotate(rad);
//    line(-siz,0,siz,0);
    rect(0,0,len,w);
    popMatrix();
  }
  
  void hit(String p) {
//    println(no + ": "+p);
    high = true;
  }
  
}
