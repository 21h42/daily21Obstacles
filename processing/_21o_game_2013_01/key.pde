
void keyReleased() {
  if(keyCode == 32) {
    processing = !processing;
  } else if(key > '0' && key < '5') {
    int id = (int)(key-'0');
    println("shoot ball \t"+id);
    
    Ball b = new Ball(ballcount++,getX(outlets[id]),0, id);
    b.b.setVelocity(random(-200.0, 200.0), 300);
    highscore += points_msg;
    balls.add(b);
    setTraceLength();
    
  } else if(key == '8') {
    effects.sparkleRain();
    println("sparkle rain");
    
  } else if(key == '7') {
    println("add big ball");
    FlagAddBigBall = true;
    
  } else if(key =='a') {
    traceBall = !traceBall;
    println("traceBall \t"+traceBall);
    
  } else if(key == 'c') {
    addTargets();
    println("addTargets");
    
  } else if(key == 't') {
    traceSwing = !traceSwing;
    println("traceSwing \t"+traceSwing);
    
  } else if(key == '9') {
    println("many balls");
    FlagAddManyBalls = true;
    
  } else if(key == 's') {
    drawSwings = !drawSwings;
    println("drawSwings \t"+drawSwings);
    
  } else if(key == 'w') {
    targetMove = !targetMove;
    println("targetMove \t"+targetMove);
    
  } else if(key == 'v') {
    printInput = !printInput;
    println("printInput \t"+printInput);
  
  } else if(key == 'e') {
    doEffects = !doEffects;
    println("doEffects \t"+doEffects);
  
  } else if(key == 'f') {
    doFake = !doFake;
    println("doFake \t"+doFake);
    
  } else if(key == 'm') {
    doMask = !doMask;
    println("doMask \t"+doMask);
    
  } else if(key == 'r') {
    if(makeMovie) {
      recording = !recording;
      println("recording \t"+recording);
      if(!recording) mm.finish();
    }
    
  } else if(key =='h') {
    Swing s = (Swing) swings.get(0);
    s.hit();
//    effects.addRadiation(random(width),random(height),color(255,0,0));

  } else if(key == 'x') {
    // restart
    println("restart world");
    FlagInitWorld = true;
    
  } else if(key == 'i') {
    idle = !idle;
    println("idle \t"+idle);
    
  } else if(key == 'j') {
    bgImgNo++;
    if(bgImgNo>2) bgImgNo = 1;
    loadBG();
    println("bgImgNo \t"+bgImgNo);
    
  } else if(key == 'b') {
    doBorder = !doBorder;
    println("doBorder \t"+doBorder);
    
  } else if(key == 'o') {
    doObjects = !doObjects;
    println("doObjects \t"+doObjects);
    
  } else if(key == 'u') {
    FlagAddRandomBall = true;
    println("add random ball");
    
  } else if(key == 'p') {
    doPhone = !doPhone;
    println("doPhone \t"+doPhone);
    if(doPhone) phone.start();
    else phone.quit();
    
  } else if(key == 'k') {
    printMore = !printMore;
    println("printMore \t"+printMore);
    
  } else if(key == 'g') {
    doGlow = !doGlow;
    println("doGlow \t"+doGlow);
    
  } else if(key == 'y') {
    logData("output");
  } else if(key == 'z') {
    highscore = 0;
    println("cleared highscore");
    
  } else if(key =='q') {
    Date d = new Date();
    DateFormat niceFormat = new SimpleDateFormat("yyyyMMdd-HHmmss");
    saveFrame("img/21o_2013_"+niceFormat.format(d)+".png"); 
    println("printed frame");
  }
}

void mouseReleased() {
  Ball b = new Ball(ballcount++,mouseX,mouseY,(int)(random(1,5)));
//  b.setOriginalDiameter(0.020);
  b.setOriginalDiameter(random(0.01, 0.03));
  balls.add(b);
}

void mouseDragged() {
//  println( mouseX/(float) sw+ " / "+mouseY/(float) sh);
}

void addRandomBall() {
  Ball b = new Ball(ballcount++,(int) random(100,width-100),0, (int) random(1,5));
  b.b.setVelocity(random(-200.0, 200.0), 300);
  balls.add(b);
}



void addBigBall() {
  Ball b = new Ball(ballcount++,(int) random(width/4,3*width/4),0, 11);
  b.shrink = false;
  b.b.setVelocity(random(-300.0, 300.0), 300);
  b.b.setGroupIndex(-1);
  b.setOriginalDiameter(0.2);
  b.b.setRestitution(1);
  b.b.setDensity(1.0);
  b.aging = 0.002;
  balls.add(b);
}
