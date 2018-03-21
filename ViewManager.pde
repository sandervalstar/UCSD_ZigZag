import java.util.concurrent.*;
import java.awt.geom.Point2D;
import interfascia.*;

class ViewManager {  
  private PApplet app;
  GUIController c;
  IFTextField t;
  IFButton joinButton;
  int MARGIN = 20;
  int MARGIN2 = 2*MARGIN;
  int MARGIN3 = 3*MARGIN;
  int DRAW_MARGIN = MARGIN3;
  int LINE_MARGIN = MARGIN3-5;
  int ARROW_LENGTH = 20;
  
  boolean USE_MOCKS = true;
  
  List<XBeeDevice> devices = new ArrayList();
  private XBeeDevice device;
  private final Object lock = new Object();
  
  private LocationEstimator locationEstimator;
  
  private String nextMove = "";
  final String L = "left";
  final String R = "right";
  final String U = "forward";
  final String D = "backward";
  
  final String HOME = "HOME";
  final String NETWORK = "NETWORK";
  final String LOCATOR = "LOCATOR";
  final String MOVEMENT_POPUP = "MOVEMENT_POPUP";
  String activeScreen = "";
      
  public ViewManager(PApplet app) {
    this.app = app;
    this.showHomeScreen();
    //this.showLocatorScreen(device);
    
    if(USE_MOCKS) {
      this.locationEstimator = new LocationEstimatorMock();
      this.device = new XBeeDeviceMock();
    } else {
      //TODO: use real impl
      this.locationEstimator = new LocationEstimatorMock();
      this.device = new XBeeDeviceMock();
    }
  };
  
  public void draw() {
    fill(color(255,255,255));
    if(LOCATOR.equals(activeScreen) || MOVEMENT_POPUP.equals(activeScreen)) {
      synchronized(lock) {
        if (device != null) {
          background(0);
          this.drawPageTitle(device.getName());
          textAlign(LEFT,BOTTOM);
          //text(this.device.getRSSI(), 100, 100);
          fill(color(255,0,0));
          ellipse(width/2, (height-2*DRAW_MARGIN)/2+DRAW_MARGIN, 10, 10);
          fill(color(255,255,255));
          List<Point2D.Float> locations = this.locationEstimator.getProbableLocations();
          drawProbableLocations(locations);
          drawMovementButtons();
          if(MOVEMENT_POPUP.equals(activeScreen)) {
            drawMovementPopup();
          }
        }
      }
    }
  }
  
  public void clearScreen() {
    this.clearHomeScreen();
  }
  
  private void drawMovementButtons() {
    line(width/2, height, width/2, height-LINE_MARGIN);
    line(width/4, height, width/4, height-LINE_MARGIN);
    line(3*width/4, height, 3*width/4, height-LINE_MARGIN);
    strokeWeight(5); 
    drawArrow(MARGIN3,height-30,ARROW_LENGTH,180f);
    drawArrow(width/2 - MARGIN3,height-MARGIN,ARROW_LENGTH,270f);
    drawArrow(width/2 + MARGIN3,height-MARGIN2,ARROW_LENGTH,90f);
    drawArrow(width-MARGIN3,height-30,ARROW_LENGTH,0f);
    strokeWeight(1); 
  }
  
  void drawArrow(int cx, int cy, int len, float angle){
    pushMatrix();
    translate(cx, cy);
    rotate(radians(angle));
    line(0,0,len, 0);
    line(len, 0, len - 8, -8);
    line(len, 0, len - 8, 8);
    popMatrix();
  }
  
  private void clearHomeScreen() {
    background(0);
    if(this.c != null) {
      this.c.remove(t);
      joinButton.setY(height+100); //hack because interfascia has a bug that doesn't let us remove buttons
    }
  }
  
  public void showHomeScreen() {
    this.activeScreen = HOME;
    background(0);
    this.drawPageTitle("ZigZag Home");
    this.drawPageSubtitle("Join a network first");    
    
    c = new GUIController(app);
    t = new IFTextField("Text Field", MARGIN, height/4, width-MARGIN2);
    joinButton = new IFButton("Join", MARGIN, height-50);
    joinButton.setWidth(width-2*MARGIN);
    joinButton.addActionListener(app);
    c.add(t);
    c.add(joinButton);
  }
  
  public void showNetworkScreen(int panId) {
    this.activeScreen = NETWORK;
    println("sdfjksdflkdsj");
    this.clearScreen();
    drawPageTitle("XBee network");
    drawPageSubtitle(""+panId);
    
    XBeeNetwork network;
    if(USE_MOCKS) {
       network = new XBeeNetworkMock(panId);
    } else {
      Antenna antenna = new AntennaImpl();
      network = new XBeeNetworkImpl(panId, antenna);
    }
    
    this.devices = network.getAllDevicesInNetwork();
    this.drawDevices();
  }
  
  private void showLocatorScreen(XBeeDevice device) {
    println("show locator screen " + device.getName());
    this.activeScreen = LOCATOR;
    this.clearScreen();
    this.device = device;
    
    if(USE_MOCKS) {
      this.locationEstimator = new LocationEstimatorMock();
    } else {
      //TODO: use real impl
      this.locationEstimator = new LocationEstimatorMock();
    }
    this.startMeasurements();
  }
  
  private void drawDevices() {
    for(int i = 0; i < this.devices.size(); i++) {
      XBeeDevice d = devices.get(i);
      textAlign(LEFT,TOP);
      text(d.getName(), 3*MARGIN, 100 + i*MARGIN2);
    }
  }
  
  public void drawPageTitle(String title) {
    textSize(20);
    textAlign(CENTER,TOP);
    text(title, width/2, 10);
  }
  
