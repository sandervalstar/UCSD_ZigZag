class XBeeDeviceImpl implements XBeeDevice {
    private String address;
    private float rssi;
    
    public XBeeDeviceImpl(String address) {
       this.address = address;
       rssi = 0f;
    }
    
    public float getRSSI() {
        return 0;
    }
    
    XBeeDevice updateRSSI() {
        return null;
    }
    
    String get64BitAddress() {
        return null;
    }
   
    String get16BitAddress(){
        return null;
    }
  
}