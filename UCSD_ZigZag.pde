import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.LinkedList;

import org.apache.log4j.PropertyConfigurator;

import com.rapplogic.xbee.api.PacketListener;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.wpan.RxResponseIoSample;

// XBee related
XBee xbee;
Queue<XBeeResponse> queue = new ConcurrentLinkedQueue<XBeeResponse>();
boolean message;
XBeeResponse response;

// signal strength related
int minSig = 26;
int maxSig = 92;
int currentSig = 0;

// application configuration
JSONObject jsonConfig;

Queue<Integer> lastPackets = new LinkedList<Integer>();

void updateQueue(int signalStrength)
{
  lastPackets.add(signalStrength);
  
  while (lastPackets.size() > 100)
    lastPackets.remove();
}

void drawSignalStrength()
{
  int x1 = 0, increment = width / 100;
  x1 -= increment; // hack to use iterator below
  int lastStrength = lastPackets.peek();
  for (Integer strength : lastPackets)
  {
    line(x1, 100 + lastStrength, x1 + increment, 100 + strength);
    x1 += increment;
    lastStrength = strength;
  }
  
}
  
void setup()
{
  // create an empty list
  for (int i = 0; i < 100; ++i)
  {
    lastPackets.add(0);
  }
  
  // load configuration
  jsonConfig =  loadJSONObject("config.json");
  String serialPortName = jsonConfig.getString("SerialPort");
  
  // make it full screen when using a cellphone
  size(640, 480);
   
  try { 
    //optional.  set up logging
    PropertyConfigurator.configure(dataPath("") + "log4j.properties");

    xbee = new XBee();
    // replace with your COM port
    xbee.open(serialPortName, 9600);
    xbee.addPacketListener(new PacketListener() {
      public void processResponse(XBeeResponse response) {
        queue.offer(response);
      }
    }
    );
  } 
  catch (Exception e) {
    System.out.println("XBee failed to initialize");
    e.printStackTrace();
    System.exit(1);
  }
}

void draw() {
  try {
    readPackets();
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  
  // updates signal strenght range
  if (currentSig < minSig)
    minSig = currentSig;
  if (currentSig > maxSig)
    minSig = currentSig;
    
   // background
   background(map(currentSig, minSig, maxSig, 255, 0), 0 , 0);//map(currentSig, minSig, maxSig, 255, 0));
   
   // print wifi signal image   
   fill(0);
   stroke(0,0,0);
   arc(width/2, 3*height/4, height, height, PI + QUARTER_PI, PI + 3*QUARTER_PI);
   fill(255);
   stroke(255,255,255);
   float range = map(currentSig, minSig, maxSig, height, 0);
   arc(width/2, 3*height/4, range, range, PI + QUARTER_PI, PI + 3*QUARTER_PI);
   
   // print signal strength
   stroke(255,255,255);
   textAlign(CENTER);
   text(currentSig, width/2, 3*height/4 + 20); 
   
   // print signal chart
   drawSignalStrength();
}

void readPackets() throws Exception {
  while ((response = queue.poll()) != null)
  {
  //  println("THIS IS A TEST " + response.getClass());
    // we got something!
    try {
      if (response.getApiId() == ApiId.ZNET_RX_RESPONSE)
      {
        ZNetRxResponse znetResponse = (ZNetRxResponse) response;
        AtCommand at = new AtCommand("DB");
        xbee.sendAsynchronous(at);
      }
      else if (response.getApiId() == ApiId.AT_RESPONSE)
      {
          // RSSI is only of last hop
          currentSig = ((AtCommandResponse)response).getValue()[0];
          updateQueue(currentSig);
      }
      else
      {
        // we didn't get an AT response
        println("expected RSSI, but received " + response.toString());
      }
    }
    catch (ClassCastException e) {
      // not an IO Sample
      println("Class cast exception");
    }
  }
}