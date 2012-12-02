class RoundShape extends Swing {

  FCircle s;

  String oname;
  PShape halfShape;
  PShape full;
 
  float dm;    // diameter
  float newDm;
  float scd;
  float svgw;
  float originx = 0;  // for displaying the SVG centered
  float originy = 0;

  float movex;        // movement up down
  float movey;        // movement left right
  float xpos;
  float ypos;
  
  float pauseCounter = 0;
  float pauseSpeed = 0.05;    // how to stay inactive / paused


  RoundShape(int idd, float xx, float yy, float sc, float mx, float my, String on, boolean ff, int t) {
//    println("init RoundShape("+d+")");
    super(idd, xx, yy);
    
    oname = on;
    full = loadShape(oname+"_full.svg");
    full.disableStyle();
    halfShape = loadShape(oname+"_half.svg");
    halfShape.disableStyle();
    
    movex = getX(mx);
    movey = getX(my);
    
    c = setColor(t);
    scF = sc;
    scd = full.width / getX(scF);
    dm = getX(scF);

    createObjects();
    world.add(s);
    setFake(ff);
  }
  
  void setPolyOrigin() {
    float minX = 1000;
    float minY = 1000;
    float maxX = 0;
    float maxY = 0;
    for(int i=0; i<full.getChild(0).getVertexCount(); i++ ) {
      float v1 = full.getChild(0).getVertexX(i);
      minX = min(minX,v1);
      maxX = max(maxX,v1);
      float v2 = full.getChild(0).getVertexY(i);
      minY = min(minY,v2);
      maxY = max(maxY,v2);
    }
    svgw = maxX-minX;
    originx = (minX+maxX)/2;
    originy = (minY+maxY)/2;
//    println("originx "+originx + " originy "+originy);
  }

  void createObjects() {
    setPolyOrigin();
    s = new FCircle(dm);
    
    s.setName(oname);
    s.setGroupIndex(-1);      // same group index as walls. prevents collisions btw them
    s.setPosition(x, y);
    s.setFill(red(c),green(c),blue(c));
//    s.setRotation(random(-0.2, 0.2));
    s.setGrabbable(false);
    s.setDrawable(false);
    s.setStaticBody(true);
    setSwingParameter(s);
  }

  void update() {
    xpos = x+updateValue*movex;
    ypos = y+updateValue*movey;
    try {
      s.setPosition(xpos,ypos);
    } catch (AssertionError e) {
      logData("Swing.update setPosition("+xpos+","+ypos+")");
    }

    FName = s.getName();
    char first = FName.charAt(0);
    if(first=='X' || first=='P') {
      if(first=='P') {
        if(pauseCounter==0) pauseCounter = 1.0;
      } else {
        s.setName(oname);
      }
      int newC = (int) (FName.charAt(1)-'0');
      if(newC > 0 && newC < 9) c = setColor(newC);
      hit();
    }
    if(pauseCounter>0) {
//      println(pauseCounter);
      pauseCounter-=advance(pauseSpeed);
      if(pauseCounter<=0) {
//        println("unpause");
        s.setName(oname);
        pauseCounter = 0;
      }
    }
    super.update();
  }

  
  void hit() {
    super.hit();
  }
  
  void drawSymbol() {
    
    pushMatrix();
    translate(xpos,ypos);
    rotate(s.getRotation());
    
    // draw glow
    if(doGlow) {
      noFill();
      
      float scf = 1.0;
      float dep = glowDepth*0.02;
      float depStep = 0.01* glowDepth/glowSteps;
      float alphaM = glowAlpha/float(glowSteps);
      for(int i=1; i<=glowSteps+1; i++) {
        stroke(255,alphaM*i);
        pushMatrix();
        strokeWeight(abs(10.0-i*2));
//        scale(1.0 + i*0.01);
        ellipse(0,0,newDm*1.02,newDm*1.02);
        if(oname == "magnet") ellipse(0,0,newDm*0.53,newDm*0.53);
        popMatrix();
      }
      strokeWeight(1.0);
    }
    
    // draw shape
    noStroke();
//    if(pauseCounter>0) fill(50); else fill(displayColor);
    fill(displayColor);
    scd = svgw / dm;
    rotate(-updateValue*2);
    shape(halfShape,-(originx/scd),-(originy/scd),full.width/scd,full.height/scd);
    shape(halfShape,-(originx/scd),(originy/scd),full.width/scd,-full.height/scd);
    popMatrix();
  }
}

