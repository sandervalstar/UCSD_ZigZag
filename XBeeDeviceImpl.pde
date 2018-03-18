class XBeeDeviceImpl implements XBeeDevice {
    private String address;
    private float distance;
    
    public XBeeDeviceImpl(String address) {
       this.address = address;
       distance = 0f;
    }
    
    public float getDistance() {
        return 0;
    }
    
    XBeeDevice updateDistance() {
        return null;
    }
    
    XBeeAddress64 get64BitAddress() {
        return null;
    }
   
    XBeeAddress16 get16BitAddress(){
        return null;
    }
  
}