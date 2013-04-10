
class Phone extends Thread {
  
  boolean running;
 
  String phppass = "go";
  String url = "http://21o.dailytlj.com/pull.php?pass=" + phppass;
  
  int counter = 0;
  int maxCount = 50;
  
  String phoneUser = "";
  String phoneMsg = "";
  int phoneLane = 0;
  
  Phone(int mc) {
    maxCount = mc;
    running = false;
    counter = 0;
  }
  
  void start() {
    running = true;
    println("start phone thread, every "+maxCount+" milliseconds");
    super.start();
  }
  
  void run() {
    while(running) {
      phoneUser = "";
      phoneMsg = "";
      check();
      try {
        // wait
        sleep((long) (maxCount));
      } catch (Exception e) {
      }
    }
  }
  
  void quit() {
    println("stop phone thread");
    running =false;
//    interrupt();
  }
  
  void check() {
    String lines[];
    try {
      lines = loadStrings(url);
      if(printMore) println(lines);
    } catch (Exception e) {
      lines = null;
      logData("loadstring "+url);
      e.printStackTrace();
    }
    String[] p;
      if(lines!= null && lines.length > 0) {
        for (int i=0; i < lines.length; i++) {
          try {
            p = splitTokens(lines[i], "|");
          } catch (Exception e) {
            logData("php-splitTokens");
            e.printStackTrace();
            p = new String[3];
            p[0] = "GO";
            p[1] = "5145555555";
            p[2] =  "1";
          }
          phoneUser = p.length > 1 ? p[1] : "5145555555";
          phoneMsg = p.length > 1 ? p[0] : "GO";
          try {
          phoneLane = p.length > 2 ? Integer.parseInt(p[2]) : 1;
          } catch (Exception e) {
            phoneLane = 1;
          }

          if(printMore) println("PHONE INPUT: \t '"+phoneMsg+ "' \tfrom "+phoneUser+"\tinto lane "+phoneLane);
          if(phoneLane >= 1 && phoneLane <= 4) {
            Ball b = new Ball(ballcount++,getX(outlets[phoneLane]),0, phoneLane);
            b.b.setVelocity(random(-200.0, 200.0), 300);
            highscore += points_msg;
            balls.add(b);
//            if(phoneLane<=shooters.size()) {
//              try {
//                Shooter h = (Shooter) shooters.get(phoneLane-1);
//                h.launch(phoneUser);
//              } catch (Exception e) {
//                logData("phone shooters.get("+phoneLane+")");
//                e.printStackTrace();
//              }
//            }
          } else if(phoneLane == 7) {  // BIG
//            addBigBall();
            FlagAddBigBall = true;
          } else if(phoneLane == 8) {  // xxx
            effects.sparkleRain();
          } else if(phoneLane == 9) {  // xxx
            FlagAddManyBalls = true;
//            for(int j=0; j<100; j++) addRandomBall();
          }  else if(phoneLane == 0) {  // xxx
//            initWorld();
            FlagInitWorld = true;
          }
          
        }
      }
  }

  public String getString() {
    return phoneUser + " "+phoneMsg;
  }
}
