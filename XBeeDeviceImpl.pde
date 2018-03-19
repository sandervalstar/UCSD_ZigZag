class XBeeDeviceImpl implements XBeeDevice {
  private String name;
  private XBeeAddress64 address64;
  private float rssi;
  private Antenna antenna;
  
  public XBeeDeviceImpl(String name, XBeeAddress64 address64, Antenna antenna) {
    this.name = name; 
    this.address64 = address64;
    this.rssi = 0;
    this.antenna = antenna;
  }
  
  public float getCurrentRSSI() {
    return this.rssi;
  }
  
  float getNewRSSI() {
    this.rssi = this.antenna.getRemoteRSSI(this.address64);
    return this.rssi;
  }
  
  String get64BitAddress() {
    return address64.toString();
  }
  
  String getName() {
    return this.name; 
  }
}