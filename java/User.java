// Vagely based on https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/user.js

class User
{
  PVector pos;
  double theta;
  
  SlacConfiguration config;
  
  
  User(SlacConfiguration config)
  {
    pos.x = 0;
    pos.y = 0;
    theta = 0;
    this.config = config;
  }
  
  User(SlacConfiguration config, double x, double y, double theta)
  {
    pos.x = x;
    pos.y = y;
    this.theta = theta;
    this.config = config;
  }
  
  
  /**
   * Move a user to a new position
   * @param  {double} r
   * @param  {double} theta
   */
  public void move(double r, double theta)
  {
    this.pos.x += r * Math.cos(theta);
    this.pos.y += r * Math.sin(theta);
    this.theta  = theta;
  }
 
  /**
   * Move a user to a new position
   * @param  {double} x
   * @param  {double} y
   */
  public void samplePose(double r, double theta)
  {

    final double sampleHeading = MathUtil.limitTheta(MathUtil.randn(theta, this.config.getPedometer().getHeadingSD()));   
    final double sampledR = MathUtil.randn(r, this.config.getPedometer().getStepSD());
    
    this.pos.x += sampledR * Math.cos(sampleHeading);
    this.pos.y += sampledR * Math.sin(sampleHeading);
    
    this.theta = sampleHeading;
  }
   
  
  PVector getPosition() { return this.pos; }
  
  User getCopy()
  {
    return new User(config, this.pos.x, this.pos.y, this.theta);
  }
  
}