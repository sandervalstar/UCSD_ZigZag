class XBeeDeviceMock implements XBeeDevice {
  float rssi;
  String address16;
  String address64;
  String name;
  
  public XBeeDeviceMock() {
    this.init("Address-64-"+Math.random() * 100, "Address-16-"+Math.random() * 10);
  }
  
  public XBeeDeviceMock(String a1, String a2) {
    this.init(a1, a2);
  }
  
  public XBeeDeviceMock(String a1, String a2, float xoff) {
    this.init(a1, a2);
  }

  private void init(String a1, String a2) {
    this.rssi = (float)Math.random() * 100;
    this.address16 = a1;
    this.address64 = a2;
    this.name = "router";
  }
    
   float getCurrentRSSI() {
     return -this.rssi;
   }
   
   XBeeDevice getNewRSSI() {
     return new XBeeDeviceMock(this.address16, this.address64);
   }
   
   String get64BitAddress() {
     return this.address64;
   }
   String get16BitAddress() {
     return this.address16;
   }
   
   String getName() {
     if (this.name == null || this.name.isEmpty()) {
      return this.get64BitAddress(); 
    }
    return this.name; 
   }
}