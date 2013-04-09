/* 21 Obstacles
 * by dailytouslesjours.com
 *
 * version 2013
 *
 */


import processing.opengl.*;  
import javax.media.opengl.*;
import processing.video.*;     // only for saving out videos

// Physics engine
// http://www.ricardmarxer.com/fisica/reference/index.html
import fisica.*;      

// OpenGL
PGraphicsOpenGL pgl; 
GL gl; 
int circleListID;             // predefine circle points for faster drawing
int swingListID;              // predefine swing shape for faster drawing

boolean test = true;          // effects resolution, second screen placement
// display fps, drawing of floor mask

int theFrameRate = 1000;      // to be updated to current framerate

// GLOBAL SETTINGS
int sw = test ? 1344 : 2688;  // 2688 (x769), 1920, 1344
int sh;

boolean doOSC = false;
boolean doPhone = false;       // thread that jacks phone input PHP every 1000ms

boolean doObjects = true;     // creates swing objects
boolean doFake = true;        // fake swing movement from processing (not osc)
boolean doEffects = false;     // sparkle and radiation
boolean traceBall = true;      // leave trace of previous positions
boolean traceSwing = true;    // swing leaves glowing trace
boolean doBorder = false;
int border = 10;
boolean printInput = false;   // print OSC input
boolean printMore = true;    // print ball actions

boolean doMask = test ? true : false;  // masking out window area of building
boolean doBG = true;          // i
boolean doSecondScreen = test ? false : true;
boolean doGlow = false;        // glowing effect of sparkle
boolean drawSwings = true;
color bgColor = color(0, 100, 200);

boolean e = false;            // true.. english  false.. french
float languageTimer = 1.0;
float languageSpeed = 0.004;
float secretTimer = 0.2;
float secretSpeed = 0.00005;

// RECORDING AND EXPORTING MOVIE FILES
boolean recording = false;
MovieMaker mm;
String moviename = "game_02.mov";
boolean makeMovie = false;

// flags to triggers events
boolean FlagAddBigBall = false;
boolean FlagInitWorld = false;
boolean FlagAddRandomBall = false;
boolean FlagAddManyBalls = false;

// PHYSICS WORLD AND OBJECTS
FWorld world; 
ArrayList swings;     // obstacles, controlled by physical swing data
ArrayList balls;      // incoming user messages
ArrayList walls;      // building floors and walls
int ballcount = 0;    
int maxcount = 5000;    // maxium number of all balls allowed, else > killing
Effects effects;                      // sparkles, etc.
float[] heightFloor = new float[6];  // positions of window areas
Row[] rows = new Row[6];              // row effects

// FONTS AND IMAGES
PFont apercu24;
PFont apercubold24;
PFont frank24;
PFont frank48;
PImage facade;        // image of building facade
int bgImgNo = 2;      // 1...map

Phone phone;          // class that checks php-files for new phone messages

float maskH = 0.024;       // 0.024;

/// HIGHSCORE
int highscore = 0;
int points_collision = 20;
int points_msg = 250;
int points_target = 100;

float outlets[] = { 
  0, 0.17, 0.45, 0.53, 0.89
};

// create 21 swings in a row, all placed center, and moving up+down
void createSwings() {
  int n = 0;
  for (int i=0; i<21; i++) {
    // POLY OBJECTS moving
    // no,   x,             y,       scale,   type, fakemoving, color, movex, movey
    swings.add(new Poly(n++, getX(0.03+i*0.047), getY(0.56), 0.04, "block", doFake, i%5, 0.0, 0.085));
  }
}


