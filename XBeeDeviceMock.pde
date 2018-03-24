class XBeeDeviceMock implements XBeeDevice {
  float rssi;
  String address16;
  String address64;
  String name;
  float xoff = 0.01;
  LocationEstimator locationEstimator; // used to get user location so that this device can provide a fake RSSI in accordance to user distance
  Point2D.Float deviceLocation;
  
  
  // this mock considers that the ZigBee device location is

  float distanceBetweenTwoPoints(Point2D.Float x1, Point2D.Float x2)
  {
    return (float) Math.sqrt(Math.pow(x1.x - x2.x, 2) + Math.pow(x1.y - x2.y, 2));
  }
  
  void updateRssiBasedOnUserLocation()
  { 
    Point2D.Float estimatedUserLocation = locationEstimator.getEstimatedUserLocation();
    float distance =  distanceBetweenTwoPoints(estimatedUserLocation, deviceLocation)
                      + 0.1*noise(estimatedUserLocation.x, estimatedUserLocation.y);  // perlin noise to add some variance 
                      
    updateRssiBasedOnDistance(distance);
   
  }
  
  void updateRssiBasedOnDistance(float distance)
  {
    this.rssi = -10 * 2 * (float) MathUtil.log(distance / 0.5,10) - 35.75;
  }
  
  
  public XBeeDeviceMock(LocationEstimator location, Point2D.Float zigbeeLocation)
  {
    this.deviceLocation = zigbeeLocation;
    this.locationEstimator = location;
    updateRssiBasedOnDistance(distanceBetweenTwoPoints(new Point2D.Float(0,0), zigbeeLocation));
    this.init("Address-64-"+Math.random() * 100, "Address-16-"+Math.random() * 10);
  }
  
  public XBeeDeviceMock(String a1, String a2) {
    this.init(a1, a2);
  }
  
  public XBeeDeviceMock(String a1, String a2, float xoff) {
    this.xoff = xoff;
    this.init(a1, a2);
  }

  private void init(String a1, String a2) {
    this.rssi = noise(xoff*1000);
    this.address16 = a1;
    this.address64 = a2;
    this.name = "router";
  }
    
   float getCurrentRSSI() {
     updateRssiBasedOnUserLocation();
     return this.rssi;
   }
   
   XBeeDevice getNewRSSI() {
     //xoff = xoff + .01;
     return this;
   }
   
   String get64BitAddress() {
     return this.address64;
   }
   String get16BitAddress() {
     return this.address16;
   }
   
   String getName() {
     if (this.name == null || this.name.isEmpty()) {
      return this.get64BitAddress(); 
    }
    return this.name; 
   }
}