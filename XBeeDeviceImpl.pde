class XBeeDeviceImpl implements XBeeDevice {
  private String name;
  private XBeeAddress64 address64;
  private float rssi;
  private Antenna antenna;
  
  public XBeeDeviceImpl(String name, XBeeAddress64 address64, Antenna antenna, float rssi) {
    this.name = name; 
    this.address64 = address64;
    this.rssi = rssi;
    this.antenna = antenna;
  }
  
  public float getCurrentRSSI() {
    return this.rssi; 
  }
  
  public XBeeDevice getNewRSSI() {
    this.rssi = this.antenna.getRemoteRSSI(this.address64);
    return new XBeeDeviceImpl(this.name, this.address64, this.antenna, this.rssi);
  }
  
  String get64BitAddress() {
    return address64.toString();
  }
  
  String getName() {
    return this.name; 
  }
}