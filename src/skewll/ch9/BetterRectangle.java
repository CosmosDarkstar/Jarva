package skewll.ch9;

import java.awt.Dimension;
import java.awt.Point;
import java.awt.Rectangle;

public class BetterRectangle extends Rectangle {

	public BetterRectangle() {

	}

	public BetterRectangle(Rectangle arg0) {
		super(arg0);

	}

	public BetterRectangle(Point arg0) {
		super(arg0);

	}

	public BetterRectangle(Dimension arg0) {
		super(arg0);

	}

	public BetterRectangle(int arg0, int arg1) {
		super(arg0, arg1);

	}

	public BetterRectangle(Point arg0, Dimension arg1) {
		super(arg0, arg1);

	}

	public BetterRectangle(int arg0, int arg1, int arg2, int arg3) {
		super(arg0, arg1, arg2, arg3);

	}

	public double getArea() {
		double boop = (super.getWidth()) * (super.getHeight());
		return boop;

	}

	public double getPerimeter() {
		double boot = 2 * ((super.getWidth()) + (super.getHeight()));
		return boot;
	}

}
