package skewll.ch10.snoipets;

public class WeebsFace {
	public static void main(String[] args) {
		class HeightMeasurer implements Measurer {
			public double measure(Object anObject) {
				Person person = (Person) anObject;
				double height = person.getHeight();
				return height;

			}
		}
		Measurer heightMeas = new HeightMeasurer();

		Person[] persons = new Person[] {
				new Person("John", 6.2),
				new Person("Grog", 4.3),
				new Person("Space Core", 1)
		};

		double avgHeight = Data.average(persons, heightMeas);
		System.out.println(avgHeight + " ft. average height.");
		double max = 0;
		int i = 0;
		for (Person obj : persons) {
			if (persons[i].getHeight() > max) {
				max = persons[i].getHeight();
				System.out.println("Tallest person: " + persons[i].toString() + " ft.");
				i++;
			}

		}

	}
}
