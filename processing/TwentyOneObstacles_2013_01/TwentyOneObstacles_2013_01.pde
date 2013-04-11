import processing.opengl.*;      
import fisica.*;      // Physics engine. Documentation at :
// http://www.ricardmarxer.com/fisica/reference/index.html
import processing.video.*;     // only for saving out videos

boolean test = true;
int theFrameRate = 60;

// GLOBAL SETTINGS
int sw = test ? 1344 : 2688;  // 2688, 1920. 1344
int sh;
boolean doOSC = true;
boolean printInput = false;
boolean printMore = false;
boolean doPhone = test ? false : true;
boolean doObjects = true;  // 
boolean doFake = true;      
boolean doEffects = true;
boolean doBorder = false;
int border = 10;
boolean doFloors = true;  // f
boolean doMask = test ? true : false;  // m
boolean doBG = true;    // i
boolean doSecondScreen = test ? false : true;
boolean doGlow = false;
boolean doFPS = test ? true : false;
color bgColor = color(0,100,200);
boolean e = true;    // 1.. english  0.. french
float languageTimer = 1.0;
float languageSpeed = 0.004;
float secretTimer = 0.2;
float secretSpeed = 0.00005;

// RECORDING AND EXPORTING MOVIE FILES
boolean recording = false;
MovieMaker mm;
String moviename = "game_02.mov";
boolean makeMovie = false;

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
int maxcount = 250;
Effects effects;
ArrayList shooters;

// FONTS AND IMAGES
//PFont arial60;
PFont arial24;
PFont apercu24;
PFont apercubold24;
PFont frank24;
PFont frank48;
PImage facade;        // image of building facade
int bgImgNo = 2;      // 1...map
//PShape logo_21b_e;
//PShape logo_21b_f;
PShape logo_parcours;

Phone phone;

float floorH = 0.034;  // 0.032;
float maskH = 0.024;  // 0.024;
float[] heightFloor = new float[6];
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
  swings.add(new Poly(n++, getX(0.2), getY(0.244), 0.08, "flipper", false, 3));  //  top align flipper 
  swings.add(new Poly(n++, getX(0.15), getY(0.43), 0.08, "flipper", false, 7));  // set above hole flipper
  swings.add(new Poly(n++, getX(0.15), getY(0.689), 0.042, "trap1", false, 6));  // trap row 4

  // 4-6
  swings.add(new RoundShape(n++, getX(0.312), getY(0.26), 0.045, 0.01, 0.04, "magnet", false, 8)); // big magnet on top
  swings.add(new Poly(n++, getX(0.282), getY(0.52), 0.025, "square", false, 9));  // square
  swings.add(new RoundShape(n++, getX(0.329), getY(0.7), 0.025, -0.03, 0.00, "multiplier", false, 4));  // left right multi
  
  // 7-9
  swings.add(new Poly(n++, getX(0.25), getY(0.999), 0.07, "cross", false, 3)); // cross at bottom getX(0.276), getY(0.882)
  swings.add(new Poly(n++, getX(0.412), getY(0.479), 0.047, "cross", false, 4));  // center cross
  swings.add(new Poly(n++, getX(0.533), getY(0.135), 0.08, "flipper", false, 1, 0.055, 0));  // logo slider
  
  // 10-12
  swings.add(new Poly(n++, getX(0.48), getY(0.56), 0.08, "flipper", false, 2, 0.0, 0.045));  // left higher elevator
  swings.add(new Poly(n++, getX(0.56), getY(0.873), 0.08, "flipper", false, 4, 0.0, 0.045));  // going up down
  swings.add(new RoundShape(n++, getX(0.642), getY(0.696), 0.02, 0.01, 0.03, "magnet", false, 5));
  
  // 13-15
  swings.add(new Poly(n++, getX(0.66), getY(0.29), 0.04, "trap1", false, 3)); // center top trap
  swings.add(new Poly(n++, getX(0.65), getY(0.47), 0.09, "flipper", false, 6));  // flipper center right
  swings.add(new RoundShape(n++, getX(0.768), getY(0.7), 0.025, -0.03, 0.00, "multiplier", false, 4));
  
  // 19-21
  swings.add(new Poly(n++, getX(0.858), getY(0.604), 0.08, "flipper", false, 4, 0.05, 0));  // slider left right
  swings.add(new RoundShape(n++, getX(0.85), getY(0.27), 0.035, 0.01, 0.04, "magnet", false, 8));  // magnet right top
  swings.add(new Poly(n++, getX(0.8), getY(0.478), 0.045, "cross", false, 3));    // cross right top
  
}


