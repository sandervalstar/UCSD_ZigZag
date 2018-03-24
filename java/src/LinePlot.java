import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.Iterator;

/***
 * Plots a line chart
 * (TODO: cache last plot);
 */
class LinePlot
{
  color lineColor;
  float lineThickness;
  Queue<Float> numberQ;
  float lineIncrement;
  
  public LinePlot(color lineColor, float lineThickness, int elements, float chartWidth)
  {
    numberQ = new ConcurrentLinkedQueue<Float>();
    
    // initializes with zeros
    for (int i = 0; i < elements; ++i)
    {
      numberQ.add(0.0f);
    }
    
    this.lineColor = lineColor;
    this.lineThickness = lineThickness;
    
    lineIncrement = chartWidth / (elements - 1);
  }
  
  public void add(float number)
  {
    numberQ.add(number);
    numberQ.remove();
  }
  
  public void draw(float x, float y)
  {
    stroke(lineColor);
    strokeWeight(lineThickness);
    
    Iterator it = numberQ.iterator();
    
    float x1 = x;
    float lastNumber = (Float) it.next();
   
    while (it.hasNext())
    {
      float currentNumber = (Float) it.next();
      line(x1, y + lastNumber, x1 + lineIncrement, y + currentNumber);
      lastNumber = currentNumber;
      x1 += lineIncrement;
    }
  }
}