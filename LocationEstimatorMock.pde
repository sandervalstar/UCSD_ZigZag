import java.awt.geom.Point2D;

class LocationEstimatorMock implements LocationEstimator {
  List<Point2D.Float> locations = new ArrayList();
  
  void addMeasurement(float rssi) {
    this.locations.add(new Point2D.Float((float)Math.random()*rssi/20, (float)Math.random()*rssi/20));
  }
  
  void addUserMovement(float x, float y) {
    for(int i = 0; i < locations.size(); i++) {
      locations.get(i).x -= x;
      locations.get(i).y -= y; 
    }
  }
  
  List<Point2D.Float> getProbableLocations() {
    return this.locations;
  }
  
  Point2D.Float getEstimatedLocation() {
    if(this.locations.size() > 0) {
      return this.locations.get(0); 
    }
    return null;
  }
  
}