void setup() {
  // 3592x1008   989x252  2688x769   1920x539
  sh = (int) (sw / (3592.0/1008.0));
  if (sw == 2688) sh = 769;
  size(sw, sh, OPENGL);   // try // JAVA2D // OPENGL 
  println("screen size: "+sw+" / "+sh);

  if (makeMovie) mm = new MovieMaker(this, width, height, moviename, 25, MovieMaker.ANIMATION, MovieMaker.BEST);
  
  phone = new Phone(1000);
  if (doPhone) phone.start();

  arial24 = loadFont("arial24.vlw");
  //  arial60 = loadFont("arial60.vlw");
  apercu24 = loadFont("Apercu-24.vlw");
  apercubold24 = loadFont("Apercu-Bold-24.vlw");
  frank24 = loadFont("FrankfurterMediumPlain-24.vlw");
  frank48 = loadFont("FrankfurterPlain-48.vlw");
  textFont(apercu24, 12);
  loadBG();
//  logo_21b_e = loadShape("logo_21b_english.svg");
//  logo_21b_e.disableStyle();
//  logo_21b_f = loadShape("logo_21b_french.svg");
//  logo_21b_f.disableStyle();
  logo_parcours = loadShape("logo_parcours.svg");
  logo_parcours.disableStyle();
  if (sw<2688) logo_parcours.scale(0.5);

  Fisica.init(this);
  initWorld();
  effects = new Effects();

  smooth();
  if (doOSC) startOSC();
  if (doSecondScreen) frame.setLocation(1440, 0);
}

public void init() {
  if (doSecondScreen) frame.removeNotify();
  if (doSecondScreen) frame.dispose();
  if (doSecondScreen) frame.setUndecorated(true);
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

  for (int i=shooters.size()-1; i>= 0; i--) {
    Shooter h = (Shooter) shooters.get(i);
    h.update();
    h.render();
  }

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
  world.setEdges(-5, -5, width+5, height+5);    // set edges so that they align with applet edges
  world.setEdgesFriction(0);                 // bouncing off edges = effortless
  world.setEdgesRestitution(0);              // bouncing off edges = effortless
  world.setGravity(0, 150);                  // world gravity

  swings = new ArrayList();
  balls = new ArrayList();
  walls = new ArrayList();
  shooters = new ArrayList();
  createBuilding();
  if (doObjects) createSwings();
  createShooters();
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
    if(random(100)<10) {
      int n = (int) (random(3) + 1);
      for(int i=0; i<n; i++) addRandomBall();
    }
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
//  shape(logo_parcours, getX(0.18), getY(0.02));
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
  FBody b1 = contact.getBody1();
  String nam = b1.getName();
  if (nam == "poly" || nam == "multiplier" || nam == "magnet") {
    FCircle ball = (FCircle) contact.getBody2();
    if (ball.getName().equals("ball")) {
      int alane = (int) (ball.getImageAlpha()*10);
      //      println("alane: "+alane);
      if (nam == "multiplier") {
        ball.setName("clone");
        b1.setName("P"+alane+nam);
      } 
      else if (nam == "magnet") {
        b1.setName("X"+alane+nam);
        //        ball.setVelocity(ball.getVelocityX()*0.2,ball.getVelocityY()*0.2);
      } 
      else {

        b1.setName("X"+alane+nam);
      }
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

