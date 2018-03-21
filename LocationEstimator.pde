import java.awt.geom.Point2D;

interface LocationEstimator {
  
  class MyLandmark
  {
      String uid, name;
      KalmanFilter filter;
      boolean moved, changed;
      int measurements;
      
      MyLandmark(String uid, boolean changed, String name, KalmanFilter filter, boolean moved)
      {
         measurements = 1;
         this.uid = uid;
         this.changed = changed;
         this.filter = filter;
         this.moved = moved;
      }
      
      //void setUid
      //void setName
      //void setFilter
      
      
      KalmanFilter getFilter() { return filter; }
      boolean getMoved() { return moved; }
      boolean getChanged() { return changed; }
      
      void setMoved(boolean moved) { this.moved = moved; }
      void setChanged(boolean changed) { this.changed = changed; }
      
      void incrementMeasurements() { measurements++; }
      int getMeasurements() { return measurements; }
      
      String getUid() { return uid; }
      String getName() { return name; }
      
  }

  public void addMeasurement(String uid, float rssi, String name);
  
  public void addUserMovement(float x, float y);
  
  public List<Point2D.Float> getProbableLocations();
  public Point2D.Float getEstimatedLocation();
  
}