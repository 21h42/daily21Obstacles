/* 21 Obstacles
 * by dailytouslesjours.com
 *
 * version 2013
 * uses physics engine fisica
 * http://www.ricardmarxer.com/fisica/reference/index.html
 */

import processing.opengl.*;  
import javax.media.opengl.*;
import processing.video.*;     // only for saving out videos
import fisica.*;               // Physics engine

<<<<<<< HEAD

boolean test = true;          // effects resolution, second screen placement
=======
boolean test = true;          
// effects resolution, second screen placement
>>>>>>> upstream/master
// display fps, drawing of floor mask



// SCREEN SETTINGS
int sw = test ? 1344 : 2688;  // 2688 (x769), 1920, 1344
//int sw = 2688;
int sh;
boolean doSecondScreen = test ? false : true;

// OpenGL
PGraphicsOpenGL pgl; 
GL gl; 
int circleListID;             // predefine circle points for faster drawing
int swingListID;              // predefine swing shape for faster drawing

// Game Levels and Game State
int level = -1;                // current game level
int numLevels = 4;            // maximum number of levels
boolean processing = true;    // physics and effects processing
boolean idle = false;         // idle mode if no active ball for 15sec
float idleTimer = 0;          // count to see if idle should happen
float idleTimerMax = 15;  
float inIdleTime = 0;         // count how long idle time is
float inIdleTimeMax = 10;
int theFrameRate = 1000;      // to be updated to current framerate

// flags to triggers events
boolean FlagAddBigBall = false;
boolean FlagInitWorld = false;
boolean FlagAddRandomBall = false;
boolean FlagAddManyBalls = false;
boolean FlagNoMoreTargets = false;
boolean FlagEndLevel = false;
boolean FlagStartLevel = true;

// PHYSICS WORLD AND OBJECTS
FWorld world; 
ArrayList swings;     // obstacles, controlled by physical swing data
ArrayList balls;      // incoming user messages
ArrayList[] targets;    // target coins
int targetRows = 5;
int ballcount = 0;    
int maxBallCount = 1000;    // maxium number of all balls allowed, else > killing
float oBallSize = 0.025;    // start diameter of balls

// EXTERNAL INPUT
Phone phone;          // class that checks php-files for new phone messages
boolean doOSC = test ? false : true;
boolean doPhone = test ? false : true;       // thread that jacks phone input PHP every 1000ms

<<<<<<< HEAD
boolean doObjects = true;     // creates swing objects
boolean doFake = test ? true : false;        // fake swing movement from processing (not osc)
=======
// ANIMATION 
boolean doFake = false; // test ? true : false;        // fake swing movement from processing (not osc)
>>>>>>> upstream/master
boolean doEffects = true;     // sparkle and radiation
boolean traceBall = true;      // leave trace of previous positions
int traceBallMax = 20;        // how many history position to save
boolean traceSwing = true;    // swing leaves glowing trace
boolean doGlow = false;        // glowing effect of sparkle
Effects effects;                      // sparkles, etc.
Graphics graphics;  

// debugging
boolean printInput = false;   // print OSC input
boolean printMore = false;    // print ball actions
boolean doBorder = false;
int border = 10;
boolean doMask = test ? true : false;  // masking out window area of building
float maskH = 0.024;       // 0.024;


//float secretTimer = 0.2;
//float secretSpeed = 0.00005;

// RECORDING AND EXPORTING MOVIE FILES
boolean recording = false;
MovieMaker mm;
String moviename = "game_02.mov";
boolean makeMovie = false;
Movie myMovie;
boolean playMovie = false;

// TARGETS
int targetcount = 0;
boolean targetMove = false;
float targetMoveX = 0;
float targetMoveSine = 0;
float targetMoveSpeed = 0.01;
float targetMoveAmp = 50.;




// FONTS AND IMAGES

// Apercu-Bold
PFont apercub15;
PFont apercub19;
PFont apercub22;
PFont apercub27;
PFont apercub30;
PFont apercub38;
// Apercu-Mono
PFont apercum37;
PFont apercum52;
PFont apercum73;
PFont apercum190;
PFont apercum272;
PFont apercum381;

/// HIGHSCORE
int highscore = 0;
int points_collision = 0;
<<<<<<< HEAD
int points_msg = 20;
int points_target = 5;
int highscoreGoal = 10000;
int highscoreGoalStep = 10000;
=======
int points_msg = 250;
int points_target[] = { 5, 7, 10, 15 };
>>>>>>> upstream/master



// swing colors, according to physical swing color/instrument
int swingColor[] = {
  2, 2, 4, 1, 3, 4, 2, 3, 4, 4, 1, 1, 2, 4, 2, 2, 3, 3, 1, 2, 2
};

// positions of window areas
float heightFloor[] = {
  0.272, 0.362, 0.497, 0.631, 0.765, 0.9
};