void setup() {

  // SCREEN RESOLUTION:   3592x1008   989x252  2688x769   1920x539
  sh = (int) (sw / (3592.0/1008.0));
  if (sw == 2688) sh = 769;
  size(sw, sh, OPENGL );   // try // JAVA2D // OPENGL // P3D // P2D 
  println("screen size \t"+sw+" / "+sh);

  smooth();

  // OPENGL
  pgl = (PGraphicsOpenGL)g;
  gl = pgl.beginGL();

  //  gl.glDisable(GL.GL_DEPTH_TEST);
  //  gl.glEnable(GL.GL_BLEND);
  //  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //  gl.glDisable(GL.GL_BLEND); 

  //  gl.glHint (gl.GL_POLYGON_SMOOTH_HINT, gl.GL_NICEST);
  //  gl.glEnable(gl.GL_LINE_SMOOTH);
  //  gl.glEnable(GL.GL_POLYGON_SMOOTH);
  //  hint(DISABLE_OPENGL_2X_SMOOTH);
  //  hint(ENABLE_OPENGL_4X_SMOOTH);

  circleListID = gl.glGenLists(1);             // generate circle geometry
  gl.glNewList(circleListID, GL.GL_COMPILE);    
  gl.glBegin(GL.GL_TRIANGLE_FAN);
  //  gl.glColor3f(0,0,0);
  gl.glVertex3f(0, 0, 0);
  gl.glNormal3f(0, 0, 1);
  int N = 30;                                  // detail level
  for (int i=0; i<=N; i++) {
    float theta = (float)(i) / (float)(N) * TWO_PI;
    gl.glVertex3f(cos(theta), sin(theta), 0);
  }
  gl.glEnd();
  gl.glEndList();

  float corner_w = 0.1;
  float corner_h = 0.5;
  swingListID = gl.glGenLists(1);
  gl.glNewList(swingListID, GL.GL_COMPILE);  
  gl.glBegin(GL.GL_TRIANGLE_FAN);
  gl.glVertex3f(-1+corner_w, -1, 0);
  gl.glVertex3f(1-corner_w, -1, 0);
  gl.glVertex3f(1, -1+corner_h, 0);
  gl.glVertex3f(1, 1-corner_h, 0);
  gl.glVertex3f(1-corner_w, 1, 0);
  gl.glVertex3f(-1+corner_w, 1, 0);
  gl.glVertex3f(-1, 1-corner_h, 0);
  gl.glVertex3f(-1, -1+corner_h, 0);
  gl.glEnd();
  gl.glEndList();
  pgl.endGL();

  if (makeMovie) mm = new MovieMaker(this, width, height, moviename, 25, MovieMaker.ANIMATION, MovieMaker.BEST);

  phone = new Phone(1000);    // checks every 1000ms
  if (doPhone) phone.start();

  apercu24 = loadFont("Apercu-24.vlw");
  apercubold24 = loadFont("Apercu-Bold-24.vlw");
  frank24 = loadFont("FrankfurterMediumPlain-24.vlw");
  frank48 = loadFont("FrankfurterPlain-48.vlw");
  textFont(apercu24, 12);
  loadBG();

  Fisica.init(this);
  initWorld();
  effects = new Effects();


  if (doOSC) startOSC();

  // set location of undecorated frame on second monitor
  if (doSecondScreen) frame.setLocation(1440, 0);
}

public void init() {
  // make frame not displayable
  if (doSecondScreen) frame.removeNotify();

  // not sure why
  if (doSecondScreen) frame.dispose();

  // sets the window mode to undecorated 
  if (doSecondScreen) frame.setUndecorated(true);

  // add notify again
  if (doSecondScreen) frame.addNotify();
  super.init();
}


