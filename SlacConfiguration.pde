class SlacConfiguration
{
 
  class ParticleConfiguration
  {
    private int N;
    private int effectiveParticleThreshold;
    
    // =========================== particle configuration =================================//
    public ParticleConfiguration()
    {
      N = 30;
      effectiveParticleThreshold = 15;
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
  }
  
  private ParticleConfiguration particles;
  public ParticleConfiguration getParticles() return { this.particles; }
  
  // ======================= pedometer =============================================//
  
  class PedometerConfiguration
  {
    float stepSize; // in meters
    
    public PedometerConfiguration() { stepSize = 0.6f; }
    
    public float getStepSize() { return this.stepSize; }
    public void setSetpSize(float stepSize) { this.setpSize = stepSize; }
  }
  
  private PedometerConfiguration pedometer;
  public PedometerConfiguration getPedometer() { return this.pedometer; }
  
  // ======================== sensor ================================================//
  
  class SensorConfiguration
  {
    float kalmanFilterR;
    float kalmanFitlerQ;
    
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