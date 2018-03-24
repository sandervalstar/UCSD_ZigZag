class SlacConfiguration
{
 
  class ParticleConfiguration
  {
    private int N, initN;
    private double effectiveParticleThreshold, initEffectiveParticleThreshold;
    private double sd;
    private double randomN;
    private double maxVariance;
    
    // =========================== particle configuration =================================//
    public ParticleConfiguration()
    {
      N = 30;
      effectiveParticleThreshold = 15;
      
      initN = 200;
      initEffectiveParticleThreshold = 75;
      
      sd = 1;
      randomN = 0;
      maxVariance = 2;
    }
       
    public int getN() { return this.N; }
    public double getEffectiveParticleThreshold() { return effectiveParticleThreshold; }

    public int getInitN() { return this.initN; }
    public double getInitEffectiveParticleThreshold() { return initEffectiveParticleThreshold; }
    
    public double getSd() { return this.sd; }
    public double getRandomN() { return this.randomN; }
    public double getMaxVariance() { return this.maxVariance; }
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
      sdHeading = 0.1f;
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
  
  
  // ============================== RSSI to Distance ====================================== //
  
  class RSSI2DistanceConfiguration
  {
    double d0, txPower, n;
    
    RSSI2DistanceConfiguration()
    {
      d0 = 0.5;
      txPower = -35.75;
      n = 2;
    }
    
    public void setD0(double D0) { this.d0 = D0; }
    public void setTxPower(double TxPower) { this.txPower = TxPower; }
    public void setN(double N) { this.n = N; }
    
    public double getD0() { return this.d0; }
    public double getTxPower() { return this.txPower; }
    public double getN() { return this.n; }
 
  }
    
  RSSI2DistanceConfiguration rssi;
  public RSSI2DistanceConfiguration getRSSI() { return this.rssi; }
  
  
  // ==========================================================================//
  
  SlacConfiguration()
  {
    particles = new ParticleConfiguration();
    pedometer = new PedometerConfiguration();
    sensor    = new SensorConfiguration();
    rssi      = new RSSI2DistanceConfiguration();
  }
  
}