// Porting https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/particle-set.js
class ParticleSet {
  
  private int nParticles;  
  private int effectiveParticleThreshold;
  private List<Particle> particleList;
  private List<String> initialisedLandmarks;
  private LandmarkInitializationSet landmarkInitSet;
  
  /**
   * Create a new particle set with a given number of particles
   * @param  {Number} nParticles Number of particles
   * @param  {Object} userConfig Config of the user
   * @param  {Object} initConfig Config for the init filter
   * @return {ParticleSet}
   */
  public ParticleSet(int nParticles, int effectiveParticleThreshold, SlacConfiguration userConfig, SlacConfiguration initConfig) {
    this.nParticles = nParticles;
    this.effectiveParticleThreshold = effectiveParticleThreshold;
    this.particleList = new ArrayList();

    //Internal list to keep track of initialised landmarks
    this.initialisedLandmarks = new ArrayList();
    this.landmarkInitSet = new LandmarkInitializationSet(initConfig);

    for (int i = 0; i < nParticles; i++) {
      this.particleList.add(new Particle(userConfig));
    }
  }

  /**
   * Given a control, let each particle sample a new user position
   * @param  {[type]} control [description]
   * @return {ParticleSet}
   */
  public ParticleSet samplePose(control) {
    for(int i = 0; i < this.particleList.size(); i++) {
      this.particleList.get(i).samplePose(control);
    }

    return this;
  }

  /**
   * Let each particle process an observation
   * @param  {object} obs
   * @return {ParticleSet}
   */
  public ParticleSet processObservation(String uid, double r, String name, boolean moved) {

    if (uid != null) {

      //If the landmark has moved we remove it from all particles
      if (moved) {
        this.removeLandmark(uid);
      }

      if (this.initialisedLandmarks.contains(uid)) {

        double uX = this.userEstimateX();
        double uX = this.userEstimateY();
        
        this.landmarkInitSet.addMeasurement(uid, uX, uY, r);

        PositionEstimate pe = this.landmarkInitSet.estimate(uid);
        
        //const {estimate, x, y, varX, varY} = this.landmarkInitSet.estimate(uid);

        if (pe.estimate > 0.6) {
          for(int i = 0; i < this.particleList.size(); i++) {
            this.particleList.get(i).addLandmark(uid, r, name, moved, pe.x, pe.y, pe.varX, pe.varY);
          }

          this.landmarkInitSet.remove(uid);
          this.initialisedLandmarks.add(uid);
        }
      }
      else {
        for(int i = 0; i < this.particleList.size(); i++) {
          this.particleList.get(i).processObservation(String uid, double r, String name, boolean moved);
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
  public ParticleSet resample() {
  
    Double weights = getWeightMappings(this.particleList);
    if (numberOfEffectiveParticles(weights) < this.effectiveParticleThreshold) {
      println('resampling');
      Set<Integer> lowVarSampl = lowVarianceSampling(this.nParticles, weights);
      this.particleList = new ArrayList();
      for (Integer i : lowVarSampl) {
        this.particleList.add(new Particle(this.particleList.get(i)));
      } 
    }

    return this;
  }

  /**
   * Get particles
   * @return {[Array]
   */
  public List<Particle> particles() {
    return this.particleList;
  }

  /**
   * Return the particle with the heighest weight
   * @return {Particle}
   */
  public Particle bestParticle() {
    Particle best = this.particleList.get(0);
    
    for(Particle p : this.particleList) {
      if (p.weigth > best.weight) {
        best = p;
      }
    }

    return best;
  }

  /**
   * Compute an average of all landmark estimates
   * @return {Map}
   */
  public Map<String, Landmark> landmarkEstimate() {
    List<Double> weights = normalizeWeights(this.particleList.map((p) => p.weight));

    Map<String, Landmark> landmarks = new HashMap();

    //Loop through all particles to get an estimate of the landmarks
    this.particleList.forEach((p, i) => {
      p.landmarks.forEach((landmark, uid) => {
        if (!landmarks.has(uid)) {
          landmarks.set(uid, {
            x: weights[i] * landmark.x,
            y: weights[i] * landmark.y,
            uid: uid,
            name: landmark.name
          });
        }
        else {
          const l = landmarks.get(uid);

          l.x += weights[i] * landmark.x;
          l.y += weights[i] * landmark.y;
        }
      });
    });
    
    
    for(int i = 0; i < this.particleList.size(); i++) {
      Particle p = this.particleList.get(i);
      for(Map.Key<String, Landmark> e : p.getLandmarks()) {
        Landmark landmark = e.getValue();
        if(!landmarks.contains(e.getKey())) {
          landmarks.put(e.getKey(), new Landmark(
            landmark.getX(),
            landmark.getY(),
            uid,
            landmark.getName(),
          ));
        } else {
          Landmark l = landmarks.get(uid);
          
          l.setX(l.getX() + weights.get(i) * landmark.getX());
          l.setY(l.getY() + weights.get(i) * landmark.getY());
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
      x += p.getWeight()*p.getUser().getX();
    }
    
    return x;
  }
  
  private double userEstimateY() {
    double y = 0;
    for(Particle p : this.particleList) {
      y += p.getWeight()*p.getUser().getY();
    }
    
    return y;
  }

  /**
   * Remove a landmark from all the particles
   * @param  {String} uid Landmark uid
   * @return {void}
   */
  private void removeLandmark(uid) {

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
    for(int i = 0; i < normalizedWeights.size(); i++) {
      total += normalizedWeights.get(i);
    }
    
    List<Double> result = weights;
    for(int i = 0; i < normalizedWeights.size(); i++) {
      result.get(i) = results.get(i) / total;
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
 * @return {Array} An array with indices corresponding to the selected weights
 */
 public Set<Integer> lowVarianceSampling(nSamples, weights) {

  int M = weights.length;
  List<Double> normalizedWeights = normalizeWeights(weights);

  double rand = Math.random() * (1 / M);

  double c = normalizedWeights.get(0);
  int i = 0;

  Set<Integer> set = new HashSet();

  for (int m = 1; m <= nSamples; m++) {
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