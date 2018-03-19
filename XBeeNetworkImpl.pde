public class XBeeNetworkImpl implements XBeeNetwork {
    
  private int panId;
  private Antenna antenna;
  private List<XBeeDevice> deviceList;

  public XBeeNetworkImpl(int panId, Antenna antenna) {
    this.panId = panId;
    this.antenna = antenna;
    antenna.setPanId(panId); 
    deviceList = new ArrayList<XBeeDevice>();
  }
  
  public int getPanId() {
    return this.panId; 
  }
  
  public List<XBeeDevice> getAllDevicesInNetwork() {
    try {
      deviceList.clear();
      discoverNodes();
    } catch (Exception excep) {
      println("error discovering"); 
    }
    return deviceList;
  }
  
  private void discoverNodes() throws XBeeException, InterruptedException {
  
    try {  
      List<? extends XBeeResponse> responses = antenna.sendNodeDiscovery();             
      println("number of responses: " + responses.size());
      for (XBeeResponse response : responses) {
        if (response instanceof AtCommandResponse) {
          AtCommandResponse atResponse = (AtCommandResponse) response;
          
          if (atResponse.getCommand().equals("ND") && atResponse.getValue() != null && atResponse.getValue().length > 0) {
            ZBNodeDiscover nd = ZBNodeDiscover.parse((AtCommandResponse) response);
            XBeeDevice device = new XBeeDeviceImpl(nd.getNodeIdentifier(), nd.getNodeAddress64(), this.antenna);
            deviceList.add(device);             
          }
        }
      }
    } catch (Exception excep) {
      println("error discovering nodes");          
    }
  }
}