import java.util.*;

// Porting https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/particle-set.js
class ParticleSet
{
  
  private int nParticles;  
  private int effectiveParticleThreshold;
  private List<Particle> particleList;
  private List<String> initialisedLandmarks;
  private LandmarkInitializationSet landmarkInitSet;

  public LandmarkInitializationSet getLandmarkInitSet() { return landmarkInitSet; }

  /**
   * Create a new particle set with a given number of particles
   * @param  {Number} nParticles Number of particles
   * @param  {SlacConfig} Algorithm configuration
   * @return {ParticleSet}
   */
  public ParticleSet(int nParticles, int effectiveParticleThreshold, SlacConfiguration slacConfig)
  {
    this.nParticles = nParticles;
    this.effectiveParticleThreshold = effectiveParticleThreshold;
    this.particleList = new ArrayList();

    //Internal list to keep track of initialised landmarks
    this.initialisedLandmarks = new ArrayList();
    this.landmarkInitSet = new LandmarkInitializationSet(slacConfig);

    for (int i = 0; i < nParticles; i++)
    {
      this.particleList.add(new Particle(slacConfig));
    }
  }

  /**
   * Given a control, let each particle sample a new user position
   * @param  {[type]} control [description]
   * @return {ParticleSet}
   */
  public ParticleSet samplePose(double r, double theta)
  {
    for (int i = 0; i < this.particleList.size(); i++)
    {
      this.particleList.get(i).samplePose(r, theta);
    }

    return this;
  }

  /**
   * Let each particle process an observation
   * @param  {object} obs
   * @return {ParticleSet}
   */
  public ParticleSet processObservation(String uid, double r, String name, boolean moved)
  {
    println("particleSet processObservation");

    if (uid != null)
    {
      //If the landmark has moved we remove it from all particles
      if (moved)
      {
        println("Moving landmark " + uid);
        this.removeLandmark(uid);
      }

      if (!this.initialisedLandmarks.contains(uid))
      {
        println("particleSet !initialisedLandmarks.contains(uid)");

        double uX = this.userEstimateX();
        double uY = this.userEstimateY();
        
        this.landmarkInitSet.addMeasurement(uid, uX, uY, r);

        PositionEstimate pe = this.landmarkInitSet.estimate(uid);
        
        //const {estimate, x, y, varX, varY} = this.landmarkInitSet.estimate(uid);
        if (pe.estimate > 0.6)
        {
          for (int i = 0; i < this.particleList.size(); i++)
          {
            println("particleSet addLandmark(uid)");
            this.particleList.get(i).addLandmark(uid, r, name, pe.x, pe.y, pe.varX, pe.varY);
          }

          this.landmarkInitSet.remove(uid);
          this.initialisedLandmarks.add(uid);
        }
      }
      else
      {
        for(int i = 0; i < this.particleList.size(); i++)
        {
          this.particleList.get(i).processObservation(uid, r);
        }
      }
    }

    return this;
  }

  /**
   * Resample the internal particle list using their weights
   *
   * Uses a low variance sample
   * @return {ParticleSet}
   */
  public ParticleSet resample()
  {
  
    List<Double> weights = getWeightMappings(this.particleList);
    if (numberOfEffectiveParticles(weights) < this.effectiveParticleThreshold) 
    {
      System.out.println("resampling");
      Set<Integer> lowVarSampl = lowVarianceSampling(this.nParticles, weights);
      this.particleList = new ArrayList();
      for (Integer i : lowVarSampl) 
      {
        this.particleList.add(new Particle(this.particleList.get(i)));
      } 
    }

    return this;
  }

  /**
   * Get particles
   * @return {[Array]
   */
  public List<Particle> particles()
  {
    return this.particleList;
  }

  /**
   * Return the particle with the heighest weight
   * @return {Particle}
   */
  public Particle bestParticle()
  {
    Particle best = this.particleList.get(0);
    
    for (Particle p : this.particleList)
    {
      if (p.getWeight() > best.getWeight())
      {
        best = p;
      }
    }

    return best;
  }

