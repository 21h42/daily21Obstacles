class Poly extends Swing {

  FPoly s;                    // main object


  String oname;
  PShape full;
  PShape outline;
  PShape offset;
 
  float scd = 1.0;    // scale divider
  float originx = 0;  // for displaying the SVG centered
  float originy = 0;
  float stretch = 1.0;  // amplify some input values
  
  int actionRot = 1;
  int actionMove = 0;
  float movex;        // movement up down
  float movey;        // movement left right
  float xpos;
  float ypos;
  

  Poly(int d, float xx, float yy, float sc, String on, boolean ff, int t, float mx, float my) {
    super(d, xx, yy);
    movex = getX(mx);
    movey = getX(my);
    actionMove = 1;
    actionRot = 0;
    init(sc,on,ff,t);
  }
  
  Poly(int d, float xx, float yy, float sc, String on, boolean ff, int t) {
    super(d, xx, yy);
    init(sc,on,ff,t);
  }
  
  void init(float sc, String on, boolean ff, int t) {
////    println("init Poly("+d+")");
    oname = on;
    outline = loadShape(oname+"_outline.svg");
    outline.disableStyle();
    offset = loadShape(oname+"_offset.svg");
    offset.disableStyle();
    full = loadShape(oname+"_full.svg");
    full.disableStyle();
    
    xpos = x+updateValue*movex;
    ypos = y+updateValue*movey;
    
    stretch = (oname == "trap1") ? 1.5 : 1.0;
    c = setColor(t);
    scF = sc;
    scd = full.width / getX(scF);
    if(oname == "square") fadeSpeed = 0.01;

    createObjects();
    world.add(s);
    setFake(ff);
  }
  
  void setPolyOrigin() {
    float minX = 1000;
    float minY = 1000;
    float maxX = 0;
    float maxY = 0;
    for(int i=0; i<outline.getChild(0).getVertexCount(); i++ ) {
      float v1 = outline.getChild(0).getVertexX(i);
      minX = min(minX,v1);
      maxX = max(maxX,v1);
      float v2 = outline.getChild(0).getVertexY(i);
      minY = min(minY,v2);
      maxY = max(maxY,v2);
    }
    originx = (minX+maxX)/2;
    originy = (minY+maxY)/2;
    if(oname == "flipperhalf") originx = originx/2;
//    originy = 0;
//    println("originx "+originx + " originy "+originy);
  }

  void createObjects() {
    setPolyOrigin();
    s = new FPoly();
    
    for(int i=0; i<outline.getChild(0).getVertexCount()-1; i++ ) {
      float v1 = outline.getChild(0).getVertexX(i) - originx;
      float v2 = outline.getChild(0).getVertexY(i) - originy;
      s.vertex(v1/scd,v2/scd);
    }

    s.setName("poly");
    s.setGroupIndex(-1);      // same group index as walls. prevents collisions btw them
    s.setPosition(xpos,ypos);
    s.setFill(red(c),green(c),blue(c));
//    s.setRotation(random(-0.2, 0.2));
    s.setGrabbable(false);
    s.setDrawable(false);
    s.setStaticBody(true);
    setSwingParameter(s);
    if(oname=="cross") s.setRestitution(0.95);
  }

  void update() {
    try {
      if(actionRot==1) s.setRotation(updateValue*stretch);
    } catch (AssertionError e) {
      logData("Swing.update setRotation()");
    }
    if(actionMove==1) {
      xpos = x+updateValue*movex;
      ypos = y+updateValue*movey;
      try {
        s.setPosition(xpos,ypos);
      } catch (AssertionError e) {
        logData("Swing.update setPosition("+xpos+","+ypos+")");
      }
    }
    
    FName = s.getName();
    char first = FName.charAt(0);
    if(first=='X' || first=='P') {
      int newC = (int) (FName.charAt(1)-'0');
      if(newC > 0 && newC < 9 && oname!="square") c = setColor(newC);
      hit();
      s.setName("poly");
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
      noStroke();
      float scf = 1.0;
      float dep = glowDepth*0.02;
      float depStep = 0.01* glowDepth/glowSteps;
      float alphaM = glowAlpha/float(glowSteps);
      for(int i=1; i<=glowSteps+1; i++) {
        fill(255,alphaM*i);
        pushMatrix();
        scale(1 + dep - i*depStep);
        shape(offset,-(originx/scd),-(originy/scd),offset.width/scd,offset.height/scd);
        popMatrix();
      }
    }
    // draw shape
    noStroke();
    fill(displayColor);
    if(oname == "square" && fadeCounter>0.5) scale(1.0 + 2.5);
    else if(oname == "square" && fadeCounter>0) scale(1.0 + fadeCounter*5);
    shape(full,-(originx/scd),-(originy/scd),full.width/scd,full.height/scd);
    popMatrix();
  }
}

