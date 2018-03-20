/**
    This is a 1D KalmanFilter port of https://github.com/wouterbulten/kalmanjs/ by Wouter Bulten
 */
class KalmanFilter
{
  private float R, Q, B, A, C, cov, x;
  /**
  * Create 1-dimensional kalman filter
  * @param  {Number} R Process noise
  * @param  {Number} Q Measurement noise
  * @param  {Number} A State vector
  * @param  {Number} B Control vector
  * @param  {Number} C Measurement vector
  * @return {KalmanFilter}
  */
  public KalmanFilter(float R, float Q, float A, float B, float C)
  {
    this.R = R; // noise power desirable
    this.Q = Q; // noise power estimated
    
    this.A = A;
    this.C = C;
    this.B = B;
    
    this.cov = Float.NaN;
    this.x   = Float.NaN;
  }
 
  /**
  * Filter a new value
  * @param  {Number} z Measurement
  * @param  {Number} u Control
  * @return {Number}
  */
  public float filter(float z, float u)
  {
    if (Float.isNaN(this.x))
    {
      this.x   = (1 / this.C) * z;
      this.cov = (1 / this.C) * this.Q * (1 / this.C);
    } else {
      
      // Compute prediction
      final float predX   = this.predict(u);
      final float predCov = this.uncertainty();
      
      // Kalman gain
      final float K = predCov * this.C * (1 / ((this.C *  predCov * this.C) + this.Q));
      
      // Correction
      this.x   = predX + K * (z - (this.C * predX));
      this.cov = predCov - (K * this.C * predCov);
    }
    
    return this.x;
  }
      
  /**
  * Predict next value
  * @param  {Number} [u] Control
  * @return {Number}
  */
  public float predict(float u)
  {
    return (this.A * this.x) + (this.B * u);
  }
  
  /**
  * Return uncertainty of filter
  * @return {Number}
  */
  public float uncertainty()
  {
    return ((this.A * this.cov) * this.A) + this.R;
  }
  
  /**
  * Return the last filtered measurement
  * @return {Number}
  */
  public float lastMeasurement() 
  {
    return this.x;
  }

  /**
  * Set measurement noise Q
  * @param {Number} noise
  */
  public void setMeasurementNoise(float noise)
  {
    this.Q = noise;
  }

  /**
  * Set the process noise R
  * @param {Number} noise
  */
  public void setProcessNoise(float noise)
  {
    this.R = noise;
  }
      
}