void draw() {

  try {
    theFrameRate = (int) frameRate;
  } 
  catch (Exception e) {
    theFrameRate = 60;
    logData("frameRate");
    e.printStackTrace();
  }

  //  if(printMore) println("checkFlags");
  checkFlags();

  background(bgColor);
  // gradient bg
  if (!doBG) {
    beginShape();
    fill(bgColor);
    vertex(0, 0);
    vertex(width, 0);
    fill(55, 55, 55);
    vertex(width, height);
    vertex(0, height);
    endShape();
  }
  if (doBG) image(facade, 0, 0, sw, sh);  // sw,sh facade.width,facade.height
  if (doEffects) for (int i=1; i<6; i++) rows[i].update();  // = render

  if (balls.size() > maxcount) {
    killBalls();
  }

  //  switchLanguage();
  drawLogos();                  // draw logos and all text information
  drawFramerate();

  float step = advance(1/120.0);
  try {
    world.step(step);  
    //    world.draw(this);        // no need, everything is drawn externally
  } 
  catch (AssertionError e) {
    logData("AssertionError world.step()");
    // e.printStackTrace();
  } 
  catch (Exception e) {
    logData("world.step()");
    e.printStackTrace();
  }


  if (doEffects) {
    effects.update();
    effects.drawRadiation();
  }

  //  for (int i=shooters.size()-1; i>= 0; i--) {
  //    Shooter h = (Shooter) shooters.get(i);
  //    h.update();
  //    h.render();
  //  }

  for (int i=0; i<swings.size(); i++) {
    Swing s = (Swing) swings.get(i);
    s.update();
    //    if(drawSwings) s.drawSymbol();
  }
  for (int i=balls.size()-1; i>= 0; i--) {
    try {
      Ball b = (Ball) balls.get(i);
      b.update();
      //      b.drawSymbol();
      if (b.dead()) balls.remove(i);
    } 
    catch (Exception e) {
      logData("balls.get()");
      e.printStackTrace();
    }
  }


  int millis1 = millis();
  gl = pgl.beginGL();            // OPENGL drawing

  for (int i=balls.size()-1; i>= 0; i--) {
    try {
      Ball b = (Ball) balls.get(i);
      b.render();
    } 
    catch (Exception e) {
      logData("balls.get()");
      e.printStackTrace();
    }
  }
  int millis2 = millis();

  for (int i=0; i<swings.size(); i++) {
    Swing s = (Swing) swings.get(i);
    if (drawSwings) s.render();
  }

  for (int i=balls.size()-1; i>= 0; i--) {
    try {
      Ball b = (Ball) balls.get(i);
      b.renderHistory();
    } 
    catch (Exception e) {
      logData("balls.get()");
      e.printStackTrace();
    }
  }

  millis1 = millis2 - millis1;
  millis2 = millis() - millis2;

  pgl.endGL();
  if (printMore && millis2 > 100) println("opengl \t render: "+millis1+ "\t  renderHistory: "+millis2);

  if (doEffects) {
    effects.drawSparkles();
  }

  if (doBorder) drawBorder();
  if (doMask) drawMask();
  if (makeMovie && recording) mm.addFrame();

  if (frameCount%30==0) println(frameRate + "\t\t"+balls.size());
}



// --------------------------------------------------------------------- //
////////////////////  PROPORTIONS    /////////////////////////////////
// --------------------------------------------------------------------- //

float getX(float p) {
  return (p*sw);
}

float getY(float p) {
  return (p*sh);
}



// --------------------------------------------------------------------- //
//////////////////  INITIALIZING. CREATION   //////////////////////////////
// --------------------------------------------------------------------- //

void initWorld() {
  println("initWorld");
  world = new FWorld();                      // initialize Physics World
  world.setEdges(-5, -5, width+5, height+5); // set edges so that they align with applet edges
  world.setEdgesFriction(0);                 // bouncing off edges = effortless
  world.setEdgesRestitution(0);              // bouncing off edges = effortless
  world.setGravity(0, 150);                  // world gravity

  swings = new ArrayList();
  balls = new ArrayList();
  walls = new ArrayList();

  ballcount = 0;

  createBuilding();                          // create walls and row effects
  if (doObjects) createSwings();
}



// --------------------------------------------------------------------- //
//////////////////////  DRAWING display   /////////////////////////////////
// --------------------------------------------------------------------- //


void switchLanguage() {
  languageTimer-=languageSpeed;
  if (languageTimer<=0) {
    e = !e;
    languageTimer = 1.0;
    //    if(random(100)<10) {
    //      int n = (int) (random(3) + 1);
    //      for(int i=0; i<n; i++) addRandomBall();
    //    }
  }
  secretTimer-=secretSpeed;
  if (secretTimer<=0) secretTimer = 1.0;
}

void loadBG() {
  //  int bgImgW = sw;
  //  if(bgImgW != 1920 && bgImgW != 2688 && bgImgW != 1400) {
  //    bgImgW = 1400;
  //  }
  //  String filetype = (bgImgW == 1400) ? ".png" : ".jpg";
  switch(bgImgNo) {
  case 1: 
    facade = loadImage("map_1400.png");
    break;
  case 2: 
    //    facade = loadImage("bluegradient-01.png");
    facade = loadImage("background.jpg");
    break;
  }
}


