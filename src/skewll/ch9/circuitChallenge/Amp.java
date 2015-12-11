package skewll.ch9.circuitChallenge;

public class Amp {
	protected double r1;
	protected double r2;

	protected double gain;
	protected String desc;

	public double getGain(double r1, double r2) {
		return gain;
	}

	public String getDesc() {
		desc = "Amp";
		return desc;
	}

	//MAIN METHOD
	public static void main(String[] args) {

		Inverting invert = new Inverting(4.2, 6.3);
		System.out.println("Invert = " + invert.getGain(4.2, 6.3) + ", " + invert.getDesc());

		NonInverting nonInvert = new NonInverting(4.2, 6.3);
		System.out.println("Non-invert = " + nonInvert.getGain(4.2, 6.3) + ", " + nonInvert.getDesc());

		VDivider vDivide = new VDivider(4.2, 6.3);
		System.out.println("Voltage-divider = " + vDivide.getGain(4.2, 6.3) + ", " + vDivide.getDesc());

	}

}

class Inverting extends Amp {
	public Inverting(double r1Temp, double r2Temp) {
		r1 = r1Temp;
		r2 = r2Temp;
	}

	public double getGain(double r1, double r2) {
		gain = r2 / r1 * (-1);
		return gain;
	}

	public String getDesc() {
		desc = "Inverting amp";
		return desc;
	}

}

class NonInverting extends Amp {
	public NonInverting(double r1Temp, double r2Temp) {
		r1 = r1Temp;
		r2 = r2Temp;
	}

	public double getGain(double r1, double r2) {
		gain = 1 + (r2 / r1);
		return gain;
	}

	public String getDesc() {
		desc = "Non-inverting amp";
		return desc;
	}

}

class VDivider extends Amp {
	public VDivider(double r1Temp, double r2Temp) {
		r1 = r1Temp;
		r2 = r2Temp;
	}

	public double getGain(double r1, double r2) {
		gain = r2 / (r1 + r2);
		return gain;
	}

	public String getDesc() {
		desc = "Voltage-divider amp";
		return desc;
	}

}
