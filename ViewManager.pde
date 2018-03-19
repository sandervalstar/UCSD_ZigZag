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
  
  List<XBeeDevice> devices = new ArrayList();
  private XBeeDevice device = new XBeeDeviceMock();
  private final Object lock = new Object();
  
  private LocationEstimator locationEstimator = new LocationEstimatorMock();
  
  final String HOME = "HOME";
  final String NETWORK = "NETWORK";
  final String LOCATOR = "LOCATOR";
  String activeScreen = "";
      
  public ViewManager(PApplet app) {
    this.app = app;
    //this.showHomeScreen();
    this.showLocatorScreen(device);
  };
  
  public void draw() {
    if(LOCATOR.equals(activeScreen)) {
      synchronized(lock) {
        background(0);
        this.drawPageTitle(device.get16BitAddress());
        textAlign(LEFT,BOTTOM);
        //text(this.device.getRSSI(), 100, 100);
        fill(color(255,0,0));
        ellipse(width/2, height/2, 10, 10);
        fill(color(255,255,255));
        List<Point2D.Float> locations = this.locationEstimator.getProbableLocations();
        drawProbableLocations(locations);
        drawMovementButtons();        
      }
    }
  }
  
  public void clearScreen() {
    this.clearHomeScreen();
  }
  
  private void drawMovementButtons() {
    //rect(30, 20, 55, 55, 3, 6, 12, 18);
    strokeWeight(5); 
    drawArrow(MARGIN3,height-30,ARROW_LENGTH,180f);
    line(10, height, 10, height-LINE_MARGIN);
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
    XBeeNetwork network = new XBeeNetworkMock(panId);
    this.devices = network.getAllDevicesInNetwork();
    this.drawDevices();
  }
  
  private void showLocatorScreen(XBeeDevice device) {
    this.activeScreen = LOCATOR;
    this.clearScreen();
    this.device = device;
    this.locationEstimator = new LocationEstimatorMock();
    this.startMeasurements();
  }
  
  private void drawDevices() {
    for(int i = 0; i < this.devices.size(); i++) {
      XBeeDevice d = devices.get(i);
      textAlign(LEFT,TOP);
      text(d.get16BitAddress(), 3*MARGIN, 100 + i*MARGIN2);
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
      println("mouse presseed " + mouseY + ", index: "+deviceIndex);
    } else if (LOCATOR.equals(activeScreen)) {
      if(height-LINE_MARGIN < mouseY && mouseY < height) {
        if(MARGIN3 <= mouseX && mouseX <= MARGIN3+ARROW_LENGTH) {
          println("click left");
        } else if (width/2 - MARGIN3 <= mouseX && mouseX <= width/2 - MARGIN3+ARROW_LENGTH) {
          println("click up");
        } else if (width/2 + MARGIN3 <= mouseX && mouseX <= width/2 + MARGIN3+ARROW_LENGTH) {
          println("click down");
        } else if (width-MARGIN3 <= mouseX && mouseX <= width-MARGIN3+ARROW_LENGTH) {
          println("click right");
        }
      }
    }
  }
  
  
  void updateDeviceRSSI() {
    synchronized (lock) {
       //println("udpating "+device.getRSSI());    
       this.device = this.device.updateRSSI();
       this.locationEstimator.addMeasurement(this.device.getRSSI());
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
    
    for(Point2D.Float p : locations) {
      ellipse(map(p.x, min, max, 0, width), map(p.y, min, max, DRAW_MARGIN, height-DRAW_MARGIN), 5, 5);
    }
    
    stroke(255);
    //line(0, MARGIN2, width, MARGIN2);
    line(0, height-LINE_MARGIN, width, height-LINE_MARGIN);
  }
  
}