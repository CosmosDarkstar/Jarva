package computinator;

public class Mainframe extends Computer {
	@SuppressWarnings("unused")
	private boolean rackmount, supercomputer, multiOS;
	@SuppressWarnings("unused")
	private double powerfullness;

	public Mainframe(double cpu, double circuits, int ram, int memory, double powerfullness, boolean rackmount, boolean supercomputer, boolean multiOS) {
		super(cpu, circuits, ram, memory);
		this.multiOS = multiOS;
		this.powerfullness = powerfullness;
		this.rackmount = rackmount;
		this.supercomputer = supercomputer;
	}

}
