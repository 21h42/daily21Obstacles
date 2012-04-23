/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import processing.video.*; 
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

boolean recording = false;
MovieMaker mm;


int sno = 21;  // number of swings
Swing[] swings;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,4111);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",4111);
  
  swings = new Swing[sno];
  for(int i=0; i<sno; i++) {
    swings[i] = new Swing(i);
    swings[i].setXY(100 + (i%3)*100, 50 + (i/3)*50);
  }
  
  mm = new MovieMaker(this, width, height, "swviz_paddle.mov", 25, MovieMaker.ANIMATION, MovieMaker.BEST);

  
  rectMode(CENTER);
  smooth();
}


void draw() {
  background(255);  
  for(int i=0; i<sno; i++) {
    swings[i].draw();
  }
   if(recording) mm.addFrame();
}

void mousePressed() {
  /* in the following different ways of creating osc messages are shown by example */

}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
//  theOscMessage.print();
//  int firstValue = theOscMessage.get(0).intValue();  
//  float secondValue = theOscMessage.get(1).floatValue();
//  String thirdValue = theOscMessage.get(2).stringValue();
      
  if(theOscMessage.checkAddrPattern("/high")) {
//    println("HIGHPOINT");
    int id = theOscMessage.get(0).intValue();
    swings[id-1].hit(theOscMessage.get(1).stringValue());
//    println(theOscMessage.get(1).stringValue());
  } else if(theOscMessage.checkAddrPattern("/var")) {
//    println("VAR");
    int id = theOscMessage.get(0).intValue();
    swings[id-1].active = theOscMessage.get(1).intValue();
    swings[id-1].sync = theOscMessage.get(2).intValue();
    
  } else if(theOscMessage.checkAddrPattern("/amp")) {
//    println("AMP");
    int id = theOscMessage.get(0).intValue();
    int val = theOscMessage.get(1).intValue();
//    println(firstValue+" - "+secondValue);
    swings[id-1].amp = val;
  }
}

void keyReleased() {
  if(key == 'm') {
    recording = !recording;
    if(!recording) mm.finish();
  }
}
