/* 21 Obstacles
 * by dailytouslesjours.com
 *
 * version 2013
 *
 */


import processing.opengl.*;  
import processing.video.*;     // only for saving out videos

// Physics engine
// http://www.ricardmarxer.com/fisica/reference/index.html
import fisica.*;      


boolean test = true;          // effects resolution, second screen placement
                              // display fps, drawing of floor mask
int theFrameRate = 60;        // to be updated to current framerate

// GLOBAL SETTINGS
int sw = test ? 1344 : 2688;  // 2688 (x769), 1920, 1344
int sh;
boolean doOSC = false;
boolean printInput = false;   // print OSC input
boolean printMore = false;    // print ball actions
boolean doPhone = false;       // thread that jacks phone input PHP every 1000ms
boolean doObjects = true;     // creates swing objects
boolean doFake = true;        // fake swing movement from processing (not osc)
boolean doEffects = false;     // sparkle and radiation
boolean doBorder = false;
int border = 10;

boolean doFloors = false;      // create/display floors
boolean doMask = test ? true : false;  // masking out window area of building
boolean doBG = true;          // i
boolean doSecondScreen = test ? false : true;
boolean doGlow = false;        // glowing effect of sparkle
boolean doFPS = test ? true : false;    // not used?
color bgColor = color(0,100,200);

boolean e = true;            // true.. english  false.. french
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
int maxcount = 250;    // maxium number of all balls allowed, else > killing
Effects effects;      // sparkles, etc.
ArrayList shooters;    // objects that 'release' balls

// FONTS AND IMAGES
//PFont arial60;
PFont arial24;
PFont apercu24;
PFont apercubold24;
PFont frank24;
PFont frank48;
PImage facade;        // image of building facade
int bgImgNo = 2;      // 1...map

Phone phone;          // class that checks php-files for new phone messages

float floorH = 0.034;      // 0.032;
float maskH = 0.024;       // 0.024;
float[] heightFloor = new float[6];  // positions of window areas
Row[] rows = new Row[6];

// SET THE PORTALS:  array with floors.
// from 0 (left) to 1 (right)
// two numbers in row make a floor partition
float[][] floorParts = { 
  {
    0.0, 0.05, 0.79, 0.822, 0.92, 1.0
  }
  , {
    0.0, 0.08, 0.15, 0.28, 0.35, 0.59, 0.7209, 0.77, 0.895, 1.0
  }
  , {
    0, 0.11, 0.189, 0.27, 0.32, 0.365, 0.52, 0.6, 0.7209, 0.74, 0.827, 0.87, 0.91, 1.0
  }
  , {
    0, 0.11, 0.189, 0.44, 0.52, 0.6, 0.67, 0.695, 0.7209, 0.79, 0.925, 1.0
  }
  , {
    0, 0.08, 0.189, 0.27, 0.38, 0.52, 0.6, 0.62, 0.67, 0.695, 0.82, 1.0
  }
  , {
    0.04, 0.2, 0.3, 0.52, 0.6, 0.87, 0.9, 1
  }
};

void createSwings() {
  

  
  int n = 0;
  for(int i=0; i<21; i++) {
      // POLY OBJECTS moving
                        // no,   x,             y,       scale,   type, fakemoving, color, movex, movey
     swings.add(new Poly(n++, getX(0.03+i*0.047), getY(0.56), 0.04, "block", doFake, i%5, 0.0, 0.045));
  }
  
}