  /**
   * Compute an average of all landmark estimates
   * @return {Map}
   */
  public Map<String, LandmarkEstimate> landmarkEstimate()
  {
    List<Double> weights = normalizeWeights(getWeightMappings(this.particleList));

    Map<String, LandmarkEstimate> landmarks = new HashMap();

    //Loop through all particles to get an estimate of the landmarks
    for(int i = 0; i < this.particleList.size(); i++) {
      Particle p = this.particleList.get(i);
      for(Map.Entry<String, Landmark> e : p.getLandmarks().entrySet()) {
        Landmark landmark = e.getValue();
        if(!landmarks.containsKey(e.getKey())) {
          landmarks.put(e.getKey(), new LandmarkEstimate(
            landmark.getX(),
            landmark.getY(),
            e.getKey(),
            landmark.getName()
          ));
        } else {
          LandmarkEstimate l = landmarks.get(e.getKey());

          l.x = l.x + weights.get(i) * landmark.getX();
          l.y = l.y + weights.get(i) * landmark.getY();
        }
      }
    }

    return landmarks;
  }

  /**
   * Get the best estimate of the current user position
   * @return {object}
   */
  private double userEstimateX() {
    double x = 0;
    for(Particle p : this.particleList) {
      x += p.getWeight()*p.getUser().getPositionX();
    }
    
    return x;
  }
  
  private double userEstimateY() {
    double y = 0;
    for(Particle p : this.particleList) {
      y += p.getWeight()*p.getUser().getPositionY();
    }
    
    return y;
  }

  /**
   * Remove a landmark from all the particles
   * @param  {String} uid Landmark uid
   * @return {void}
   */
  private void removeLandmark(String uid) {

    //Remove from the landmark list if it exists
    int index = this.initialisedLandmarks.indexOf(uid);

    if (index != -1) {
      this.initialisedLandmarks.remove(index);

      //Remove it from all particles
      for(int i = 0; i < this.particleList.size(); i++) {
        this.particleList.get(i).removeLandmark(uid);
      }
    }
    else {

      //It is not initalised yet, so we remove it from the init set
      this.landmarkInitSet.remove(uid);
    }
  }
  
  private double numberOfEffectiveParticles(List<Double> weights) {
    List<Double> normalizedWeights = normalizeWeights(weights);
    double total = 0;
    for(int i = 0; i < normalizedWeights.size(); i++) {
      double w = normalizedWeights.get(i);
      total += w*w;
    }
    return 1 / total;
  }
  
  private List<Double> normalizeWeights(List<Double> weights) {
    double total = 0;
    for(int i = 0; i < weights.size(); i++) {
      total += weights.get(i);
    }
    
    List<Double> result = weights;
    for(int i = 0; i < weights.size(); i++) {
      result.set(i, result.get(i) / total);
    }
  
    return result;
  }
  
  public List<Double> getWeightMappings(List<Particle> particles) {
   List<Double> weights = new ArrayList<Double>();
   for (Particle particle : particles) {
       weights.add(particle.getWeight());
   }
   return weights;
 }
 
 /**
 * Samples a new set using a low variance sampler from a array of weights
 * @param {Number} nSamples Number of samples to sample
 * @param {Array} weights   Weight array
 * @param nParticles
  *@param weights @return {Array} An array with indices corresponding to the selected weights
 */
 public Set<Integer> lowVarianceSampling(int nParticles, List<Double> weights) {

  int M = weights.size();
  List<Double> normalizedWeights = normalizeWeights(weights);

  double rand = Math.random() * (1 / M);

  double c = normalizedWeights.get(0);
  int i = 0;

  Set<Integer> set = new HashSet();

  for (int m = 1; m <= nParticles; m++) {
    double U = rand + (m - 1) * (1 / M);

    while (U > c) {
      i = i + 1;
      c = c + normalizedWeights.get(i);
    }

    set.add(i);
  }

  return set;
}
  
}