import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.apache.log4j.PropertyConfigurator;

import com.rapplogic.xbee.api.PacketListener;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.wpan.RxResponseIoSample;

XBee xbee;
Queue<XBeeResponse> queue = new ConcurrentLinkedQueue<XBeeResponse>();
boolean message;
XBeeResponse response;
  
void setup() {
  try { 
    //optional.  set up logging
    PropertyConfigurator.configure(dataPath("") + "log4j.properties");

    xbee = new XBee();
    // replace with your COM port
    xbee.open("/dev/tty.usbmodem14231", 9600);
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
}

void readPackets() throws Exception {
  while ((response = queue.poll()) != null) {
    println("THIS IS A TEST " + response.getClass());
    // we got something!
    try {
      if (response.getApiId() == ApiId.ZNET_RX_RESPONSE) {
        ZNetRxResponse znetResponse = (ZNetRxResponse) response;
        AtCommand at = new AtCommand("DB");
        xbee.sendAsynchronous(at);
      } else if (response.getApiId() == ApiId.AT_RESPONSE) {
          // RSSI is only of last hop
          println("RSSI of last response is " + -((AtCommandResponse)response).getValue()[0]);
      } else {
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