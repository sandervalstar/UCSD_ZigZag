// based of https://github.com/wouterbulten/slacjs/blob/e21748e5c11f1eb6357dc528bc60a4645ff09e22/src/app/util/math.js
class MathUtil
{

  /**
   * Random following normal distribution
   * @param  {double} mean mean
   * @param  {double} sd   standard deviation
   * @return {double}
   */
  public static double randn(double mean, double sd)
  {
  
    //Retrieved from jStat
    double u;
    double v;
    double x;
    double y;
    double q;
  
    do {
      u = Math.random();
      v = 1.7156 * (Math.random() - 0.5);
      x = u - 0.449871;
      y = Math.abs(v) + 0.386595;
      q = x * x + y * (0.19600 * y - 0.25472 * x);
    } while (q > 0.27597 && (q > 0.27846 || v * v > -4 * Math.log(u) * u * u));
  
    return (v / u) * sd + mean;
  }
  
  public static double limitTheta(double theta) {
  
    if (theta > Math.PI) {
      return theta - (Math.PI * 2);
    }
    else if (theta < -Math.PI) {
      return theta + (Math.PI * 2);
    }
  
    return theta;
  }
    
    
  
  /**
   * pdf for a normal distribution
   * @param  {Number} x
   * @param  {Number} mean
   * @param  {Number} sd
   * @return {Number}
   */
  public static double pdfn(double x, double mean, double sd)
  {
    return (1.0 / (sd * Math.sqrt(2.0 * Math.PI))) * Math.exp(-(Math.pow(x - mean, 2.0)) / (2.0 * sd * sd));
  }
  
  /**
   * Compute the log with a given base
   *
   * Used primarily as log10 is not implemented yet on mobile browsers
   * @param  {int}
   * @param  {int}
   * @return {double}
   */
  public static double log(int x, int base)
  {
    return Math.log(x) / Math.log(base);
  }
  
  /**
   * Calculates two eigenvalues and eigenvectors from a 2x2 covariance matrix
   * @param  {Array} cov
   * @return {object}
   */
  //public static  eigenvv(cov) {
  
  //  final double a = cov[0][0];
  //  final double b = cov[0][1];
  //  final double c = cov[1][0];
  //  final double d = cov[1][1];
  
  //  final double A = 1.0;
  //  final double B = -(a + d);
  
  //  //const C = (a * d) - (c * b);
  
  //  final double L1 = (-B + Math.sqrt((Math.pow(a - d, 2) + (4 * c * d))) / 2 * A);
  //  final double L2 = (-B - Math.sqrt((Math.pow(a - d, 2) + (4 * c * d))) / 2 * A);
  
  //  final double y1 = (L1 - a) / b;
  //  final double y2 = (L2 - a) / b;
  //  final double mag1 = Math.sqrt(1 + (y1 * y1));
  //  final double mag2 = Math.sqrt(1 + (y2 * y2));
  
  //  return {
  //    values: [L1, L2],
  //    vectors: [[1 / mag1, y1 / mag1], [1 / mag2, y2 / mag2]]
  //  };
  //}
  
  /**
   * Calculate the variance of an array given a value function
   * @param  {Array} data
   * @param  {Function} valueFunc Function that maps an array element to a number
   * @return {Number}
   */
  //export function variance(data, valueFunc) {
  
  //  let sum = 0;
  //  let sumSq = 0;
  //  const n = data.length;
  
  //  data.forEach((d) => {
  
  //    const value = valueFunc(d);
  
  //    sum += value;
  //    sumSq += (value * value);
  //  });
  
  //  return (sumSq - ((sum * sum) / n)) / n;
  //}

}