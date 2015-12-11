package skewll.ch10.snoipets;

import java.util.ArrayList;

public class Gride {
	private int rows;
	private int columns;
	ArrayList<Location> locations;
	ArrayList<String> descriptions;

	public Gride(int rows, int columns) {
		this.columns = columns;
		this.rows = rows;
	}

	public void add(String desc, int row, int column) {
		if (row <= rows && column <= columns) {
			Location e = new Location(row, column);
			locations.add(e);
			descriptions.add(desc);
		} else {
			System.err.println("Out of bounds exception");
		}
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
