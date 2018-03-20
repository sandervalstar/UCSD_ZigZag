import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

//ported from https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/particle.js
class Particle {
  
  double weight;
  User user;
  Map<String, Landmark> landmarks;
  
  /**
   * Create a new particle
   * @return {Particle}
   */
  public Particle(SlacConfiguration config)
  {
    this.user = new User(config);
    this.landmarks = new HashMap<String, Landmark>();
    this.weight = 1.0;
  }
  
  /**
   * Create a new particle
   * @param {Particle} 
   * @return {Particle}
   */
  public Particle(Particle parent)
  {
      this.user = parent.user.getCopy();            // user deep copy
      this.landmarks = parent.getLandmarksCopy();   // landmarks deep copy
      this.weight = 1.0;
  }

  /**
   * Given a control, sample a new user position
   * @param  //double r
   * @param  //double tetha
   * @return {Particle}
   */
  public Particle samplePose(double r, double theta)
  {

    // Sample a pose from the 'control'
    this.user.samplePose(r, theta);
    return this;
  }

  /**
   * Reset the weight of the particle
   * @return {Particle}
   */
  public Particle resetWeight()
  {
    this.weight = 1.0;
    return this;
  }

  /**
   * Register a new landmark
   * @param {String} options.uid
   * @param {double} options.r
   * @param {String} options.name
   * @param {double} options.x   Initial x position
   * @param {double} options.y   Initial y
   */
  public void addLandmark(String uid, double r, String name,
                          double x, double y)
  {
    addLandmark(uid, r, name, x, y, 1.0, 1.0);
  }
  
  /**
   * Register a new landmark
   * @param {String} options.uid
   * @param {double} options.r
   * @param {String} options.name
   * @param {double} options.x   Initial x position
   * @param {double} options.y   Initial y
   * @param {double} options.varX Cov in X direction
   * @param {double} options.varY Cov in Y direction
   */
  public void addLandmark(String uid, double r, String name,
                          double x, double y,
                          double varX, double varY)
  {

    double[][] cov = new double[2][2];
    cov[0][0] = varX;
    cov[0][1] = 0;
    cov[1][0] = 0;
    cov[1][1] = varY;
    
    Landmark landmark = new Landmark(x, y, name, cov);
    this.landmarks.put(uid, landmark);
  }

  /**
   * Remove a landmark from this particle
   * @param  {String} uid landmark uid
   * @return {void}
   */
  public void removeLandmark(String uid)
  {
    this.landmarks.remove(uid);
  }

  /**
   * Update a landmark using the EKF update rule
   * @param  {string} options.uid landmark id
   * @param  {float} options.r    range measurement
   * @return {void}
   */
  public void processObservation(String uid, double r)
  {

    // Find the correct EKF
    final Landmark l = this.landmarks.get(uid);

    //Compute the difference between the predicted user position of this
    //particle and the predicted position of the landmark.
    final double dx = this.user.x - l.getX();
    final double dy = this.user.y - l.getY();

    //@todo find better values for default covariance
    final double errorCov = MathUtil.randn(2, 0.1);

    final double dist = Math.max(0.001, Math.sqrt((dx * dx) + (dy * dy)));

    //Compute innovation: difference between the observation and the predicted value
    final double v = r - dist;

    //Compute Jacobian
    final double[] H = new double[]{-dx / dist, -dy / dist};

    //Compute covariance of the innovation
    //covV = H * Cov_s * H^T + error
    
    double[][] lcov = l.getCov();
    final double[] HxCov = new double[] {lcov[0][0] * H[0] + lcov[0][1] * H[1],
                                         lcov[1][0] * H[0] + lcov[1][1] * H[1]};
    final double covV = (HxCov[0] * H[0]) + (HxCov[1] * H[1]) + errorCov;

    //Kalman gain
    final double[] K = new double[]{HxCov[0] * (1 / covV), HxCov[1] * (1.0 / covV)};

    //Calculate the new position of the landmark
    final double newX = l.getX() + (K[0] * v);
    final double newY = l.getY() + (K[1] * v);

    //Calculate the new covariance
    //cov_t = cov_t-1 - K * covV * K^T
    double[][] updateCov = new double[2][2];
    updateCov[0][0] = K[0] * K[0] * covV;
    updateCov[0][1] = K[0] * K[1] * covV;
    updateCov[1][0] = K[1] * K[0] * covV;
    updateCov[1][1] = K[1] * K[1] * covV;

    double[][] newCov = new double[2][2];
    newCov[0][0] = lcov[0][0] - updateCov[0][0];
    newCov[0][1] = lcov[0][1] - updateCov[0][1];
    newCov[1][0] = lcov[1][0] - updateCov[1][0];
    newCov[1][1] = lcov[1][1] - updateCov[1][1];

    //Update the weight of the particle
    //this.weight = this.weight - (v * (1.0 / covV) * v);
    this.weight = this.weight * MathUtil.pdfn(r, dist, covV);

    //Update particle
    l.setX(newX);
    l.setY(newY);
    l.setCov(newCov);
  }

  /**
   * Deep copies landmarks
   * @return {Map}
   */
  public Map<String, Landmark> getLandmarksCopy()
  {
    Map<String, Landmark> copy = new HashMap<String, Landmark>();

    // copies each landmark
    for (Map.Entry<String, Landmark> entry : landmarks.entrySet())
    {
      copy.put(entry.getKey(), entry.getValue().getCopy());
    }

    return copy;
  }


  /**
  * Returns landmarks
  * @return {Map}
  */
  public  Map<String, Landmark> getLandmarks()
  {
    return this.landmarks;
  }


}