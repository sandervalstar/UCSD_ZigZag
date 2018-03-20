class SlacConfiguration
{
 
  class ParticleConfiguration
  {
    private int N;
    private int effectiveParticleThreshold;
    private int sd;
    private int randomN;
    private int maxVariance;
    
    // =========================== particle configuration =================================//
    public ParticleConfiguration()
    {
      N = 30;
      effectiveParticleThreshold = 15;
      sd = 1;
      randomN = 0;
      maxVariance = 4;
    }
    
    public void setN(int N)
    {
      this.N = N;
    }
    
    public void setEffectiveParticleThreshold(int x)
    {
      this.effectiveParticleThreshold = x;
    }
    
    public int getN() { return this.N; }
    public int getEffectiveParticleThreshold() { return effectiveParticleThreshold; }
    public int getSd() { return this.sd; }
    public int getRandomN() { return this.randomN; }
    public int getMaxVariance() { return this.maxVariance; }
  }
  
  private ParticleConfiguration particles;
  public ParticleConfiguration getParticles() { return this.particles; }
  
  // ======================= pedometer =============================================//
  
  class PedometerConfiguration
  {
    double stepSize;   // in meters
    double sdStep;     // standard deviation per step
    double sdHeading;  // standard deviation of direction angle (theta)
    
    public PedometerConfiguration()
    { 
      stepSize  = 0.6f;
      sdStep    = 0.15f;
      sdHeading = 0.1;
    }
    
    public double getStepSize() { return this.stepSize; }
    public double getStepSD() { return this.sdStep; }
    public double getHeadingSD() { return this.sdHeading; }
    
    public void setStepSize(double stepSize) { this.stepSize = stepSize; }
    public void setStepSD(double sdStep) { this.sdStep = sdStep; }
    public void setHeadingSD(double sdHeading) { this.sdHeading = sdHeading; }
  }
  
  private PedometerConfiguration pedometer;
  public PedometerConfiguration getPedometer() { return this.pedometer; }
  
  
  // ======================== sensor ================================================//
  
  class SensorConfiguration
  {
    double kalmanFilterR;
    double kalmanFilterQ;

    int minMeasurements;
    
    public SensorConfiguration()
    {
      kalmanFilterR = 0.008f;
      kalmanFilterQ = 4f;
      
      minMeasurements = 30;
    }
    
    public void setKalmanFilterR(double R) { this.kalmanFilterR = R; }
    public void setKalmanFilterQ(double Q) { this.kalmanFilterQ = Q; }
    public void setMinMeasurements(int min) { this.minMeasurements = min; }
    
    public double getKalmanFilterR() { return this.kalmanFilterR; }
    public double getKalmanFilterQ() { return this.kalmanFilterQ; }
    public int   getMinMeasurements() { return this.minMeasurements; }
   
  }
  
  SensorConfiguration sensor;
  public SensorConfiguration getSensor() { return this.sensor; }
  
  
  // ==========================================================================//
  
  SlacConfiguration()
  {
    particles = new ParticleConfiguration();
    pedometer = new PedometerConfiguration();
    sensor    = new SensorConfiguration();
  }
  
}