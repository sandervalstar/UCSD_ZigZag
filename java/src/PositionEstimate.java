class PositionEstimate {
  public double estimate, x, y, varX, varY;
  
  public PositionEstimate(double estimate, double x, double y, double varX, double varY) {
    this.estimate = estimate;
    this.x = x;
    this.y = y;
    this.varX = varX;
    this.varY = varY;
  }
}