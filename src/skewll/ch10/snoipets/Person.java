package skewll.ch10.snoipets;

public class Person {
	private String name;
	private double height;

	public Person(String name, double height) {
		this.name = name;
		this.height = height;
	}

	public double getHeight() {
		return height;
	}

	public String getName() {
		return name;
	}

	public String toString() {
		return name + " " + height;
	}

}
