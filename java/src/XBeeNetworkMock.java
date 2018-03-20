class XBeeNetworkMock implements XBeeNetwork {
  private List<XBeeDevice> devices;
  private int panId;
  
  public XBeeNetworkMock(int panId) {
    this.panId = panId;
    this.devices = new ArrayList();
    this.devices.add(new XBeeDeviceMock());
    this.devices.add(new XBeeDeviceMock());
    this.devices.add(new XBeeDeviceMock());
    this.devices.add(new XBeeDeviceMock());
  }
  
  public int getPanId(){
    return this.panId;
  }
 
  List<XBeeDevice> getAllDevicesInNetwork() {
    return this.devices;
  }
}