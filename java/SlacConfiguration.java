class SlacConfiguration
{
 
  class ParticleConfiguration
  {
    private int N;
    private int effectiveParticleThreshold;
    private int sd;
    private int randomN;
    private int maxVariance: 4;
    
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
    public int getSd() { return this.N; }
    public int getRandomN() { return this.N; }
    public int getMaxVariance() { return this.N; }
  }
  
  private ParticleConfiguration particles;
  public ParticleConfiguration getParticles() { return this.particles; }
  
  // ======================= pedometer =============================================//
  
  class PedometerConfiguration
  {
    float stepSize;   // in meters
    float sdStep;     // standard deviation per step
    float sdHeading;  // standard deviation of direction angle (theta)
    
    public PedometerConfiguration()
    { 
      stepSize  = 0.6f;
      sdStep    = 0.15f;
      sdHeading = 0.1;
    }
    
    public float getStepSize() { return this.stepSize; }
    public float getStepSD() { return this.sdStep; }
    public float getHeadingSD() { return this.sdHeading; }
    
    public void setStepSize(float stepSize) { this.stepSize = stepSize; }
    public void setStepSD(float sdStep) { this.sdStep = sdStep; }
    public void setHeadingSD(float sdHeading) { this.sdHeading = sdHeading; }
  }
  
  private PedometerConfiguration pedometer;
  public PedometerConfiguration getPedometer() { return this.pedometer; }
  
  
  // ======================== sensor ================================================//
  
  class SensorConfiguration
  {
    float kalmanFilterR;
    float kalmanFilterQ;

    int minMeasurements;
    
    public SensorConfiguration()
    {
      kalmanFilterR = 0.008f;
      kalmanFilterQ = 4f;
      
      minMeasurements = 30;
    }
    
    public void setKalmanFilterR(float R) { this.kalmanFilterR = R; }
    public void setKalmanFilterQ(float Q) { this.kalmanFilterQ = Q; }
    public void setMinMeasurements(float min) { this.minMeasurements = min; }
    
    public float getKalmanFilterR() { return this.kalmanFilterR; }
    public float getKalmanFilterQ() { return this.kalmanFilterQ; }
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