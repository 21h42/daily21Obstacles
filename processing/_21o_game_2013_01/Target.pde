class Target {
  
  int id;
   
  boolean active;
   
  FCircle b;          // physical body of target 
  
  float x;                // position
  float y;  
  float w;            // size
  
  
  Target(int d, float xx, float yy) {
    active = true;
    id = d;
    init(xx,yy);
  }
  
  void init(float xx, float yy) {
    x = xx;
    y = yy;
    w = getX(0.007);
    
    b = new FCircle(getX(0.005));
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
    if(first=='X') active = false;
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
