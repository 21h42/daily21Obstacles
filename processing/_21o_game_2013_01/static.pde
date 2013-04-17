

class Graphics {
  
  float resScale = 1.0f;
  // scale depends on display resolution 
  // (full 2688 or smaller 1920 or test 1344)
  
  float levelEndTimer = 0;
  float levelStartTimer = 0;
  float transitionSpeedEnd = 0.003;  // 5.5 seconds?
  float transitionSpeedStart = 0.01;  // 
  float transitionFade = 1;
  
  // for level-start animation, values that indicate how many x will be displayed
  float showTargets = 1.0;
  float showSwings = 1.0;
  float showOutlets = 1.0;
  
  boolean idleScreen = false;
  
  boolean drawSwings = true;
  color bgColor = color(255);
  float bgAlpha = 1;
  
  // language
  boolean e = false;   // true.. english  false.. french
  float languageTimer = 1.0;
  float languageSpeed = 0.004;
  
  PImage[] facade;        // background images
  PImage logo;
  PImage bigBall;
  
  Outlet[] outlets;
  
  // position of zap/ kick / pop/ go/
  float outlet_posx[] = { 
    0.076, 0.172, 0.6415, 0.7845
  };
  
  String outlet_text[] = {
    "zap", "pop", "kick", "go"
  };
  
  Graphics() {
    
  }
  
  void init() {
    resScale = sw/2688.0;
    loadBG();
    logo = loadImage("title.png");
    bigBall = loadImage("level_cleared_ball.png");
    println("init Graphics: \t resolution Scale \t"+resScale);
    
    outlets = new Outlet[4];
    for(int i=0; i<4; i++) {
       outlets[i] = new Outlet(i+1, getX(outlet_posx[i]), getY(0.29), "flag_"+outlet_text[i]+".png"); 
    }
  }
  
  void update() {
     // switchLanguage();
    
     // update animation counter 
     if(levelEndTimer > 0) {
       // END OF LEVEL ANIMATION
       levelEndTimer -= advance(transitionSpeedEnd);
       
       // fade out all elements
       transitionFade = (levelEndTimer>0.8) ? (levelEndTimer-0.8)*5 : 0;
       
       // fade out bg images to white
       bgAlpha = (levelEndTimer < 0.1) ? levelEndTimer*10 : 1;
       
       if(levelEndTimer <= 0) {
         levelEndTimer = 0;
         FlagStartLevel = true;
       }
     } else if(levelStartTimer > 0) {
       // START OF LEVEL ANIMATION
       transitionFade = 1;
       levelStartTimer -= advance(transitionSpeedStart);
       
       // fade in all elements
       transitionFade = (levelStartTimer>0.8) ? 1-(levelStartTimer-0.8)*5 : 1;
       
       // fade in bg image from white
       bgAlpha = (levelStartTimer > 0.9) ? (1-levelStartTimer)*10 : 1;
       
       showTargets = (levelStartTimer > 0.8) ? 0 : (levelStartTimer < 0.4) ? 1 : 1-(levelStartTimer-0.4)*2.5;
       showSwings = (levelStartTimer > 0.4) ? 0 : (levelStartTimer < 0.2) ? 1 : 1-(levelStartTimer-0.2)*5;
       showOutlets = (levelStartTimer > 0.2) ? 0 : (levelStartTimer < 0.1) ? 1 : 1-(levelStartTimer-0.1)*10;
       
       if(levelStartTimer <= 0) {
         levelStartTimer = 0;
       }
     }
     
     if(idle) {
       float mapIdle = map(inIdleTime, 0, inIdleTimeMax, 0, 1);
       transitionFade = (mapIdle>0.95) ? (mapIdle-0.95)*20 : (mapIdle<0.05) ? 1-(mapIdle*20) : 0;
       idleScreen = (mapIdle < 0.95 && mapIdle > 0.05) ? true : false;
     }
     
     // effects: sparkles, row, radiation update
     if (doEffects) effects.update();      
     
     // outlet update
     for(int i=0; i<4; i++) outlets[i].update();
  }
  
