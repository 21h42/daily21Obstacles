

color setColor(int t) {
  switch(t) {
    case 1:  return color(255,255,0);    // yellow
    case 2:  return color(97,255,247);   // cyan
    case 3:  return color(50,255,50);    // green
    case 4:  return color(255,0,255);    // pink
    
    case 5:  return color(245,85,95);    // lachs
    case 6:  return color(255,100,50);   // orange
    case 7:  return color(255,0,0);      // red
    case 8:  return color(120,85,240);   // pale violet
    case 9:  return color(255,0,0);
    case 11: return color(255);
    default: return color(random(255),random(255),random(255));
  }
}



class Swing {
  
  int id;
  
  boolean active;     // active or not. depending on swing. difference in display?
  boolean sync = false;
  boolean fake;       // faked swing motion
  String FName;      // object name
  
  float updateValue = 0;
  
  int highpoint = 0;  // highpoint event

  float x;                // position
  float y;  
  float scF;            // scale factor
  
  // fake behavior
  float fakeSine = 0;      // motorized Swing, angle
  float fakeAmp = 0.6;     // motorized Swing, amplitude
  float fakeVal = 0;
  float fakeSpeed = 2.0/60.f;    // speed to be divided by frameRate
  
  // glow
  int glowSteps = 5;
  int glowDepth = 20;
  int glowAlpha = 40;
  
  color c;
  color oc;
  color white;
  color displayColor;
  float fadeCounter;
  float fadeSpeed = 0.03;
  
  Swing(int d, float xx, float yy) {
    id = d;
    x = xx;
    y = yy;
    fakeSine = random(0,2*PI);
    fakeAmp = random(0.05,1.3);
    white = color(255);
    oc = setColor(1);
    displayColor = white;
    fadeCounter = 0;
  }
  
  void update() {
    if (highpoint>0) {
      highpoint++;
      if (highpoint>2) {
        highpoint = 0;
      }
    }
    if(fadeCounter > 0) {
      fadeCounter -= advance(fadeSpeed);
      if(fadeCounter<0) fadeCounter = 0;
      displayColor = lerpColor(c,white, 1.0-fadeCounter);
    }
    if(fake && doFake) fakeStep();
  }

  // standard swing parameter
  void setSwingParameter(FBody s) {
    s.setRestitution(0.7);
    s.setDensity(0.09);
    s.setDamping(0.0);
    s.setFriction(0.0);
    s.setAngularDamping(0.5);
  }
  
  void inputValue(float v) {
    updateValue = v;
  }
  
  void setActive(boolean a) {
    if(a != active) {
      active = a;
      println("swing "+id+ " : active ["+active+"]");
    }
  }
  
  void setFake(boolean f) {
    fake = f;
  }
  
  void fakeStep() {
      fakeSine+=advance(fakeSpeed);
      fakeVal = sin(fakeSine)*fakeAmp;
      updateValue = fakeVal;
  }

  // Highpoint Event. Physical Swing reaches highpoint / makes sound
  void hit() {
    fadeCounter = 1.0;
  }
  
  void highp() {
    highpoint = 1;
  }
  
  void drawSymbol() {
    
  }
  
  void render() {
    
  }
  
}