void createSwings2012() {
  // POLY OBJECTS rotating
  // no, x, y, scale, type, fakemoving, color

  // POLY OBJECTS moving
  // no, x, y, scale, type, fakemoving, color, movex, movey

  // ROUNDSHAPE OBJECTS
  // no, x, y, scale, type, movex, movey, fakemoving, color

  int n = 0;



  //  for(int i=0; i<18; i++) {
  //    if(i%2==0) {
  ////    swings.add(new RoundShape(n++,getX(0.1+i*0.05),getY(0.5),0.02,0.1,0.1,"magnet", true, 8));
  //      swings.add(new Poly(n++,getX(0.1+i*0.05),getY(0.5),0.1,"flipperhalf", true, 8));
  //    } else {
  ////    swings.add(new RoundShape(n++,getX(0.1+i*0.05),getY(0.5),0.02,0.1,0.1,"multiplier", true, 8));
  ////      swings.add(new Poly(n++,getX(0.1+i*0.05),getY(0.5),0.03,"trap1", true, 8,0.1,0.1));
  //    }
  //  }

  // 1-3
  swings.add(new Poly(n++, getX(0.2), getY(0.244), 0.08, "flipper", doFake, 3));  //  top align flipper 
  swings.add(new Poly(n++, getX(0.15), getY(0.43), 0.08, "flipper", doFake, 7));  // set above hole flipper
  swings.add(new Poly(n++, getX(0.15), getY(0.689), 0.042, "trap1", doFake, 6));  // trap row 4

  // 4-6
  swings.add(new RoundShape(n++, getX(0.312), getY(0.26), 0.045, 0.01, 0.04, "magnet", doFake, 8)); // big magnet on top
  swings.add(new Poly(n++, getX(0.282), getY(0.52), 0.025, "square", doFake, 9));  // square
  swings.add(new RoundShape(n++, getX(0.329), getY(0.7), 0.025, -0.03, 0.00, "multiplier", doFake, 4));  // left right multi
  
  // 7-9
  swings.add(new Poly(n++, getX(0.25), getY(0.999), 0.07, "cross", doFake, 3)); // cross at bottom getX(0.276), getY(0.882)
  swings.add(new Poly(n++, getX(0.412), getY(0.479), 0.047, "cross", doFake, 4));  // center cross
  swings.add(new Poly(n++, getX(0.533), getY(0.135), 0.08, "flipper", doFake, 1, 0.055, 0));  // logo slider
  
  // 10-12
  swings.add(new Poly(n++, getX(0.48), getY(0.56), 0.08, "flipper", doFake, 2, 0.0, 0.045));  // left higher elevator
  swings.add(new Poly(n++, getX(0.56), getY(0.873), 0.08, "flipper", doFake, 4, 0.0, 0.045));  // going up down
  swings.add(new RoundShape(n++, getX(0.642), getY(0.696), 0.02, 0.01, 0.03, "magnet", doFake, 5));
  
  // 13-15
  swings.add(new Poly(n++, getX(0.66), getY(0.29), 0.04, "trap1", doFake, 3)); // center top trap
  swings.add(new Poly(n++, getX(0.65), getY(0.47), 0.09, "flipper", doFake, 6));  // flipper center right
  swings.add(new RoundShape(n++, getX(0.768), getY(0.7), 0.025, -0.03, 0.00, "multiplier", doFake, 4));
  
  // 19-21
  swings.add(new Poly(n++, getX(0.858), getY(0.604), 0.08, "flipper", doFake, 4, 0.05, 0));  // slider left right
  swings.add(new RoundShape(n++, getX(0.85), getY(0.27), 0.035, 0.01, 0.04, "magnet", doFake, 8));  // magnet right top
  swings.add(new Poly(n++, getX(0.8), getY(0.478), 0.045, "cross", doFake, 3));    // cross right top
  
}


void setup() {
  // 3592x1008   989x252  2688x769   1920x539
  sh = (int) (sw / (3592.0/1008.0));
  if (sw == 2688) sh = 769;
  size(sw, sh, OPENGL );   // try // JAVA2D // OPENGL // P3D // P2D 
  println("screen size \t"+sw+" / "+sh);

  if (makeMovie) mm = new MovieMaker(this, width, height, moviename, 25, MovieMaker.ANIMATION, MovieMaker.BEST);
  
  phone = new Phone(1000);    // checks every 1000ms
  if (doPhone) phone.start();

  arial24 = loadFont("arial24.vlw");
  //  arial60 = loadFont("arial60.vlw");
  apercu24 = loadFont("Apercu-24.vlw");
  apercubold24 = loadFont("Apercu-Bold-24.vlw");
  frank24 = loadFont("FrankfurterMediumPlain-24.vlw");
  frank48 = loadFont("FrankfurterPlain-48.vlw");
  textFont(apercu24, 12);
  loadBG();

  Fisica.init(this);
  initWorld();
  effects = new Effects();

  smooth();
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
  try{
    theFrameRate = (int) frameRate;
  } catch (Exception e) {
    theFrameRate = 60;
    logData("frameRate");
    e.printStackTrace();
  }
  
  checkFlags();
  
  background(bgColor);
  // gradient bg
  if(!doBG) {
    beginShape();
    fill(bgColor);
    vertex(0,0);
    vertex(width,0);
    fill(55,55,55);
    vertex(width,height);
    vertex(0,height);
    endShape();
  }
  if (doBG) image(facade, 0, 0, sw, sh);  // sw,sh facade.width,facade.height
  for(int i=1; i<6; i++) rows[i].update();  // = render
 
  
  if(balls.size() > maxcount) {
      killBalls();
  }
  
  switchLanguage();
  drawLogos();

  float step = advance(1/120.0);
  try{
    world.step(step);  
    world.draw(this);  
  } catch (AssertionError e) {
    logData("AssertionError world.step()");
    // e.printStackTrace();
  } catch (Exception e) {
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
    s.drawSymbol();
  }
  for (int i=balls.size()-1; i>= 0; i--) {
    try{
      Ball b = (Ball) balls.get(i);
      b.update();
      b.drawSymbol();
      if (b.dead()) balls.remove(i); 
    } catch (Exception e) {
      logData("balls.get()");
      e.printStackTrace();
    }
  }

  if (doEffects) {
    effects.drawSparkles();
  }

  if (doBorder) drawBorder();
  if (doFloors) drawFloors();
  if (doMask) drawMask();
  if (makeMovie && recording) mm.addFrame();
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

  createBuilding();                          // create walls and row effects
  if (doObjects) createSwings();
  //  shooters = new ArrayList();
//  createShooters();
}




