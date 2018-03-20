// Vagely based on https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/models/user.js

class User
{
  PVector pos;
  
  User()
  {
    pos.x = 0;
    pos.y = 0;
  }
  
  User(float x, float y)
  {
    pos.x = x;
    pos.y = y;
  }
  
  
  /**
   * Move a user to a new position
   * @param  {float} x
   * @param  {float} y
   */
  public void move(float x, float y)
  {
    this.pos.x += x;
    this.pos.y += y;
  }
  
  PVector getPosition() { return this.pos; }
  
  User getCopy()
  {
    return new User(this.pos.x, this.pos.y);
  }
  
}