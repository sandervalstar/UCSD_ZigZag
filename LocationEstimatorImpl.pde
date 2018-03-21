import java.awt.geom.Point2D;
import java.util.*;

class LocationEstimatorImpl implements LocationEstimator
{
  List<Point2D.Float> locations = new ArrayList();
  
  SlacConfiguration config;
  Map<String, MyLandmark> landmarks = new HashMap<String, MyLandmark>();
  int iteration;
  
  public LocationEstimatorImpl(SlacConfiguration config)
  {
    this.config = config;
  }
  
  public void addMeasurement(String uid, float rssi, String name)
  {

    if (rssi > 0)
        return;

    if (landmarks.containsKey(uid))
    {
      // if (this._hasMoved(uid, name)) {
      //  this._moveLandmark(uid, rssi, name);
      //}
      //else {
        this.updateLandmark(uid, rssi);
      //}
    } else {
      this.registerLandmark(uid, rssi, name);
    }
    
  }
  
  protected void updateLandmark(String uid, float rssi)
  {
    MyLandmark landmark = landmarks.get(uid);
    landmark.getFilter().filter(rssi, 0);
    landmark.incrementMeasurements();
    landmark.setChanged(true);                // updates the landmark so that the main algorithm can use the new poses
  }
  
  protected void registerLandmark(String uid, float rssi, String name)
  {
    registerLandmark(uid, rssi, name, false);  
  }
  
  protected void registerLandmark(String uid, float rssi, String name, boolean moved)
  {
    if (!moved)
    {
      print("New landmark found with name " + name);
    }
    
    KalmanFilter filter = new KalmanFilter((float) config.getSensor().getKalmanFilterR(), 
                                           (float) config.getSensor().getKalmanFilterQ());
                                           
    filter.filter(rssi, 0);
    
    this.landmarks.put(uid, new MyLandmark(uid, true, name, filter, moved));
    
  }
  
  protected boolean hasMoved(String uid, String name)
  {
    MyLandmark landmark = this.landmarks.get(uid);
    if (landmark != null)
    {
      //return this.hasMoved !== undefined && this.hasMoved(
      //{uid, name},
      //{uid: landmark.uid, name: landmark.name}
      //);
      
      return false;
    } else {
      print("hasMoved could not find landmark " + uid);
      return false;
    }
    
  }
  
  protected List<ObservedLandmark> getObservations()
  {
    List<ObservedLandmark> observedLandmarks = new LinkedList<ObservedLandmark>();
    
    for (Map.Entry<String, MyLandmark> entry : landmarks.entrySet())
    {
      MyLandmark thisLandmark = entry.getValue();
      final double rssi =  thisLandmark.getFilter().lastMeasurement();
      
      
      // the original code converts the ble name here, it does not seem like we need it 
      // https://github.com/wouterbulten/slacjs/blob/master/src/app/models/sensor.js
      
      observedLandmarks.add( new ObservedLandmark(entry.getKey(),                 // uid
                                                  rssiToDistance(rssi),
                                                  thisLandmark.getName(),
                                                  thisLandmark.getMoved()));
                                                  
      thisLandmark.setChanged(true);
      thisLandmark.setMoved(true);
    }
    
    return observedLandmarks;
  }
  
  double rssiToDistance(double rssi)
  {
    return rssi;
  }
  
  void addUserMovement(float x, float y)
  {
    for (int i = 0; i < locations.size(); i++)
    {
      //print("from x="+locations.get(i).x);
      locations.get(i).x -= x;
      //println(" to x="+locations.get(i).x);
      //print("from y="+locations.get(i).y);
      locations.get(i).y -= y;
      //println(" to y="+locations.get(i).y);
    }
  }
  
  List<Point2D.Float> getProbableLocations()
  {
    return this.locations;
  }
  
  Point2D.Float getEstimatedLocation()
  {
    if (this.locations.size() > 0)
    {
      return this.locations.get(0); 
    }
    return null;
  }
  
  void update()
  {
    
  }
  
}