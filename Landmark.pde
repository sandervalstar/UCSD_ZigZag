class Landmark
{
  double x, y;
  String name;
  double[][] cov;
  
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

}