// create 21 swings in a row, all placed center, and moving up+down
void createSwings() {
  int n = 0;
  float x = 0;
  for (int i=0; i<21; i++) {
    x = 0.03 + i*0.0457;
    // 0.0015
    if (x > 0.7) x+=0.0265;     // leave gap for window column
    // POLY OBJECTS moving up and down
    // no,   x,             y,       scale,   type, fakemoving, color, movex, movey
    swings.add(new Poly(n++, getX(x), getY(0.7), 0.04, "block", doFake, swingColor[i], 0.0, 0.07));
  }
}


void setup() {

  // SCREEN RESOLUTION:  2688x755  3592x1008   989x252  2688x769   1920x539
  sh = (int) (sw / (3592.0/1008.0));
  if (sw == 2688) sh = 755;
  size(sw, sh, OPENGL );   // try // JAVA2D // OPENGL // P3D // P2D 

  println("screen size \t"+sw+" / "+sh);

  smooth();    // working? ??

  createOpenGLData();

  if (makeMovie) mm = new MovieMaker(this, width, height, moviename, 25, MovieMaker.ANIMATION, MovieMaker.BEST);

  phone = new Phone(1000);    // checks every 1000ms
  if (doPhone) phone.start();

  apercub15 = loadFont("Apercu-Bold-15.vlw");
  apercub19 = loadFont("Apercu-Bold-19.vlw");
  apercub22 = loadFont("Apercu-Bold-22.vlw");
  apercub27 = loadFont("Apercu-Bold-27.vlw");
  apercub30 = loadFont("Apercu-Bold-30.vlw");
  apercub38 = loadFont("Apercu-Bold-38.vlw");

  apercum37 = loadFont("Apercu-Mono-37.vlw");
  apercum52 = loadFont("Apercu-Mono-52.vlw");
  apercum73 = loadFont("Apercu-Mono-73.vlw");
  apercum190 = loadFont("Apercu-Mono-190.vlw");
  apercum272 = loadFont("Apercu-Mono-272.vlw");
//  apercum381 = loadFont("Apercu-Mono-381.vlw");

  Fisica.init(this);
  initWorld();

  graphics = new Graphics();
  effects = new Effects();

  graphics.init();

  if (playMovie) {
    //myMovie = new Movie(this, "21O_MOUNTAIN_01.mov");
    myMovie.loop();
  }

  if (doOSC) startOSC();

  // set location of undecorated frame on second monitor
  if (doSecondScreen) frame.setLocation(1920, 0);
  else frame.setLocation(0, 0);
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

  ///////////////// UPDATE step /////////////////////////////

  if (processing) {
    checkFlags();      // check for ball-add-kill events

    updatePhysics();    // new step in physics world
    graphics.update();  // GRAPHICS update with animation counter
    updateSwings();     // either swing-data via OSC, or fake animation update
    updateBalls();      // update location based on physics engine
    updateTargets();    //
  }

  //////////////// RENDER step ///////////////////////////////////////

  graphics.render();


  if (makeMovie && recording) mm.addFrame();

  if (printMore && frameCount%30==0) println(frameRate + "\t\t"+balls.size());
}


void createOpenGLData() {
  // OPENGL
  pgl = (PGraphicsOpenGL)g;
  gl = pgl.beginGL();
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
}

// --------------------------------------------------------------------- //
////////////////////  PROPORTIONS    /////////////////////////////////
// --------------------------------------------------------------------- //

// screen width mapped from 0 to 1 to 0 to width
float getX(float p) {
  return (p*sw);
}

// screen height mapped from 0 to 1 to 0 to height
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
  targets = new ArrayList[targetRows];
  for (int j=0; j<targetRows; j++) targets[j] = new ArrayList();

  ballcount = 0;
  targetcount = 0;

  createSwings();
  addTargets();
}



// --------------------------------------------------------------------- //
//////////////////////  DRAWING display   /////////////////////////////////
// --------------------------------------------------------------------- //

