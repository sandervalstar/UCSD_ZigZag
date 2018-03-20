import java.awt.geom.Point2D;

class LocationEstimatorImpl implements LocationEstimator
{
  List<Point2D.Float> locations = new ArrayList();
  
  void addMeasurement(float rssi)
  {
    int xdir = Math.random() < 0.5 ? -1 : 1;
    int ydir = Math.random() < 0.5 ? -1 : 1;
    this.locations.add(new Point2D.Float(xdir*(float)Math.random()*rssi/5, ydir*(float)Math.random()*rssi/5));
    //this.locations.add(new Point2D.Float(0f,0f));
    //this.locations.add(new Point2D.Float(10f,10f));
    //this.locations.add(new Point2D.Float(-10f,-10f));
    //this.locations.add(new Point2D.Float(-5f,5f));
    //this.locations.add(new Point2D.Float(5f,-5f));
  }
  
  void addUserMovement(float x, float y)
  {
    for (int i = 0; i < locations.size(); i++)
    {
      //print("from x="+locations.get(i).x);
      locations.get(i).x -= x;
      //println(" to x="+locations.get(i).x);
      //print("from y="+locations.get(i).y);
      locations.get(i).y -= y;
      //println(" to y="+locations.get(i).y);
    }
  }
  
  List<Point2D.Float> getProbableLocations()
  {
    return this.locations;
  }
  
  Point2D.Float getEstimatedLocation()
  {
    if (this.locations.size() > 0)
    {
      return this.locations.get(0); 
    }
    return null;
  }
  
}