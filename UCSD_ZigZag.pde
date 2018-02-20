import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

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
PImage imgSignal[];
  
void setup()
{
  // load images
  imgSignal = new PImage[4];
  for (int i = 0; i < 4; ++i)
    imgSignal[i] = loadImage("wifi_signal_" + i + ".png");
  
  // make it full screen when using a cellphone
  size(640, 480);
   
  try { 
    //optional.  set up logging
    PropertyConfigurator.configure(dataPath("") + "log4j.properties");

    xbee = new XBee();
    // replace with your COM port
    xbee.open("COM10", 9600);
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
  
  if (currentSig < minSig)
    minSig = currentSig;
  if (currentSig > maxSig)
    minSig = currentSig;
   background(map(currentSig, minSig, maxSig, 255, 0), 0 , 0);//map(currentSig, minSig, maxSig, 255, 0));
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