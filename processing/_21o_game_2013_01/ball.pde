

class Ball {

  int id;

  float lifetimer;
  float aging = 1.0 / (60.0 * 60);  // lives 60 seconds
  boolean shrink = true;      // shrink diameter based on age

  FCircle b;          // physical body of ball

  float d;            // actual diameter (scaled to overall scale with getX())
  float dm = 0.02;   // set diameter
  float odm = 0.02;  // original diamter (before aging)
  float scd = 2.0;    // scale divider
  float trace_d;
  float trace_dm = 0.003;
  
  int lane = 1;       // which lane it was launched at, effects color

  float originx = 0;  // for displaying the SVG centered
  float originy = 0;
  float xpos;
  float ypos;
  
  
  ArrayList history;      // position history
//  float[] historyXY;      // history in array form
//  int historyPointer = 0;
  float historyCounter = 0;  // counter, save new position when hit max
//  int historyCounts = 0;
  int historyCounterMax = 5;  // save new history position every x 
  boolean historyEqual = true;
  float equalStep = getX(0.01);

  color c;
  float color_r = 0;
  float color_g = 0;
  float color_b = 0;
  boolean blink = false;

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
    color_r = red(c)/255.0f;
    color_g = green(c)/255.0f;
    color_b = blue(c)/255.0f;
    
    b = new FCircle(d);
    b.setName("ball");
    b.setNoStroke();
    b.setFill(red(c),green(c),blue(c));
    b.setImageAlpha(lane/10.0);
    b.setPosition(x, y);
    b.setVelocity(random(-30.0, 30.0), 200);
    b.setRestitution(0.99);
    b.setDamping(0);
    b.setDensity(0.5);
    b.setDrawable(false);  // draw with drawSymbol() instead

    // add ball to physics world
    world.add(b);    
    
    history = new ArrayList();
//    historyXY = new float[historyMax*2];
//    for(int i=0; i<historyMax*2; i++) historyXY[i] = 0;
//    historyPointer = 0;
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
    
//    if(traceBall) {      // trace history even if not displayed
    Vector2D v = new Vector2D(xpos, ypos);
    if(historyEqual) {
      if(history.size() < 1) {
        history.add(v);    // add position, if first time!
      } else {
        // get last position in history
        Vector2D last = (Vector2D) history.get(history.size()-1);
        float distance = sqrt( sq(v._x-last._x) + sq(v._y-last._y) );
        if(distance > equalStep) history.add(v);
      }
    } else {
      historyCounter += advance(1.0);
      if(historyCounter >= historyCounterMax) {
        historyCounter = 0;
        // save current position to history
        history.add(v);
      }
    }
    while(history.size() > traceBallMax) {
       history.remove(0);
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
    } else if(FName.equals("T-ball")) {
      b.setName("ball");    // return name to standard name
      blink = true;
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
  
  void renderHistory() {
//    gl.glColor3f(color_r,color_g,color_b);
//    int maxi = (historyCounts < 12) ? historyCounts : 12;
//    for(int i=0; i<maxi; i++) {  // historyCounts
//       glEllipse(historyXY[i*2], historyXY[i*2 + 1], trace_d, trace_d);
//    }
    for(int i=0; i<history.size(); i++) {
       Vector2D v = (Vector2D) history.get(i);
       float history_alpha = (float) i / history.size();
       history_alpha = history_alpha < 0.2 ? history_alpha*5 : 1.0;  // only fade last 20%
       gl.glColor4f(color_r,color_g,color_b, history_alpha);
       glEllipse(v._x, v._y, trace_d, trace_d);
    }
  }
  // opengl drawing
  void render() {
    // red(c)*255,(int) green(c),(int) blue(c)
    if(blink) {
      blink = false;
      // add some action
    }
    gl.glColor3f(color_r,color_g,color_b);
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

