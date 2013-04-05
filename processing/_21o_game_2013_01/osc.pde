import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

  
void startOSC() {
  oscP5 = new OscP5(this,4111);
  myRemoteLocation = new NetAddress("127.0.0.1",4111);
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage msg) {
//  msg.print();

    int id = msg.get(0).intValue() -1;
    
    if(msg.checkAddrPattern("/high")) {            // HIGHPOINT
//      if(id < swings.size()) {
//        Swing s = (Swing) swings.get(id);
//        s.hit();    // msg.get(1).stringValue()
//        if(printInput) println("osc: "+id+ " HIGHPOINT! ");
//      }
      
      
    } else if(msg.checkAddrPattern("/var")) {      // VAR
//      if(id < swings.size()) {
//        Swing s = (Swing) swings.get(id);
//        int av = msg.get(1).intValue();
//        int sv = msg.get(2).intValue();
////        s.setActive(av == 1);  
//        if(printInput) println("osc: "+id+ " VAR: "+av+" / "+sv);
//      }
  //    s.sync = msg.get(2).intValue();
      
    } else if(msg.checkAddrPattern("/amp")) {      // AMPLITUDE
      int val = msg.get(1).intValue();
      if(id >= 18 && id <=20) id-=3;
      if(id >= 0 && id < swings.size()) {
          try {
            Swing s = (Swing) swings.get(id);
            // val between  -90 and 90.. .map to  radians ... -1.5 to 1.5
            s.inputValue(PI*(val/180.0));    
            if(printInput) println("osc: "+id+ " AMP: "+val);
          } catch (Exception e) {
            logData("osc.swings.get("+id+")");
            e.printStackTrace();
          }
      }
    }
  

  
}