void drawBorder() {
  fill(255, 0, 0);
  rect(0, 0, width, border);
  rect(width-border, 0, border, height);
  rect(0, height-border, width, border);
  rect(0, 0, border, height);
}

void drawMask() {
  fill(50);
  noStroke();
  float mth = getY(0.04);

  for (int i=0; i<5; i++) {

    if (i==4) {
      rect(0, getY(0.343)+i*getY(0.134), getX(0.695), mth);
      rect(getX(0.7204), getY(0.343)+i*getY(0.134), getX( 0.334), mth);
      rect(getX(0.707), getY(0.343)+i*getY(0.134), getX( 0.011), getY(0.044));
    } 
    else {
      rect(0, getY(0.342)+i*getY(0.134), getX(0.695), mth);
      rect(getX(0.7204), getY(0.342)+i*getY(0.134), getX( 0.334), mth);
      rect(getX(0.707), getY(0.342)+i*getY(0.134), getX( 0.011), getY(0.07));
    }
  }
}

void drawLogos() {
  // draw logos
  noStroke();

  fill(setColor(2));
  textAlign(CENTER);
  if (sw<2688) textFont(frank24, 24); 
  else textFont(frank48, 48);
  text("21 OBSTACLES", getX(0.31), getY(0.11));
  if (sw<2688) textFont(apercu24, 11); 
  else textFont(apercubold24, 23);
  if (e) text("POWERED BY 21 SWINGS", getX(0.31), getY(0.16)); 
  else text("ACTIVÉS PAR 21 BALANÇOIRES", getX(0.31), getY(0.16)); 

  fill(255);
  if (sw<2688) textFont(apercu24, 11); 
  else textFont(apercu24, 23);
  fill(255, 255, 255, 100);
  text("D A I L Y   T O U S   L E S   J O U R S", getX(0.31), getY(0.97));


  textAlign(LEFT);
  if (sw<2688) textFont(apercu24, 12); 
  else textFont(apercubold24, 24);
  fill(255);
  textAlign(LEFT);
  //  if(e) text("Your ball : Text GO, POP or ZOU to 514 400 1156", getX(0.006), getY(0.84));
  text("VOTRE BALLE : Textez GO ou POP au 514 400 1156", getX(0.006), getY(0.84));
  textAlign(LEFT);
  //  if(e) text("Your ball : Text KICK, POW or BOING to 514 400 1156", getX(0.99), getY(0.84));
  text("VOTRE BALLE : Textez KICK ou ZAP au 514 400 1156", getX(0.725), getY(0.84));
  textAlign(LEFT);

  fill(255);
  if (secretTimer > 0.5 && secretTimer < 0.52) {
    text("Pour un peu de chaos, textez WHAM", getX(0.3), getY(0.84));
  } 
  else if (secretTimer > 0.98 && secretTimer < 1.00) {
    text("Pour un peu de chaos, textez BOOM", getX(0.3), getY(0.84));
  }


  // GO
  textAlign(CENTER);
  if (sw<2688) textFont(frank24, 20); 
  else textFont(frank48, 40);
  float y_text = getY(0.1);
  float y_triangle = getY(0.16);
  fill(setColor(1));
  text("GO", getX(outlets[1]), y_text);
  drawTriangle(getX(outlets[1]), y_triangle);

  fill(setColor(2));
  text("POP", getX(outlets[2]), y_text);
  drawTriangle(getX(outlets[2]), y_triangle);

  fill(setColor(3));
  text("KICK", getX(outlets[3]), y_text);
  drawTriangle(getX(outlets[3]), y_triangle);

  fill(setColor(4));
  text("ZAP", getX(outlets[4]), y_text);
  drawTriangle(getX(outlets[4]), y_triangle);


  textAlign(RIGHT);
  fill(255);
  if (sw<2688) textFont(frank48, 64); 
  else textFont(frank48, 128);
  text(highscore, getX(0.7), getY(0.15));
  if (sw<2688) textFont(apercubold24, 14); 
  else textFont(apercubold24, 28);
  fill(255, 255, 255, 100);
  text("CE SOIR", getX(0.695), getY(0.22));
  rect(getX(0.695), getY(0.182), -getX(0.09), -getY(0.004));
}

