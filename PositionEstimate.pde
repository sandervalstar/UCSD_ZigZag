class PositionEstimate {
  public int estimate, x, y, varX, varY;
  
  public PositionEstimate(int estimate, int x, int y, int varX, int varY) {
    this.estimate = estimate;
    this.x = x;
    this.y = y;
    this.varX = varX;
    this.varY = varY;
  }
}