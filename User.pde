// Vagely based on https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/user.js

class User
{
  private double x, y, theta;
  
  SlacConfiguration config;
  
  
  User(SlacConfiguration config)
  {
    x = 0;
    y = 0;
    theta = 0;
    this.config = config;
  }
  
  User(SlacConfiguration config, double x, double y, double theta)
  {
    println("Creating user with " + x + " " + y + " " +  theta);
    this.x = x;
    this.y = y;
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
    this.x += r * Math.cos(theta);
    this.y += r * Math.sin(theta);
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
    
    this.x += sampledR * Math.cos(sampleHeading);
    this.y += sampledR * Math.sin(sampleHeading);
    
    this.theta = sampleHeading;
  }
   
  
  double getPositionX() { return this.x; }
  double getPositionY() { return this.y; }

  User getCopy()
  {
    return new User(config, this.x, this.y, this.theta);
  }
  
}