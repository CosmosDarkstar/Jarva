package skewll.ch9;

import java.awt.Point;

public class LabeledPoint extends Point {
	protected int x;
	protected int y;
	protected String label;

	public LabeledPoint(int x, int y, String label) {
		Point point = new Point(x, y);
		this.x = x;
		this.y = y;
		this.label = label;
	}

	public String toString() {
		//return point.toSring+", label: "+label;
		return "x: " + x + ", y: " + y + ", Label: " + label;
	}

}
