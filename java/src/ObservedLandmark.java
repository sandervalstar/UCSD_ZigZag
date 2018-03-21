class ObservedLandmark
{
  String uid;
  String name;
  boolean moved;
  double radius;
  
  public ObservedLandmark(String uid,  double radius, String name, boolean moved)
  {
    this.uid = uid;
    this.radius = radius;
    this.name = name;
    this.moved = moved;
  }
  
  public String getUid() { return uid; }
  public String getName() { return name; }
  public boolean getMoved() { return moved; }
  public double getRadius() { return radius; }

}