  void render() {
    
    background(bgColor);
    
    tint(255,bgAlpha*255);
    image(facade[level], 0, 0, sw, sh);  // sw,sh facade.width,facade.height
  
    drawLogo(); 
    
    if(idleScreen) {
      drawIdleInstructions();
      
    } else {
      if(levelStartTimer <= 0) drawInstructions(transitionFade);
      drawOutlets(transitionFade);
  //    drawFramerate();
      
      drawHighscore(transitionFade);
      if(levelEndTimer > 0 && levelEndTimer < 0.8) {
        drawGiantHighscore();
        drawBigBall();
      }
      
  //    if (doEffects) effects.drawRadiation();
  //    if (doEffects) effects.drawRows();
  
  
      ////////////////////////// OPENGL drawing /////////////////
      gl = pgl.beginGL();        
      drawBallHistory(transitionFade); 
      pgl.endGL();
      ////////////////////////// ------------- /////////////////
      
      drawTargets(transitionFade);
      
      ////////////////////////// OPENGL drawing /////////////////
      gl = pgl.beginGL();        
      drawSwings(transitionFade);
      drawBalls(transitionFade);
      pgl.endGL();
      ////////////////////////// ------------- /////////////////
  
      
  //    
  //    if (doEffects) effects.drawSparkles();
      if (doEffects) effects.drawWinPoints(resScale, transitionFade);
//    

    }
    if (doBorder) drawBorder();
    if (doMask) drawMask();

  }
  
  
  void loadBG() {
    facade = new PImage[numLevels];
    
    // load background for all levels
    for(int i=0; i<numLevels; i++) facade[i] = loadImage("level_"+(i+1)+".jpg");
    
    // display images once, for faster processing afterwards
    for(int i=0; i<numLevels; i++) image(facade[i], 0,0, sw, sh);
  }
  
  
  void switchLanguage() {
    languageTimer-=languageSpeed;
    if (languageTimer<=0) {
      e = !e;
      languageTimer = 1.0;
    }
  }
  
  void drawTargets(float _alpha) {
    float mapID;  // number of item, mapped btw. 0 and 1
    int targetCount = 0;
    int totalTargetCount = 0;
    for(int j=0; j<targets.length; j++) totalTargetCount += targets[j].size();
    
    if(_alpha>0) {
      for(int j=0; j<targets.length; j++) {
        for (int i=0; i<targets[j].size(); i++) {
          try {
            Target t = (Target) targets[j].get(i);
            targetCount++;
            mapID = map(targetCount, 0, totalTargetCount, 0, 1);
            if( showTargets >= 1 || mapID < showTargets) t.render(resScale, _alpha);
          } catch (Exception e) {
            logData("targets.get()");
            e.printStackTrace();
          }
        }
      }
    }
  }
  
  void drawOutlets(float _alpha) {
    if(_alpha > 0) {
      float mapID;
      for(int i=0; i<outlets.length; i++) {
        mapID = map(i, 0, outlets.length, 0, 1);
        if (showOutlets >= 1 || mapID < showOutlets) outlets[i].render(resScale, _alpha);
      }
    }
  }
  
  void drawBalls(float _alpha) {
    if(_alpha>0) {
      for (int i=balls.size()-1; i>= 0; i--) {
        try {
          Ball b = (Ball) balls.get(i);
          b.render(_alpha);
        } 
        catch (Exception e) {
          logData("balls.get()");
          e.printStackTrace();
        }
      }
    }
  }
  
  void drawSwings(float _alpha) {
    if(_alpha>0) {
      float mapID;
      for (int i=0; i<swings.size(); i++) {
        Swing s = (Swing) swings.get(i);
        mapID = map(i, 0, swings.size(), 0, 1);
        if ((showSwings >= 1 || mapID < showSwings) && drawSwings) s.render(_alpha);
      }
    }
  }
  
  void drawBallHistory(float _alpha) {
    if(_alpha>0) {
      for (int i=balls.size()-1; i>= 0; i--) {
        try {
          Ball b = (Ball) balls.get(i);
          if(traceBall) b.renderHistory(_alpha);
        } 
        catch (Exception e) {
          logData("balls.get()");
          e.printStackTrace();
        }
      }
    }
  }
  
  
  