  public void drawPageSubtitle(String subtitle) {
    textSize(16);
    textAlign(CENTER,TOP);
    text(subtitle, width/2, 40);
  }
  
  void actionPerformed(GUIEvent e) {
    println("joeheo");
    if (e.getSource() == joinButton) {
      println("PanId was: "+t.getValue());
      this.showNetworkScreen(Integer.parseInt(t.getValue()));
    }
  }
  
  void mousePressed() {
    if(NETWORK.equals(activeScreen)) {
      int deviceIndex = mouseY - 100;
      deviceIndex = deviceIndex/MARGIN2;
      if(0 <= deviceIndex && deviceIndex < devices.size()) {
        println("showing location estimation page");
        this.showLocatorScreen(devices.get(deviceIndex));
        
      }        
      println("mouse presseed " + mouseY + ", index: "+deviceIndex + " " + device.getName());
    } else if (LOCATOR.equals(activeScreen)) {
      if(height-LINE_MARGIN < mouseY && mouseY < height) {
        if(0 <= mouseX && mouseX < width/4) {
          this.nextMove = L;
        } else if (width/4 <= mouseX && mouseX < width/2) {
          this.nextMove = U;
        } else if (width/2 <= mouseX && mouseX < 3*width/4) {
          this.nextMove = D;
        } else if (3*width/4 <= mouseX && mouseX <= width) {
          this.nextMove = R;
        }
        
        this.drawMovementPopup();
      }
    } else if (MOVEMENT_POPUP.equals(activeScreen)) {
      if(height/2-MARGIN2 < mouseY && mouseY < height/2) {
        if(100+MARGIN <= mouseX && mouseX < 100+MARGIN+width/2) {
          closeMovementPopup();
          doMove();
        }
      }
    }
  }
  
  
  void updateDeviceRSSI() {
    synchronized (lock) {
       if(MOVEMENT_POPUP.equals(activeScreen)) {
         println("Skipping RSSI update because of user movement");
       } else if (this.device != null) {
         //println("udpating "+device.getRSSI());    

          this.device = this.device.getNewRSSI();
          this.locationEstimator.addMeasurement("device1", this.device.getCurrentRSSI(), "device1");
       }
    }
  }   
  
  void startMeasurements() {
        // schedule executor service to poll responses and send again every second
    // TODO maybe a better way to do this
    ScheduledExecutorService scheduledExecutorService =
          Executors.newScheduledThreadPool(1);
    Runnable run = new Runnable() {
      public void run() {
        try {
          updateDeviceRSSI();
          //println("measuring");
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    };
    scheduledExecutorService.scheduleAtFixedRate(run, 0, 1,  TimeUnit.SECONDS);
    
  }
  
  
  void stopMeasurements() {
    
  } 
  
  private void drawProbableLocations(List<Point2D.Float> locations) {
    float max = Float.MIN_VALUE;
    float min = Float.MAX_VALUE;
    float sum = 0f;
    
    for(Point2D.Float p : locations) {
      if(max < p.x) max = p.x;
      if(min > p.x) min = p.x;
      if(max < p.y) max = p.y;
      if(min > p.y) min = p.y;
      sum += p.x + p.y;
    }
    
    float average = sum / (2*locations.size());
    
    float absMin = Math.abs(min);
    if(absMin > max) {
      max = absMin;
    } else {
      min = -max;
    }
    
    for(Point2D.Float p : locations) {
      ellipse(
        scalePointCoordinate(p.x, min, max, 0, width), 
        scalePointCoordinate(-p.y, min, max, DRAW_MARGIN, height-DRAW_MARGIN),
        5, 5);
    }
    
    ////draw the axis
    //fill(0,255,0);
    ////print("min: "+min+" max "+max);
    //for(float i = min; i < max; i++) {
    //  ellipse(
    //    scalePointCoordinate(i, min, max, 0, width), 
    //    scalePointCoordinate(0, min, max, DRAW_MARGIN, height-DRAW_MARGIN),
    //    5, 5);
        
    //   ellipse(
    //    scalePointCoordinate(0, min, max, 0, width), 
    //    scalePointCoordinate(-i, min, max, DRAW_MARGIN, height-DRAW_MARGIN),
    //    5, 5);
    //}
        
    
    stroke(255);
    //line(0, MARGIN2, width, MARGIN2);
    line(0, height-LINE_MARGIN, width, height-LINE_MARGIN);
  }
  
  private float scalePointCoordinate(float val, float min, float max, float targetMin, float targetMax) {
    float center = (targetMax-targetMin)/2+targetMin;
    return val < 0 ? map(val, min, 0, targetMin, center) : map(val, 0, max, center, targetMax);
  }
  
  private void drawMovementPopup() {
    this.activeScreen = MOVEMENT_POPUP;
    
    rect(100, 100, width-200, height-400, 6, 6, 6, 6);
    fill(0,0,0);
    textAlign(CENTER,TOP);
    text("Take one step " + this.nextMove, width/2, height/4);
    
    rect(100+MARGIN, height/2-MARGIN2, width/2, MARGIN2, 6, 6, 6, 6);
    fill(255,255,255);
    text("DONE",width/2,height/2-30);
  }
  
  private void closeMovementPopup() {
    this.activeScreen = LOCATOR;
  }
  
  private void doMove() {
    synchronized(lock) {
      switch(nextMove) {
        case L:
          this.locationEstimator.addUserMovement(-1f, 0f);
          break;
        case U:
          this.locationEstimator.addUserMovement(0f, 1f);
          break;
        case D:
          this.locationEstimator.addUserMovement(0f, -1f);
          break;
        case R:
          this.locationEstimator.addUserMovement(1f, 0f);
          break;
      }
    }
  }
  
}