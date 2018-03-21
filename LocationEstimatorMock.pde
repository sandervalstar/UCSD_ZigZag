import java.awt.geom.Point2D;

class LocationEstimatorMock implements LocationEstimator {
  List<Point2D.Float> locations = new ArrayList();
  float userX, userY;
  
  public LocationEstimatorMock() {
    int xdir = Math.random() < 0.5 ? -1 : 1;
    int ydir = Math.random() < 0.5 ? -1 : 1;
    this.userX = (float) Math.random() * 10 * xdir;
    this.userY = (float) Math.random() * 10 * ydir;
  }
  
  void addMeasurement(String uid, float rssi, String name) {
    int xdir = Math.random() < 0.5 ? -1 : 1;
    int ydir = Math.random() < 0.5 ? -1 : 1;
    this.locations.add(new Point2D.Float(xdir*(float)Math.random()*rssi/5, ydir*(float)Math.random()*rssi/5));
  }
  
  void addUserMovement(float x, float y) {
    for(int i = 0; i < locations.size(); i++) {
      this.userX -= x;
      this.userY -= y;
    }
  }
  
  List<Point2D.Float> getProbableLocations() {
    return this.locations;
  }
  
  List<Point2D.Float> getEstimatedLocation() {
    return this.locations;

  }
  
  public Point2D.Float getEstimatedUserLocation() {
    return new Point2D.Float(this.userX, this.userY);
  }
  
  
  void update()
  {
  }
  
}