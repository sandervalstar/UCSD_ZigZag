class Landmark
{
  private double x, y;
  private String name;
  private double[][] cov;
  
  public Landmark(double x, double y, String name, double[][] cov)
  {
    this.x = x;
    this.y = y;
    this.name = name;
    this.cov = cov;
  }
  
  public Landmark getCopy()
  {
     double[][] newCov = new double[2][2];
     
     newCov[0][0] = cov[0][0];
     newCov[0][1] = cov[0][1];
     newCov[1][0] = cov[1][0];
     newCov[1][1] = cov[1][1];
     
     return new Landmark(x, y, name, newCov);
  }
  
  
  public String getName() { return this.name; }
  
  public double getX() { return this.x; }
  public double getY() { return this.y; }
  public double[][] getCov() { return this.cov; }
  
  public void setX(double x) { this.x = x; }
  public void setY(double y) { this.y = y; }
  public void setCov(double[][] cov) { this.cov = cov; }

}