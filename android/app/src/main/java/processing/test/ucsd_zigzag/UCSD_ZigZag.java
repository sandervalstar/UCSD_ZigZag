package processing.test.ucsd_zigzag;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Queue; 
import java.util.concurrent.ConcurrentLinkedQueue; 
import org.apache.log4j.PropertyConfigurator; 
import com.rapplogic.xbee.api.PacketListener; 
import com.rapplogic.xbee.api.XBee; 
import com.rapplogic.xbee.api.XBeeResponse; 
import com.rapplogic.xbee.api.wpan.RxResponseIoSample; 

import org.apache.log4j.*; 
import org.apache.log4j.chainsaw.*; 
import org.apache.log4j.config.*; 
import org.apache.log4j.helpers.*; 
import org.apache.log4j.jdbc.*; 
import org.apache.log4j.jmx.*; 
import org.apache.log4j.lf5.*; 
import org.apache.log4j.lf5.util.*; 
import org.apache.log4j.lf5.viewer.*; 
import org.apache.log4j.lf5.viewer.categoryexplorer.*; 
import org.apache.log4j.lf5.viewer.configure.*; 
import org.apache.log4j.net.*; 
import org.apache.log4j.nt.*; 
import org.apache.log4j.or.*; 
import org.apache.log4j.or.jms.*; 
import org.apache.log4j.or.sax.*; 
import org.apache.log4j.pattern.*; 
import org.apache.log4j.spi.*; 
import org.apache.log4j.varia.*; 
import org.apache.log4j.xml.*; 
import gnu.io.*; 
import com.rapplogic.xbee.*; 
import com.rapplogic.xbee.test.*; 
import com.rapplogic.xbee.util.*; 
import com.rapplogic.xbee.examples.*; 
import com.rapplogic.xbee.examples.wpan.*; 
import com.rapplogic.xbee.examples.zigbee.*; 
import com.rapplogic.xbee.api.*; 
import com.rapplogic.xbee.api.wpan.*; 
import com.rapplogic.xbee.api.zigbee.*; 
import com.rapplogic.xbee.socket.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class UCSD_ZigZag extends PApplet {



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
  
public void setup()
{
  // load configuration
  jsonConfig =  loadJSONObject("config.json");
  String serialPortName = jsonConfig.getString("SerialPort");

  // make it full screen when using a cellphone
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

public void draw() {
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
}

public void readPackets() throws Exception {
  if ((response = queue.poll()) != null)
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
  public void settings() {  size(640, 480); }
}
