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
        println("Add response " + response.getApiId() + " " + response.getClass());
        if (response instanceof AtCommandResponse) {
          println("Add response 2");
          AtCommandResponse atResponse = (AtCommandResponse) response;
          
          if (atResponse.getCommand().equals("ND") && atResponse.getValue() != null && atResponse.getValue().length > 0) {
            println("Add response 3");
            ZBNodeDiscover nd = ZBNodeDiscover.parse((AtCommandResponse) response);
            XBeeDevice device = new XBeeDeviceImpl(nd.getNodeIdentifier(), nd.getNodeAddress64(), this.antenna, 0);
            deviceList.add(device);             
          }
        } else if (response instanceof ErrorResponse) {
            ErrorResponse error = (ErrorResponse) response;
            println("error messsage: " + error.getErrorMsg());
        }
      }
    } catch (Exception excep) {
      println("error discovering nodes");          
    }
  }
}