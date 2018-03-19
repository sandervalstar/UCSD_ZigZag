import java.awt.geom.Point2D;

class LocationEstimatorMock implements LocationEstimator {
  List<Point2D.Float> locations = new ArrayList();
  
  void addMeasurement(float rssi) {
    this.locations.add(new Point2D.Float(rssi/20, rssi/20));
  }
  
  void addUserMovement(float x, float y) {
    for(int i = 0; i < locations.size(); i++) {
      locations.get(i).x -= x;
      locations.get(i).y -= y; 
    }
  }
  
  List<Point2D.Float> getEstimatedLocations() {
    return this.locations;
  }
  
}