void createShooters() {
  float dy = -0.13;
  int n = 0;
  // left side
  shooters.add(new Shooter(n++, getX(0.0), getY(heightFloor[1]+dy), "POP"));  // 3 at once, smaller, red yellow blue
  shooters.add(new Shooter(n++, getX(0.0), getY(heightFloor[2]+dy), "GO"));
  shooters.add(new Shooter(n++, getX(0.0), getY(heightFloor[3]+dy), "ZOU"));  // upwards movement
  //  shooters.add(new Shooter(n++,getX(0.0),getY(heightFloor[3]+dy),"WOP"));

  // right side
  shooters.add(new Shooter(n++, getX(0.98), getY(heightFloor[1]+dy), "KICK"));  // straight and super fast
  shooters.add(new Shooter(n++, getX(0.98), getY(heightFloor[2]+dy), "POW"));  // bigger, less bouncy
  shooters.add(new Shooter(n++, getX(0.98), getY(heightFloor[3]+dy), "BOING"));  // bouncier, bounce up and down
  //  shooters.add(new Shooter(7,getX(1.0),getY(heightFloor[3]+dy),"SNAP"));  

  // go, pop, kick, roll, shoot, snap, bzzz, bounce, bang, boom, wop, wham
  // ding, flash, flick, flop, hoot, push, pint, plip, plop, pow, snip, splash, splat, thud, thunk, tuff, tzing, wap, whaam, whack, whap, whoop, whop, zing, zap
}

// --------------------------------------------------------------------- //
//////////////////////  DRAWING display   /////////////////////////////////
// --------------------------------------------------------------------- //


void switchLanguage() {
  languageTimer-=languageSpeed;
  if(languageTimer<=0) {
    e = !e;
    languageTimer = 1.0;
//    if(random(100)<10) {
//      int n = (int) (random(3) + 1);
//      for(int i=0; i<n; i++) addRandomBall();
//    }
  }
  secretTimer-=secretSpeed;
  if(secretTimer<=0) secretTimer = 1.0;
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
    facade = loadImage("bluegradient-01.png");
    break;
  }
}

void drawFloors() {

  // black layer 
  //  fill(0);
  //  noStroke();
  //  for(int i=1; i<6; i++) {
  //    rect(0,getY(heightFloor[i]-floorH),width,getY(floorH));
  //  }
  // white layer on top
  int parts = 0;
  float sx = 0;
  float wx = 100;
  float th = 0;
  fill(255);
  noStroke();
  for (int i=0; i<6; i++) {
    parts = floorParts[i].length / 2;
    if (parts>0) {
      for (int j=0; j<parts; j++) {
        sx = floorParts[i][j*2];
        wx = floorParts[i][j*2+1]-floorParts[i][j*2];
        th = (i==0) ?  (floorH/3) :  floorH;
        rect(getX(sx), getY(heightFloor[i]-floorH), getX(wx), getY(th));
      }
    }
  }
  // first floor. simulate black mask

  //  fill(0);
  //  for(int i=0; i<1; i++) {
  //    parts = floorParts[i].length / 2;
  //    if(parts>0) {
  //      for(int j=0; j<parts; j++) {
  //        sx = floorParts[i][j*2];
  //        wx = floorParts[i][j*2+1]-floorParts[i][j*2];
  //        
  //        rect(getX(sx)-1,getY(heightFloor[i]-maskH),getX(wx)+2,getY(maskH*2));
  //      }
  //    }
  //  }
}


