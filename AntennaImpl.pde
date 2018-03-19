import com.rapplogic.xbee.api.XBee;

import com.rapplogic.xbee.api.XBeeResponse;

public class AntennaImpl implements Antenna {
  
  private XBee xbee;
  private JSONObject jsonConfig;

  public AntennaImpl() {
    jsonConfig =  loadJSONObject("config.json");
    String serialPortName = jsonConfig.getString("SerialPort");
    try {
      xbee = new XBee();
      xbee.open(serialPortName, 9600);
    } catch (XBeeException exception) {
      println("error opening antenna port");
    }
  }
  
  public void setPanId(int panId) {
    //AtCommand atid = new AtCommand("ID", 123); 
    //try {
    //  println("going to set panid");
    //  AtCommandResponse response = (AtCommandResponse) xbee.sendSynchronous(atid, 5000);
    //  println(response.getApiId());
    //  println("going to check current pan id");
    //  AtCommand currentid = new AtCommand("ID"); 
    //  response = (AtCommandResponse) xbee.sendSynchronous(currentid, 5000);
    //  if (response.getApiId() == ApiId.AT_RESPONSE) {
    //    println("pan id request response");
    //    println("pan id set to: " + response.getValue()[0]);
    //  }
    //} catch (Exception excep) {
    //    println("error sending remote at command " + excep); 
    //}
  }
  
  public List<? extends XBeeResponse> sendNodeDiscovery() {
    try {
      // get the Node discovery timeout
      xbee.sendAsynchronous(new AtCommand("NT"));
      AtCommandResponse nodeTimeout = (AtCommandResponse) xbee.getResponse();
  
      // default is 6 seconds
      int nodeDiscoveryTimeout = ByteUtils.convertMultiByteToInt(nodeTimeout.getValue()) * 100;      
      println("Node discovery timeout is " + nodeDiscoveryTimeout + " milliseconds");
            
      println("Sending Node Discover command");
      xbee.sendAsynchronous(new AtCommand("ND")); 
      return xbee.collectResponses(nodeDiscoveryTimeout);
    } catch (XBeeException exception) {
      println("error discovering nodes");
    }
    
    return null;
  }
  
  public float getRemoteRSSI(XBeeAddress64 remoteAddress64) {
    RemoteAtRequest remoteAtRequest = new RemoteAtRequest(remoteAddress64, "DB");
    try {
      RemoteAtResponse response = (RemoteAtResponse) xbee.sendSynchronous(remoteAtRequest, 5000);
      if (response.getApiId() == ApiId.REMOTE_AT_RESPONSE) {
          RemoteAtResponse atResponse = (RemoteAtResponse) response;
          if (atResponse.getValue().length > 0) {
            println("RSSI: " + atResponse.getValue()[0]);
            return atResponse.getValue()[0];
          }
      }
    } catch (Exception excep) {
        println("error sending remote at command"); 
    }
    return 0;
  }
}