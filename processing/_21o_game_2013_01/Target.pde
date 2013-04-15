void addTargets() {
  for(int i=0; i<200; i++) {
    // directly on top of swing: getX(0.075 + 0.047*i)
    Target t = new Target(targetcount++, getX(0.0985 + 0.047*i), getY(0.43);
    targets.add(t);
  }
}



class Target {
  
  int id;
   
  boolean active;
   
  FCircle b;          // physical body of target 
  
  float x;                // position
  float ox;              // original x position (changed by target-sine-movement)
  float y;  
  float w;            // size
  
  
  Target(int d, float xx, float yy) {
    active = true;
    id = d;
    init(xx,yy);
  }
  
  void init(float xx, float yy) {
    ox = x = xx;
    y = yy;
    w = getX(0.007);
    
    b = new FCircle(getX(0.01));
    b.setName("target");
    b.setStaticBody(true);
    b.setSensor(true);        // not a physical body, just sensor (> contacts)
//    b.setImageAlpha(lane/10.0);
    b.setPosition(x, y);
    b.setDrawable(false);  // draw with drawSymbol() instead
    b.setGroupIndex(-1);      // same group index as walls/swings, prevents collision btw them

    world.add(b);    
  }
  
  void update() {
    String FName = b.getName();
    char first = FName.charAt(0);
    if(first=='X') {
      active = false;
    }
    try {
      x = ox + targetMoveX;
      b.setPosition(x,y);
    } catch (AssertionError e) {
      logData("Target.update setPosition()");
    }
  }
  
  boolean dead() {
    return !active;
  }
  
  void kill() {
    world.remove(b);
  }
  
  void render() {
    
    gl.glColor3f(1.0, 1.0, 0.1);
    gl.glPushMatrix();
    gl.glBegin(GL.GL_TRIANGLE_FAN);
    gl.glVertex3f(x, y, 0);
    gl.glVertex3f(x-w, y, 0);
    gl.glVertex3f(x, y-w, 0);
    gl.glVertex3f(x+w, y, 0);
    gl.glVertex3f(x, y+w, 0);
    gl.glVertex3f(x-w, y, 0);
    gl.glEnd();
    gl.glPopMatrix();
  }
  
}
