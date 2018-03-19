import java.awt.geom.Point2D;

interface LocationEstimator {
  void addMeasurement(float rssi);
  void addUserMovement(float x, float y);
  List<Point2D.Float> getEstimatedLocations();
}