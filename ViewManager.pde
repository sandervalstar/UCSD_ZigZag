import interfascia.*;

class ViewManager {  
  private PApplet app;
  GUIController c;
  IFTextField t;
  IFButton b;
  int MARGIN = 20;
      
  public ViewManager(PApplet app) {
    this.app = app;
    c = new GUIController(app);
    t = new IFTextField("Text Field", MARGIN, height/4, width-2*MARGIN);
    b = new IFButton("Join", MARGIN, height-50);
    b.setWidth(width-2*MARGIN);
    b.addActionListener(app);
    c.add(t);
    c.add(b);
  };
  
  public void draw() {
    this.drawHomeScreen();
  }
  
  public void drawHomeScreen() {
    background(0);
    this.drawPageTitle("ZigZag Home");
    this.drawPageSubtitle("Join a network first");
    
    
    
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
  }
  
}