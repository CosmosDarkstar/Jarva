package skewll.ch9;

public class Person {

	protected int birthday, birthmonth, birthyear;
	protected String name;

	public Person(String name, int birthday, int birthmonth, int birthyear) {

		this.name = name;
		this.birthday = birthday;
		this.birthmonth = birthmonth;
		this.birthyear = birthyear;
	}

	public String toString() {
		return "Name: " + name + ". Birthday: " + birthday + ", " + birthmonth + ", " + birthyear;
	}

}

class Student extends Person {
	protected String major;

	public Student(String name, int birthday, int birthmonth, int birthyear, String major) {
		super(name, birthday, birthmonth, birthyear);
		this.major = major;
	}

	public String toString() {
		return "Name: " + name + ". Birthday: " + birthday + ", " + birthmonth + ", " + birthyear + ". Major: " + major + ".";
	}

}

class Instructor extends Person {
	protected double salary;

	public Instructor(String name, int birthday, int birthmonth, int birthyear, double salary) {
		super(name, birthday, birthmonth, birthyear);
		this.salary = salary;
	}

	public String toString() {
		return "Name: " + name + ". Birthday: " + birthday + ", " + birthmonth + ", " + birthyear + ". Salary: $" + salary + ".";
	}

}