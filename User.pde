// Vagely based on https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/user.js

class User
{
  PVector pos;
  SlacConfiguration config;
  
  
  User(SlacConfiguration config)
  {
    pos.x = 0;
    pos.y = 0;
    this.config = config;
  }
  
  User(SlacConfiguration config, float x, float y)
  {
    pos.x = x;
    pos.y = y;
    this.config = config;
  }
  
  
  /**
   * Move a user to a new position
   * @param  {float} r
   * @param  {float} theta
   */
  public void move(float r, float theta)
  {
    this.pos.x += r * cos(theta);
    this.pos.y += r * sin(theta);
  }
  
  
 
  /**
   * Move a user to a new position
   * @param  {float} r
   * @param  {float} theta
   */
  public void samplePose(float r, float theta)
  {
    // todo
    
    this.pos.x += r * cos(theta);
    this.pos.y += r * sin(theta);
  }
   
  
  PVector getPosition() { return this.pos; }
  
  User getCopy()
  {
    return new User(config, this.pos.x, this.pos.y);
  }
  
}