package skewll.ch10.snoipets;

import java.util.ArrayList;

public class Bag {

	public static void main(String[] args) {
		class Item {
			String name;
			double quantity;
			Item boop;

			ArrayList<Item> items;

			public Item(String name, double quantity) {
				this.name = name;
				this.quantity = quantity;
			}

			public void add(String itemName, double quantity) {
				Item no = new Item(itemName, quantity);
				items.add(no);

			}

			public void count(String itemName) {
				int i = 0;
				double counter = 0;
				for (Item obj : items) {
					if (items.get(i).equals(itemName)) {
						counter++;
					}
					i++;
				}
			}
		}
	}
}
