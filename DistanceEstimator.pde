class DistanceEstimator {
  double x, y;  
  double distance = 0;
  
  private KalmanFilter kalmanFilter = new KalmanFilter(0.008, 1, 1, 0, 1);
 
  public DistanceEstimator(double x, double y){
    this.x = x;
    this.y = y;
  }
  
  public void addMeasurement(double rssi) {
    if(rssi > 0) {
      println("Ignored RSSI > 0");
      return;
    }
    
    double d0 = 0.5;
    double A0 = -35.75;
    int n = 2;
    double d = d0*Math.pow(10, (A0-rssi)/(10*n));
    
    this.distance = kalmanFilter.filter((float)d, 0);
  }
}