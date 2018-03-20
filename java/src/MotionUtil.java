import java.awt.geom.Point2D;

public class MotionUtil {
    /**
     * Convert polar coordinates to cartesian coordinates
     *
     * @param {float} r
     * @param {float} theta
     * @return {object}
     */
    public static Point2D.Double polarToCartesian(double r, double theta) {
        return new Point2D.Double(r * Math.cos(theta), r * Math.sin(theta));
    }
}
