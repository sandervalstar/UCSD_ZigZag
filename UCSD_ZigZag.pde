ViewManager viewManager;
import interfascia.*;

void setup()
{  
  size(480, 640);
  viewManager = new ViewManager(this);
  
  //// Measurement code
  //if (saveMeasurements)
  //{
  //  try
  //  {
  //    measurementWriter = new PrintWriter(dataPath("") + "\\" + measurementFileName,"UTF-8");
  //    savingToFile = true;
  //    numbersSaved = 0;
  //  } catch (Exception e) {
  //    savingToFile = false;
  //  } 
  //}
  
  //// load configuration
  //jsonConfig =  loadJSONObject("config.json");
  //String serialPortName = jsonConfig.getString("SerialPort");
  
  //// make it full screen when using a cellphone
  
  //// create line plots
  //rssiPlot = new LinePlot(color(255,255,255), 2, 100, 640);
  //filteredPlot = new LinePlot(color(128,128,255), 3, 100, 640);
   
  //try { 
  //  //optional.  set up logging
  //  PropertyConfigurator.configure(dataPath("") + "log4j.properties");

  //  xbee = new XBee();
  //  // replace with your COM port
  //  xbee.open(serialPortName, 9600);
  //  xbee.addPacketListener(new PacketListener() {
  //    public void processResponse(XBeeResponse response) {
  //      println("process response " + response.getApiId());
  //      queue.offer(response);
  //    }});

  //// This sleep is a hack to wait for the packet listener to register
  //Thread.sleep(5000);
  //println("going to send first remote at request");
  //xbee.sendPacket(remoteAtRequest);
  //println("sent");
  
  //// schedule executor service to poll responses and send again every second
  //// TODO maybe a better way to do this
  //ScheduledExecutorService scheduledExecutorService =
  //      Executors.newScheduledThreadPool(1);
  //Runnable run = new Runnable() {
  //  public void run() {
  //    try {
  //      readPackets();
  //    } catch (Exception e) {
  //      e.printStackTrace();
  //    }
  //  }
  //};
  //scheduledExecutorService.scheduleAtFixedRate(run, 0, 1,  TimeUnit.SECONDS);
  //} catch (Exception e) {
  //  System.out.println("XBee failed to initialize");
  //  e.printStackTrace();
  //  System.exit(1);
  //}
}

void actionPerformed(GUIEvent e) {
  this.viewManager.actionPerformed(e);
}

void mousePressed() {
  this.viewManager.mousePressed();
}

void draw() {
  viewManager.draw();
  //// updates signal strenght range
  //if (currentSig < minSig)
  //  minSig = currentSig;
  //if (currentSig > maxSig)
  //  minSig = currentSig;
    
  // // background
  // background(map(currentSig, minSig, maxSig, 255, 0), 0 , 0);//map(currentSig, minSig, maxSig, 255, 0));
   
  // // print wifi signal image   
  // fill(0);
  // stroke(0,0,0);
  // arc(width/2, 3*height/4, height, height, PI + QUARTER_PI, PI + 3*QUARTER_PI);
  // fill(255);
  // stroke(255,255,255);
  // float range = map(currentSig, minSig, maxSig, height, 0);
  // arc(width/2, 3*height/4, range, range, PI + QUARTER_PI, PI + 3*QUARTER_PI);
   
  // // print signal strength
  // stroke(255,255,255);
  // textAlign(CENTER);
   
  // text(currentSig, width/2, 3*height/4 + 20); 
  // text(roundTripDistance, width/2, 3*height/4 + 50);
   
  // // print signal chart
  // filteredPlot.draw(0, 100);
  // rssiPlot.draw(0, 100);
}

/**
 This method is called to poll for any current responses and send another AT request for RSSI.
 Another request is sent only when the previous reseponse was processed. 
 TODO: This may be slow and non responsive
 TODO: This doesn't filter if there are multiple devices
*/


//void readPackets() throws Exception {
//  if ((response = queue.poll()) != null)
//  {
//    //  println("THIS IS A TEST " + response.getClass());
//    // we got something!
//    if (response.getApiId() == ApiId.REMOTE_AT_RESPONSE)
//    {
//      // RSSI is only of last hop
//      RemoteAtResponse atResponse = (RemoteAtResponse) response;
//      // print remote address
//      //println("remote at response received, remote address: " + atResponse.getRemoteAddress16());
//      if (atResponse.getValue().length > 0)
//      {
//        //println("RSSI: " + atResponse.getValue()[0]);
//        currentSig = atResponse.getValue()[0];
//        rssiPlot.add(currentSig);
//        float smoothedSig = kalmanFilter.filter(currentSig, 0);
//        filteredPlot.add(smoothedSig);
        
//        // BEGIN Measurement code
//        if (saveMeasurements)
//        {
//          if (savingToFile)                                                             
//          {                                                                           
//            Timestamp timestamp = new Timestamp(System.currentTimeMillis());          
//            measurementWriter.println(timestamp.getTime() + "," + currentSig + "," + smoothedSig);
//            println("\n\nNumbers saved: " + ++numbersSaved);                          
//          } else {                                                                    
//            measurementWriter.close();                                                
//            saveMeasurements = false;
//          }
//        }// END Measurement code
        
        
//        currentSig = smoothedSig;
//      }
//    }
//    xbee.sendPacket(remoteAtRequest);
//    //println("sent again");
//  }
//}

//void mouseClicked()
//{
//  // Measurement code
//  if (saveMeasurements)
//  {
//    savingToFile = false;  
//  }
//}