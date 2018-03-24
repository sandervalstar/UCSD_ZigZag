import java.awt.geom.Point2D;
import java.util.*;

class LocationEstimatorImpl implements LocationEstimator
{
  List<Point2D.Float> locations = new ArrayList(), bestWeightParticleLandmarks = new ArrayList();
  
  SlacConfiguration config;
  Map<String, MyLandmark> landmarks = new HashMap<String, MyLandmark>();
  ParticleSet particleSet;
  
  Point2D.Float bestWeightUser; // Todo, turn this into a list when we support more devices
  
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
    this.bestWeightUser     = new Point2D.Float(0, 0);
  }
  
  // ====================== Sensor related =========================== //
  
  public void addMeasurement(String uid, float rssi, String name)
  {

    if (rssi > 0)
    {
      println("Ignoring positive RSSI" + rssi); 
      return;
    }

    if (landmarks.containsKey(uid))
    {
      println("found device "+uid);
      //if (this.hasMoved(uid, name))
      //{
      //  this.moveLandmark(uid, rssi, name);
      //}
      //else {
        this.updateLandmark(uid, rssi);
      //}
    } else {
      println("register new device "+uid);
      this.registerLandmark(uid, rssi, name);
    }
    
    println("Received signal strength " + rssi + " with estimated distance of " + rssiToDistance(rssi));
    
  }
  
  protected void updateLandmark(String uid, float rssi)
  {
    println("Updating landmark " + uid);
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
      println("New landmark found with name " + name);
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
      println("hasMoved could not find landmark " + uid);
      return false;
    }
    
  }
  
  protected List<ObservedLandmark> getObservations()
  {
    List<ObservedLandmark> observedLandmarks = new LinkedList<ObservedLandmark>();
    
    for (Map.Entry<String, MyLandmark> entry : landmarks.entrySet())
    {
      MyLandmark thisLandmark = entry.getValue();
      if (thisLandmark.getChanged())
      {
        final double rssi =  thisLandmark.getFilter().lastMeasurement();
        
        
        // the original code converts the ble name here, it does not seem like we need it 
        // https://github.com/wouterbulten/slacjs/blob/master/src/app/models/sensor.js
        
        observedLandmarks.add( new ObservedLandmark(entry.getKey(),                 // uid
                                                    rssiToDistance(rssi),
                                                    thisLandmark.getName(),
                                                    thisLandmark.getMoved()));
                                                    
        // reset flags                                            
        thisLandmark.setChanged(false);
        thisLandmark.setMoved(false);
      }
    }
    
    return observedLandmarks;
  }
  
  double rssiToDistance(double rssi)
  {
    return this.config.getRSSI().getD0() * Math.pow(10, (rssi - this.config.getRSSI().getTxPower()) / (-10 * this.config.getRSSI().getN()));
  }
  
  // ======================================================================================= //  
  // ====================== User movement related =========================== //
  // our algorithm only updates landmarks when the user moves
  
  // todo: double check that when this method is called, when won't have any rssi
  // info from the recently moved location
  void addUserMovement(float x, float y)
  {
      println("Slac running iteration " + ++iteration);
      
      double distX = x;
      double distY = y;
      
      // find distance and heading
      double dist = Math.sqrt(distX*distX + distY*distY);
      double heading = Math.atan2(distY, distX);
      
      // sample a new pose for each particle in the set
      this.particleSet.samplePose(dist, heading);
      
      // let each particle process the observations
      List<ObservedLandmark> observations = this.getObservations();
      
      for (ObservedLandmark landmark : observations)
      {
        println("process obsertvation for "+landmark.getUid());
        this.particleSet.processObservation(landmark.getUid(), landmark.getRadius(), landmark.getName(), landmark.getMoved()); 
      }
      
      this.particleSet.resample();
      
      // finds the best particle of the set to estimate landmarks and user location
      double bestWeight = Double.NEGATIVE_INFINITY;
      Particle bestWeightParticle = null;      
      
      for (Particle particle : this.particleSet.particles())
      {
        if (bestWeight < particle.getWeight())
        {
          bestWeightParticle = particle;
          bestWeight = particle.getWeight();
        }
      }
      
      if (bestWeightParticle != null)
      {
        bestWeightParticleLandmarks = new ArrayList();
        
        // finds user location based on best particle 
        bestWeightUser = new Point2D.Float((float) bestWeightParticle.getUser().getPositionX(), (float) bestWeightParticle.getUser().getPositionY());
        
        // finds landmarks based on best particle
        for (Map.Entry<String, Landmark> it : bestWeightParticle.getLandmarks().entrySet())
        {
          Landmark landmark = it.getValue();
          bestWeightParticleLandmarks.add(new Point2D.Float((float)landmark.getX(), (float)landmark.getY()));
        }
        
      }
      
      // updates particle locations based on initSet
      this.locations = new ArrayList();
      
      for (Map.Entry<String, LandmarkParticleSet> it : this.particleSet.getLandmarkInitSet().getParticleSetMap().entrySet())
      {
          LandmarkParticleSet lpset = it.getValue();
          for (LandmarkParticleSet.MyParticle particle : lpset.getParticles())
          {
              this.locations.add(new Point2D.Float( (float) particle.getX(), (float) particle.getY() ));
          }
      }
            
      // keep local understanding of user location
      userX += x;
      userY += y;
  }
  
  
  // ======================================================================================= //
  
  List<Point2D.Float> getProbableLocations()
  {
    return this.locations;
  }
  
  List<Point2D.Float> getEstimatedLocation()
  {
    return bestWeightParticleLandmarks;
  }
  
  public Point2D.Float getEstimatedUserLocation()
  {
    return bestWeightUser;
  }
  
  
}