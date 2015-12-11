package skewll.ch9;

public class Employee {
	protected String name;
	protected double salary;

	public Employee(String name, double salary) {
		this.name = name;
		this.salary = salary;
	}

	public String toString() {
		return "Name: " + name + ", Salary: " + salary;
	}

}

class Manager extends Employee {
	protected String department;

	public Manager(String name, double salary, String department) {
		super(name, salary);
		this.department = department;
	}

	public String toString() {
		return "Name: " + name + ", Salary: " + salary + ", Department: " + department;
	}

}

class Executive extends Manager {

	public Executive(String name, double salary, String department) {
		super(name, salary, department);
	}

	public String toString() {
		return "Name: " + name + ", Salary: " + salary + ", Department: " + department;
	}

}