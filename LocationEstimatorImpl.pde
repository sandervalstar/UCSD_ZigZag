import java.awt.geom.Point2D;
import java.util.*;

class LocationEstimatorImpl implements LocationEstimator
{
  List<Point2D.Float> locations = new ArrayList();
  
  SlacConfiguration config;
  Map<String, MyLandmark> landmarks = new HashMap<String, MyLandmark>();
  ParticleSet particleSet;
  
  int iteration;
  
  float userX, userY;
  
  public LocationEstimatorImpl(SlacConfiguration config)
  {
    this.config = config;
    this.userX = 0;
    this.userY = 0;
    this.iteration = 0;
    this.particleSet = new ParticleSet (config.getParticles().getN(),
                                        config.getParticles().getEffectiveParticleThreshold(),
                                        config);
  }
  
  // ====================== Sensor related =========================== //
  
  public void addMeasurement(String uid, float rssi, String name)
  {

    if (rssi > 0)
        return;

    if (landmarks.containsKey(uid))
    {
      //if (this.hasMoved(uid, name))
      //{
      //  this.moveLandmark(uid, rssi, name);
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
    return rssi; // TODO
  }
  
  // ======================================================================================= //
  
  
  // ====================== User movement related =========================== //
  // our algorithm only updates landmarks when the user moves
  
  // todo: double check that when this method is called, when won't have any rssi
  // info from the recently moved location
  void addUserMovement(float x, float y)
  {
      print("Slac running iteration " + ++iteration);
      
      
      double distX = x - userX;
      double distY = y - userY;
      
      // find distance and heading
      double dist = Math.sqrt(Math.pow(x - userX, 2) + Math.pow(y - userY, 2));
      double heading = Math.atan(distY / distX);
      
      // sample a new pose for each particle in the set
      this.particleSet.samplePose(dist, heading);
      
      // let each particle process the observations
      List<ObservedLandmark> observations = this.getObservations();
      
      for (ObservedLandmark landmark : observations)
      {
        this.particleSet.processObservation(landmark.getUid(), landmark.getRadius(), landmark.getName(), landmark.getMoved()); 
      }
      
      this.particleSet.resample();
  }
  
  
  // ======================================================================================= //
  
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
  
  
}