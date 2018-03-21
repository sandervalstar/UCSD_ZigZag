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
  
  public Point2D.Double getMinAndMax() {
      double min = 0;
      double max = 1;
    
      for(DistanceEstimator e : this.distanceEstimators) {
        if(e.x > max) max = e.x;
        if(e.x < min) min = e.x;
        if(e.y > max) max = e.y;
        if(e.y < min) min = e.y;
        if(e.distance > max) max = e.distance;
        if(e.distance < min) min = e.distance;
      }
      
      return new Point2D.Double(min, max);
  }
}