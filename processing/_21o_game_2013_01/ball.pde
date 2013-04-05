

class Ball {

  int id;
  boolean active;
  
  float lifetimer;
  float aging = 0.0002;
  boolean shrink = true;      // shrink diameter based on age

  FCircle b;          // physics library body

  float d;            // actual diameter (scaled to overall scale with getX())
  float dm = 0.008;   // set diameter
  float odm = 0.008;  // original diamter (before aging)
  float scd = 2.0;    // scale divider

//  boolean superHero = false;
//  int superCounter = 0;
//  int superMax = 3;
  
  int lane = 1;       // effects color
//  PShape original;
  float originx = 0;  // for displaying the SVG centered
  float originy = 0;
  float xpos;
  float ypos;
  
  
  
  color c;

  Ball(int ii, float x, float y, int no) {
    lane = no;
    id = ii;
    init(x,y);
  }
  
  Ball(int ii, float x, float y) {
    id = ii;
    lane = 1;
    init(x,y);
  }
  
  void setOriginalDiameter(float dd) {
    odm = dd;
    setDiameter(odm);
  }
  
  void setDiameter(float dd) {
    dm = dd;
    d = getX(dm);
    b.setSize(d);
  }
  
  void init(float x, float y) {
    d = getX(dm);
    lifetimer = 1.0;
    c = setColor(lane);

    b = new FCircle(d);
    b.setName("ball");
    b.setNoStroke();
    b.setFill(red(c),green(c),blue(c));
    b.setImageAlpha(lane/10.0);
    b.setPosition(x, y);
    b.setVelocity(random(-30.0, 30.0), 200);
    b.setRestitution(0.9);
    b.setDamping(0);
    b.setDensity(0.5);
    b.setDrawable(true);

    world.add(b);
  }
  
  void launch(int lane) {
//    println("launch ball into lane "+lane);
//    float launchx = (lane <5) ? 0 : 1;
//    float launchy = 0.31 + (lane-1)%4 * 0.132 + random(-0.03, 0.03);
//    b.setPosition(getX(launchx),getY(launchy));
//    if(lane <5) b.setVelocity(200,-100);
//    else b.setVelocity(-200,-100);
  }

  void update() {
    lifetimer-= advance(aging);
    
    // shrink ball while aging
    if(shrink) {
      // change diameter only 20*times during lifetime
      int age = (int) (lifetimer*1000);  // conversion to have clean number
      if( age%50 == 0 ) {
        // minimum diamter = 20% of original diameter
        float ndm = odm*0.2 + 0.8*odm* age / 1000.0;
        if(ndm < dm) {
//          println("lifetime "+age+"  shrink to "+ndm);
          setDiameter(ndm);
        }
      }
    }
    
    xpos = b.getX();
    ypos = b.getY();
    String FName = b.getName();
    if(FName.equals("clone")) {
      
      b.setName("ball");
      // clone itself 3 times
      if(balls.size() < maxcount) {
        if(printMore) println("clone ball!!!   "+balls.size());
        for(int i= 0; i<2; i++) {
          Ball nb = new Ball(ballcount++,(int) xpos,(int) ypos, lane);
          nb.b.setVelocity(b.getVelocityX(),b.getVelocityY());
          nb.setOriginalDiameter(dm);
          balls.add(nb);
        }
      }
    }
  }
  
  void drawSymbol() {
    fill(c);
    noStroke();
    ellipse(xpos,ypos,d,d);
//    pushMatrix();
//    translate(xpos,ypos);
//    rotate(b.getRotation());
//    shape(original,-(originx/scd),-(originy/scd),original.width/scd,original.height/scd);
//    popMatrix();
  }
  
  void kill() {
    world.remove(b);
  }
  
  boolean dead() {
    if (lifetimer <= 0.0) {
      world.remove(b);
      return true;
    } else {
      return false;
    }
  }
}

