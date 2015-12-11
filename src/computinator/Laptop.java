package computinator;

public class Laptop extends Computer {
	@SuppressWarnings("unused")
	private boolean clamshell, usablePorts, fan, scratchPad;

	public Laptop(double cpu, double circuits, int ram, int memory, boolean clamshell, boolean usablePorts, boolean fan, boolean scratchPad) {
		super(cpu, circuits, ram, memory);
		this.clamshell = clamshell;
		this.fan = fan;
		this.scratchPad = scratchPad;
		this.usablePorts = usablePorts;
	}

}
