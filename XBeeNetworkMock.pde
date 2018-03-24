class XBeeNetworkMock implements XBeeNetwork {
  private List<XBeeDevice> devices;
  private int panId;
  
  public XBeeNetworkMock(LocationEstimator loc, int panId) {
    this.panId = panId;
    this.devices = new ArrayList();
    this.devices.add(new XBeeDeviceMock(loc, new Point2D.Float(3,4)));
    this.devices.add(new XBeeDeviceMock(loc, new Point2D.Float(0,4)));
    this.devices.add(new XBeeDeviceMock(loc, new Point2D.Float(0,-4)));
    this.devices.add(new XBeeDeviceMock(loc, new Point2D.Float(-3,-4)));
  }
  
  public int getPanId(){
    return this.panId;
  }
 
  List<XBeeDevice> getAllDevicesInNetwork() {
    return this.devices;
  }
}