void drawFramerate() {
  fill(50, 100, 100);
  if (sw==2688) textFont(apercub30, 30); 
  else if (sw==1920) textFont(apercub22, 22); 
  else textFont(apercub15, 15);
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
    }
  } 
  else if (nam == "target" || nam == "ball") {
    // target and balls can be first or second, as they are both added during the run
    FBody b2 = contact.getBody2();
    FBody ball = b2;
    FBody target = b2;
    String nam2 = b2.getName();
    boolean targetHit = false;
    if (nam.equals("target")) {
      target = b1;
      targetHit = true;
    } 
    else if (nam2.equals("target")) {
      ball = b1;
      targetHit = true;
    }
    if (targetHit) {
      target.setName("X-target");
      ball.setName("T-ball");
      highscore += points_target[level];
      if (doEffects) {
//        effects.addRadiation(contact.getX(), contact.getY(), setColor(1));  // ball.getFillColor()
//        effects.addSparkles(contact.getX(), contact.getY());
        effects.addWinPoints(target.getX(), target.getY());
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



/////////////////// flags /////////////////////////
// to be executed before update of swings/balls/targets, and not in between loop

void checkFlags() {
  if (balls.size() > maxBallCount) {
    killBalls();
  }
  // IDLE TIME
  if (!idle && balls.size() == 0) {
    idleTimer += advance(1/60.0);
//    println("!idle \t"+idleTimer);
    if(idleTimer >= idleTimerMax) {
      idle = true;
      inIdleTime = 0;
      println("idle mode!");
    }
  }
  if(idle) {
    inIdleTime += advance(1/60.0);
//    println("idle \t"+inIdleTime);
    if(inIdleTime >= inIdleTimeMax) {
      idleTimer = 0;
      idle = false;
      println("end idle time");
    }
  }
  //
  if (FlagAddManyBalls) {
    for (int i=0; i<100; i++) addRandomBall();
    FlagAddManyBalls = false;
    setTraceLength();
  }
  if (FlagInitWorld) {
    initWorld();
    FlagInitWorld = false;
  }
  if (FlagAddRandomBall) {
    addRandomBall();
    highscore += points_msg;
    FlagAddRandomBall = false;
    setTraceLength();
  } 
  if (FlagAddBigBall) {
    addBigBall();
    FlagAddBigBall = false;
  }
  if (FlagNoMoreTargets) {
    boolean noMoreTargets = true;
    for (int j=0; j<targets.length; j++) {
      if (targets[j].size() > 0) noMoreTargets = false;
    }
    if (noMoreTargets) {
      if (printMore) println("All Targets are hit!");
      // TODO: go to next level
      FlagEndLevel = true;
    }
    FlagNoMoreTargets = false;
  }
  if (FlagEndLevel) {
    killAllBalls();
    graphics.levelEndTimer = 1;
    FlagEndLevel = false;
  }
  
  if (FlagStartLevel) {
    level++;
    if(level>=numLevels) level = 0;
    graphics.levelStartTimer = 1;
    println("level \t"+level);
    addTargets();
    FlagStartLevel = false;
  }
}

// make trace length inverse proportional to number of active balls
void setTraceLength() {
  int no_balls = balls.size();
  if (no_balls == 0) traceBallMax = 20;
  else if (no_balls >= 33) traceBallMax = 3;
  else {
    //    traceBallMax = 3 + 96 - (int) map(no_balls, 1, 99, 0, 96);
    // 1 ..100   2..50  3..33  4..25  5..20  6..17  10..10
    traceBallMax = 200/no_balls;
  }
  if (printMore) println("setTraceLength to \t"+ traceBallMax + " \t balls "+no_balls);
}

// change update value based on current framerate
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


void updatePhysics() {
  float step = advance(1/60.0);
  try {
    world.step(step);
  } 
  catch (AssertionError e) {
    logData("AssertionError world.step()");
    // e.printStackTrace();
  } 
  catch (Exception e) {
    logData("world.step()");
    e.printStackTrace();
  }
}

void updateBalls() {
  // BALLS update
  for (int i=balls.size()-1; i>= 0; i--) {
    try {
      Ball b = (Ball) balls.get(i);
      b.update();
      if (b.dead()) {
        balls.remove(i);
        setTraceLength();
      }
    } 
    catch (Exception e) {
      logData("balls.get()");
      e.printStackTrace();
    }
  }
}

void updateSwings() {
  // SWINGS update
  for (int i=0; i<swings.size(); i++) {
    Swing s = (Swing) swings.get(i);
    s.update();
  }
}

void updateTargets() {
  // TARGETS update
  if (targetMove) {
    targetMoveSine+=advance(targetMoveSpeed);
    targetMoveX = sin(targetMoveSine)*targetMoveAmp;
  }
  for (int j=0; j<targets.length; j++) {
    for (int i=targets[j].size()-1; i>= 0; i--) {
      try {
        Target t = (Target) targets[j].get(i);
        t.update();
        if (t.dead()) {
          t.kill();
          targets[j].remove(i);
          if (targets[j].size() < 1) {
            FlagNoMoreTargets = true;
            effects.rows[j].animate();
          }
        }
      } 
      catch (Exception e) {
        logData("targets[t].get()");
        e.printStackTrace();
      }
    }
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
  setTraceLength();
}

void killAllBalls() {
  for (int i=balls.size()-1; i>= 0; i--) {
    Ball b = (Ball) balls.get(i);
    b.kill();
    balls.remove(i);
  }
  setTraceLength();
}

void resetIdle() {
  idle = false;
  idleTimer = 0;
  inIdleTime = 0;
  graphics.idleScreen = false;
  graphics.transitionFade = 1;
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

