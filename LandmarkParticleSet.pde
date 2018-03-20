//import { randn, pdfn, variance } from '../util/math';
//import { lowVarianceSampling, numberOfEffectiveParticles, normalizeWeights } from '../util/sampling';
//import { polarToCartesian } from '../util/motion';

// Ported from https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/landmark-particle-set.js

class LandmarkParticleSet {
  
  class Pair {
    
    private double x;
    private double y;
    
    public Pair(double x, double y) {
      this.x = x;
      this.y = y;
    }
    
    public double getX() {
      return this.x;  
    }
    
    public double getY() {
      return this.y;  
    }
  }
  
  private int numParticles;
  private int stdRange;
  private int randomParticles;
  private int effectiveParticleThreshold;
  private double maxVariance;
  private int measurements;
  private List<Particle> particles;
  
  public LandmarkParticleSet(int nParticles, int stdRange, int randomParticles, 
                            int effectiveParticleThreshold, double maxVariance) {
    this.numParticles = nParticles;
    this.stdRange = stdRange;
    this.randomParticles = randomParticles;
    this.effectiveParticleThreshold = effectiveParticleThreshold;
    this.maxVariance = maxVariance;
    this.measurements = 0;
    this.particles = new ArrayList<Particle>();
  }
  
  public void addMeasurement(int x, int y, int r) {
    if (this.measurements == 0) {
      this.particles = this.randomParticles(this.numParticles, x, y, r);  
    } else {
      this.updateWeights(x, y, r);
      List<Integer> weights = this.getWeightMappings();
      
      if (this.numberOfEffectiveParticles(weights) < this.effectiveParticleThreshold) {
        List<Particle> randomSet = this.resample(this.numParticles - this.randomParticles);
        this.particles.addAll(randomSet);
      }
    }
    this.measurements++;
  }
  
   /**
   * Return the current estimate of this landmark's position
   * @return PositionEstimate
   */
  public PositionEstimate positionEstimate() {
    if (this.measurements < 10) {
      return new PositionEstimate (0, 0, 0, 1, 1);
    }
    
    final Pair pair - this.particleVariance();
    if (pair.getX() < this.maxVariance && this.getY() < this.maxVariance) {
      Pair avg = this.averagePosition();
      return new PositionEstimate(1, x, y, varX, varY);
    }
    return new PositionEstimate(0, 0, 0, 1, 1);
  }
  
   /**
   * Return the particle with the heighest weight
   * @return {Particle}
   */
  public Particle bestParticle() {
    Particle best = this.particles.get(0);
    for (Particle tuple : this.particles) {
      if (tuple.getWeight() > best.getWeight()) {
        best = tuple;
      }
    }
    return best;
  }
  
  public Pair averagePosition() {
    List<Integer> weights = normalizeWeights(this.getWeightMappings());
    
    int x;
    for (int i = 0; i < weights.size(); i++) {
      x += weights.get(i) * this.particles.get(i).getX();
    }
    int y;
    for (int i = 0; i < weights.size(); i++) {
      y += weights.get(i) * this.particles.get(i).getY();
    }
    return new Pair(x, y);
  }
  
  public Pair particleVariance() {
      return new Pair(varianceX(this.particles), varianceY(this.particles));
  }
  
  public List<Particle> resample(nSamples) {
    List<Double> weights = this.getWeightMappings();
    List<Integer> indices = lowVarianceSampling(nSamples, weights);
    List<Particle> particlesLocal = new ArrayList<Particle>();
    for (int i in indicies) {
     particlesLocal.add(new Particle(MathUtil.randn(this.particles.get(i).getX(), this.stdRange/4),
                                     MathUtil.randn(this.particles.get(i).getY(), this.stdRange/4), 1));
    }
    return particlesLocal;
  }
  
  public List<Double> getWeightMappings() {
    List<Double> weights = new ArrayList<Double>();
    for (Particle particle : this.particles) {
        weights.add(particle.getWeight());
    }
    return weights;
  }
  
  public List<Particle> randomParticles(int n, int x, int y, int r) {
    final double deltaTheta = 2 * Math.PI/n;
    final List<Particle> particles = new ArrayList<Particle>();
    for (int i = 0; i < n; i++) {
      double theta = i * deltaTheta;
      double range = r * MathUtil.randn(0, this.stdRange);
      Pair pair = this.polarToCartesian(range, theta);
      Particle particle = new Particle(x + pair.getX(), y + pair.getY(), 1);
      particles.add(particle);
    }
    return particles;
  }
  
  public void updateWeights(int x, int y, int r) {
    for (Particle p : this.particles) {
      double dist = Math.sqrt(Math.pow(p.getX() - x, 2) + Math.pow(p.getY() - y, 2));
      double weight = MathUtil.pdfn(r, dist, this.stdRange);
      p.setWeight() = p.getWeight() * weight;
    }
  }
  
   /**
   * Convert cartesian coordiantes to polar coordinates
   * @param  {float} dx  x value from 0,0
   * @param  {float} dy  y value from 0,0
   * @return {object}
   */
  public Pair cartesianToPolar(dx, dy) {
    final r = Math.sqrt((dx * dx) + (dy * dy));
    final theta = Math.atan2(dy, dx);
    return new Pair{r, theta};
  }
  
  /**
 * Samples a new set using a low variance sampler from a array of weights
 * @param {Number} nSamples Number of samples to sample
 * @param {Array} weights   Weight array
 * @return {Array} An array with indices corresponding to the selected weights
 */
  public List<Integer> lowVarianceSampling(nSamples, weights) {
  
    int M = weights.length;
    List<Double> normalizedWeights = normalizeWeights(weights);
  
    double rand = Math.random() * (1 / M);
  
    double c = normalizedWeights.get(0);
    int i = 0;
  
    List<Double> set = new ArrayList<Double>();
  
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

  public double numberOfEffectiveParticles(weights) {
    List<Double> normalisedWeights = normalizeWeights(weights);
    
    double total = 0;
    for (double i in normalisedWeights) {
      total += (i*i);
    }
    return 1 / total;
  }
  
  List<Double> normalizeWeights(List<Double> weights) {
    double totalWeight = 0;
    for (double i in weights) {
      totalWeight += i;
    }
    List<Double> weights2 = new ArrayList<Double>();
    for (double i : weights) {
      weights2.add(i / totalWeight);
    }
    return weights2;
  }
  
   /**
   * Calculate the variance of an array given a value function
   * @param  {Array} data
   * @param  {Function} valueFunc Function that maps an array element to a number
   * @return {Number}
   */
   public double varianceX(List<Particle> data) {
  
    int sum = 0;
    double sumSq = 0;
    int n = data.length;
  
    for (Particle part : data) {
      int value = part.getX();
      sum += value;
      sumSq += (value * value);
    }
  
    return (sumSq - ((sum * sum) / n)) / n;
  }
  
     /**
   * Calculate the variance of an array given a value function
   * @param  {Array} data
   * @param  {Function} valueFunc Function that maps an array element to a number
   * @return {Number}
   */
   public double varianceY(List<Particle> data) {
  
    int sum = 0;
    double sumSq = 0;
    int n = data.length;
  
    for (Particle part : data) {
      int value = part.getY();
      sum += value;
      sumSq += (value * value);
    }
  
    return (sumSq - ((sum * sum) / n)) / n;
  }
}