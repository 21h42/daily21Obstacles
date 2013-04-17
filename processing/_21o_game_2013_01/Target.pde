void addTargets() {
<<<<<<< HEAD
  for(int i=0; i<200; i++) {
    // directly on top of swing: getX(0.075 + 0.047*i)
    Target t = new Target(targetcount++, getX(0.0985 + 0.047*i), getY(0.43);
    targets.add(t);
=======
  int count = 0;
  
  for(int j=0; j<targets.length; j++) {
    
    //  clear out targets first
    if(targets[j].size() > 0) {
      for(int t = targets[j].size()-1; t>=0; t--) {
        Target t0 = (Target) targets[j].get(t);
        t0.kill();
        targets[j].remove(t);
      }
      targets[j].clear();
    }

    if(level == 0) {
      
      float x = 0.03;
      if(j%2 != 0) x+= 0.0095;
      while(x < 0.97) {
        Target t = new Target(targetcount++, getX(x), getY(heightFloor[j+1]+0.07), "target_level_1.png");
        if(x < 0.7 || x > 0.72) targets[j].add(t);
        x += 0.019;
      }
      
    } else if(level == 1) {
      
      float x = 0.03 + random(0.2);
      while(x < 0.97) {
        Target t = new Target(targetcount++, getX(x), getY(heightFloor[j+1]+0.03+random(0.07)), "target_level_2.png");
        t.rot = random(PI*2);
        if(x < 0.7 || x > 0.72) targets[j].add(t);
        x += 0.03 + random(0.2);
      }
      
    } else if(level == 2) {
      
      float x = 0.1;
      if(j%2 != 0) x+= 0.06;
      while(x < 0.97) {
        Target t = new Target(targetcount++, getX(x), getY(heightFloor[j+1]+0.07), "target_level_3.png");
        if(x < 0.7 || x > 0.72) targets[j].add(t);
        x += 0.2;
      }
      
    } else if(level == 3) {
      
      float x = 0.04;
      if(j%2 == 0) x+= 0.04;
      while(x < 0.97) {
        Target t = new Target(targetcount++, getX(x), getY(heightFloor[j+1]+0.07), "target_level_4.png");
        if(x < 0.7 || x > 0.72) targets[j].add(t);
        x += 0.08;
      }
      
    }
    count += targets[j].size();
>>>>>>> upstream/master
  }
  
  println("addTarget count \t"+count);
  
}



class Target {
  
  int id;
   
  boolean active;
   
  FCircle b;          // physical body of target 
  
  float x;                // position
  float ox;              // original x position (changed by target-sine-movement)
  float y;  
  float w;            // size
  
  PImage item;
  float rot = 0;      // rotation
  
  
  Target(int d, float xx, float yy, String filename) {
    active = true;
    id = d;
    loadFile(filename);
    init(xx,yy);
  }
  
  void loadFile(String filename) {
    item = loadImage(filename);
    w = item.height*0.0002;
  }
  
  void init(float xx, float yy) {
    ox = x = xx;
    y = yy;
    
    
    
    b = new FCircle(getX(w));
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
  
  void render(float scaleV, float _alpha) {
    if(_alpha>0) {
      pushMatrix();
      translate(x,y);
      rotate(rot);
      tint(255,_alpha*255);
      image(item,-item.width*scaleV/2.0,-item.height*scaleV/2.0,item.width*scaleV,item.height*scaleV);
      popMatrix();
    }
  }
  
  void renderOpenGL() {
    
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
