void createBuilding() {
  
  float fl = 0.031;  // half of floor thickness
  float floorth = getY(fl*1.7);
  heightFloor[0] = 0.272;
  heightFloor[1] = 0.362;
  heightFloor[2] = 0.497;
  heightFloor[3] = 0.631;
//  heightFloor[4] = 0.762;
//  heightFloor[5] = 0.897;
  heightFloor[4] = 0.765;
  heightFloor[5] = 0.9;

  int parts = 0;
  float sx = 0;
  float wx = 100;
  int th = 0;
  for(int i=0; i<6; i++) {
    rows[i] = new Row(i,getY(heightFloor[i]-0.02));
    parts = floorParts[i].length / 2;
    if(parts>0) {
    for(int j=0; j<parts; j++) {
      sx = floorParts[i][j*2];
      wx = floorParts[i][j*2+1]-floorParts[i][j*2];
//      rect(getX(sx),getY(heightFloor[i]-floorH),getX(wx),getY(floorH*2));
      th = (i==0) ? (int) (floorth/5) : (int) floorth;
      walls.add(new Wall((int) getX(wx), th, (int) getX(sx), (int) getY(heightFloor[i]-fl) ,0));
    }
    }
  }

}


class Shooter {
  
  int id;
  PShape full;
  float xpos;
  float ypos;
  int direction;  // either 1 or -1
  float scF;
  
  FBox bar;  // blocking balls
  
  float moveX;  // movement along x axis. push and spring
  float startX;
  float moveF;  // 
  float timer;
  float speed = 0.005;

  
  String command;
  String phone;
  boolean launchBall = false;
  color c;
  
  ArrayList queue;  // queue for incoming text messages
  
  Shooter(int ii, float xx, float yy, String cc) {
    id = ii;
    c = setColor(id+1);
    if(id+1 == 1) c = color(57,205,207);
    if(id+1 == 5) c = color(0,200,0);
    xpos = xx;
    ypos = yy;
    startX = getX(0.06);
    moveX = getX(0.05);
    command = cc;
    moveF = 0.0;
    timer = 0;
    
    queue = new ArrayList();
    
    direction = (xx<50) ? 1 : -1;
    full = loadShape("shooter.svg");
    full.disableStyle();
    scF = getX(0.1) / full.width;

    bar = new FBox(full.width*scF*0.89,full.height*scF*0.5);  // getX(0.02),getX(0.05)
    bar.setPosition(xpos+(full.width/2)*scF*direction-startX*direction+moveX*moveF*direction,ypos+(full.height*0.5)*scF);
    bar.setFill(255,0,0);
    bar.setDrawable(false);
    bar.setGroupIndex(-1);
    bar.setStaticBody(true);
    world.add(bar);
    
  }
  
  void render() {
    pushMatrix();
    translate(xpos-startX*direction+moveX*moveF*direction,ypos);
    fill(255);
    noStroke();
    shape(full,0,0,full.width*scF*direction, full.height*scF);
    
    fill(c);
//    if(direction>0) textAlign(LEFT); else textAlign(RIGHT);
    if(timer>0.1 && timer< 0.8) {
      if(sw==2688) textFont(apercu24,24); else textFont(apercu24,12);
      if(direction>0) text(phone, (full.width*0.33)*scF*direction, (full.height*0.6)*scF);
      else text(phone, (full.width*0.84)*scF*direction, (full.height*0.6)*scF);
    } else if(timer<=0.1 || timer>=0.85) {
      if(sw==2688) textFont(frank24,24); else textFont(frank24,12);
      if(direction>0) text(command+"!", (full.width*0.62)*scF*direction, (full.height*0.6)*scF);
      else text(command+"!", (full.width*0.84)*scF*direction, (full.height*0.6)*scF);
    }
    
    textAlign(LEFT); 
    popMatrix();
  }
  
  void launch(String input) {
    String pno = input;
    if(pno.charAt(0) == '1') pno = pno.substring(1);
    pno = pno.substring(0,3) + " XXX "+pno.substring(6);
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
    Ball b = new Ball(ballcount++,xpos+(full.width*0.8)*scF*direction,ypos+(full.height*0.5)*scF,id+1);
    if(id+1 == 1) {
      b.b.setVelocity(random(60,120)*direction,random(-100,-60));
      b.setDiameter(0.006);
      // add more if POP
      for(int i=0; i<2; i++) {
        Ball bb = new Ball(ballcount++,xpos+(full.width*0.8)*scF*direction,ypos+(full.height*0.5)*scF,7+i);
        b.b.setVelocity(random(60,120)*direction,random(-100,-60));
        bb.setDiameter(0.006);
        balls.add(bb);
      }
    }
    
    int updown = (random(0,2) > 1) ? 1 : -1;
    updown = 1;
    
    switch(id+1) {
      // POP
      case 1: 
              break;
      // GO
      case 2: b.b.setVelocity(140.0*direction,random(-150,150));
              break;
       // ZOU
      case 3: b.b.setVelocity(400.0*direction,0);                      // straight and fast
              break;
//      case 4: b.b.setVelocity(100.0*direction,random(-50,50));    
//              break;
      // KICK
      case 4: b.b.setVelocity(random(180,300)*direction,-200);      // upwards kick
              break;
      case 5: b.b.setVelocity(random(70,120)*direction,random(90,150));  // heavy, bigger, less bouncy
              b.b.setRestitution(0.6);
              b.setDiameter(0.013);
              break;
       // BOING
      case 6: b.b.setVelocity(random(90.0,130)*direction,-300); // bounce up and down / set bouncier?
              b.b.setRestitution(0.97);
              break;
//      case 8: b.b.setVelocity(random(140.0,160)*direction,random(-100.0,-80)); 
//              break;
      default: b.b.setVelocity(100.0*direction,updown*50);
      break;
    }
    balls.add(b);
  }
  
  void update() {
    if(timer>0) {
      timer -= advance(speed);
      if(timer > 0.9) {
        moveF = 0.6 - (timer-0.9)*6;
      } else if(timer < 0.08) {
        moveF = 1.0 -(0.08-timer)*12;
      } else if(timer < 0.1) {
        if(launchBall) {
          release();
          launchBall=false;
        }
        moveF = 0.8 +(0.1-timer)*10;
      
      } else {
        
        moveF = 0.6;
      }
      if(timer <= 0) {
        timer = 0;
        moveF = 0.0;
        // done with number
        queue.remove(0);
        nextInQueue();
      }
//      moveF -= 0.01;
//    if(moveF<0) moveF = 0;
       try {
        bar.setPosition(xpos+(full.width/2)*scF*direction-(startX)*direction+moveX*moveF*direction,ypos+(full.height*0.5)*scF);
      } catch (AssertionError e) {
        logData("Swing.update setPosition()");
      }
      
    }
  }
  
}



class Wall {

  FBox wall;
  
  Wall(int w, int h, int x, int y, float r) {
    wall = new FBox(w,h);
    wall.setStaticBody(true);
    wall.setName("wall");
    wall.setNoStroke();
    wall.setFill(0,200,200);
    wall.setDrawable(false);
    wall.setPosition(x+w/2,y+h/2);
    
    wall.setGroupIndex(-1);
    
    wall.setRestitution(0.0);
    wall.setDamping(0.0);
    wall.setFriction(0.0);
    
    wall.setRotation(r);
    world.add(wall);
  }
  
}
