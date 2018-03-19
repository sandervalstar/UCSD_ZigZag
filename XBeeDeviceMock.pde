class XBeeDeviceMock implements XBeeDevice {
  float rssi;
  String address16;
  String address64;
  
  public XBeeDeviceMock() {
    this.rssi = (float)Math.random() * 100;
    this.address16 = "Address-64-"+Math.random() * 100;
    this.address64 = "Address-16-"+Math.random() * 100;
  }
  
   float getRSSI() {
     return this.rssi;
   }
   
   XBeeDevice updateRSSI() {
     return new XBeeDeviceMock();
   }
   
   String get64BitAddress() {
     return this.address64;
   }
   String get16BitAddress() {
     return this.address16;
   }
}