void drawTriangle(float x, float y) {
  triangle(x, y, x-getX(0.01), y-getY(0.036), x+getX(0.01), y-getY(0.036));
}

void drawFramerate() {
  fill(50, 100, 100);
  textFont(apercu24, 12);
  text((int) theFrameRate, getX(0.01), getY(0.98));    // display framerate
}


// --------------------------------------------------------------------- //
////////////////////  collision CONTACT   /////////////////////////////////
// --------------------------------------------------------------------- //

void contactStarted(FContact contact) {

  // first object for sure will be either a swing or a wall 
  // because they were added to the world first
  FBody b1 = contact.getBody1();
  String nam = b1.getName();

  // check for swing names
  if (nam == "poly" || nam == "multiplier" || nam == "magnet") {
    highscore += points_collision;
    // get ball
    FCircle ball = (FCircle) contact.getBody2();

    if (ball.getName().equals("ball")) {

      // get lane/color of ball (saved in the image alpha value)
      int alane = (int) (ball.getImageAlpha()*10);

      if (nam == "multiplier") {
        // set ball name to "clone" to execute cloning in next ball.update()
        ball.setName("clone");
        // set swing name, to color it to ball/lane color in next poly.update()
        b1.setName("P"+alane+nam);
      } 

      else if (nam == "magnet") {
        // set swing name, to color it to ball/lane color in next poly.update()
        b1.setName("X"+alane+nam);
        // ball.setVelocity(ball.getVelocityX()*0.2,ball.getVelocityY()*0.2);
      } 
      else {
        // set swing name, to color it to ball/lane color in next poly.update()
        b1.setName("X"+alane+nam);
      }

      if (doEffects) {
        effects.addRadiation(contact.getX(), contact.getY(), ball.getFillColor());
        effects.addSparkles(contact.getX(), contact.getY());

        // get Height, translate to row
        int theRow = (int) ((contact.getY()/(float)sh)*8) - 3;
        if (random(0, 100) < 5) {
          if (theRow>0 && theRow<=6) rows[theRow].animate();
        }
      }
    }
  }
}

void contactPersisted(FContact contact) {
  //  FBody b1 = contact.getBody1();
  //  String nam = b1.getName();
  //  if (nam == "poly" || nam == "multiplier" || nam == "magnet") {
  //    FCircle ball = (FCircle) contact.getBody2();
  //    if(ball.getName().equals("ball")) {
  //    }
  //  }
}

void contactEnded(FContact contact) {
  FBody b1 = contact.getBody1();
  String nam = b1.getName();
}

void checkFlags() {
  if (FlagAddManyBalls) {
    for (int i=0; i<100; i++) addRandomBall();
    FlagAddManyBalls = false;
  }
  if (FlagInitWorld) {
    initWorld();
    FlagInitWorld = false;
  }
  if (FlagAddRandomBall) {
    addRandomBall();
    FlagAddRandomBall = false;
  } 
  if (FlagAddBigBall) {
    addBigBall();
    FlagAddBigBall = false;
  }
}

// change value based on current framerate
float advance(float timestep) {
  try {
    return timestep*60.0/(float) theFrameRate;
  } 
  catch (Exception e) {
    logData("advance");
    e.printStackTrace();
    return timestep;
  }
}

void killBalls() {
  if (printMore) println(balls.size()+ " // kill balls!");
  int kb = 20;
  if (balls.size()<21) {
    kb = balls.size()-1;
  }
  for (int i=kb; i>= 0; i--) {
    Ball b = (Ball) balls.get(i);
    b.kill();
    balls.remove(i);
  }
}

void logData(String cause) {
  println("### "+getDate() + " ERROR: "+cause+":\tballs: "+balls.size()+"\tframeRate: "+theFrameRate);
  if (cause.substring(0, 5).equals("Swing")) initWorld();
  else if (cause != "output") killBalls();
}

String getDate() {
  SimpleDateFormat sdf = new SimpleDateFormat("[yyyy/MM/dd HH:mm:ss]");
  return sdf.format(new Date());
}

