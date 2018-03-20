class XBeeDeviceMock implements XBeeDevice {
  float rssi;
  String address16;
  String address64;
  String name;
  
  public XBeeDeviceMock() {
    this.rssi = (float)Math.random() * 100;
    this.address16 = "Address-64-"+Math.random() * 100;
    this.address64 = "Address-16-"+Math.random() * 100;
    this.name = "router";
  }
  
  public XBeeDeviceMock(String a1, String a2) {
    this.rssi = (float)Math.random() * 100;
    this.address16 = a1;
    this.address64 = a2;
  }
  
   float getCurrentRSSI() {
     return this.rssi;
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
     return this.name;
   }
}