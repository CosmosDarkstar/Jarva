package skewll.ch10.snoipets;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * An action listener that prints a message.
 */
public class ClickListener implements ActionListener {
	private static int i = 0;
	private static int count = 0;

	public void actionPerformed(ActionEvent event) {
		i++;
		System.out.println("Button A was clicked " + i + " times.");

	}

}