void drawBorder() {
  fill(255, 0, 0);
  rect(0, 0, width, border);
  rect(width-border, 0, border, height);
  rect(0, height-border, width, border);
  rect(0, 0, border, height);
}

void fadebackground() {
  fill(0, 2);
  noStroke();
  rect(0, 0, width, height);
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
  fill(0,255,255);
//  if(e) shape(logo_21b_e, getX(0.5), getY(0.05));
//  else  shape(logo_21b_f, getX(0.5), getY(0.05));
  textAlign(CENTER);
  if (sw<2688) textFont(frank24, 24);
  else textFont(frank48,48);
  text("21 OBSTACLES", getX(0.533), getY(0.11));
  
  if (sw<2688) textFont(apercu24, 11);
  else textFont(apercubold24, 23);
  if(e) text("POWERED BY 21 SWINGS",getX(0.533), getY(0.18)); 
  else text("ACTIVÉS PAR 21 BALANÇOIRES",getX(0.533), getY(0.18)); 
  textAlign(LEFT);
  fill(255);
  if (sw<2688) textFont(apercu24, 11);
  else textFont(apercu24, 23);

  text("D A I L Y   T O U S   L E S   J O U R S", getX(0.3), getY(0.97));
  fill(50,100,100);
  textFont(apercu24, 12);
  text((int)frameRate, getX(0.01), getY(0.98));    // display framerate
  

  if (sw<2688) textFont(apercu24, 12);
  else textFont(apercubold24, 24);
  fill(255);
  textAlign(LEFT);
//  if(e) text("Your ball : Text GO, POP or ZOU to 514 400 1156", getX(0.006), getY(0.84));
  text("Votre balle : textez GO, POP ou ZOU au 514 400 1156", getX(0.006), getY(0.84));
  textAlign(LEFT);
//  if(e) text("Your ball : Text KICK, POW or BOING to 514 400 1156", getX(0.99), getY(0.84));
  text("Votre balle : textez KICK, POW, BOING au 514 400 1156", getX(0.725), getY(0.84));
  textAlign(LEFT);
  
  fill(255,255,0);
  if(secretTimer > 0.5 && secretTimer < 0.52) {
    text("Pour un peu de chaos, textez WHAM", getX(0.3), getY(0.84));
  } else if(secretTimer > 0.98 && secretTimer < 1.00) {
    text("Pour un peu de chaos, textez BOOM", getX(0.3), getY(0.84));
  }
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
      } else {
        // set swing name, to color it to ball/lane color in next poly.update()
        b1.setName("X"+alane+nam);
      }
      
      if(doEffects) {
        effects.addRadiation(contact.getX(), contact.getY(), ball.getFillColor());
        effects.addSparkles(contact.getX(), contact.getY());
        
        // get Height, translate to row
        int theRow = (int) ((contact.getY()/(float)sh)*8) - 3;
        if(random(0,100) < 5) {
          if(theRow>0 && theRow<=6) rows[theRow].animate();
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
  if(FlagAddManyBalls) {
    for(int i=0; i<100; i++) addRandomBall();
    FlagAddManyBalls = false;
  }
  if(FlagInitWorld) {
    initWorld();
    FlagInitWorld = false;
  }
  if(FlagAddRandomBall) {
    addRandomBall();
    FlagAddRandomBall = false;
  } 
  if(FlagAddBigBall) {
    addBigBall();
    FlagAddBigBall = false;
  }
}

float advance(float timestep) {
  try {
    return timestep*60.0/(float) theFrameRate;
  } catch (Exception e) {
    logData("advance");
    e.printStackTrace();
    return timestep;
  }
}

void killBalls() {
  if(printMore) println(balls.size()+ " // kill balls!");
  int kb = 20;
  if(balls.size()<21) {
    kb = balls.size()-1;
  }
  for(int i=kb; i>= 0; i--) {
    Ball b = (Ball) balls.get(i);
    b.kill();
    balls.remove(i);
  }
}

void logData(String cause) {
  println("### "+getDate() + " ERROR: "+cause+":\tballs: "+balls.size()+"\tframeRate: "+theFrameRate);
  if(cause.substring(0,5).equals("Swing")) initWorld();
  else if(cause != "output") killBalls();
}

String getDate() {
  SimpleDateFormat sdf = new SimpleDateFormat("[yyyy/MM/dd HH:mm:ss]");
  return sdf.format(new Date());
}

