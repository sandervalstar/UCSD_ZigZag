import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.apache.log4j.PropertyConfigurator;

import com.rapplogic.xbee.api.PacketListener;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.wpan.RxResponseIoSample;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.TimeUnit;

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

Queue<Long> timestampsQueue = new ConcurrentLinkedQueue<Long>();
long roundTripDistance = 0;

// application configuration
JSONObject jsonConfig;

/* 
  * Example Message types for reference

  * Tx Request with "testing" payload
    0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFE, 0x00, 0x00, 0x74, 
    0x65, 0x73, 0x74, 0x69, 0x6E, 0x67
 
  * Remote ATAS
    0x17, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFE, 0x02, 0x41, 0x53

  * Remote ATDB
    0x17, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFE, 0x02, 0x44, 0x42
    
*/

/*
  Remote at request for RSSI. This message is broadcast to all nodes in the same PanID
  Packet frame generated from XCTU
*/
XBeePacket remoteAtRequest = new XBeePacket(new int[]{0x17, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFE, 0x02, 0x44, 0x42});

void setup()
{
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
        println("process response " + response.getApiId());
        queue.offer(response);
      }});

  // This sleep is a hack to wait for the packet listener to register
  Thread.sleep(5000);
  println("going to send first remote at request");
  xbee.sendPacket(remoteAtRequest);
  println("sent");
  
  // schedule executor service to poll responses and send again every second
  // TODO maybe a better way to do this
  ScheduledExecutorService scheduledExecutorService =
        Executors.newScheduledThreadPool(1);
  Runnable run = new Runnable() {
    public void run() {
      try {
        readPackets();
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  };
  scheduledExecutorService.scheduleAtFixedRate(run, 0, 1,  TimeUnit.SECONDS);
  } catch (Exception e) {
    System.out.println("XBee failed to initialize");
    e.printStackTrace();
    System.exit(1);
  }
}

void draw() {
  
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
   text(roundTripDistance, width/2, 3*height/4 + 50);
}

/**
 This method is called to poll for any current responses and send another AT request for RSSI.
 Another request is sent only when the previous reseponse was processed. 
 TODO: This may be slow and non responsive
 TODO: This doesn't filter if there are multiple devices
*/
void readPackets() throws Exception {
  if ((response = queue.poll()) != null) {
    println("THIS IS A TEST " + response.getApiId());
    if (response.getApiId() == ApiId.REMOTE_AT_RESPONSE) {
      RemoteAtResponse atResponse = (RemoteAtResponse) response;
      // print remote address
      println("remote at response received, remote address: " + atResponse.getRemoteAddress16());
      if (atResponse.getValue().length > 0) {
        println("RSSI: " + atResponse.getValue()[0]);
        currentSig = atResponse.getValue()[0];
      }
    }
    xbee.sendPacket(remoteAtRequest);
    println("sent again");
  }
}