  void drawLogo() {
    image(logo, getX(0.2425), getY(0.042), logo.width * resScale, logo.height * resScale);
  }
  
  
  void drawInstructions(float _alpha) {
    if(_alpha > 0) {
      textAlign(LEFT);
      
      if (sw==2688) textFont(apercub30, 30); 
      else if(sw==1920) textFont(apercub22, 22);
      else textFont(apercub15, 15);
      
      fill(255,_alpha*255);
      float y = getY(0.3);
      float x = getX(0.2423);
      //  if(e) text("YOUR BALL : Text GO or POP to 514 400 1156", getX(0.006), getY(0.84));
      
      String s = "VOTRE BALLE : TEXTEZ ";
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[0].toUpperCase();
      fill(setColor(1,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = ", ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[1].toUpperCase();
      fill(setColor(2,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " OU ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[2].toUpperCase();
      fill(setColor(3,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " AU 514 400 1156";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
  
  //    //  if(e) text("YOUR BALL : Text KICK or ZAP to 514 400 1156", getX(0.725), getY(0.84));
      s = "TEXTEZ ";
      fill(255,_alpha*255);
      x = getX(0.82);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[3].toUpperCase();
      fill(setColor(4,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " AU 514 400 1156";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
    }
  }
  
  void drawIdleInstructions() {
    float _alpha = 1;
    if(_alpha > 0) {
      textAlign(LEFT);
      
      if (sw==2688) textFont(apercub38, 38); 
      else if(sw==1920) textFont(apercub27, 27);
      else textFont(apercub19, 19);
      
      fill(255,_alpha*255);
      float y = getY(0.45);
      float x = getX(0.2);
      //  if(e) text("YOUR BALL : Text GO or POP to 514 400 1156", getX(0.006), getY(0.84));
      
      // french
      String s = "POUR JOUER, TEXTEZ ";
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[0].toUpperCase();
      fill(setColor(1,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = ", ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[1].toUpperCase();
      fill(setColor(2,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = ", ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[2].toUpperCase();
      fill(setColor(3,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " OU ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[3].toUpperCase();
      fill(setColor(4,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " AU 514 400 1156";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      // english
      y = getY(0.58);
      x = getX(0.23);
      
      fill(255,_alpha*255);
      s = "TO PLAY, TEXT ";
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[0].toUpperCase();
      fill(setColor(1,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = ", ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[1].toUpperCase();
      fill(setColor(2,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = ", ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[2].toUpperCase();
      fill(setColor(3,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " OR ";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
      
      s = outlet_text[3].toUpperCase();
      fill(setColor(4,_alpha));
      text(s, x, y);
      x += textWidth(s);
      
      s = " TO 514 400 1156";
      fill(255,_alpha*255);
      text(s, x, y);
      x += textWidth(s);
    }
  }
  
  void drawHighscore(float _alpha) {
    if(_alpha>0) {
      textAlign(RIGHT);
      fill(255,_alpha*255);
      
      if (sw==2688) textFont(apercum73, 73); 
      else if(sw==1920) textFont(apercum52, 52);
      else textFont(apercum37, 37);
      
      text(highscore, getX(0.665), getY(0.12));
    }
  }
  
  void drawGiantHighscore() {
    float t = levelEndTimer;
    // blinking
    if( (t<0.6&&t>0.45) || (t<0.4&&t>0.25) || (t<0.2&&t>0.05)) {
      textAlign(RIGHT);
      fill(255);
      if (sw==2688) textFont(apercum381, 381); 
      else if(sw==1920) textFont(apercum272, 272);
      else textFont(apercum190, 190);
      
      text(highscore, getX(0.5), getY(0.905));

      textAlign(LEFT);
      if (sw==2688) textFont(apercub38, 38); 
      else if(sw==1920) textFont(apercub27, 27);
      else textFont(apercub19, 19);
      
      text("SCORE :", getX(0.3), getY(0.44));
    }
  }
  
  void drawBigBall() {
    float t = levelEndTimer;
    
    float ballx = map(1-levelEndTimer,0,0.8, -0.5, 1.5);
    float bally = map(sin(ballx * 25.5),0, 2*PI, 0, 1);
    
    image(bigBall, getX(ballx), getY(bally), bigBall.width * resScale, bigBall.height * resScale);
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
  
}


class Outlet {
  
  int id;
  PImage item;
  
  float x;
  float y;
  
  float timer;
  float speed = 0.006;

  String command;
  String phone;
  boolean launchBall = false;
  color c;
  
  ArrayList queue;  // queue for incoming text messages
  
  Outlet(int ii, float xx, float yy, String filename) {
    id = ii;
    
    c = setColor(id);
    
    item = loadImage(filename);

    x = xx;
    y = yy;

    timer = 0;
    
    queue = new ArrayList();
    
  }
  
  void render(float scaleV, float _alpha) {
    if(_alpha>0) {
      tint(255,_alpha*255);
      image(item,x-item.width*scaleV/2.0,y-item.height*scaleV/2.0,item.width*scaleV,item.height*scaleV);
      
      if(timer > 0.7) {
        // move ball from top
        fill(setColor(id,_alpha));
        ellipse( x, getY(-0.05 + (1-timer)*0.75), getX(oBallSize),getX(oBallSize) );
        
      } else if(timer > 0 && timer < 0.7) {
        
        // blink
        if( !(timer>0.45&&timer<0.5) && !(timer>0.2&&timer<0.25) ) {
          // static ball
          fill(setColor(id,_alpha));
          ellipse( x, getY(0.175), getX(oBallSize),getX(oBallSize) );
        
          // display phone number
          textAlign(RIGHT);
          if (sw==2688) textFont(apercub30, 30); 
          else if(sw==1920) textFont(apercub22, 22);
          else textFont(apercub15, 15);
          text(phone, x-item.width/1.6*scaleV, y+getY(0.01));
        }
      }
    }
  }
  
  void launch(String input) {
    // just last four numbers!
    String pno = (input.length()>4) ? input.substring(input.length()-4) : input;
    queue.add(new String(pno));
    if(timer <= 0) {
      nextInQueue();
    }
  }
  
  void nextInQueue() {
    if(queue.size()>0) {
      phone = (String) queue.get(0);
      if(printMore) println("launch "+phone+ " into "+id+"|"+command);
      timer = 1.0;
      launchBall = true;
    }
  }
  
  void release() {
    Ball b = new Ball(ballcount++,x, getY(0.175),id);  
    b.b.setVelocity(random(-200.0, 200.0), 300);
    balls.add(b);
    highscore += points_msg;
    setTraceLength();
  }
  
  void update() {
    if(timer>0) {
      timer -= advance(speed); 

      if(timer <= 0) {
        release();
        timer = 0;
        // done with number
        queue.remove(0);
        nextInQueue();
      }
    }
    

  }
  
}

