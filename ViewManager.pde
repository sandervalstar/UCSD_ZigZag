import interfascia.*;

class ViewManager {  
  private PApplet app;
  GUIController c;
  IFTextField t;
  IFButton joinButton;
  int MARGIN = 20;
  List<XBeeDevice> devices = new ArrayList();
  
  final String HOME = "HOME";
  String activeScreen = "";
      
  public ViewManager(PApplet app) {
    this.app = app;
    this.showHomeScreen();
  };
  
  public void draw() {
  }
  
  public void clearScreen() {
    this.clearHomeScreen();
  }
  
  private void clearHomeScreen() {
    background(0);
    this.c.remove(t);
    joinButton.setY(height+100); //hack because interfascia has a bug that doesn't let us remove buttons
  }
  
  public void showHomeScreen() {
    this.activeScreen = HOME;
    background(0);
    this.drawPageTitle("ZigZag Home");
    this.drawPageSubtitle("Join a network first");    
    
    c = new GUIController(app);
    t = new IFTextField("Text Field", MARGIN, height/4, width-2*MARGIN);
    joinButton = new IFButton("Join", MARGIN, height-50);
    joinButton.setWidth(width-2*MARGIN);
    joinButton.addActionListener(app);
    c.add(t);
    c.add(joinButton);
  }
  
  public void showNetworkScreen(int panId) {
    println("sdfjksdflkdsj");
    this.clearScreen();
    drawPageTitle("XBee network");
    drawPageSubtitle(""+panId);
    XBeeNetwork network = new XBeeNetworkMock(panId);
    this.devices = network.getAllDevicesInNetwork();
    this.drawDevices();
  }
  
  private void showLocationEstimationPage(XBeeDevice device) {
    this.clearScreen();
    this.drawPageTitle(device.get16BitAddress());
  }
  
  private void drawDevices() {
    for(int i = 0; i < this.devices.size(); i++) {
      XBeeDevice d = devices.get(i);
      textAlign(LEFT,TOP);
      text(d.get16BitAddress(), 3*MARGIN, 100 + i*2*MARGIN);
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
    int deviceIndex = mouseY - 100;
    deviceIndex = deviceIndex/(2*MARGIN);
    if(0 <= deviceIndex && deviceIndex < devices.size()) {
      println("showing location estimation page");
      this.showLocationEstimationPage(devices.get(deviceIndex));
      
    }        
    println("mouse presseed " + mouseY + ", index: "+deviceIndex);
  }
  
}