package skewll.ch10.snoipets;

import java.util.ArrayList;

public class Gride2 {
	private int rows;
	private int columns;
	ArrayList<Location> locations;
	ArrayList<String> descriptions;

	public Gride2() {
	}

	public void add(String desc, int row, int column) {
		Location e = new Location(row, column);
		locations.add(e);
		descriptions.add(desc);

	}

	public String getDesc(int row, int column) {
		int i = 0;
		Location poot = new Location(row, column);
		for (Location obj : locations) {
			if (locations.get(i).equals(poot)) {
				return descriptions.get(i);
			} else if (i < locations.size()) {
				i++;
			} else {
				return "Error: Location not found.";
			}
		}
		return null;

	}

	public ArrayList<Location> getLocations() {
		return locations;

	}

	class Location {
		private int row;
		private int column;

		public Location(int row, int column) {
			this.row = row;
			this.column = column;
		}
	}

	public static void main(String[] args) {

	}

}
