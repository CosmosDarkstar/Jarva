package computinator;

public class Desktop extends Computer {
	@SuppressWarnings("unused")
	private boolean cdDrive, externalMonitor, floppyDrive, soundcard;

	public Desktop(double cpu, double circuits, int ram, int memory, boolean cdDrive, boolean externalMonitor, boolean floppyDrive, boolean soundcard) {
		super(cpu, circuits, ram, memory);
		this.cdDrive = cdDrive;
		this.externalMonitor = externalMonitor;
		this.floppyDrive = floppyDrive;
		this.soundcard = soundcard;
	}

}
