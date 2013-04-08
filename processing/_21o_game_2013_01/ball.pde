

class Ball {

  int id;

  float lifetimer;
  float aging = 0.0002;
  boolean shrink = true;      // shrink diameter based on age

  FCircle b;          // physical body of ball

  float d;            // actual diameter (scaled to overall scale with getX())
  float dm = 0.008;   // set diameter
  float odm = 0.008;  // original diamter (before aging)
  float scd = 2.0;    // scale divider
  float trace_d;
  float trace_dm = 0.002;
  
  int lane = 1;       // which lane it was launched at, effects color

  float originx = 0;  // for displaying the SVG centered
  float originy = 0;
  float xpos;
  float ypos;
  
  
  ArrayList history;      // position history
  float[] historyXY;      // history in array (arraylist remove slowed fps down)
  int historyPointer = 0;
  int historyMax = 200;   // maximum trail to save
  float historyCounter = 0;  // counter, save new position when hit max
  int historyCounterMax = 5;

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
  
  // set original diameter, independent of aging diameter
  void setOriginalDiameter(float dd) {
    odm = dd;
    setDiameter(odm);
  }
  
  // set diameter of ball
  void setDiameter(float dd) {
    dm = dd;
    d = getX(dm);
    b.setSize(d);
  }
  
  void init(float x, float y) {
    d = getX(dm);
    trace_d = getX(trace_dm);
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
    b.setDrawable(false);  // draw with drawSymbol() instead

    // add ball to physics world
    world.add(b);    
    
    history = new ArrayList();
    historyXY = new float[historyMax*2];
    historyPointer = 0;
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
        if(ndm < dm) setDiameter(ndm);
      }
    }
    
    // get x/y position from physics body
    xpos = b.getX();
    ypos = b.getY();
    
    if(traceBall) {
      historyCounter += advance(1.0);
      if(historyCounter >= historyCounterMax) {
        historyCounter = 0;
        
        // save current position to history
//        Vector2D v = new Vector2D(xpos, ypos);
//        history.add(v);
//        if(history.size() > historyMax) {
//          history.remove(0);
//        }
        historyXY[historyPointer] = xpos;
        historyXY[historyPointer+1] = ypos;
        historyPointer+=2;
        if(historyPointer >= historyMax) historyPointer = 0;
      }
    }
    
    String FName = b.getName();
    if(FName.equals("clone")) {
      
      b.setName("ball");    // return name to standard name
      
      // clone itself 2 times
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
//    if(traceBall) {
//      for(int i=0; i<history.size(); i++) {
//        Vector2D v = (Vector2D) history.get(i);
//        ellipse(v._x, v._y, trace_d, trace_d);
//      }
//    }
    ellipse(xpos,ypos,d,d);
  }
  
  // opengl drawing
  void render() {
    // red(c)*255,(int) green(c),(int) blue(c)
    gl.glColor3f(red(c)/255.0,green(c)/255.0,blue(c)/255.0);
    if(traceBall) {
//      for(int i=0; i<history.size(); i++) {
//        Vector2D v = (Vector2D) history.get(i);
//        glEllipse(v._x, v._y, trace_d, trace_d);
//      }
      for(int i=0; i<historyMax; i++) {
        glEllipse(historyXY[i*2], historyXY[i*2 + 1], trace_d, trace_d);
      }
    }
    glEllipse(xpos,ypos,d,d);
  }
  
  void glEllipse(float x, float y, float w, float h) {
    gl.glPushMatrix();
    gl.glTranslatef(x,y,0);
    gl.glScalef(w/2.0,h/2.0,1);  
    gl.glCallList(circleListID);
    gl.glPopMatrix();
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


class Vector2D {
  float _x;
  float _y;
  
  Vector2D(float x, float y) {
    _x = x;
    _y = y;
  }
}

