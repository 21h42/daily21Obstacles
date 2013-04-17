
class Effects {
  
  ArrayList radiations;  // radiations
  ArrayList particles;
  Row[] rows = new Row[6];              // row effects
  ArrayList winpoints;
  
  int maxParticles = 400;
  int maxRadiation = 20;
  int maxWinPoints = 20;
  
  Effects() {
    radiations = new ArrayList();
    particles = new ArrayList();
    winpoints = new ArrayList();
    
    for(int i=0; i<6; i++) {
      rows[i] = new Row(i,getY(heightFloor[i]-0.02));
    }
  }
  
  void update() {
    if(radiations.size() > 0) {
      for(int i=radiations.size()-1; i>= 0; i--) {
        Radiation p = (Radiation) radiations.get(i);
        p.run();
        if(p.dead()) {
          radiations.remove(i);
        }
      }
    }
    if(particles.size() > 0) {
      for(int i=particles.size()-1; i>= 0; i--) {
        Sparkle s = (Sparkle) particles.get(i);
        s.run();
        if(s.dead()) {
          particles.remove(i);
        }
      }
    }
    
    if(winpoints.size() > 0) {
      for(int i=winpoints.size()-1; i>= 0; i--) {
        winPoints w = (winPoints) winpoints.get(i);
        w.run();
        if(w.dead()) {
          winpoints.remove(i);
        }
      }
    }
    
    for (int i=1; i<6; i++) rows[i].update();
    
    if(particles.size() > maxParticles) {
      // kill the first 10
      for(int i=50; i>= 0; i-=5) {
        particles.remove(i);
      }
    }
    if(radiations.size() > maxRadiation) {
      // kill the first 10
      for(int i=10; i>= 0; i-=2) {
        radiations.remove(i);
      }
    }
    if(winpoints.size() > maxWinPoints) {
      // kill the first 10
      for(int i=10; i>= 0; i-=2) {
        winpoints.remove(i);
      }
    }
  }
  
  void addRadiation(float xx, float yy, color cc) {
    radiations.add(new Radiation(xx, yy, cc));
  }
  
  void addWinPoints(float xx, float yy) {
    winpoints.add(new winPoints(xx, yy, points_target[level] + ".png"));
  }
  
  void addSparkles(float xx, float yy) {
    for(int i=0; i<10; i++) {
      particles.add(new Sparkle(xx+random(-10,10), yy+random(-10,10)));
    }
  }
  
  void sparkleRain() {
    for(int i=0; i<600; i++) {
      Sparkle s = new Sparkle(random(0,width), random(0,height/4));
      s.fadeSpeed = 0.005;
      s.timer = random(0.6,1.0);
      particles.add(s);
    }
  }
  
  void drawSymbol() {
    
    
  }
  
  void drawRadiation() {
    if(radiations.size() > 0) {
      for(int i=radiations.size()-1; i>= 0; i--) {
        Radiation p = (Radiation) radiations.get(i);
        p.render();
      }
    }
  }
  
  void drawSparkles() {
    
    if(particles.size() > 0) {
      for(int i=particles.size()-1; i>= 0; i--) {
        Sparkle s = (Sparkle) particles.get(i);
        s.render();
      }
    }
  }
  
  void drawWinPoints(float resScale, float _alpha) {
    if(winpoints.size() > 0 && _alpha>0) {
      for(int i=winpoints.size()-1; i>= 0; i--) {
        winPoints w = (winPoints) winpoints.get(i);
        w.render(resScale, _alpha);
      }
    }
  }
  
  void drawRows() {
    for (int i=1; i<6; i++) rows[i].render();
  }
  
}


class Row {
  float timer = 0.0;
  float speed = 0.03;
  float y;
  
  int id;
  color c;
  
  float h;
  int stripes = 40;
  int startS = 0;
  int endS = 0;
  int vis = 80;
  float th = 0.01;
  
  Row(int ii,float yy) {
    // println("new row "+yy);
    id = ii;
    y = yy;
//    timer = 1.0;
    h = getY(0.14);
    c = setColor(id);
  }
  
