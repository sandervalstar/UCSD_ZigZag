//import java.awt.geom.Point2D.*;

class LocationEstimator {
  List<DistanceEstimator> distanceEstimators = new ArrayList();
  
  public LocationEstimator(){
  }
  
  public Point2D.Double getUserLocation() {
    if(this.distanceEstimators.isEmpty()) {
      println("returnint 0,0");
      return new Point2D.Double(0,0);
    }
    //println("estimators not empty");
    
    DistanceEstimator e = this.distanceEstimators.get(distanceEstimators.size()-1);
    return new Point2D.Double(e.x, e.y);
  }
  
  public void addUserMovement(double x, double y) {
    Point2D.Double location = this.getUserLocation();
    x += location.x;
    y += location.y;
    this.distanceEstimators.add(new DistanceEstimator(x, y));
  }
  
  public void addMeasurement(double rssi) {
    if(this.distanceEstimators.size() == 0) {
      println("No distance estimators, adding one");
      DistanceEstimator d = new DistanceEstimator(0,0);
      this.distanceEstimators.add(d);
    }
    this.distanceEstimators.get(distanceEstimators.size()-1).addMeasurement(rssi);
  }
}