package computinator;

public class Handheld extends Computer {
	//these are literally the same as tablets so yeah.
	@SuppressWarnings("unused")
	private boolean stylus, camera, screenSize, cellular;

	public Handheld(double cpu, double circuits, int ram, int memory, boolean stylus, boolean camera, boolean screenSize, boolean cellular) {
		super(cpu, circuits, ram, memory);
		this.camera = camera;
		this.cellular = cellular;
		this.screenSize = screenSize;
		this.stylus = stylus;
	}

}