  void render() {
    pushMatrix();
    translate(0,y);
    // draw BG
    noStroke();
    fill(c);
//    rect(0,0,width,h);
    // draw shapes
    if(startS<endS) {
      float sw = getX(th);
      float dp = getX(0.02);
//      println("render "+startS+ " > "+endS);
      for(int j=startS; j<endS; j++) {
        pushMatrix();
        translate(j*width/(float)stripes,0);
        beginShape();
        vertex(0, h);
        vertex(sw, h);
        vertex(sw+dp, 0);
        vertex(dp, 0);
        endShape(CLOSE);
        popMatrix();
      }
    }
    popMatrix();
  }
  
  void update() {
    if(timer>0) {
//      println("timer : "+timer);
      timer-=advance(speed);
      endS = (int) ((1.0 - timer)*(stripes+vis));
      startS = endS - vis;
//      println(id+" : "+startS+" > "+endS);
      if(startS < 0 ) startS = 0;
      if(endS > stripes) endS = stripes;
      if(timer<=0) {
        timer = 0;
        startS = 0;
        endS = 0;
      }
    }
  }
  
  void animate() {
    timer = 1.0;
  }
  
  void animate(color cc) {
//    println("row "+id+" animate(cc) ");
    c = color(red(cc),green(cc),blue(cc));
    timer = 1.0;
  }
}

class Radiation {
  
  float dm = getX(0.05);;
  float ddm = 0.1;
  
  color c;
  
  float timer = 1.0;
  float speed = 0.2;
  
  float x;
  float y;
  
  Radiation(float xx, float yy, color cc) {
    x = xx;
    y = yy;
    c = cc;
    timer = 1.0;
  }
  
  void render() {
    pushMatrix();
    translate(x,y);
    noStroke();
    fill(c,50*timer);
    float newDm = dm * (1 + (1-timer)*0.3);
    ellipse(0,0,newDm*(1+3*ddm),newDm*(1+3*ddm));
    fill(c,150*timer);
    ellipse(0,0,newDm*(1+ddm),newDm*(1+ddm));
    fill(c,255*timer);
    ellipse(0,0,newDm,newDm);
    popMatrix();
  }
  
  void run() {
    timer -= advance(speed);
  }
  
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
  
}


class winPoints {
  
  PImage img;
  
  float x;
  float y;
  
  float timer;
  float fadeSpeed = 0.025;
  
  winPoints(float xx, float yy, String filename) {
    x = xx;
    y = yy;
    img = loadImage(filename);
    timer = 0.0;
  }
  
  void render(float scaleRes, float _alpha) {
    pushMatrix();
    translate(x,y);
    float scaleV;
    if(timer > 1.0) {
      // fade out again
      scaleV = scaleRes;
      tint(255, ((1.2-timer)*255*5)*_alpha);
    } else {
      // scale in, fade in
      scaleV = timer * scaleRes;
      tint(255, (255*scaleV)*_alpha);
    }
    image(img, -img.width*scaleV/2.0, -img.height*scaleV/2.0, img.width*scaleV, img.height*scaleV);
    popMatrix();
  }
  
  void run() {
    timer += advance(fadeSpeed);
  }
  
  boolean dead() {
    if (timer >= 1.2) {
      return true;
    } else {
      return false;
    }
  }
  
}

class Sparkle {
  PVector loc;
  PVector vel;
  PVector acc;
  float r;    // radius
  float timer;
  float fadeSpeed = 0.02;
  

  Sparkle(float px, float py) {
    acc = new PVector(0,random(0.01, 0.03),0);
    vel = new PVector(random(-1,1),random(0,-1),0);
    loc = new PVector(px,py,0);
    r = getX(0.003);
    timer = 1.0;
  }

  void run() {
    vel.add(acc);
    loc.add(vel);
    timer -= advance(fadeSpeed);
  }

  // Method to display
  void render() {
    ellipseMode(CENTER);
    noStroke();
    if(doGlow) {
      fill(255,timer*255*0.5);
      ellipse(loc.x,loc.y,timer*r*2,timer*r*2);
    }
    fill(255);
    ellipse(loc.x,loc.y,timer*r,timer*r);
  }
  
  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

